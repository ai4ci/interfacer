# Use a dataframe in a package including structure based documentation

Using the interfacer framework you can document data during development.
This provides the basic documentation framework for a dataset based on a
dataframe in the correct format into the right place.

## Usage

``` r
use_dataframe(
  df,
  name = deparse(substitute(df)),
  output = "R/data.R",
  pkg = "."
)
```

## Arguments

- df:

  the data frame to use

- name:

  the name of the variable you wish to use (defaults to whatever the
  function is called with)

- output:

  where to write data documentation code (defaults to `R/data.R`)

- pkg:

  the package (defaults to current)

## Value

nothing, used for side effects.

## Details

If this is your only use case for `interfacer` then you will not need to
import `interfacer` in your package, as none of the generated code will
depend on it.

## Examples

``` r
# example code
if (interactive()) {
  # This is not run as it is designed for interactive use only and will
  # write to the userspace after checking that is what the user wants.
  use_dataframe(iris)
}
```
