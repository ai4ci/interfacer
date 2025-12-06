# Define a conformance rule to match a factor with specific levels.

Define a conformance rule to match a factor with specific levels.

## Usage

``` r
type.enum(..., .drop = FALSE, .ordered = FALSE)
```

## Arguments

- ...:

  the levels (no quotes, backticks if required)

- .drop:

  should levels present in the data and not specified cause an error
  (FALSE the default) or be silently dropped to NA values (TRUE).

- .ordered:

  must the factor be ordered

## Value

a function that can check and convert input into the factor with
specified levels. This will re-level factors with matching levels but in
a different order.

## Examples

``` r
f = type.enum(one,two,three)
f(c("three","two","one"))
#> [1] three two   one  
#> Levels: one two three
f(factor(rep(1:3,5), labels = c("one","two","three")))
#>  [1] one   two   three one   two   three one   two   three one   two   three
#> [13] one   two   three
#> Levels: one two three
```
