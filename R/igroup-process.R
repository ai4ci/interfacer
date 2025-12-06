#' Handle unexpected additional grouping structure
#'
#' This function is designed to be used by a package author within an enclosing
#' function. The enclosing function is assumed to take as input a dataframe and
#' have an `iface` specified for that dataframe.
#'
#' This function detects when the grouping of the input has additional groups
#' over and above those in the specification and intercepts them, regrouping the
#' dataframe and applying `fn` group-wise using an equivalent of a
#' `dplyr::group_modify`. The parameters provided to the enclosing function will
#' be passed to `fn` and they should have compatible method signatures.
#'
#' @param df a dataframe from an enclosing function in which the grouping may or
#'   may not have been correctly supplied.
#' @param fn a function to call with the correctly grouped dataframe as
#'   specified by the `iface` in the enclosing function. This must be a function
#'   (not a `purrr` style lambda) and share parameter naming with the enclosing
#'   function. The first parameter of this dispatch function must be the
#'   dataframe (correctly grouped), and other named parameters here are looked
#'   for in the enclosing function call. The function *must* return a dataframe.
#' @param ... passed onto `iconvert` this could be used to supply
#'   `.prune` parameters. triple dot parameters in the enclosing function will
#'   be separately handled and automatically passed to `fn` so in general should
#'   not be passed to `igroup_process` as an intermediary although it probably
#'   won't hurt. This behaviour is similar to `NextMethod` in S3 method
#'   dispatch.
#' @param .iface experimental feature to override the detection of the data from
#'   the enclosing function and use a directly supplied one. This can be useful
#'   if you want to process a dataframe by grouping defined by some criteria
#'   supplied at runtime.
#'
#' @concept interface
#'
#' @return the result of calling `fn(df, ...)` on each unexpected group
#' @export
#'
#' @examples
#'
#' # This specification requires that the dataframe is grouped only by the color
#' # column
#' i_diamond_price = interfacer::iface(
#'   color = enum(`D`,`E`,`F`,`G`,`H`,`I`,`J`, .ordered=TRUE) ~ "the color column",
#'   price = integer ~ "the price column",
#'   .groups = ~ color
#' )
#'
#' # An example function which would be exported in a package
#' # This function expects a dataframe with a colour and price column, grouped
#' # by price.
#' mean_price_by_colour = function(df = i_diamond_price, extra_param = ".") {
#'
#'   # When called with a dataframe with extra groups `igroup_process` will
#'   # regroup the dataframe according to the structure
#'   # defined for `i_diamond_price` and apply the inner function to each group
#'   # after first calling `ivalidate` on each group.
#'
#'   igroup_process(df,
#'
#'     # the real work of this function is provided as an anonymous inner
#'     # function (but can be any other function e.g. package private function
#'     # but not a purrr style lambda). Ideally this function parameters are named the
#'     # same as the enclosing function (here `ex_mean(df,extra_param)`), however
#'     # there is some flexibility here. The special `.groupdata` parameter will
#'     # be populated with the values of the unexpected grouping.
#'
#'     function(df, extra_param, .groupdata) {
#'       message(extra_param, appendLF = FALSE)
#'       if (nrow(.groupdata) == 0) message("zero length group data")
#'       return(df %>% dplyr::summarise(mean_price = mean(price)))
#'     }
#'
#'   )
#' }
#'
#' # The correctly grouped dataframe. The `ex_mean` function calculates the mean
#' # price for each `color` group.
#' ggplot2::diamonds %>%
#'   dplyr::group_by(color) %>%
#'   mean_price_by_colour(extra_param = "without additional groups...") %>%
#'   dplyr::glimpse()
#'
#' # If an additionally grouped dataframe is provided by the user. The `ex_mean`
#' # function calculates the mean price for each `cut`,`clarity`, and `color`
#' # combination.
#'
#' ggplot2::diamonds %>%
#'   dplyr::group_by(cut, color, clarity) %>%
#'   mean_price_by_colour() %>%
#'   dplyr::glimpse()
#'
#' # The output of this is actually grouped by cut then clarity as
#' # color is consumed by the `igroup_dispatch`.
#'
#' # This example is somewhat contorted. The real power of `igroup_process` is
#' # if it is used recursively:
#'
#' recursive_example = function(df = i_diamond_price) {
#'
#'   # call main function recursively if additional groups detected
#'   igroup_process(df, recursive_example)
#'   # N.B. this also works if the second argument is omitted e.g.:
#'   # igroup_process(df)
#'
#'   # otherwise proceed with function as normal
#'   return(tibble::tibble("rows detected:"=nrow(df)))
#' }
#'
#' ggplot2::diamonds %>% dplyr::group_by(color) %>%
#'    recursive_example() %>%
#'    dplyr::glimpse()
#' ggplot2::diamonds %>% dplyr::group_by(cut,clarity,color) %>%
#'    recursive_example() %>%
#'    dplyr::glimpse()
igroup_process = function(df = NULL, fn, ..., .iface = NULL) {
  if (rlang::is_missing(fn)) {
    fn = rlang::caller_fn()
  }
  dispatch_fn = rlang::as_function(fn)

  dname = tryCatch(rlang::as_label(rlang::ensym(df)), error = function(e) {
    return(NA)
  })
  caller_fn = rlang::caller_fn()
  if (is.null(caller_fn)) {
    stop(
      "`igroup_dispatch(...)` must be called from within an enclosing function.",
      call. = FALSE
    )
  }
  if (is.na(dname)) {
    df = .get_first_param_value()
    dname = .get_first_param_name()
  }
  fname = .get_fn_name(caller_fn)
  if (is.null(.iface)) {
    # Get the spec from the enclosing/caller function
    spec = .get_spec(caller_fn, dname)
  } else {
    spec = .iface
  }

  exp_grps = .spec_grps(spec)
  obs_grps = dplyr::group_vars(df)

  # Dispatch environment:
  # have to dispatch using declared params from caller environment
  env = rlang::caller_env()
  # get any dots
  if ("..." %in% names(formals(caller_fn))) {
    # evaluate `...` in the caller function environment.
    # TODO: this forces evaluation of the `...` parameters.
    # This maybe makes sense given the nature but in idispatch we have moved
    # to an alternative with rewrites data back to env rewrites the function
    # call and evals it in env.
    # TBH This is a different use case I think.
    tmp = do.call(rlang::list2, list(as.symbol("...")), envir = env)
    params = c(as.list(env), tmp)
  } else {
    params = as.list(env)
  }

  additional_grps = setdiff(obs_grps, exp_grps)
  missing_grps = setdiff(exp_grps, obs_grps)

  if (length(missing_grps) > 0) {
    fmt_exp_grp = .none(
      exp_grps,
      collapse = ",",
      none = "%>% ungroup()",
      fmt = "%%>%% group_by(%s)"
    )
    stop(
      sprintf(
        "missing grouping in `%s` parameter of %s(...):\nmissing: %s\n",
        dname,
        fname,
        .none(missing_grps, "+")
      ),
      sprintf(
        "consider regrouping your data before calling function `%s`, e.g.:\n",
        fname
      ),
      sprintf("`df %s %%>%% %s(...)`\n", fmt_exp_grp, fname),
      call. = FALSE
    )
  }

  # the parameter name can be incorrect if the inner function is defined
  # using a different naming convention or more importantly if the variable is
  # renamed:
  # function(x = iface(...)) {
  #   x2 = x
  #   igroup_process(x2, function(y) {...})
  # }
  # the dispatch function must take a dataframe as the first parameter
  dispatch_dname = names(formals(dispatch_fn))[[1]]
  # if (dispatch_dname != dname) ... could log this if core R had a debug logger ...
  dispatch_has_dots = "..." %in% names(formals(dispatch_fn))
  if (!dispatch_has_dots) {
    # subset to expected dispatch function parameters.
    params = params[names(params) %in% names(formals(dispatch_fn))]
  }

  dispatch_expects_groups = ".groupdata" %in%
    names(formals(dispatch_fn)) &
    !".groupdata" %in% names(params)

  missing_dispatch_params = setdiff(
    names(formals(dispatch_fn)),
    c("...", names(params), dispatch_dname, ".groupdata")
  )

  if (length(missing_dispatch_params) > 0) {
    stop(
      sprintf(
        "`igroup_process(...)` call in function `%s(...)` failed because the dispatch ",
        fname
      ),
      sprintf(
        "function could not resolve parameters: %s",
        paste0(missing_dispatch_params, collapse = ",")
      ),
      call. = FALSE
    )
  }

  if (length(additional_grps) == 0) {
    if (identical(caller_fn, dispatch_fn)) {
      ## This call to igroup_process happening within another top level call
      ## TODO: update progress maybe?
      ## we need to exist the igroup_process and
      ## return to the calling function to complete it
      return(NULL)
    } else {
      # The default case is that the input is the correct grouping
      # We can check it conforms to the spec:
      df = iconvert(df, spec, ...)
      if (is.null(df)) {
        stop("Could not validate dataframe input.", call. = FALSE)
      }
      params[[dispatch_dname]] = df
      # no additional groups here so grouping is an empty tibble
      if (dispatch_expects_groups) {
        params[[".groupdata"]] = tibble::tibble()
      }
      out = do.call(dispatch_fn, params, envir = env)
    }
  } else {
    ## TODO: setup progress monitor?
    # wrap the call to fn in a group_modify grouped with the unexpected groupings
    df = df %>% dplyr::group_by(dplyr::across(dplyr::all_of(additional_grps)))
    out = df %>%
      dplyr::group_modify(function(d, g, ...) {
        # Fix any residual grouping issues, making sure that the grouping in the
        # dispatch function :
        d = d %>% dplyr::group_by(dplyr::across(dplyr::all_of(exp_grps)))
        d = tryCatch(
          iconvert(d, spec, ...), # validate the dataframe in the expected grouping
          error = function(e) {
            stop(
              "Could not validate dataframe input in group:\n",
              g %>%
                purrr::imap_chr(~ sprintf("%s=%s", .y, as.character(.x))) %>%
                paste0(collapse = "; "),
              "\n",
              e$message
            )
          }
        )
        if (!is.null(d)) {
          params[[dispatch_dname]] = d
          # we are in a group_modify here and g is the single line tibble of the grouping values:
          if (dispatch_expects_groups) {
            params[[".groupdata"]] = g
          }
          return(do.call(dispatch_fn, params, envir = env))
        }
        stop("Could not validate dataframe input", call. = FALSE)
      })
  }
  # insert the output dataframe into the environment that called igroup_process
  env[[".iface_output"]] = out %>% .recover_attributes(df)
  # trigger a return(.output) from that environment.
  rlang::eval_bare(quote(return(.iface_output)), env)
}
