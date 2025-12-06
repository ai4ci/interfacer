# Define a conformance rule to confirm that a numeric is in a set range

This is anticipated to be part of a `iface` rule e.g.

## Usage

``` r
type.in_range(min, max, include.min = TRUE, include.max = TRUE)
```

## Arguments

- min:

  the lower limit

- max:

  the upper limit

- include.min:

  is lower limit open (default TRUE)

- include.max:

  is upper limit open (default TRUE)

## Value

a function which checks the values and returns them if OK or throws an
error if not

## Details

`iface(test_col = integer + in_range(-10,10) ~ "An integer from -10 to 10")`

## Examples

``` r
type.in_range(0,10,TRUE,TRUE)(0:10)
#>  [1]  0  1  2  3  4  5  6  7  8  9 10
try(type.in_range(0,10,TRUE,FALSE)(0:10))
#> Error : values not in range: 0 ≤ x < 10
try(type.in_range(0,10,FALSE)(0:10))
#> Error : values not in range: 0 < x ≤ 10
type.in_range(0,10,FALSE,TRUE)(1:10)
#>  [1]  1  2  3  4  5  6  7  8  9 10
type.in_range(0,10,TRUE,FALSE)(0:9)
#>  [1] 0 1 2 3 4 5 6 7 8 9
type.in_range(0,Inf,FALSE,FALSE)(1:9)
#> [1] 1 2 3 4 5 6 7 8 9
try(type.in_range(0,10)(1:99))
#> Error : values not in range: 0 ≤ x ≤ 10
```
