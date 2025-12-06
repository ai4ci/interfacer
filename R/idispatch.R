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
#' # this input matches `i1` and the `extract_mean` call is dispatched
#' # via `extract_mean.i1`
#' test = tibble::tibble( col2 = 1:10 )
#' tmp = extract_mean(test, uplift = 50)
#' testthat::expect_equal(tmp, 55.5)
#'
#' # this input matches `i2` and the `extract_mean` call is dispatched
#' # via `extract_mean.i2`
#' test2 = tibble::tibble( col1 = 1:10 )
#' extract_mean(test2, uplift = 50)
#'
#' # This input does not match any of the allowable input specifications and
#' # generates an error.
#' test3 = tibble::tibble( wrong_col = 1:10 )
#' try(extract_mean(test3, uplift = 50))
idispatch = function(x, ..., .default = NULL) {
  # have to dispatch using declared params from caller environment
  env = rlang::caller_env()
  call = rlang::caller_call()
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
    if (!exists(fn_name, mode = "function", envir = env)) {
      stop("Cannot find dispatch function: ", fn_name, call. = FALSE)
    }

    x2 = try(iconvert(x, ifc, .dname = "nested"), silent = TRUE)

    if (!inherits(x2, "try-error")) {
      fn = tryCatch(
        get(fn_name, mode = "function", envir = env),
        error = function(e) {
          stop("could not find function: ", fn_name, call. = FALSE)
        }
      )

      # This has converted the input x into the correct format x2
      # This is then inserted back into the caller environment under a new name
      # the original (undispatched) call is modified to the matching function
      # name and the new variable name.

      conv_name = sprintf(".%s.%s", format(call[[2]]), fn_name)
      assign(conv_name, x2, envir = env)
      call[[1]] = as.symbol(fn_name)
      call[[2]] = as.symbol(conv_name)
      tmp = eval(call, envir = env)
      assign(conv_name, NULL, envir = env)
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
