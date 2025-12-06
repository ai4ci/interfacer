# Execute a function or return a value if a column in present in a dataframe

The simple use case. For more complex behaviour see
[`switch_pipeline()`](https://ai4ci.github.io/interfacer/reference/switch_pipeline.md).

## Usage

``` r
if_col_present(df, col, if_present, if_missing = ~.x)
```

## Arguments

- df:

  a dataframe

- col:

  a column name

- if_present:

  a `purrr` style function to execute on the dataframe if the column is
  present (or a plain value)

- if_missing:

  a `purrr` style function to execute on the dataframe if the column is
  missing (or a plain value)

## Value

either the value of `if_present`/`if_absent` or the result of calling
`if_present`/`if_absent` as functions on `df`.

## Examples

``` r
iris %>% if_col_present(Species, ~ .x %>% dplyr::rename(new = Species)) %>%
  colnames()
#> [1] "Sepal.Length" "Sepal.Width"  "Petal.Length" "Petal.Width"  "new"         

# in contrast to `purrr` absolute values are not interpreted as function names  
iris %>% if_col_present(Species2, "Yes", "No")
#> [1] "No"
```
