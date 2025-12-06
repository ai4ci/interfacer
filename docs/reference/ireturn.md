# Validate and return a value from a function

This is intended to be used within a function to check the validity of a
data frame being returned from a function against the provided `iface`
specification.

## Usage

``` r
ireturn(df, iface, .prune = FALSE)
```

## Arguments

- df:

  a dataframe - if missing then the first parameter of the calling
  function is assumed to be a dataframe.

- iface:

  the interface specification that `df` should conform to.

- .prune:

  get rid of excess columns that are not in the specification.

## Value

a dataframe based on `df` with validity checks passed, data-types
coerced, and correct grouping applied to conform to `iface`

## Details

As checks on output files can be unnecessary they are only run in
certain circumstances:

`interfacer::ireturn()` checks run if:

- an option is set: `options(interfacer.always_check=TRUE)`.

- we are locally developing a package and running functions in smoke
  testing e.g. with
  [`devtools::load_all()`](https://devtools.r-lib.org/reference/load_all.html).

- we are developing functions in the global environment.

- we are running functions in a `testthat` or R CMD check.

- we are running functions in a vignette during a R CMD check.

- we are running functions in a R markdown file (e.g. vignette)
  interactively in RStudio.

checks are not run if:

- package referencing `interfacer::ireturn` is installed from CRAN or
  r-universe

- package referencing `interfacer::ireturn` is installed locally using
  [`devtools::install`](https://devtools.r-lib.org/reference/install.html)

- vignette building directly using `knitr` (unless option is set in
  vignette).

- vignette building using
  [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html).

## Examples

``` r
input = iface(col_in = integer ~ "an integer column" )
output = iface(col_out = integer ~ "an integer column" )

x = function(df = input, ...) {
  df = ivalidate(...)
  tmp = df %>% dplyr::rename(col_out = col_in)
  ireturn(tmp, output)
  stop("not executed as function has returned")
}
x(tibble::tibble(col_in = c(1,2,3)))
#> # A tibble: 3 × 1
#>   col_out
#> *   <int>
#> 1       1
#> 2       2
#> 3       3
output
#> A dataframe containing the following columns: 
#> * col_out (integer) - an integer column
#> Any grouping allowed.
```
