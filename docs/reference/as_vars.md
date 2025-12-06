# Reuse tidy-select syntax outside of a tidy-select function

Reuse tidy-select syntax outside of a tidy-select function

## Usage

``` r
as_vars(tidyselect, data = NULL)
```

## Arguments

- tidyselect:

  a tidyselect syntax which will be evaluated in context by looking for
  a call in the call stack that includes a dataframe as the first
  argument

- data:

  (optional) a specific dataframe with which to evaluate the tidyselect

## Value

a list of symbols resulting from the evaluation of the tidyselect in the
context of the current call stack (or a provided data frame)
