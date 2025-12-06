# Dispatch to a named function based on the characteristics of a dataframe

This provides a dataframe analogy to S3 dispatch. If multiple possible
dataframe formats are possible for a function, each with different
processing requirements, then the choice of function can be made based
on matching the input dataframe to a set of `iface` specifications. The
first matching `iface` specification determines which function is used
for dispatch.

## Usage

``` r
idispatch(x, ..., .default = NULL)
```

## Arguments

- x:

  a dataframe

- ...:

  a set of
  `function name`=[`interfacer::iface`](https://ai4ci.github.io/interfacer/reference/iface.md)
  pairs

- .default:

  a function to apply in the situation where none of the rules can be
  matched. The default results in an error being thrown.

## Value

the result of dispatching the dataframe to the first function that
matches the rules in `...`. Matching is permissive in that the test is
passed if a dataframe can be coerced to the `iface` specified format.

## Examples

``` r
i1 = iface( col1 = integer ~ "An integer column" )
i2 = iface( col2 = integer ~ "A different integer column" )

# this is an example function that would typically be inside a package, and
# is exported from the package.
extract_mean = function(df, ...) {
  idispatch(df,
    extract_mean.i1 = i1,
    extract_mean.i2 = i2
  )
}

# this is expected to be an internal package function
# the naming convention here is based on S3 but it is not required
extract_mean.i1 = function(df = i1, ...) {
  message("using i1")
  # input validation is not required in functions that are being called using
  # `idispatch` as the validation occurs during dispatch. 
  mean(df$col1)
}

extract_mean.i2 = function(df = i2, uplift = 1, ...) {
  message("using i2")
  mean(df$col2)+uplift
}

# this input matches `i1` and the `extract_mean` call is dispatched 
# via `extract_mean.i1`
test = tibble::tibble( col2 = 1:10 )
extract_mean(test, uplift = 50)
#> using i2
#> [1] 55.5

# this input matches `i2` and the `extract_mean` call is dispatched 
# via `extract_mean.i2`
test2 = tibble::tibble( col1 = 1:10 )
extract_mean(test2, uplift = 50)
#> using i1
#> [1] 5.5

# This input does not match any of the allowable input specifications and 
# generates an error.
test3 = tibble::tibble( wrong_col = 1:10 )
try(extract_mean(test3, uplift = 50))
#> Error : the parameter in extract_mean(...) does not match any of the expected formats.
#> extract_mean.i1 - Error : missing columns: col1
#> extract_mean.i2 - Error : missing columns: col2
#> 
```
