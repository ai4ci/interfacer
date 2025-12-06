# Specify mappings that can make dataframes compatible with an interface

This function is expected to be used only in a `.imap = imap(...)`
context to overcome some mapping issues

## Usage

``` r
imap(...)
```

## Arguments

- ...:

  a set of
  [`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html)
  specifications that when applied to a dataframe will rename or
  otherwise fix missing columns

## Value

a set of mappings

## Examples

``` r
x = function(df = iface(col1 = integer ~ "an integer column" ), ...) {
  df = ivalidate(df,...)
}
input=tibble::tibble(col2 = c(1,2,3)) 
# This fails because col1 is missing
try(x(input))
#> Error in iconvert(df, spec, .imap, dname, .get_fn_name(fn), .has_dots,  : 
#>   1 missing columns in parameter `df` in call to x(...)
#> consider renaming to create `col1` columns
#> or by adding `.imap = interfacer::imap(`col1` = ???)` to your function call.
#> 
# This fixes it for this input
x(input, .imap=imap(col1 = col2))
```
