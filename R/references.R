#' Import Familias case data
#'
#' @param x a \code{\link[pedtools]{ped}} object or a list of such
#' @param file a path to a Familias case data file
#'
#' @return an updated version of \code{x} with provided genotypes attached
#' @export
read_familias_case_data <- function(x, file) {
  if (pedtools::is.pedList(x)) {
    return(lapply(x, function(p) {
      read_familias_case_data(p, file)
    }))
  }

  df <- read.table(file,
                  sep = '\t',
                  header = T,
                  row.names = 1,
                  as.is = T,
                  check.names = F)


  ids = intersect(rownames(df), labels(x))
  markers = intersect(rtrim(colnames(df), 2), get_marker_names(x))
  relevant_alleles <- df[ids, rtrim(colnames(df), 2) %in% markers]

  pedtools::setAlleles(x,
                       ids = ids,
                       markers = markers,
                       alleles = relevant_alleles)
}

#' Read case data (in the generic format)
#'
#' @param x a \code{\link[pedtools]{ped}} object or a list of such
#' @param file filename of an appropriate CSV file
#' @param ... further parameters passed to \code{read.table}
#'
#' @return an updated version of \code{x} with the provided genotypes attached
#'
#' @importFrom utils read.table
#'
#' @export
read_generic_case_data <- function(x, file, ...) {
  if (pedtools::is.pedList(x)) {
    return(lapply(x, function(p) {
      read_generic_case_data(x, file, ...)
    }))
  }

  df <- read.table(file, ...)

  markers <- unique(df[,2])

  for (mname in markers) {
    # find df rows concerning the current marker
    relevant = df[df[, 2] == mname, ]
    for (person in relevant[, 1]) {
      if (person %in% labels(x)) {
        alleles <- c(relevant[relevant[, 1] == person, 3],
                     relevant[relevant[, 1] == person, 4])
        x <- pedtools::setAlleles(x,
                                  ids = person,
                                  markers = mname,
                                  alleles = alleles)
      }
    }
  }

  x
}

#' Trim a string from the right
#'
#' @param xs a string or character vector
#' @param nchars the number of characters to remove (must be non-negative)
#' @export
#'
#' @examples
#' rtrim("hello", 2) == "hel"
#'
#' rtrim("hello", 10) == ""
#'
#' rtrim("hello", 0) == "hello"
#'
#' rtrim(c("hello", "bye"), 1) == c("hell", "by")
rtrim <- function(xs, nchars) {
  lapply(xs, function(x) { substr(x, 1, nchar(x) - nchars) })
}
