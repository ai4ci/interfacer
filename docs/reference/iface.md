# Construct an interface specification

An `iface` specification defines the expected structure of a dataframe,
in terms of the column names, column types, grouping structure and
uniqueness constraints that the dataframe must conform to. A dataframe
can be tested for conformance to an `iface` specification using
[`ivalidate()`](https://ai4ci.github.io/interfacer/reference/ivalidate.md).

## Usage

``` r
iface(..., .groups = NULL, .default = NULL)
```

## Arguments

- ...:

  The specification of the interface (see details), or an unnamed
  `iface` object to extend, or both.

- .groups:

  either `FALSE` for no grouping allowed or a formula of the form
  `~ var1 + var2 + ...` which defines what columns must be grouped in
  the dataframe (and in which order). If `NULL` (the default) then any
  grouping is permitted. If the formula contains a dot e.g.
  `~ . + var1 + var2` then the grouping must include `var1` and `var2`
  but other groups are also allowed.

- .default:

  a default value to supply if there is nothing given in a function
  parameter using the `iface` as a formal. This is either `NULL` in
  which case there is no default, `TRUE` in which case the default is a
  zero row dataframe conforming to the specification, or a provided
  dataframe, which is checked to conform, and used as the default.

## Value

the definition of an interface as a `iface` object

## Details

An `iface` specification is designed to be used to define the type of a
parameter in a function. This is done by using the `iface` specification
as the default value of the parameter in the function definition. The
definition can then be validated at runtime by a call to
[`ivalidate()`](https://ai4ci.github.io/interfacer/reference/ivalidate.md)
inside the function.

When developing a function output an `iface` specification may also be
used in
[`ireturn()`](https://ai4ci.github.io/interfacer/reference/ireturn.md)
to enforce that the output of a function is correct.

`iface` definitions can be printed and included in `roxygen2`
documentation and help us to document input dataframe parameters and
dataframe return values in a standardised way by using the `@iparam`
`roxygen2` tag.

`iface` specifications are defined in the form of a named list of
formulae with the structure `column_name = type ~ "documentation"`.

`type` can be one of `anything`, `character`, `complete`, `date`,
`default`, `double`, `enum`, `factor`, `finite`, `group_unique`,
`in_range`, `integer`, `logical`, `not_missing`, `numeric`, `of_type`,
`positive_double`, `positive_integer`, `proportion`, `unique_id` (e.g.
`enum(level1,level2,...)`, `in_range(min,max)`) or alternatively
anything that resolves to a function e.g. `as.ordered`.

If `type` is a function name, then the function must take a single
vector parameter and return a single vector of the same size. The
function must also return a zero length vector of an appropriate type if
passed `NULL`.

`type` can also be a concatenation of rules separated by `+`, e.g.
`integer + group_unique` for an integer that is unique within a group.

## Examples

``` r
test_df = tibble::tibble(
  grp = c(rep("a",10),rep("b",10)),
  col1 = c(1:10,1:10)
) %>% dplyr::group_by(grp)

my_iface = iface(
  col1 = integer + group_unique ~ "an integer column",
  .default = test_df
)

print(my_iface)
#> A dataframe containing the following columns: 
#> * col1 (integer + group_unique) - an integer column
#> Any grouping allowed.
#> A default value is defined.

# the function x defines a formal `df` with default value of `my_iface`
# this default value is used to validate the structure of the user supplied
# value when the function is called.
x = function(df = my_iface, ...) {
  df = ivalidate(df,...)
  return(df)
}

# this works
x(tibble::tibble(col1 = c(1,2,3)))
#> # A tibble: 3 × 1
#>    col1
#> * <int>
#> 1     1
#> 2     2
#> 3     3

# this fails as x is of the wrong type
try(x(tibble::tibble(col1 = c("a","b","c"))))
#> Error : input column `col1` in function parameter `x(df = ?)` cannot be coerced to a integer + group_unique: non numeric format

# this fails as x has duplicates
try(x(tibble::tibble(col1 = c(1,2,3,3))))
#> Error : input column `col1` in function parameter `x(df = ?)` cannot be coerced to a integer + group_unique: values are not unique within each group; check grouping is correct

# this gives the default value
x()
#> # A tibble: 20 × 2
#> # Groups:   grp [2]
#>    grp    col1
#>  * <chr> <int>
#>  1 a         1
#>  2 a         2
#>  3 a         3
#>  4 a         4
#>  5 a         5
#>  6 a         6
#>  7 a         7
#>  8 a         8
#>  9 a         9
#> 10 a        10
#> 11 b         1
#> 12 b         2
#> 13 b         3
#> 14 b         4
#> 15 b         5
#> 16 b         6
#> 17 b         7
#> 18 b         8
#> 19 b         9
#> 20 b        10


my_iface2 = iface(
  first_col = numeric ~ "column order example",
  my_iface,
  last_col = character ~ "another col", .groups = ~ first_col + col1
)
print(my_iface2)
#> A dataframe containing the following columns: 
#> * first_col (numeric) - column order example
#> * col1 (integer + group_unique) - an integer column
#> * last_col (character) - another col
#> Must be grouped by: first_col + col1 (exactly).



my_iface_3 = iface(
  col1 = integer + group_unique ~ "an integer column",
  .default = test_df_2
)
x = function(d = my_iface_3) {ivalidate(d)}

# Doesn't work as test_df_2 hasn't been defined
try(x())
#> Error in eval(ex, env) : object 'test_df_2' not found

test_df_2 = tibble::tibble(
  grp = c(rep("a",10),rep("b",10)),
  col1 = c(1:10,1:10)
) %>% dplyr::group_by(grp)

# now it works as has been defined
x()
#> # A tibble: 20 × 2
#> # Groups:   grp [2]
#>    grp    col1
#>  * <chr> <int>
#>  1 a         1
#>  2 a         2
#>  3 a         3
#>  4 a         4
#>  5 a         5
#>  6 a         6
#>  7 a         7
#>  8 a         8
#>  9 a         9
#> 10 a        10
#> 11 b         1
#> 12 b         2
#> 13 b         3
#> 14 b         4
#> 15 b         5
#> 16 b         6
#> 17 b         7
#> 18 b         8
#> 19 b         9
#> 20 b        10

# it still works as default has been cached.
rm(test_df_2)
x()
#> # A tibble: 20 × 2
#> # Groups:   grp [2]
#>    grp    col1
#>  * <chr> <int>
#>  1 a         1
#>  2 a         2
#>  3 a         3
#>  4 a         4
#>  5 a         5
#>  6 a         6
#>  7 a         7
#>  8 a         8
#>  9 a         9
#> 10 a        10
#> 11 b         1
#> 12 b         2
#> 13 b         3
#> 14 b         4
#> 15 b         5
#> 16 b         6
#> 17 b         7
#> 18 b         8
#> 19 b         9
#> 20 b        10
```
