# Set a default value for a column

Any NA values will be replaced by this value. N.b. default values must
be provided before any other rules if the validation is not to fail.

## Usage

``` r
type.default(value)
```

## Arguments

- value:

  a length one item of the correct type.

## Value

a validation function that switches NAs for default values
