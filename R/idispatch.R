#' Dispatch to a named function based on the characteristics of a dataframe
#'
#' This provides a dataframe analogy to S3 dispatch. If multiple possible
#' dataframe formats are possible for a function, each with different processing
#' requirements, then the choice of function can be made based on matching the
#' input dataframe to a set of `iface` specifications. The first matching
#' `iface` specification determines which function is used for dispatch.
#'
#' @param x a dataframe
#' @param ... a set of `function name`=`interfacer::iface` pairs
#' @param .default a function to apply in the situation where none of the rules
#'   can be matched. The default results in an error being thrown.
#' @param .prune get rid of excess columns that are not in the spec.
#'
#' @return the result of dispatching the dataframe to the first function that
#'   matches the rules in `...`. Matching is permissive in that the test is
#'   passed if a dataframe can be coerced to the `iface` specified format.
#' @export
#'
#' @concept interface
#'
#' @examples
#' i1 = iface( col1 = integer ~ "An integer column" )
#' i2 = iface( col2 = integer ~ "A different integer column" )
#'
#' # this is an example function that would typically be inside a package, and
#' # is exported from the package.
#' extract_mean = function(df, ...) {
#'   idispatch(df,
#'     extract_mean.i1 = i1,
#'     extract_mean.i2 = i2
#'   )
#' }
#'
#' # this is expected to be an internal package function
#' # the naming convention here is based on S3 but it is not required
#' extract_mean.i1 = function(df = i1, ...) {
#'   message("using i1")
#'   # input validation is not required in functions that are being called using
#'   # `idispatch` as the validation occurs during dispatch.
#'   mean(df$col1)
#' }
#'
#' extract_mean.i2 = function(df = i2, uplift = 1, ...) {
#'   message("using i2")
#'   mean(df$col2)+uplift
#' }
#'
#' # this input matches `i2` and the `extract_mean` call is dispatched
#' # via `extract_mean.i2`
#' test = tibble::tibble( col2 = 1:10 )
#' tmp = extract_mean(test, uplift = 50, this_env = TRUE)
#' testthat::expect_equal(tmp, 55.5)
#'
#' # this input matches `i1` and the `extract_mean` call is dispatched
#' # via `extract_mean.i1` and the uplift is not applied
#' test2 = tibble::tibble( col1 = 1:10 )
#' tmp2 = extract_mean(test2, uplift = 50)
#' testthat::expect_equal(tmp2, 5.5)
#'
#' # In the event that a parameter refers to itself we need to do somthing special
#' tmp3 = extract_mean(test, uplift = mean(test$col2))
#' testthat::expect_equal(tmp3, 11)
#'
#' # This input does not match any of the allowable input specifications and
#' # generates an error.
#' test3 = tibble::tibble( wrong_col = 1:10 )
#' try(extract_mean(test3, uplift = 50))
idispatch = function(x, ..., .default = NULL, .prune = FALSE) {
  # This function redirects program flow based on the format of `x` by calling
  # one of a set of different functions with similar parameters. We however are
  # also validating `x` and may make some type changes before dispatching.

  # Firstly we need to find the environment that we are trying to dispatch from
  # This is the caller environment in which
  # the function that called the idispatch was called (hence two levels up).
  # this could be the global environment but may not be.
  env = rlang::caller_env(2)
  # We are potentially going to modify it so we copy it first.
  env = rlang::env_clone(env)
  # The environment (or namespace) in which the function that called idispatch
  # is defined in: we assume the dispatch targets are also defined in this
  # enviroment / namespace
  # It seems functions do not need to be visible in for this code to work
  # and its hard to test, but running the examples in `demo_ivalidate()` works
  # from a fresh session.
  fn_env = rlang::fn_env(rlang::caller_fn())
  # This is how the call was that triggered the function that triggered this
  # idispatch call. This is the call we are going to modify:
  call = rlang::caller_call()
  # This is the dots of the idispatch call. This is a named list of format
  # specifications where the name defines a function to dispatch to.
  dots = rlang::list2(...)
  if (any(names(dots) == "")) {
    stop("all parameters must be named", call. = FALSE)
  }
  if (!all(sapply(dots, is.iface))) {
    stop("all `...` parameters must be `iface` specifications", call. = FALSE)
  }
  errors = character()
  for (i in seq_along(dots)) {
    fn_name = names(dots)[[i]]
    ifc = dots[[i]]
    if (!exists(fn_name, mode = "function", envir = fn_env)) {
      stop(
        "Cannot find dispatch function: ",
        fn_name,
        "\n (Maybe it needs to be exported?)",
        call. = FALSE
      )
    }

    dname = deparse(substitute(x))
    x2 = try(
      iconvert(x, ifc, .dname = dname, .fname = fn_name, .prune = .prune),
      silent = TRUE
    )

    if (!inherits(x2, "try-error")) {
      fn_quo = rlang::new_quosure(as.symbol(fn_name), fn_env)

      # This has converted the input x into the correct format x2
      # This is then inserted back into the caller environment
      # the original (undispatched) call is modified to use the quosure
      # using the matching function name.

      orig_name = format(call[[2]])
      assign(orig_name, x2, envir = env)

      # Alternatively it couldbe inserted under a new namw and the call
      # modified to use the new variable name but this turns out to be not
      # needed:
      # conv_name = sprintf(".%s.%s", orig_name, fn_name)
      # assign(conv_name, x2, envir = env)
      # call[[2]] = as.symbol(conv_name)

      # The following can maybe fail if the namespaces of the call are different and
      # this is hard to test for as it needs to be run in a different package.
      # call[[1]] = as.symbol(fn_name)
      # tmp = eval(call, envir = env)

      call[[1]] = fn_quo
      tmp = rlang::eval_tidy(call, env = env)

      # Do we need to tidy up. I think not as this is a disposable environment
      # assign(conv_name, NULL, envir = env)
      # assign(orig_name, old, envir = env)
      return(tmp)
    } else {
      errors = c(errors, fn_name, " - ", as.character(x2))
    }
  }

  if (is.null(.default)) {
    stop(
      sprintf(
        "the parameter in %s(...) does not match any of the expected formats.\n",
        format(call[[1]])
      ),
      errors,
      call. = FALSE
    )
  } else {
    .default = rlang::as_function(.default)
    call[[1]] = .default
    return(eval(call, envir = env))
  }
}

#
# # this input matches `i2` and the `extract_mean` call is dispatched
# # via `extract_mean.i2`
# test = tibble::tibble( col2 = 1:10 )
# tmp = extract_mean(test, uplift = 50, this_env = TRUE)
# quos = eval(expression(rlang::enquos(...)),envir = env)
# quos
# quos = eval(expression(rlang::enquos(...)),envir = env)
# ls(env)
# ifc
# fn
# quos
# formals(fn)
# names(formals(fn))[[1]]
# p1nm = names(formals(fn))[[1]]
# quos[[p1nm]] = rlang::quo(x2)
# quos
# do.call(fn, quos)
# fn(!!!quos)
# fn(!!quos)
# fn(rlang::inject(quos))
# quos
# fn
# x2
# do.call(fn, rlang::inject(quos)))
# do.call(fn, rlang::inject(quos))
# quos
# ls(env)
# env$df
# rlang::fn_env(rlang::caller_fn())
# ls(rlang::fn_env(rlang::caller_fn()))
# rlang::caller_fn()
# rlang::caller_fn(2)
# rlang::caller_fn()
# rlang::fn_env(rlang::caller_fn())
# fnenv = rlang::fn_env(rlang::caller_fn())
# fn = get(fn_name, mode = "function", envir = fnenv)
