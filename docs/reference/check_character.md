# Checks a set of variables can be coerced to a character and coerces them

Checks a set of variables can be coerced to a character and coerces them

## Usage

``` r
check_character(
  ...,
  .message = "`{param}` is not a character: ({err}).",
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
f = iris$Species
g = NA
check_character(a,b,f,g)
```
