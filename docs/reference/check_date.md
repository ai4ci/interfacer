# Checks a set of variables can be coerced to a date and coerces them

Checks a set of variables can be coerced to a date and coerces them

## Usage

``` r
check_date(
  ...,
  .message = "`{param}` is not a date: ({err}).",
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
a = c(Sys.Date()+1:10)
b = format(a)
f = "1970-01-01"
g = NA
check_date(a,b,f,g)

c = c("dfsfs")
try(check_date(c,d, mean))
#> Warning: 1) 'd' is not defined in this context
#> 2) 'mean' is not defined in this context
#> Error in .check_framework(..., predicate = predicate, convert = convert,  : 
#>   1) `c` is not a date: (error casting to date: character string is not in a standard unambiguous format).
```
