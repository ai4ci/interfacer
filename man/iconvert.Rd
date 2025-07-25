% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/interfacer.R
\name{iconvert}
\alias{iconvert}
\title{Convert a dataframe to a format compatible with an interface specification}
\usage{
iconvert(
  df,
  iface,
  .imap = interfacer::imapper(),
  .dname = "<unknown>",
  .fname = "<unknown>",
  .has_dots = TRUE,
  .prune = FALSE,
  .env = rlang::current_env()
)
}
\arguments{
\item{df}{the dataframe to convert}

\item{iface}{the interface spec as an \code{iface}}

\item{.imap}{an optional \code{imapper} mapping}

\item{.dname}{the name of the parameter value (optional).}

\item{.fname}{the name of the function (optional).}

\item{.has_dots}{internal library use only. Changes the nature of the error message.}

\item{.prune}{do you want to remove non matching columns?}

\item{.env}{internal use only}
}
\value{
the input dataframe coerced to be conformant to the \code{iface}
specification, or an informative error is thrown.
}
\description{
This function is called by \code{\link[=ivalidate]{ivalidate()}} and is not generally intended to be
used directly by the end user. It may be helpful in debugging during package
development to interactive test a \code{iface} spec. \code{iconvert} is an interactive
version of \code{\link[=ivalidate]{ivalidate()}}.
}
\examples{
i_diamonds = iface(
  color = enum(D,E,F,G,H,I,J,extra) ~ "the colour",
  price = integer ~ "the price"
)

iconvert(ggplot2::diamonds, i_diamonds,.prune = TRUE)


}
\concept{interface}
