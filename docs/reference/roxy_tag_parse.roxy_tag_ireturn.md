# Parser for `@ireturn` tags

The `@ireturn <description>` tag can be used in `roxygen2` documentation
of a function to describe a dataframe return value. The function must be
using
[`interfacer::ireturn`](https://ai4ci.github.io/interfacer/reference/ireturn.md)
to define the output dataframe format. The `@ireturn` tag will then
generate documentation about the type of dataframe the function outputs.

## Usage

``` r
# S3 method for class 'roxy_tag_ireturn'
roxy_tag_parse(x)
```

## Arguments

- x:

  A tag

## Value

a `roxy_tag` object with the `val` field set to the parsed value

## Examples

``` r
# This provides support to `roxygen2` and only gets executed in the context
# of `devtools::document()`. There is no interactive use of this function.
```
