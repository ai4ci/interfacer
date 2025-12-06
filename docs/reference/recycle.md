# Strictly recycle function parameters

`recycle` is called within a function and ensures the parameters in the
calling function are all the same length by repeating them using `rep`.
This function alters the environment from which it is called. It is
stricter than R recycling in that it will not repeat vectors other than
length one to match the longer ones, and it throws more informative
errors.

## Usage

``` r
recycle(..., .min = 1, .env = rlang::caller_env())
```

## Arguments

- ...:

  the variables to recycle

- .min:

  the minimum length of the results (defaults to 1)

- .env:

  the environment to recycle within.

## Value

the length of the longest variable

## Details

NULL values are not recycled, missing values are ignored.

## Examples

``` r
testfn = function(a, b, c) {
  n = recycle(a,b,c)
  print(a)
  print(b)
  print(c)
  print(n)
}

testfn(a=c(1,2,3), b="needs recycling", c=NULL)
#> [1] 1 2 3
#> [1] "needs recycling" "needs recycling" "needs recycling"
#> NULL
#> [1] 3
try(testfn(a=c(1,2,3), c=NULL))
#> [1] 1 2 3
#> Error in testfn(a = c(1, 2, 3), c = NULL) : 
#>   argument "b" is missing, with no default

testfn(a=character(), b=integer(), c=NULL)
#> character(0)
#> integer(0)
#> NULL
#> [1] 0

# inconsistent to have a zero length and a non zero length
try(testfn(a=c("a","b"), b=integer(), c=NULL))
#> Error : Parameter `b` is/are the wrong lengths. They should be length 2 (or 1)
```
