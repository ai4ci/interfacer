# Test if an `iface` parameter was supplied to a function

As interfacer uses default values to specify the interface, a value will
always be available, but it may be the `iface` spec itself. This is
picked up by `ivalidate` calls and default value substituted if defined.
This means that if you want to know that the parameter was not supplied
you cannot use `rlang::is_missing(...)` as it will always think there is
a default. `base::missing(...)` on the other hand will work as it
differentiates between defaults and supplied values. This is a wrapper
around [`base::missing`](https://rdrr.io/r/base/missing.html) to remind
us to use it.

## Usage

``` r
imissing(param)
```

## Arguments

- param:

  a parameter name, as supplied to the enclosing function

## Value

TRUE if the parameter was not supplied to the function

## Examples

``` r
my_iface = iface(
  col1 = integer + group_unique ~ "an integer column",
  .default = tibble::tibble(col1 = 1:3)
)

x = function(df = my_iface, ...) {
  if(imissing(df)) {
    message("missing parameter")
  } else {
    message("parameter given")
  }
  df = ivalidate(df)
  return(df)
}

x() # missing parameter message, and function returns default value
#> missing parameter
#> # A tibble: 3 × 1
#>    col1
#> * <int>
#> 1     1
#> 2     2
#> 3     3
try(x(iris)) # parameter given message but input will not validate
#> parameter given
#> Error : missing columns in the `df` parameter of `x(...)`.
#> missing: col1
#> consider renaming / creating missing columns before calling `x(...)`
#> 
```
