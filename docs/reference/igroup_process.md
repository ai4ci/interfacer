# Handle unexpected additional grouping structure

This function is designed to be used by a package author within an
enclosing function. The enclosing function is assumed to take as input a
dataframe and have an `iface` specified for that dataframe.

## Usage

``` r
igroup_process(df = NULL, fn, ..., .iface = NULL)
```

## Arguments

- df:

  a dataframe from an enclosing function in which the grouping may or
  may not have been correctly supplied.

- fn:

  a function to call with the correctly grouped dataframe as specified
  by the `iface` in the enclosing function. This must be a function (not
  a `purrr` style lambda) and share parameter naming with the enclosing
  function. The first parameter of this dispatch function must be the
  dataframe (correctly grouped), and other named parameters here are
  looked for in the enclosing function call. The function *must* return
  a dataframe.

- ...:

  passed onto `iconvert` this could be used to supply `.prune`
  parameters. triple dot parameters in the enclosing function will be
  separately handled and automatically passed to `fn` so in general
  should not be passed to `igroup_process` as an intermediary although
  it probably won't hurt. This behaviour is similar to `NextMethod` in
  S3 method dispatch.

- .iface:

  experimental feature to override the detection of the data from the
  enclosing function and use a directly supplied one. This can be useful
  if you want to process a dataframe by grouping defined by some
  criteria supplied at runtime.

## Value

the result of calling `fn(df, ...)` on each unexpected group

## Details

This function detects when the grouping of the input has additional
groups over and above those in the specification and intercepts them,
regrouping the dataframe and applying `fn` group-wise using an
equivalent of a
[`dplyr::group_modify`](https://dplyr.tidyverse.org/reference/group_map.html).
The parameters provided to the enclosing function will be passed to `fn`
and they should have compatible method signatures.

## Examples

``` r
# This specification requires that the dataframe is grouped only by the color
# column
i_diamond_price = interfacer::iface(
  color = enum(`D`,`E`,`F`,`G`,`H`,`I`,`J`, .ordered=TRUE) ~ "the color column",
  price = integer ~ "the price column",
  .groups = ~ color
)

# An example function which would be exported in a package
# This function expects a dataframe with a colour and price column, grouped
# by price.
mean_price_by_colour = function(df = i_diamond_price, extra_param = ".") {

  # When called with a dataframe with extra groups `igroup_process` will
  # regroup the dataframe according to the structure
  # defined for `i_diamond_price` and apply the inner function to each group
  # after first calling `ivalidate` on each group.

  igroup_process(df,

    # the real work of this function is provided as an anonymous inner
    # function (but can be any other function e.g. package private function
    # but not a purrr style lambda). Ideally this function parameters are named the
    # same as the enclosing function (here `ex_mean(df,extra_param)`), however
    # there is some flexibility here. The special `.groupdata` parameter will
    # be populated with the values of the unexpected grouping.

    function(df, extra_param, .groupdata) {
      message(extra_param, appendLF = FALSE)
      if (nrow(.groupdata) == 0) message("zero length group data")
      return(df %>% dplyr::summarise(mean_price = mean(price)))
    }

  )
}

# The correctly grouped dataframe. The `ex_mean` function calculates the mean
# price for each `color` group.
ggplot2::diamonds %>%
  dplyr::group_by(color) %>%
  mean_price_by_colour(extra_param = "without additional groups...") %>%
  dplyr::glimpse()
#> without additional groups...
#> zero length group data
#> Rows: 7
#> Columns: 2
#> $ color      <ord> D, E, F, G, H, I, J
#> $ mean_price <dbl> 3169.954, 3076.752, 3724.886, 3999.136, 4486.669, 5091.875,…

# If an additionally grouped dataframe is provided by the user. The `ex_mean`
# function calculates the mean price for each `cut`,`clarity`, and `color`
# combination.

ggplot2::diamonds %>%
  dplyr::group_by(cut, color, clarity) %>%
  mean_price_by_colour() %>%
  dplyr::glimpse()
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> .
#> Rows: 276
#> Columns: 4
#> Groups: cut, clarity [40]
#> $ cut        <ord> Fair, Fair, Fair, Fair, Fair, Fair, Fair, Fair, Fair, Fair,…
#> $ clarity    <ord> I1, I1, I1, I1, I1, I1, I1, SI2, SI2, SI2, SI2, SI2, SI2, S…
#> $ color      <ord> D, E, F, G, H, I, J, D, E, F, G, H, I, J, D, E, F, G, H, I,…
#> $ mean_price <dbl> 7383.000, 2095.222, 2543.514, 3187.472, 4212.962, 3501.000,…

# The output of this is actually grouped by cut then clarity as
# color is consumed by the `igroup_dispatch`.

# This example is somewhat contorted. The real power of `igroup_process` is
# if it is used recursively:

recursive_example = function(df = i_diamond_price) {

  # call main function recursively if additional groups detected
  igroup_process(df, recursive_example)
  # N.B. this also works if the second argument is omitted e.g.:
  # igroup_process(df)

  # otherwise proceed with function as normal
  return(tibble::tibble("rows detected:"=nrow(df)))
}

ggplot2::diamonds %>% dplyr::group_by(color) %>%
   recursive_example() %>%
   dplyr::glimpse()
#> Rows: 1
#> Columns: 1
#> $ `rows detected:` <int> 53940
ggplot2::diamonds %>% dplyr::group_by(cut,clarity,color) %>%
   recursive_example() %>%
   dplyr::glimpse()
#> Rows: 40
#> Columns: 3
#> Groups: cut, clarity [40]
#> $ cut              <ord> Fair, Fair, Fair, Fair, Fair, Fair, Fair, Fair, Good,…
#> $ clarity          <ord> I1, SI2, SI1, VS2, VS1, VVS2, VVS1, IF, I1, SI2, SI1,…
#> $ `rows detected:` <int> 210, 466, 408, 261, 170, 69, 17, 9, 96, 1081, 1560, 9…
```
