# Specify mappings that can make dataframes compatible with an `iface` specification

When a function uses
[`ivalidate()`](https://ai4ci.github.io/interfacer/reference/ivalidate.md)
internally to check a dataframe conforms to the input it can attempt to
rescue an incorrectly formatted dataframe. This is a pretty advanced
idea and is not generally recommended.

## Usage

``` r
imapper(...)
```

## Arguments

- ...:

  a set of
  [`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html)
  specifications that when applied to a dataframe will rename or
  otherwise fix missing columns

## Value

a set of mappings

## Details

This function is expected to be used only in the context of a
`.imap = imapper(...)` parameter to an
[`ivalidate()`](https://ai4ci.github.io/interfacer/reference/ivalidate.md)
call to make sure that certain columns are present or are a set value.
Anything provided here will overwrite existing dataframe columns and its
use is likely to make function behaviour obtuse. It may be deprecated in
the future. The `...` input expressions should almost certainly check
for the values already existing before overwriting them.

If you are considering using this for replacing missing values check
using the `default(...)` `iface` type definition instead.

## Examples

``` r
x = function(df = iface(col1 = integer ~ "an integer column" ), ...) {
  df = ivalidate(df,...)
}
input=tibble::tibble(col2 = c(1,2,3)) 
# This fails because col1 is missing
try(x(input))
#> Error : missing columns in the `df` parameter of `x(...)`.
#> missing: col1
#> consider renaming / creating missing columns before calling `x(...)`
#> 
# This fixes it for this input
x(input, .imap=imapper(col1 = col2))
```
