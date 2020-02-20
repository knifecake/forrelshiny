#' Plot a pedigree (list) for the forrel GUI
#'
#' @param x a \code{\link[pedtools]{ped}} object or a list of such
#'
#' @seealso \code{\link[pedtools]{plotPedList}}
#'
#' @export
custom_ped_plot <- function(x) {
  pedtools::plotPedList(x)
}


#' Read a pedigree from a file for the forrel GUI
#'
#' Wraps a \code{\link[pedtools]{readPed}} call so that invalid pedigree files don't make shiny crash.
#'
#' @param filepath the path to the pedigree file
#'
#' @return a \code{\link[pedtools]{ped}} object or a list of such
#'
#' @seealso \code{\link[pedtools]{readPed}}
#'
#' @export
custom_read_ped <- function(filepath) {
  p <- tryCatch(pedtools::readPed(filepath),
                error = function(e) { FALSE })

  shiny::validate(shiny::need(p, "Invalid pedigree file"))

  p
}
