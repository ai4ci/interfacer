# Test dataframe conformance to an interface specification.

`ivalidate` throws errors deliberately however sometimes dealing with
invalid input may be desirable. `itest` is generally designed to be used
within a function which specifies the expected input using `iface`, and
allows the function to test if its given input is conformant to the
interface.

## Usage

``` r
itest(df = NULL, iface = NULL, .imap = imapper())
```

## Arguments

- df:

  a dataframe to test. If missing the first parameter of the calling
  function is assumed to be the dataframe to test.

- iface:

  an interface specification produced by
  [`iface()`](https://ai4ci.github.io/interfacer/reference/iface.md). If
  missing this will be inferred from the current function signature.

- .imap:

  an optional mapping specification produced by
  [`imapper()`](https://ai4ci.github.io/interfacer/reference/imapper.md)

## Value

TRUE if the dataframe is conformant, FALSE otherwise

## Examples

``` r
if (rlang::is_installed("ggplot2")) {
  i_diamonds = iface(
    color = enum(D,E,F,G,H,I,J,extra) ~ "the colour",
    price = integer ~ "the price"
  )

  # Ad hoc testing
  itest(ggplot2::diamonds, i_diamonds)

  # Use within function:
  x = function(df = i_diamonds) {
    if(itest()) message("PASS!")
  }

  x(ggplot2::diamonds)
}
#> PASS!
```
