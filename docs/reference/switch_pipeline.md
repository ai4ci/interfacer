# Branch a `dplyr` pipeline based on a set of conditions

Branch a `dplyr` pipeline based on a set of conditions

## Usage

``` r
switch_pipeline(.x, ...)
```

## Arguments

- .x:

  a dataframe

- ...:

  a list of formulae of the type `predicate ~ purrr function` using `.x`
  as the single parameter

## Value

the result of applying `purrr function` to `.x` in the case where
`predicate` evaluates to true. Both predicate and function can refer to
the pipeline dataframe using `.x`

## Examples

``` r
iris %>% switch_pipeline(
  is_col_present(.x, Species) ~ .x %>% dplyr::rename(new = Species)
) %>% dplyr::glimpse()
#> Rows: 150
#> Columns: 5
#> $ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9, 5.4, 4.…
#> $ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1, 3.7, 3.…
#> $ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5, 1.5, 1.…
#> $ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.…
#> $ new          <fct> setosa, setosa, setosa, setosa, setosa, setosa, setosa, s…
```
