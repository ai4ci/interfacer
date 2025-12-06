# Parser for `@iparam` tags

The `@iparam <name> <description>` tag can be used in `roxygen2`
documentation of a function to describe a dataframe parameter. The
function must be using
[`interfacer::iface`](https://ai4ci.github.io/interfacer/reference/iface.md)
to define the input dataframe parameter format. The `@iparam` tag will
then generate documentation about the type of dataframe the function is
expecting.

## Usage

``` r
# S3 method for class 'roxy_tag_iparam'
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
