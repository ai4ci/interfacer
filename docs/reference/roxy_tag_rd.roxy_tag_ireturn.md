# Support for `@ireturn` tags

The `@ireturn <description>` tag can be used in `roxygen2` documentation
of a function to describe a dataframe return value. The function must be
using
[`interfacer::ireturn`](https://ai4ci.github.io/interfacer/reference/ireturn.md)
to validate the output dataframe parameter format. The `@ireturn` tag
will then generate documentation about the type of dataframe the
function is returning.

## Usage

``` r
# S3 method for class 'roxy_tag_ireturn'
roxy_tag_rd(x, base_path, env)
```

## Arguments

- x:

  The tag

- base_path:

  Path to package root directory.

- env:

  Environment in which to evaluate code (if needed)

## Value

an
[`roxygen2::rd_section`](https://roxygen2.r-lib.org/reference/rd_section.html)
(see `roxygen2` documentation)

## Examples

``` r
# An example function definition:
fn_definition <- "
#' This is a title
#'
#' This is the description.
#'
#' @md
#' @ireturn the output dataframe
#' @export
f <- function() {
  interfacer::ireturn(iris,
    interfacer::iface(
      Sepal.Length = numeric ~ \"the Sepal.Length column\",
      Sepal.Width = numeric ~ \"the Sepal.Width column\",
      Petal.Length = numeric ~ \"the Petal.Length column\",
      Petal.Width = numeric ~ \"the Petal.Width column\",
      Species = enum(`setosa`,`versicolor`,`virginica`) ~ \"the Species column\",
      .groups = NULL
    ))
}
"

# For this example we manually parse the function specification in `fn_definition`
# creating a .Rd block - normally this is done by `roxygen2` which then
# writes this to an .Rd file. This function is not intended to be used
# outside of a call to `devtools::document`.

tmp = roxygen2::parse_text(fn_definition)
print(tmp[[1]])
#> <roxy_block> [<text>:9]
#>   $tag
#>     [line:  2] @title 'This is a title' {parsed}
#>     [line:  4] @description 'This is the description.' {parsed}
#>     [line:  6] @md '' {parsed}
#>     [line:  7] @ireturn 'the output dataframe' {parsed}
#>     [line:  8] @export '' {parsed}
#>     [line:  9] @usage '<generated>' {parsed}
#>     [line:  9] @.formals '<generated>' {unparsed}
#>     [line:  9] @backref '<generated>' {parsed}
#>   $call   f <- function() { ...
#>   $object <function> 
#>     $topic f
#>     $alias f
```
