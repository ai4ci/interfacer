# Check for existence of a set of columns in a dataframe

Check for existence of a set of columns in a dataframe

## Usage

``` r
is_col_present(df, ...)
```

## Arguments

- df:

  a dataframe to test

- ...:

  the column names (unquoted)

## Value

TRUE if the columns are all there, false otherwise

## Examples

``` r
is_col_present(iris, Species, Petal.Width)
#> [1] TRUE
```
