# Dataframe validation

``` r
library(interfacer)
```

## Rationale

`interfacer` is designed to support package authors who wish to use
dataframes as input parameters to package functions. In this case
assumptions about the structure of the input dataframe, in terms of
expected column names, expected column data types, and expected grouping
structure is a common problem that leads to a lot of code to validate
input and detect edge cases in grouping, and creates the requirement for
detailed documentation about the nature of accepted input dataframes.

`interfacer` provides a mechanism for simply specifying input dataframe
constraints as an `iface` specification, a one liner for validating
input, and an `roxygen2` tag for automating documentation of dataframe
inputs. This is not dissimilar conceptually to the definition of a table
in a relational database, or the specification of an XML schema.

`interfacer` also provides capabilities that support checking dataframe
function outputs are consistent (typically during development), and
documenting return dataframe formats. It is also capable of dispatching
inputs to different functions based on dataframe input structure, and
flexibly handling unexpected grouping in input data.

## Defining an interface

An `iface` specification defines the structure of acceptable dataframes.
It is a list of column names, plus types and some documentation about
the column.

``` r
i_test = iface(
  id = integer ~ "an integer ID",
  test = logical ~ "the test result"
)
```

Printing an interface specification shows the structure that the `iface`
defines.

``` r
cat(print(i_test))
#> A dataframe containing the following columns: 
#> * id (integer) - an integer ID
#> * test (logical) - the test result
#> Any grouping allowed.
```

An `iface` specification is associated with a specific function
parameter by being set as the default value for that parameter. This is
a dummy default value but when combined with `ivalidate` in the function
body a user supplied dataframe is validated to ensure it is of the right
shape. We can use `@iparam <param> <description>` in the `roxygen2`
documentation to describe the dataframe constraints.

``` r
#' An example function
#'
#' @iparam mydata description of a dataframe - format automatically documented
#' @param another an example
#' @param ... not used
#'
#' @return the conformant dataframe
#' @export
example_fn = function(
  mydata = i_test,
  another = "value",
  ...
) {
  mydata = ivalidate(mydata)
  return(mydata)
}
```

In this case when we later call `example_fn` the data is checked against
the requirements by `ivalidate`, and if acceptable passed on to the rest
of the function body (in this case it does nothing and the validated
input is returned).

If we call this function with data that conforms the validation succeeds
and the validated input data is returned.

``` r

example_data = tibble::tibble(
    id = c(1,2,3), # this is a numeric vector
    test = c(TRUE,FALSE,TRUE)
  )

# this returns the qualifying data
example_fn(
  example_data, 
  "value for another"
) %>% dplyr::glimpse()
#> Rows: 3
#> Columns: 2
#> $ id   <int> 1, 2, 3
#> $ test <lgl> TRUE, FALSE, TRUE
```

It should be noted that although we passed a numeric vector in the `id`
column to the function it has been coerced into an `int` vector by
`ivalidate`. Data type checking in `interfacer` is permissive in that if
something can be coerced without warning it will be.

If we pass non-conformant data `ivalidate` throws an informative error
about what is wrong with the data. In this case the `test` column is
missing:

``` r
bad_example_data = tibble::tibble(
    id = c(1,2,3),
    wrong_name = c(TRUE,FALSE,TRUE)
  )

# this causes an error as example_data_2$wrong_test is wrongly named
try(example_fn(
  bad_example_data, 
  "value for another"
))
#> Error : missing columns in the `mydata` parameter of `example_fn(...)`.
#> missing: test
#> consider renaming / creating missing columns before calling `example_fn(...)`
```

We can recover from this error by renaming the columns before passing
`bad_example_data` to `example_fn()`.

In a second example the input data frame is non-conformant to the
specification as the id column cannot be coerced to an integer.

``` r
bad_example_data_2 = tibble::tibble(
    id = c(1, 2.1, 3), # cannot be cleanly coerced to integer.
    test = c(TRUE,FALSE,TRUE)
  )

try(example_fn(
  bad_example_data_2, 
  "value for another"
))
#> Error : input column `id` in function parameter `example_fn(mydata = ?)` cannot be coerced to a integer: rounding detected
```

This error aims to be informative enough for the user to fix the
problem.

## Extension and composition

Interface specifications can be composed and extended. In this case an
extension of the `i_test` specification can be created:

``` r
i_test_extn = iface(
  i_test,
  extra = character ~ "a new value",
  .groups = FALSE
)

print(i_test_extn)
#> A dataframe containing the following columns: 
#> * id (integer) - an integer ID
#> * test (logical) - the test result
#> * extra (character) - a new value
#> Ungrouped.
```

This extended `iface` specification adds in the constraint for a
character column named `extra` and that there must not be any grouping.
This is used to constrain the input of another example function as
before. We also constrain the output of this second function to be
conformant to the original specification using `ireturn`. Examples of
documenting the input parameter and the output parameter are provided
here:

``` r

#' Another example function 
#' 
#' @iparam mydata a more constrained input
#' @param another an example   
#' @param ... not used
#'
#' @ireturn a test output, format will be automatically documented
#' @export
example_fn2 = function(
    mydata = i_test_extn,
    ...
) {
  mydata = ivalidate(mydata, ..., .prune = TRUE)
  print(paste0("extra column:", mydata$extra))
  mydata = mydata %>% dplyr::select(-extra)
  # check the return value conforms to a new specification
  ireturn(mydata, i_test)
}
```

In this case the `ivalidate` call prunes unneeded data from the
dataframe, removing any extra columns, and also ensures that the input
is not grouped in any way. (Grouping is described in more detail below.)

``` r
grouped_example_data = tibble::tibble(
    id = c(1,2,3),
    test = c(TRUE,FALSE,TRUE),
    extra = c("a","b","c"),
    unneeded = c("x","y","z")
  ) %>% dplyr::group_by(id)
```

This is rejected because the grouping is incorrect. An informative error
message is provided:

``` r
try(example_fn2(grouped_example_data))
#> Error : unexpected additional groups in `mydata` parameter of `example_fn2(...)`
#> additional: id
#> consider regrouping your data before calling function `example_fn2(...)`, e.g.:
#> `df %>% ungroup() %>% example_fn2(...)`
#> or calling function `example_fn2(...)` using a group_modify, e.g.:
#> `df %>% group_by(id) %>% group_modify(example_fn2, ...)`
```

Following the instructions in the error message makes this previously
failing data validate against `i_test_extn`:

``` r
grouped_example_data %>% 
  dplyr::ungroup() %>% 
  example_fn2() %>% 
  dplyr::glimpse()
#> [1] "extra column:a" "extra column:b" "extra column:c"
#> Rows: 3
#> Columns: 2
#> $ id   <int> 1, 2, 3
#> $ test <lgl> TRUE, FALSE, TRUE
```

## Grouping

Unanticipated grouping is a common cause of unexpected behaviour in
functions that operate on dataframes. `interfacer` can also specify what
degree of grouping is expected. This can take the form of constraints
that a) enforce that no grouping is present, or b) enforce that the
dataframe is grouped by exactly a given set of columns, or c) enforce
that a data frame is grouped by at least a given set of columns (with
possibly more).

An `iface` specification can permissive or dogmatic about the grouping
of the input. If the .groups option in an `iface` specification is NULL
(e.g. `iface(..., .groups=NULL)`) then any grouping is allowed. If it is
`FALSE` then no grouping is allowed. The third option is to supply a one
sided formula. In this case the variables in the formula define the
grouping that must be exactly present, e.g. `~ grp1 + grp2`, but if it
also includes a `.`, then additional grouping is also permitted
(e.g. `~ . + grp1 + grp2`). This permissive form would allow a grouping
such as `df %>% group_by(anything, grp1, grp2)`.

``` r

i_diamonds = interfacer::iface(
    carat = numeric ~ "the carat column",
    color = enum(`D`,`E`,`F`,`G`,`H`,`I`,`J`, .ordered=TRUE) ~ "the color column",
    x = numeric ~ "the x column",
    y = numeric ~ "the y column",
    z = numeric ~ "the z column",
    # This specifies a permissive grouping with at least `carat` and `cut` columns
    .groups = ~ . + carat + cut
)

if (rlang::is_installed("ggplot2")) {
  
  # permissive grouping with the `~ . + carat + cut` groups rule
  ggplot2::diamonds %>% 
    dplyr::group_by(color, carat, cut) %>% 
    # in a usual workflow this would be an `ivalidate` call within a package 
    # function but for this example we are directly calling the underlying function
    # `iconvert`
    iconvert(i_diamonds, .prune = TRUE) %>% 
    dplyr::glimpse()

}
#> Rows: 53,940
#> Columns: 6
#> Groups: color, carat, cut [4,803]
#> $ color <ord> E, E, E, I, J, J, I, H, E, H, J, J, F, J, E, E, I, J, J, J, I, E…
#> $ carat <dbl> 0.23, 0.21, 0.23, 0.29, 0.31, 0.24, 0.24, 0.26, 0.22, 0.23, 0.30…
#> $ cut   <ord> Ideal, Premium, Good, Premium, Good, Very Good, Very Good, Very …
#> $ x     <dbl> 3.95, 3.89, 4.05, 4.20, 4.34, 3.94, 3.95, 4.07, 3.87, 4.00, 4.25…
#> $ y     <dbl> 3.98, 3.84, 4.07, 4.23, 4.35, 3.96, 3.98, 4.11, 3.78, 4.05, 4.28…
#> $ z     <dbl> 2.43, 2.31, 2.31, 2.63, 2.75, 2.48, 2.47, 2.53, 2.49, 2.39, 2.73…
```

If a group column is specified it must be present, regardless of the
rest of the `iface` specification. So in this example the `cut` column
is required by the `i_diamonds` contract but its data type is not
specified.

Rather than create a third example function we have in this example used
`iconvert` which is an interactive for of `ivalidate`.

## Documentation

The `roxygen2` block of documentation for this second interface is
determined by the `#' @iparam` block, which uses the underlying function
`idocument`. Demonstrating the behaviour of the `@iparam` `roxygen2` tag
is hard in a vignette but essentially it inserts the following block
into the documentation when
[`devtools::document`](https://devtools.r-lib.org/reference/document.html)
is called:

``` r
cat(idocument(example_fn2))
#> A dataframe containing the following columns: 
#> 
#> * id (integer) - an integer ID
#> * test (logical) - the test result
#> * extra (character) - a new value
#> 
#> Ungrouped.
```

There is a matching `@ireturn` tag which can be used instead of
`@return` and this inspects the function looking for an
`interfacer::ireturn(output, spec)` call and uses the specification to
document the structure of the value returned by the function.

## Type coercion

`interfacer` does not implement a rigid type system, but rather a
permissive one. If the provided data can be coerced to the specified
type without major loss then this is automatically done, as long as it
can proceed with no warnings. In this example `id` (expected to be an
integer) is provided as a `character` and `extra` (expected to be a
character) is coerced from the provided numeric.

``` r

tibble::tibble(
  id=c("1","2","3"),
  test = c(TRUE,FALSE,TRUE),
  extra = 1.1
) %>%
example_fn2() %>% 
dplyr::glimpse()
#> [1] "extra column:1.1" "extra column:1.1" "extra column:1.1"
#> Rows: 3
#> Columns: 2
#> $ id   <int> 1, 2, 3
#> $ test <lgl> TRUE, FALSE, TRUE
```

Completely incorrect data types on the other hand are picked up and
rejected. In this case the data supplied for `id` cannot be cast to
integer without loss. Similar behaviour is seen if logical data is
anything other than 0 or 1 for example.

``` r
try(example_fn(
  tibble::tibble(
    id= c("1.1","2","3"),
    test = c(TRUE,FALSE,TRUE)
  )))
#> Error : input column `id` in function parameter `example_fn(mydata = ?)` cannot be coerced to a integer: rounding detected
```

Factors might have allowable levels as well. For this we define them as
an `enum` which accepts a list of values, which then must be matched by
the levels of a provided factor. The order of the levels will be taken
from the `iface` specification and re-levelling of inputs is taken to
ensure the factor levels match the specification. If `.drop = TRUE` is
specified then values which don’t match the levels will be cast to `NA`
rather than causing failure to allow conformance to a subset of factor
values.

``` r

if (rlang::is_installed("ggplot2")) {
  
  i_diamonds = iface( 
    color = enum(D,E,F,G,H,I,J,extra) ~ "the colour",
    cut = enum(Ideal, Premium, .drop=TRUE) ~ "the cut",
    price = integer ~ "the price"
  )
  
  ggplot2::diamonds %>% 
    iconvert(i_diamonds, .prune = TRUE) %>% 
    dplyr::glimpse()
   
} 
#> Rows: 53,940
#> Columns: 3
#> $ color <fct> E, E, E, I, J, J, I, H, E, H, J, J, F, J, E, E, I, J, J, J, I, E…
#> $ cut   <fct> Ideal, Premium, NA, Premium, NA, NA, NA, NA, NA, NA, NA, Ideal, …
#> $ price <int> 326, 326, 327, 334, 335, 336, 336, 337, 337, 338, 339, 340, 342,…
```

## More complex type constraints

The type of a dataframe column can be defined as a basic data-type,
however more complex constraints are also available provided in
`interfacer`. These can be listed by searching the help system with
`??interfacer::type.` at the console.

| Topic | Title |
|:---|:---|
| anything | Coerce to an unspecified type |
| character | Coerce to a character. |
| complete | Coerce to a complete set of values. |
| date | Coerce to a Date. |
| default | Set a default value for a column |
| double | Coerce to a double. |
| enum | Define a conformance rule to match a factor with specific levels. |
| factor | Coerce to a factor. |
| finite | Check for non-finite values |
| group_unique | Coerce to a unique value within the current grouping structure. |
| in_range | Define a conformance rule to confirm that a numeric is in a set range |
| integer | Coerce to integer |
| logical | Coerce to a logical |
| not_missing | Check for missing values |
| numeric | Coerce to a numeric. |
| of_type | Check for a given class |
| positive_double | Coerce to a positive double. |
| positive_integer | Coerce to a positive integer. |
| proportion | Coerce to a number between 0 and 1 |
| unique_id | A globally unique ids. |

The individual help files for these functions explain their use but in
an `iface` specification they are used on the left hand side of a
formula and can be composed to allow multiple constraints. For example:

``` r
iface(
  col1 = double + finite ~ "A finite double",
  col2 = integer + in_range(0,100) ~ "an integer in the range 0 to 100 inclusive",
  col3 = numeric + in_range(0,10, include.max=FALSE) ~ "a numeric 0 <= x < 10", 
  col4 = date ~ "A date",
  col5 = logical + not_missing ~ "A non-NA logical",
  col6 = logical + default(TRUE) ~ "A logical with missing (i.e. NA) values coerced to TRUE",
  col7 = factor ~ "Any factor",
  col8 = enum(`A`,`B`,`C`) + not_missing ~ "A factor with exactly 3 levels A, B and C and no NA values"
)
```

Column wise default values can be supplied with the `default(...)`
pseudo-function and ranges with `in_range(...)`. Their documentation is
available in
[`?interfacer::type.default`](https://ai4ci.github.io/interfacer/reference/type.default.md)
and
[`?interfacer::type.in_range`](https://ai4ci.github.io/interfacer/reference/type.in_range.md).
It can be noted that although the internal functions are all prefixed
with `type.XXX`, the prefix is not needed in the `iface` specification.

It is also theoretically possible to supply your own checks in this
specification. These must be in the form of a function that accepts one
vector as input and produces one vector as output, or throws an error as
in this example.

``` r
uppercase = function(x) {
  if (any(x != toupper(x))) stop("not upper case input",call. = FALSE)
  return(x)
}

custom_eg = function(df = iface(
  text = character + uppercase ~ "An uppercase input only"
)) {
  df = ivalidate(df)
  return(df)
}

tibble::tibble(text = "SUCCESS") %>% custom_eg()
#> # A tibble: 1 × 1
#>   text   
#> * <chr>  
#> 1 SUCCESS

try(tibble::tibble(text = "fail") %>% custom_eg())
#> Error : input column `text` in function parameter `custom_eg(df = ?)` cannot be coerced to a character + uppercase: not upper case input
```

N.B. When using custom conditions within a package they must be visible
to `interfacer` this normally means they will need to be exported and
may need to be referred to with package prefix.

A final option is to use an `as.XXX` function as a condition. In this
example we define a column as a `POSIXct` type, and a second column is
defined as a `ts` class vector:

``` r

# Coerce the `date_col` to a POSIXct and 
custom_eg_2 = function( df = iface(
    date_col = POSIXct ~ "a posix date",
    ts_col = of_type(ts) ~ "A timeseries vector"
  )) {
  df = ivalidate(df)
  return(lapply(df, class))
}

tibble::tibble(
  date_col = c("2001-01-01","2002-01-01"),
  ts_col = ts(c(2,1))
) %>% custom_eg_2()
#> $date_col
#> [1] "POSIXct" "POSIXt" 
#> 
#> $ts_col
#> [1] "ts"
```

## Default dataframe values

Because `interfacer` hijacks the R default value for a function
parameter to define the input dataframe constraints, there needs to be
an alternative way to supply a default value if one is needed. To do
this the `iface` specification can define a default. This can either be
a) A zero length dataframe, or b) a dataframe supplied at the time of
interface definition, or c) a data frame supplied at the time of
function execution.

To get a zero length dataframe as the default the value of `TRUE` is
passed to the `.default` value of `iface`:

``` r

i_iris = interfacer::iface(
    Sepal.Length = numeric ~ "the Sepal.Length column",
    Sepal.Width = numeric ~ "the Sepal.Width column",
    Petal.Length = numeric ~ "the Petal.Length column",
    Petal.Width = numeric ~ "the Petal.Width column",
    Species = enum(`setosa`,`versicolor`,`virginica`) ~ "the Species column",
    .groups = NULL,
  .default = TRUE
)

test_fn = function(i = i_iris, ...) {
  # if i is not provided (a missing value) the default zero length 
  # dataframe defined by `i_iris` is used.
  i = ivalidate(i)
  return(i)
}

# Outputs a zero length data frame as the default value
test_fn() %>% dplyr::glimpse()
#> Rows: 0
#> Columns: 5
#> $ Sepal.Length <dbl> 
#> $ Sepal.Width  <dbl> 
#> $ Petal.Length <dbl> 
#> $ Petal.Width  <dbl> 
#> $ Species      <fct>
```

In this second example the default value is specified during the
interface specification.

``` r

i_iris_2 = interfacer::iface(
    Sepal.Length = numeric ~ "the Sepal.Length column",
    Sepal.Width = numeric ~ "the Sepal.Width column",
    Petal.Length = numeric ~ "the Petal.Length column",
    Petal.Width = numeric ~ "the Petal.Width column",
    Species = enum(`setosa`,`versicolor`,`virginica`) ~ "the Species column",
    .groups = NULL,
  .default = iris
)

test_fn_2 = function(i = i_iris_2, ...) {
  i = ivalidate(i)
  return(i)
}

# Outputs the 150 row iris data frame as a default value from the definition of `i_iris_2`
test_fn_2() %>% dplyr::glimpse()
#> Rows: 150
#> Columns: 5
#> $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9, 5.4, 4.…
#> $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1, 3.7, 3.…
#> $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5, 1.5, 1.…
#> $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.…
#> $ Species      <fct> setosa, setosa, setosa, setosa, setosa, setosa, setosa, s…
```

In this third example we override the default on a per function basis by
supplying a default to `ivalidate` within the function body. In this
case the default is just the first 5 rows:

``` r

test_fn_3 = function(i = i_iris_2, ...) {
  i = ivalidate(i, .default = iris %>% head(5))
  return(i)
}

# Outputs the first 5 rows of the iris data frame as the default value
test_fn_3() %>% dplyr::glimpse()
#> Rows: 5
#> Columns: 5
#> $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.6, 5.0
#> $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.1, 3.6
#> $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.5, 1.4
#> $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.2, 0.2
#> $ Species      <fct> setosa, setosa, setosa, setosa, setosa
```

## Conclusion

This vignette covers the primary validation functions of `interfacer`,
including missing columns, data-type checks and enforcing grouping
structure. Automation of documentation and interface composition is also
covered.

Please see the other vignettes for topics such as function dispatch
based on `iface` specifications, automatically handling grouped input,
nesting and `purrr` style list columns, and a quick summary of tools to
help developers.
