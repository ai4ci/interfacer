# Checks a set of variables can be coerced to integer and coerces them

N.B. This only works for the specific environment (to prevent weird side
effects)

## Usage

``` r
check_integer(
  ...,
  .message = "`{param}` is not an integer ({err}).",
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
a = c(1:4)
b = c("1",NA,"3")
f = NULL
g = NA
check_integer(a,b,f,g)

c = c("dfsfs")
e = c(1.0,2.3)
try(check_integer(c,d,e, mean))
#> Warning: 1) 'd' is not defined in this context
#> 2) 'mean' is not defined in this context
#> Error in .check_framework(..., predicate = predicate, convert = convert,  : 
#>   1) `c` is not an integer (non numeric format).
#> 2) `e` is not an integer (rounding detected).
```
