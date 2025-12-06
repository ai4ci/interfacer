# Coerce to a complete set of values.

This test checks either for factors that all factor levels are present
in the input, or for numerics if the sequence from minimum to maximum by
the smallest difference are not all (approximately) present. Empty
values are ignored.

## Usage

``` r
type.complete(x)
```

## Arguments

- x:

  any vector, factor or numeric

## Value

the input or error if not complete
