# Cast an `iface` to a plain list.

Cast an `iface` to a plain list.

## Usage

``` r
# S3 method for class 'iface'
as.list(x, ..., flatten = FALSE)
```

## Arguments

- x:

  object to be coerced or tested.

- ...:

  objects, possibly named.

- flatten:

  get a list of lists representation instead of the dataframe column by
  column list.

## Value

a list representation of the `iface` input.

## Examples

``` r
my_iface = iface(
  col1 = integer + group_unique ~ "an integer column"
)

as.list(my_iface, flatten=TRUE)
#> $groups
#> character(0)
#> 
#> $allow_other
#> [1] TRUE
#> 
#> $has_default
#> [1] FALSE
#> 
#> $default
#> NULL
#> 
#> $columns
#> $columns[[1]]
#> $columns[[1]]$name
#> [1] "col1"
#> 
#> $columns[[1]]$type
#> [1] "integer + group_unique"
#> 
#> $columns[[1]]$doc
#> [1] "an integer column"
#> 
#> 
#> 
```
