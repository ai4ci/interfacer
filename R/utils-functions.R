

.get_fn_name = function(fn) {
  if (is.null(fn)) return("<unknown>")
  fnenv = as.list(rlang::fn_env(fn))
  fnenv = fnenv[sapply(fnenv,is.function)]
  # fnenv = lapply(fnenv, digest::digest)
  # matches = sapply(fnenv, function(x) isTRUE(all.equal(x,digest::digest(fn))))
  matches = sapply(fnenv, identical, fn)
  if (any(matches)) return(paste0(names(fnenv)[matches],collapse = "/"))
  return("<unknown>")
}


# only works for itest and ivalidate, anything else will be wrong depth
.get_first_param_name = function() {
  names(formals(sys.function(-2)))[[1]]
}

# only works for itest and ivalidate, anything else will be wrong depth
.get_first_param_value = function() {
  first_name = names(formals(sys.function(-2)))[[1]]
  value = sys.frame(-2)[[first_name]]
  return(value)
}


# look for a block as the first argument of a function in the call stack
.search_call_stack = function(nframe = sys.nframe()-1, .class="roxy_block") {
  frame = sys.frame(nframe)
  first_arg_name = names(formals(sys.function(nframe)))[[1]]
  try({
    data = suppressWarnings(get(first_arg_name, envir=frame))
    if(inherits(data, .class)) return(data)
  },silent = TRUE)
  nframe = nframe-1
  if (nframe < 1) stop("no block found")
  .search_call_stack(nframe)
}

#' Determine whether context is in-development or deployed.
#' 
#' This function is used internally to decide whether to run `ireturn()` checks
#' 
#' `interfacer::ireturn` checks run if:
#' * the option is set: `options(interfacer.always_check=TRUE)`.
#' * we are locally developing a package and running functions in smoke testing.
#' * we are running a package function in `testthat`.
#' * we are developing functions in the global environment.
#' * we are running functions in a `testthat` or R CMD check.
#' * we are running functions in a vignette in a R CMD check.
#' * we are running functions in a vignette interactively.
#' 
#' checks are not run if:
#' * package referencing `interfacer::ireturn` is installed from CRAN or r-universe
#' * package referencing `interfacer::ireturn` is installed locally using 
#'   `devtools::install`
#' * vignette building directly using `knitr` (unless option is set in vignette).
#' * vignette building using `pkgdown::build_site()`.
#'
#' @return TRUE if we're not in an installed package, FALSE otherwise
#' @keywords internal
.should_run_checks = function() {
  
  # User has set option to check
  if (getOption("interfacer.always_check_outputs",FALSE)) {
    rlang::inform(
      "interfacer: development mode active (options(interfacer.always_check=TRUE)).",
      .frequency = "regularly",
      .frequency_id = "interfacer.option_override"
    )
    return(TRUE)
  }
  
  # Get the immediate calling environment
  caller_env = parent.frame(n = 1L)
  # Find the namespace environment of the caller
  pkg_env = .find_namespace(caller_env)
  
  # If no package env found → not in a package → run checks
  if (is.null(pkg_env)) {
    rlang::inform(
      "interfacer: development mode active (local function).",
      .frequency = "regularly",
      .frequency_id = "interfacer.local_dev_mode"
    )
    return(TRUE)
  }
  
  # Check if package env has 'path' attribute which is set by devtools
  if (!is.null(attr(pkg_env, "path"))) {
    rlang::inform(
      "interfacer: development mode active (package functions).",
      .frequency = "regularly",
      .frequency_id = "interfacer.package_dev_mode"
    )
    return(TRUE)
    
  }
  
  # Case 3: Are we in a test environment?
  if (identical(Sys.getenv("TESTTHAT"), "true") ||
      identical(Sys.getenv("NOT_CRAN"), "true") ||
      identical(Sys.getenv("IN_EXT_TEST"), "true")) {
    rlang::inform(
      "interfacer: development mode active (test environment).",
      .frequency = "regularly",
      .frequency_id = "interfacer.package_test_mode"
    )
    return(TRUE)
  }
  
  return(FALSE)
}

.find_namespace = function(env) {
  while (!identical(env, emptyenv())) {
    if ("package" %in% names(attributes(env))) {
      return(env)
    }
    env <- parent.env(env)
  }
  NULL
}

