# Convert a dataframe to a format compatible with an interface specification

This function is called by
[`ivalidate()`](https://ai4ci.github.io/interfacer/reference/ivalidate.md)
and is not generally intended to be used directly by the end user. It
may be helpful in debugging during package development to interactive
test a `iface` spec. `iconvert` is an interactive version of
[`ivalidate()`](https://ai4ci.github.io/interfacer/reference/ivalidate.md).

## Usage

``` r
iconvert(
  df,
  iface,
  .imap = interfacer::imapper(),
  .dname = "<unknown>",
  .fname = "<unknown>",
  .has_dots = TRUE,
  .prune = FALSE,
  .env = rlang::current_env()
)
```

## Arguments

- df:

  the dataframe to convert

- iface:

  the interface spec as an `iface`

- .imap:

  an optional `imapper` mapping

- .dname:

  the name of the parameter value (optional).

- .fname:

  the name of the function (optional).

- .has_dots:

  internal library use only. Changes the nature of the error message.

- .prune:

  do you want to remove non matching columns?

- .env:

  internal use only

## Value

the input dataframe coerced to be conformant to the `iface`
specification, or an informative error is thrown.

## Examples

``` r
i_diamonds = iface(
  color = enum(D,E,F,G,H,I,J,extra) ~ "the colour",
  price = integer ~ "the price"
)

iconvert(ggplot2::diamonds, i_diamonds,.prune = TRUE)
#> # A tibble: 53,940 × 2
#>    color price
#>  * <fct> <int>
#>  1 E       326
#>  2 E       326
#>  3 E       327
#>  4 I       334
#>  5 J       335
#>  6 J       336
#>  7 I       336
#>  8 H       337
#>  9 E       337
#> 10 H       338
#> # ℹ 53,930 more rows

```
