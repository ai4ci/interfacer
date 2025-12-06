# Check function parameters conform to a set of rules

If the parameters of a function are given in some combination but have
an interdependency (e.g. different parametrisations of a probability
distribution) or a constraint (like `x>0`) this function can
simultaneously check all interrelations are satisfied and report on all
the not conformant features of the parameters.

## Usage

``` r
check_consistent(..., .env = rlang::caller_env())
```

## Arguments

- ...:

  a set of rules to check either as `x=y+z`, or `x>y`. Single `=`
  assignment is checked for equality using `identical` otherwise the
  expressions are evaluated and checked they all are true. This for
  consistency with
  [`resolve_missing()`](https://ai4ci.github.io/interfacer/reference/resolve_missing.md)
  which only uses assignment, and ignores logical expressions.

- .env:

  the environment to check in

## Value

nothing, throws an informative error if the checks fail.

## Examples

``` r
testfn = function(pos, neg, n) {
  check_consistent(pos=n-neg, neg=n-pos, n=pos+neg, n>pos, n>neg)
}

testfn(pos = 1:4, neg=4:1, n=rep(5,4))
try(testfn(pos = 1:4, neg=5:2, n=rep(5,4)))
#> Error : inconsistent inputs detected:
#> 1) constraint 'pos = n - neg' is not met.
#> 2) constraint 'neg = n - pos' is not met.
#> 3) constraint 'n = pos + neg' is not met.
#> 4) constraint 'n > neg' is not met
```
