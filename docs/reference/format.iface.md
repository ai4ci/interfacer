# Format an `iface` specification for printing

Format an `iface` specification for printing

## Usage

``` r
# S3 method for class 'iface'
format(x, ...)
```

## Arguments

- x:

  an `iface` specification

- ...:

  not used.

## Value

a formatted string representation of an `iface`

## Examples

``` r
my_iface = iface(
  col1 = integer + group_unique ~ "an integer column"
)

print(my_iface)
#> A dataframe containing the following columns: 
#> * col1 (integer + group_unique) - an integer column
#> Any grouping allowed.
knitr::knit_print(my_iface)
#> [1] "A dataframe containing the following columns: \n\n* col1 (integer + group_unique) - an integer column\n\nAny grouping allowed."
#> attr(,"class")
#> [1] "knit_asis"
```
