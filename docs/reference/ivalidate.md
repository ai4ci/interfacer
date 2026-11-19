# Perform interface checks on dataframe inputs using enclosing function formal parameter definitions

`ivalidate(...)` is intended to be used within a function to check the
validity of a data frame parameter (usually the first parameter) against
an `iface` specification which is given as a default value of a formal
parameter.

## Usage

``` r
ivalidate(
  df = NULL,
  ...,
  .imap = imapper(),
  .prune = FALSE,
  .fix = FALSE,
  .default = NULL
)
```

## Arguments

- df:

  a dataframe - if missing then the first parameter of the calling
  function is assumed to be a dataframe.

- ...:

  not used.

- .imap:

  a set of mappings as an `imapper` object.

- .prune:

  get rid of excess columns that are not in the spec.

- .fix:

  add in missing columns with `NA` or default values as defined in the
  spec

- .default:

  a default dataframe conforming to the spec. This overrides any
  defaults defined in the enclosing function formal defaults

## Value

a dataframe based on `df` with validity checks passed and `.imap`
mappings applied if present

## Examples

``` r
x = function(df = iface(col1 = integer ~ "an integer column" ), ...) {
  df = ivalidate(...)
  return(df)
}
input=tibble::tibble(col1 = c(1,2,3))
x(input)
#> # A tibble: 3 × 1
#>    col1
#> * <int>
#> 1     1
#> 2     2
#> 3     3

# This fails because col1 is not coercable to integer
input2=tibble::tibble(col1 = c(1.5,2,3))
try(x(input2))
#> Error : input column `col1` in function parameter `x(df = ?)` cannot be coerced to a integer: rounding detected
```
