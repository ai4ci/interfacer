# interfacer <a href="https://ai4ci.github.io/interfacer/"><img src="man/figures/logo.svg" align="right" height="139" alt="interfacer website" /></a>

<!-- badges: start -->
[![R-CMD-check](https://github.com/ai4ci/interfacer/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ai4ci/interfacer/actions/workflows/R-CMD-check.yaml)
[![DOI](https://zenodo.org/badge/896003024.svg)](https://doi.org/10.5281/zenodo.14794614)
[![interfacer status badge](https://ai4ci.r-universe.dev/badges/interfacer)](https://ai4ci.r-universe.dev)
[![CRAN status](https://www.r-pkg.org/badges/version/interfacer)](https://CRAN.R-project.org/package=interfacer)
[![metacran downloads](https://cranlogs.r-pkg.org/badges/last-week/interfacer)](https://cran.r-project.org/package=interfacer)
[![EPSRC badge](https://img.shields.io/badge/EPSRC%20grant-EP%2FY028392%2F1-05acb5)](https://gow.epsrc.ukri.org/NGBOViewGrant.aspx?GrantRef=EP/Y028392/1)
<!-- badges: end -->

`interfacer` is primarily aimed at R package developers. It provides a framework
for specifying the structure of dataframes as parameters for user functions and
checking that user supplied dataframes conform to expectations. Missing columns
or incorrectly typed columns can be identified and useful error messages
returned. Specifying structure is part of the function definition and can be
automatically included in `roxygen2` documentation.

## Installation

You can install the released version of `interfacer` from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("interfacer")
```

Most likely though you will be including this in another package via a
DESCRIPTION file:

```yaml
...
Imports: 
    tidyverse,
    interfacer
Suggests: 
    knitr,
    rmarkdown
...
```

This development versions of the package are hosted in the [AI4CI
r-universe](https://ai4ci.r-universe.dev/).
Installation from there is as follows:

``` r
options(repos = c(
  "ai4ci" = 'https://ai4ci.r-universe.dev/',
  CRAN = 'https://cloud.r-project.org'))

# Download and install interfacer in R
install.packages("interfacer")
```

Or via a DESCRIPTION file:

```yaml
...
Imports: 
    tidyverse,
    interfacer
Remotes: github::ai4ci/interfacer
Suggests: 
    knitr,
    rmarkdown
...
```

You can also install the development version of interfacer from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ai4ci/interfacer")
```

## Example

`interfacer` is used within a function definition in a package to 
constrain the input of a function to be a particular shape. The `@iparam`
annotation will generate documentation which explains the expected dataframe 
format.

```r
#' An example function
#'
#' @iparam mydata a test dataframe input parameter
#' @param another an example other input parameter  
#' @param ... not used
#'
#' @return ... something not yet defined ...
#' @export
example_fn = function(
  
  # this parameter will be a dataframe with id and test columns
  # id will be a unique integer, and test a logical value
  mydata = interfacer::iface(
    id = integer + group_unique ~ "an integer ID",
    test = logical + default(FALSE) ~ "the test result"
  ),
  
  another = "value",
  ...
  
) {
  
  # this line enforces the `iface` rules for the dataframe, coercing columns
  # if possible and throwing helpful errors if not.
  mydata = interfacer::ivalidate(mydata, ...)
  
  # rest of function body can use `mydata` in the certain knowledge that
  # id is a unique integer and test is a logical value...
}
```

When calling this function, column name, data type and grouping structure checks
are made on the input and informative errors thrown if the input is incorrectly
specified.

`interfacer` also includes tools to help developers adopt `iface` specifications
by generating them from example data, and for documenting dataframes bundled in
a package.

## Funding

The authors gratefully acknowledge the support of the UK Research and Innovation
AI programme of the Engineering and Physical Sciences Research Council [EPSRC
grant EP/Y028392/1](https://gow.epsrc.ukri.org/NGBOViewGrant.aspx?GrantRef=EP/Y028392/1).
