# Create an `iface` specification from an example dataframe

When developing with `interfacer` it is useful to be able to base a
function input off a prototype that you are for example using as
testing. This function generates an
[`interfacer::iface`](https://ai4ci.github.io/interfacer/reference/iface.md)
specification for the supplied data frame and copies it to the clipboard
so that it can be pasted into the package code you are working on.

## Usage

``` r
iclip(df, df_name = deparse(substitute(df)))
```

## Arguments

- df:

  a prototype dataframe

- df_name:

  an optional name for the parameter (defaults to `i_<df name>`)

## Value

nothing, populates clipboard

## Details

If the dataframe contains one or more list columns with nested
dataframes the nested dataframes are also defined using a second `iface`
specification.

## Examples

``` r
if (interactive()) iclip(iris)
```
