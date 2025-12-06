# Checks a set of variables can be coerced to numeric and coerces them

N.B. This only works for the specific environment (to prevent weird side
effects)

## Usage

``` r
check_numeric(
  ...,
  .message = "`{param}` is non-numeric ({err}).",
  .env = rlang::caller_env()
)
```

## Arguments

- ...:

  a list of symbols

- .message:

  a glue specification containing `{param}` as the name of the parameter
  and `{err}` the cause of the error

- .env:

  the environment to check (defaults to calling environment)

## Value

nothing. called for side effects. throws error if not all variables can
be coerced.

## Examples

``` r
a = c(1:4L)
b = c("1",NA,"3.3")
f = NULL
g = NA
check_numeric(a,b,f,g)

c = c("dfsfs")
try(check_numeric(c,d, mean))
#> Warning: 1) 'd' is not defined in this context
#> 2) 'mean' is not defined in this context
#> Error in .check_framework(..., predicate = predicate, convert = convert,  : 
#>   1) `c` is non-numeric (non numeric format).
```
