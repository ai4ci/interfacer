## internal test interfaces ---

i_test = iface(
  id = integer ~ "an integer ID",
  test = logical ~ "the test result"
)

i_test_extn = iface(
  i_test,
  extra = character ~ "a new value",
  .groups = FALSE
)

# Roxygen tag testing ----

#' An example function
#'
#' @iparam mydata description of a dataframe - format automatically documented
#' @param another an example
#' @param ... not used
#' @return the conformant dataframe
#' @keywords internal
demo_iparam_tag = function(
  mydata = i_test,
  another = "value",
  ...
) {
  mydata = ivalidate(mydata)
  return(mydata)
}


#' Another example function
#'
#' @iparam mydata a more constrained input
#' @param ... not used
#'
#' @ireturn a test output, format will be automatically documented
#' @keywords internal
demo_ireturn_tag = function(
  mydata = i_test_extn,
  ...
) {
  mydata = ivalidate(mydata, ..., .prune = TRUE)
  mydata = mydata %>% dplyr::select(-extra)
  # check the return value conforms to a new specification
  ireturn(mydata, i_test)
}

# idispatch testing ----

#' Test the interfacer `idispatch` functions
#'
#' Allows testing from the context of an installed package
#' this is here for testing purposes only. The majority of functions are
#' tested in `testthat` but one or two need package infrastructure to test
#' things like the documentation
#'
#' @iparam x one of 2 possibilities
#' @param ... passed on to methods
#'
#' @return a list of the parameters passed to one of two functions.
#' @keywords internal
#' @export
#' @examples
#'
#' # When we run examples this should run in an isolated session so
#' # we might be able to see visibility failures:
#'
#' # Should dispatch to demo_idispatch.test
#' test_data = tibble::tibble(
#'   id = c(1, 2, 3), # this is a numeric vector
#'   test = c(TRUE, FALSE, TRUE)
#' )
#'
#' # Should dispatch to demo_idispatch.test_extn
#' test_extn_data = tibble::tibble(
#'   id = c(1, 2, 3),
#'   test = c(TRUE, FALSE, TRUE),
#'   extra = c("a", "b", "c"),
#'   unneeded = c("x", "y", "z")
#' )
#'
#' new_a = c(2, 3)
#' dots_test_value = "true"
#' tmp = demo_idispatch(test_extn_data, a = new_a, dots_test = dots_test_value)
#' print(tmp)
#'
#' # The value was dispatched to the correct function
#' testthat::expect_equal(tmp$fn, "test_extn")
#' # The inline value for b was evaluated correctly as `new_a^2`
#' testthat::expect_equal(tmp$b_value, new_a^2)
#' # the type was in fact converted during dispatch:
#' testthat::expect_equal(tmp$types[["id"]], "integer")
#' testthat::expect_equal(tmp$validates, TRUE)
#' # dynamic dots were evaluated correctly from this environment
#' testthat::expect_equal(tmp$dots, list(dots_test = "true"))
#'
#' tmp2 = demo_idispatch(test_data)
#' print(tmp2)
#' testthat::expect_equal(tmp2$a, NULL)
#' testthat::expect_equal(tmp2$types[["id"]], "integer")
#' testthat::expect_equal(tmp2$validates, TRUE)
#' testthat::expect_equal(tmp2$fn, "test")
#'
#' tmp3 = demo_idispatch(test_data, sym1, sym2, a_expr = sin(pi) + cos(pi))
#' print(tmp3)
#'
#' # expression passed correctly as expression:
#' testthat::expect_equal(tmp3$a_expr, "sin(pi) + cos(pi)")
#' # expression can be evaluated (in context):
#' testthat::expect_equal(tmp3$a, -1)
#' # dots can be handled as symbols:
#' testthat::expect_equal(
#'   unname(tmp3$dots),
#'   lapply(c("sym1", "sym2"), as.symbol)
#' )
#'
#' tmp4 = demo_idispatch(test_extn_data, a = class(test_extn_data$id), b = 0)
#' print(tmp4)
#' # The reference to class(test_extn_data$id) evaluates on the validated input.
#' # This is potentially confusing but probably the best option:
#' testthat::expect_equal(tmp4$a_value, "integer")
#' testthat::expect_equal(class(test_extn_data$id), "numeric")
#'
demo_idispatch = function(x, ...) {
  interfacer::idispatch(
    x,
    demo_idispatch.test_extn = i_test_extn,
    demo_idispatch.test = i_test
  )
}

# not exported
# has additional parameters
demo_idispatch.test_extn = function(x, ..., a = c(1, 2, 3), b = a^2) {
  return(list(
    fn = "test_extn",
    validates = itest(x, i_test_extn),
    types = sapply(x, class),
    dots = rlang::list2(...),
    a_value = a,
    b_value = b,
    defn = format(demo_idispatch.test_extn)
  ))
}

# not exported
# additional parameters which are lazily evaluated
demo_idispatch.test = function(x, ..., a_expr = NULL) {
  a_expr = rlang::enexpr(a_expr)
  return(list(
    fn = "test",
    validates = itest(x, i_test),
    types = sapply(x, class),
    dots = rlang::ensyms(...),
    a_expr = format(a_expr),
    a = eval(a_expr),
    defn = format(demo_idispatch.test)
  ))
}
