# Checks a set of variables are all of length one

Checks a set of variables are all of length one

## Usage

``` r
check_single(
  ...,
  .message = "`{param}` is not length one: ({err}).",
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
a = 1
b = "Hello"
g = NA
check_single(a,b,g)

c= c(1,2,3)
d=list(a,b)
try(check_single(c,d,missing))
#> Warning: 1) 'missing' is not defined in this context
#> Error in .check_framework(..., predicate = predicate, convert = convert,  : 
#>   1) `c` is not length one: (list/vector input not allowed).
#> 2) `d` is not length one: (list/vector input not allowed).
```
