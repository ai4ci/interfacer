# Test the interfacer idispatch functions

Allows testing from the context of an installed package this is here for
testing purposes only. The majority of functions are tested in testthat
but one or two need package infrastructure to test things like the
documentation

## Usage

``` r
demo_idispatch(x, ...)
```

## Arguments

- x:

  one of 2 possibilities - EITHER: a dataframe with columns:

  - id (integer) - an integer ID

  - test (logical) - the test result

  - extra (character) - a new value

  Ungrouped.

  OR with columns:

  - id (integer) - an integer ID

  - test (logical) - the test result

  Any grouping allowed.

- ...:

  passed on to methods

## Value

a list of the parameters passed to one of two functions.

## Examples

``` r
# When we run examples this should run in an isolated session so
# we might be able to see visibility failures:

# Should dispatch to demo_idispatch.test
test_data = tibble::tibble(
  id = c(1, 2, 3), # this is a numeric vector
  test = c(TRUE, FALSE, TRUE)
)

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
print(tmp)
#> $fn
#> [1] "test_extn"
#> 
#> $validates
#> [1] TRUE
#> 
#> $types
#>          id        test       extra    unneeded 
#>   "integer"   "logical" "character" "character" 
#> 
#> $dots
#> $dots$dots_test
#> [1] "true"
#> 
#> 
#> $a_value
#> [1] 2 3
#> 
#> $b_value
#> [1] 4 9
#> 
#> $defn
#> [1] "function (x, ..., a = c(1, 2, 3), b = a^2) "                              
#> [2] "{"                                                                        
#> [3] "    return(list(fn = \"test_extn\", validates = itest(x, i_test_extn), "  
#> [4] "        types = sapply(x, class), dots = rlang::list2(...), a_value = a, "
#> [5] "        b_value = b, defn = format(demo_idispatch.test_extn)))"           
#> [6] "}"                                                                        
#> 

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
print(tmp2)
#> $fn
#> [1] "test"
#> 
#> $validates
#> [1] TRUE
#> 
#> $types
#>        id      test 
#> "integer" "logical" 
#> 
#> $dots
#> named list()
#> 
#> $a_expr
#> [1] "NULL"
#> 
#> $a
#> NULL
#> 
#> $defn
#> [1] "function (x, ..., a_expr = NULL) "                                              
#> [2] "{"                                                                              
#> [3] "    a_expr = rlang::enexpr(a_expr)"                                             
#> [4] "    return(list(fn = \"test\", validates = itest(x, i_test), types = sapply(x, "
#> [5] "        class), dots = rlang::ensyms(...), a_expr = format(a_expr), "           
#> [6] "        a = eval(a_expr), defn = format(demo_idispatch.test)))"                 
#> [7] "}"                                                                              
#> 
testthat::expect_equal(tmp2$a, NULL)
testthat::expect_equal(tmp2$types[["id"]], "integer")
testthat::expect_equal(tmp2$validates, TRUE)
testthat::expect_equal(tmp2$fn, "test")

tmp3 = demo_idispatch(test_data, sym1, sym2, a_expr = sin(pi) + cos(pi))
print(tmp3)
#> $fn
#> [1] "test"
#> 
#> $validates
#> [1] TRUE
#> 
#> $types
#>        id      test 
#> "integer" "logical" 
#> 
#> $dots
#> $dots[[1]]
#> sym1
#> 
#> $dots[[2]]
#> sym2
#> 
#> 
#> $a_expr
#> [1] "sin(pi) + cos(pi)"
#> 
#> $a
#> [1] -1
#> 
#> $defn
#> [1] "function (x, ..., a_expr = NULL) "                                              
#> [2] "{"                                                                              
#> [3] "    a_expr = rlang::enexpr(a_expr)"                                             
#> [4] "    return(list(fn = \"test\", validates = itest(x, i_test), types = sapply(x, "
#> [5] "        class), dots = rlang::ensyms(...), a_expr = format(a_expr), "           
#> [6] "        a = eval(a_expr), defn = format(demo_idispatch.test)))"                 
#> [7] "}"                                                                              
#> 

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
print(tmp4)
#> $fn
#> [1] "test_extn"
#> 
#> $validates
#> [1] TRUE
#> 
#> $types
#>          id        test       extra    unneeded 
#>   "integer"   "logical" "character" "character" 
#> 
#> $dots
#> list()
#> 
#> $a_value
#> [1] "integer"
#> 
#> $b_value
#> [1] 0
#> 
#> $defn
#> [1] "function (x, ..., a = c(1, 2, 3), b = a^2) "                              
#> [2] "{"                                                                        
#> [3] "    return(list(fn = \"test_extn\", validates = itest(x, i_test_extn), "  
#> [4] "        types = sapply(x, class), dots = rlang::list2(...), a_value = a, "
#> [5] "        b_value = b, defn = format(demo_idispatch.test_extn)))"           
#> [6] "}"                                                                        
#> 
# The reference to class(test_extn_data$id) evaluates on the validated input.
# This is potentially confusing but probably the best option:
testthat::expect_equal(tmp4$a_value, "integer")
testthat::expect_equal(class(test_extn_data$id), "numeric")
```
