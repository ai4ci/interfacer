# Resolve missing values in function parameters and check consistency

Uses relationships between parameters to iteratively fill in missing
values. It is possible to specify an inconsistent set of rules or data
in which case the resulting values will be picked up and an error
thrown.

## Usage

``` r
resolve_missing(
  ...,
  .env = rlang::caller_env(),
  .eval_null = TRUE,
  .error = NULL
)
```

## Arguments

- ...:

  either a set of relationships as a list of `x=y+z` expressions

- .env:

  the environment to check in (optional - defaults to `caller_env()`)

- .eval_null:

  The default behaviour (when this option is `TRUE`) considers missing
  values to be are either not given, given explicitly as `NULL` or given
  as a `NULL` default value. Sometimes we need to consider `NULL` values
  differently to missing values. If this is set to `FALSE` only strictly
  missing values are resolved, and explicit `NULL` values left as is.

- .error:

  a glue specification defining the error message. This can use
  parameters `.missing`, `.constraints`, `.present` and `.call` to
  construct an error message. If `NULL` a default message is provided
  that is generally sufficient.

## Value

nothing. Alters the `.env` environment to fill in missing values or
throws an informative error

## Examples

``` r
# missing variables left with no default value in function definition
testfn = function(pos, neg, n) {
  resolve_missing(pos=n-neg, neg=n-pos, n=pos+neg)
  return(tibble::tibble(pos=pos,neg=neg,n=n))
}

testfn(pos=1:4, neg = 4:1)
#> # A tibble: 4 × 3
#>     pos   neg     n
#>   <int> <int> <int>
#> 1     1     4     5
#> 2     2     3     5
#> 3     3     2     5
#> 4     4     1     5
testfn(neg=1:4, n = 10:7)
#> # A tibble: 4 × 3
#>     pos   neg     n
#>   <int> <int> <int>
#> 1     9     1    10
#> 2     7     2     9
#> 3     5     3     8
#> 4     3     4     7

try(testfn())
#> Error : unable to infer missing variables: no non-null parameters provided

# not enough info to infer the missing variables
try(testfn(neg=1:4))
#> Error : unable to infer missing variable(s): `pos`, `n` using:
#> `pos = n - neg`
#> `neg = n - pos`
#> `n = pos + neg`
#> given known variable(s): `neg` in `testfn(neg = 1:4)`

# the parameters given are inconsistent with the relationships defined.
try(testfn(pos=2, neg=1, n=4))
#> Error : inconsistent inputs detected:
#> 1) constraint 'pos = n - neg' is not met.
#> 2) constraint 'neg = n - pos' is not met.
#> 3) constraint 'n = pos + neg' is not met.
```
