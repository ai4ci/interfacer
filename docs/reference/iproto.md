# Generate a zero length dataframe conforming to an `iface` specification

This function is used internally for default values for a dataframe
parameter. It generates a zero length dataframe that conforms to a
`iface` specification, in terms of column names, data types and
groupings. Such a dataframe is not guaranteed to be fully conformant to
the `iface` specification if, for example, completeness constraints are
applied.

## Usage

``` r
iproto(iface)
```

## Arguments

- iface:

  the specification

## Value

a dataframe conforming to `iface`

## Examples

``` r
i = interfacer::iface(
  col1 = integer ~ "A number",
  col2 = character ~ "A string"
)

iproto(i)
#> # A tibble: 0 × 2
#> # ℹ 2 variables: col1 <int>, col2 <chr>
```
