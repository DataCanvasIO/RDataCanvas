% Generated by roxygen2 (4.0.2): do not edit by hand
\name{DCRuntime}
\alias{DCRuntime}
\title{\code{DCRuntime} will parse and extract Input/Output/Paramter, and return
in S3 object.}
\usage{
DCRuntime(spec_json = "spec.json", zetrt_json = NULL, args = NULL)
}
\arguments{
\item{spec_json}{The path for "spec.json".}

\item{zetrt_json}{The path for "zetrt.json". The default is NULL, which
means we can get it from system environment variable "ZETRT".}

\item{args}{The arguments for Input/Output with format like "A=1". The default is
NULL, which means we can get it from command line arguments with "commandArgs".}
}
\value{
A S3 object.
}
\description{
This function will create a runtime object(in S3) for module.
In order to create a DCRuntime object, we should provide the following items:
\describe{
  \item{\emph{spec.json}}{which defines the inputs/outputs/parameters of the module.}
  \item{\emph{zetrt.json}}{the parameters at runtime.}
  \item{\emph{arguments}}{the arguments from command line. In the format, like "A=1".}
}
}
\examples{
\dontrun{example to use DCRuntime
  rt <- DCRuntime(spec_json = "/your_path/spec.json",
                      zetrt_json = "/some_path/zetrt.json")
  # Use "rt" like this:
  rt$Output$o1$Val
  rt$Input$i1$Val
  rt$Param$P1$Val
}
}
\seealso{
See \href{http://screwjack.readthedocs.org/en/latest/}{Screwjack} about
  howto create a module.
}

