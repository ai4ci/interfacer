# Determine whether context is in-development or deployed.

This function is used internally to decide whether to run
[`ireturn()`](https://ai4ci.github.io/interfacer/reference/ireturn.md)
checks

## Usage

``` r
.should_run_checks()
```

## Value

TRUE if we're not in an installed package, FALSE otherwise

## Details

[`interfacer::ireturn`](https://ai4ci.github.io/interfacer/reference/ireturn.md)
checks run if:

- the option is set: `options(interfacer.always_check=TRUE)`.

- we are locally developing a package and running functions in smoke
  testing.

- we are running a package function in `testthat`.

- we are developing functions in the global environment.

- we are running functions in a `testthat` or R CMD check.

- we are running functions in a vignette in a R CMD check.

- we are running functions in a vignette interactively.

checks are not run if:

- package referencing
  [`interfacer::ireturn`](https://ai4ci.github.io/interfacer/reference/ireturn.md)
  is installed from CRAN or r-universe

- package referencing
  [`interfacer::ireturn`](https://ai4ci.github.io/interfacer/reference/ireturn.md)
  is installed locally using
  [`devtools::install`](https://devtools.r-lib.org/reference/install.html)

- vignette building directly using `knitr` (unless option is set in
  vignette).

- vignette building using
  [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html).
