# Check for a given class

Any values of the wrong class will cause failure of validation. This is
particularly useful for custom vectors of for list types (e.g.
`list(of_type(lm))`)

## Usage

``` r
type.of_type(type, .not_null = FALSE)
```

## Arguments

- type:

  the class of the type we are checking as a symbol

- .not_null:

  are NULL values allowed (for list column entries only)

## Value

a function that can check the input is of the correct type.
