# Extract the `interfacer` specification for a function

Extract the `interfacer` specification for a function

## Usage

``` r
get_iface(fn, param = names(formals(fn))[[1]])
```

## Arguments

- fn:

  the function

- param:

  the parameter name (defaults to first parameter)

## Value

the `iface` on the parameter

## Examples

``` r
my_iface = iface(
  col1 = integer + group_unique ~ "an integer column",
  .default = test_df
)

# the function x defines a formal `df` with default value of `my_iface`
# this default value is used to validate the structure of the user supplied
# value when the function is called.
x = function(df = my_iface, ...) {
  df = ivalidate(df,...)
  return(df)
}

get_iface(x,"df")
#> A dataframe containing the following columns: 
#> * col1 (integer + group_unique) - an integer column
#> Any grouping allowed.
#> A default value is defined.
```
