# Tools to work with \`interfacer\`

## Automating `iface` specifications

Adopting `interfacer` for package functions can go hand in hand with
developing test data for the project. In this scenario a function that
relies on a specific dataframe format, can be defined using the test
data as a prototype to help generate the `iface` specification.

This is the role of `iclip` and `use_iface`. Suppose we wish to develop
a function that supports datasets in the same format as `mtcars` we can
use the `mtcars` dataset as a prototype by calling `iclip(mtcars)`. This
writes a `iface` specification to the clipboard. Pasting it gives us:

``` r
i_mtcars = interfacer::iface(
    mpg = numeric ~ "the mpg column",
    cyl = numeric ~ "the cyl column",
    disp = numeric ~ "the disp column",
    hp = numeric ~ "the hp column",
    drat = numeric ~ "the drat column",
    wt = numeric ~ "the wt column",
    qsec = numeric ~ "the qsec column",
    vs = numeric ~ "the vs column",
    am = numeric ~ "the am column",
    gear = numeric ~ "the gear column",
    carb = numeric ~ "the carb column",
    .groups = NULL
)
```

If we instead called `use_iface(mtcars)` this definition would be
written to the file `R/interfaces.R` (or the definition updated if it is
already present). `iface` specifications can be anywhere in the package
hierarchy but it does make some sense to keep them all in one file.
Interface specifications do not need to be exported from a package to
function (although they can be).

In both cases as the developer you will want to update the default
column description, if the `use_iface` function was used, care must be
taken to ensure changes you make will not be over written if `use_iface`
is called again. This is a question of removing the relevant comment in
`R/interfaces.R`

## Dataframe documentation

When using
[`usethis::use_data`](https://usethis.r-lib.org/reference/use_data.html)
to embed data in a package there is inevitably a reminder to document
your data. When you are embedding a dataframe `interfacer` can inspect
your dataframe and generate a template data documentation into
`R/data.R` at the same this as embedding the data to ease this pain.

This is triggered with a call to, for example,
`interfacer::use_dataframe(mtcars)` which will create an entry in
`R/data.R` for your dataframe documentation.

This function uses the `interfacer` framework to generate the
documentation but does not need it afterwards, so you can use this
without putting interfacer in your description file, if that is all you
want to use the package for.

## `roxygen2` documentation

`@iparam <name> <description>` tags can be used in the `roxygen2`
documentation of an `interfacer` enabled function. This enables
[`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
to automatically write the documentation for dataframe parameters. It
may require that you call
[`library(interfacer)`](https://ai4ci.github.io/interfacer/) before
running
[`devtools::document()`](https://devtools.r-lib.org/reference/document.html).
In this example, the `@iparam` tag will be expanded to include the
documentation of the expected input as defined in the `iface`
specification of the `df` parameter:

``` r
#' A function
#' 
#' @iparam df An input dataframe
#' @return ... something ...
test_function = function(df = interfacer::iface(col1 = integer ~ "An integer value")) {
  df = interfacer::ivalidate(df)
  # ... main function body ...
}
```

The `@iparam` tag picks the `iface` specification from the current
function and parameter. A more flexible alternative is provided by
[`idocument()`](https://ai4ci.github.io/interfacer/reference/idocument.md)
which allows you to specify the function and parameter you wish to
document. This is useful if documenting a generic function that may
dispatch to multiple functions based on the dataframe structures. In the
future we will try and automate this.

``` r
# This may be defined in the file R/interfaces.R
i_type1 = interfacer::iface(col1 = integer ~ "An integer value")
i_type2 = interfacer::iface(col1 = date ~ "A date value")

#' A multiple dispatch function
#' 
#' @param df An input dataframe conforming to one of:
#' `r interfacer::idocument(test_function.type1, df)`
#' or
#' `r interfacer::idocument(test_function.type2, df)` 
#'
#' @return ... something ...
test_function = function(df) {
  interfacer::idispatch(df,
    test_function.type1 = i_type1,
    test_function.type2 = i_type2
  )
}

test_function.type1 = function(df = i_type1) {
  # ... deal with integer input ...
}

test_function.type1 = function(df = i_type2) {
  # ... deal with date input ...
}
```

Return values using the `roxygen2` `@ireturn` tag that picks up format
definitions from the (first) call to `ireturn(value, spec)` in the
function body. This is then used to describe the format of the output
dataframe.

If, as in the previous example, the `iface` definitions are defined as
package local variables it is also possible to refer directly to these
variables in the documentation where they will be expanded to their
definition.

``` r
# This can be defined in another file such as R/interfaces.R
i_input_type = interfacer::iface(col1 = integer ~ "An integer value")
i_return_type = interfacer::iface(output = date ~ "A date value")

#' An example function
#' 
#' The parameter and return values will be expanded to describe the
#' input and output dataframe formats defined above.
#' 
#' @iparam df An input dataframe
#' @ireturn A description of the output dataframe
#' 
test_function = function(df = i_input_type) {
  df = interfacer::ivalidate(df)
  # ... main function body ...
  interfacer::ireturn( ...output... , i_return_type)
}
```
