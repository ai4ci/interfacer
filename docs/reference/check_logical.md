# Checks a set of variables can be coerced to a logical and coerces them

Checks a set of variables can be coerced to a logical and coerces them

## Usage

``` r
check_logical(
  ...,
  .message = "`{param}` is not a logical: ({err}).",
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
a = c("T","F")
b = c(1,0,1,0)
f = TRUE
g = NA
check_logical(a,b,f,g)

c = c("dfsfs")
try(check_logical(c,d, mean))
#> Warning: 1) 'd' is not defined in this context
#> 2) 'mean' is not defined in this context
#> Error in .check_framework(..., predicate = predicate, convert = convert,  : 
#>   1) `c` is not a logical: (not T/F input).
```
