testfn = function(x, ...) {
  interfacer::idispatch(x, testfn.diamonds = i_diamonds, testfn.iris = i_iris)
}

testfn.diamonds = function(x, ...) {
  sprintf("%d rows of diamonds", nrow(x))
}

testfn.iris = function(x, ...) {
  sprintf("%d rows of iris", nrow(x))
}


test_that("dispatch works", {
  expect_equal(
    testfn(ggplot2::diamonds),
    "53940 rows of diamonds"
  )

  expect_equal(
    testfn(iris),
    "150 rows of iris"
  )

  expect_error(
    testfn(mtcars)
  )
})


test_that("dispatch works in pkg context", {
  # Should dispatch to demo_idispatch.test
  test_data = tibble::tibble(
    id = c(1, 2, 3), # this is a numeric vector
    test = c(TRUE, FALSE, TRUE)
  )

  bad_test_extn_data = tibble::tibble(
    id = c(1, 2, 3),
    test = c(TRUE, FALSE, TRUE),
    extra = c("a", "b", "c"),
    unneeded = c("x", "y", "z")
  ) %>%
    dplyr::group_by(id)

  # Should dispatch to demo_idispatch.test_extn
  test_extn_data = tibble::tibble(
    id = c(1, 2, 3),
    test = c(TRUE, FALSE, TRUE),
    extra = c("a", "b", "c"),
    unneeded = c("x", "y", "z")
  )

  new_a = c(2, 3)
  dots_test_value = "true"
  tmp = demo_idispatch(test_extn_data, a = new_a, dots_test = dots_test_value)
  # The value was dispatched to the correct function
  testthat::expect_equal(tmp$fn, "test_extn")
  # The inline value for b was evaluated correctly as `new_a^2`
  testthat::expect_equal(tmp$b_value, new_a^2)
  # the type was in fact converted during dispatch:
  testthat::expect_equal(tmp$types[["id"]], "integer")
  testthat::expect_equal(tmp$validates, TRUE)
  # dynamic dots were evaluated correctly from this environment
  testthat::expect_equal(tmp$dots, list(dots_test = "true"))

  tmp2 = demo_idispatch(test_data)
  testthat::expect_equal(tmp2$a, NULL)
  testthat::expect_equal(tmp2$types[["id"]], "integer")
  testthat::expect_equal(tmp2$validates, TRUE)
  testthat::expect_equal(tmp2$fn, "test")

  tmp3 = demo_idispatch(test_data, sym1, sym2, a_expr = sin(pi) + cos(pi))
  # expression passed correctly as expression:
  testthat::expect_equal(tmp3$a_expr, "sin(pi) + cos(pi)")
  # expression can be evaluated (in context):
  testthat::expect_equal(tmp3$a, -1)
  # dots can be handled as symbols:
  testthat::expect_equal(
    unname(tmp3$dots),
    lapply(c("sym1", "sym2"), as.symbol)
  )

  tmp4 = demo_idispatch(test_extn_data, a = class(test_extn_data$id), b = 0)
  # The reference to class(test_extn_data$id) evaluates on the validated input.
  # This is potentially confusing but probably the best option:
  testthat::expect_equal(tmp4$a_value, "integer")
  testthat::expect_equal(class(test_extn_data$id), "numeric")
})
