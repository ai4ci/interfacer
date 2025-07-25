% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/interfacer.R
\name{itest}
\alias{itest}
\title{Test dataframe conformance to an interface specification.}
\usage{
itest(df = NULL, iface = NULL, .imap = imapper())
}
\arguments{
\item{df}{a dataframe to test. If missing the first parameter of the calling
function is assumed to be the dataframe to test.}

\item{iface}{an interface specification produced by \code{iface()}. If missing
this will be inferred from the current function signature.}

\item{.imap}{an optional mapping specification produced by \code{imapper()}}
}
\value{
TRUE if the dataframe is conformant, FALSE otherwise
}
\description{
\code{ivalidate} throws errors deliberately however sometimes dealing with invalid
input may be desirable. \code{itest} is generally designed to be used within a function which
specifies the expected input using \code{iface}, and allows the function to test if
its given input is conformant to the interface.
}
\examples{
if (rlang::is_installed("ggplot2")) {
  i_diamonds = iface(
    color = enum(D,E,F,G,H,I,J,extra) ~ "the colour",
    price = integer ~ "the price"
  )

  # Ad hoc testing
  itest(ggplot2::diamonds, i_diamonds)

  # Use within function:
  x = function(df = i_diamonds) {
    if(itest()) message("PASS!")
  }

  x(ggplot2::diamonds)
}
}
\concept{interface}
