# Document an interface contract for inserting into `roxygen2`

This function is expected to be called within the documentation of a
function as inline code in the parameter documentation of the function.
It details the expected columns that the input dataframe should possess.
This has mostly been superseded by the `@iparam <name> <description>`
`roxygen2` tag which does this automatically, however in some
circumstances (particularly multiple dispatch) you may want to assemble
dataframe documentation manually.

## Usage

``` r
idocument(fn, param = NULL)
```

## Arguments

- fn:

  the function that you are documenting

- param:

  the parameter you are documenting (optional. if missing defaults to
  the first argument of the function)

## Value

a markdown snippet

## Examples

``` r
#' @param df `r idocument(x, df)`
x = function(df = iface( col1 = integer ~ "an integer column" )) {}

cat(idocument(x, df))
#> A dataframe containing the following columns: 
#> 
#> * col1 (integer) - an integer column
#> 
#> Any grouping allowed.
```
