# Generate interfacer code for a dataframe

Generating and documenting an `iface` for a given dataframe would be
time consuming and annoying if you could not do it automatically. In
this case as you interactively develop a package using a test dataframe,
the structure of which can be explicitly documented and made into a
specific contract within the package. This supports development using
test dataframes as a prototype for function ensuring future user input
conforms to the same expectations as the test data.

## Usage

``` r
use_iface(
  df,
  name = deparse(substitute(df)),
  output = "R/interfaces.R",
  use_as_default = FALSE,
  pkg = "."
)
```

## Arguments

- df:

  the data frame to use

- name:

  the name of the variable you wish to use (defaults to whatever the
  dataframe was called)

- output:

  where within the current package to write data documentation code
  (defaults to `R/interfaces.R`)

- use_as_default:

  if this is set to true the current dataframe is saved as package data
  and the
  [`interfacer::iface`](https://ai4ci.github.io/interfacer/reference/iface.md)
  specification is created referring to the package copy of the current
  dataframe as the default value.

- pkg:

  the package (defaults to current)

## Value

nothing, used for side effects.

## Examples

``` r
# example code
if (interactive()) {
  # This is not run as it is designed for interactive use only and will
  # write to the userspace after checking that is what the user wants.
  use_iface(iris)
}
```
