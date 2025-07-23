test_that("@iparam generates an entry", {
  out <- roxygen2::roc_proc_text(
    roxygen2::rd_roclet(),
    "
    #' Bar
    #'
    #' @iparam df A test dataframe
    bar <- function(df = interfacer::iface(
      x = integer ~ \"The X column\",
      y = double ~ \"The Y column\",
      .groups = ~ x
    )) {}

  "
  )

  out = format(out$bar.Rd)

  # I expect to see here the foo dot params documented

  lapply(
    c(
      "\\item{df}{A test dataframe",
      "\\item x (integer) - The X column",
      "\\item y (double) - The Y column",
      "Must be grouped by: x (exactly)."
    ),
    function(.x) {
      expect(
        stringr::str_detect(out, stringr::fixed(.x)),
        paste0("could not find documentation string: ", .x)
      )
    }
  )
})


test_that("@ireturn generates an entry", {
  out <- roxygen2::roc_proc_text(
    roxygen2::rd_roclet(),
    "
    #' Bar
    #'
    #' @ireturn A test dataframe
    bar <- function() {
      ireturn(
        df,
        interfacer::iface(
          x = integer ~ \"The X column\",
          y = double ~ \"The Y column\",
      ))
    }
  "
  )

  out = format(out$bar.Rd)

  # I expect to see here the foo dot params documented

  lapply(
    c(
      "\\value{",
      "A test dataframe",
      "\\item x (integer) - The X column",
      "\\item y (double) - The Y column"
    ),
    function(.x) {
      expect(
        stringr::str_detect(out, stringr::fixed(.x)),
        paste0("could not find documentation string: ", .x)
      )
    }
  )
})


test_that("@iparam grouping resolved by igroup_process call", {
  out <- roxygen2::roc_proc_text(
    roxygen2::rd_roclet(),
    "
    #' Bar
    #'
    #' @iparam df A test dataframe
    bar = function(df = interfacer::iface(
      x = integer ~ \"The X column\",
      y = double ~ \"The Y column\",
      .groups = ~ x
    )) {
      interfacer::igroup_process(df)
    }

  "
  )

  out = format(out$bar.Rd)

  # I expect to see here the foo dot params documented

  lapply(
    c(
      "\\item{df}{A test dataframe",
      "\\item x (integer) - The X column",
      "\\item y (double) - The Y column",
      "Minimally grouped by: x (and other groupings allowed)."
    ),
    function(.x) {
      expect(
        stringr::str_detect(out, stringr::fixed(.x)),
        paste0("could not find documentation string: ", .x)
      )
    }
  )
})
