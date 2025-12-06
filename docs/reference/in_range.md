# Define a conformance rule to confirm that a numeric is in a set range

This is anticipated to be part of a `iface` rule e.g.

## Usage

``` r
in_range(min, max)
```

## Arguments

- min:

  the lower limit (inclusive)

- max:

  the upper limit (inclusive)

## Value

a function which checks the values and returns them if OK or throws an
error if not

## Details

`iface(test_col = integer + in_range(-10,10) ~ "An integer from -10 to 10")`

## Examples

``` r
in_range(0,100)(1:99)
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
#> [26] 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50
#> [51] 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75
#> [76] 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99
try(in_range(0,10)(1:99))
#> Error in in_range(0, 10)(1:99) : values not in range: 0-10
```
