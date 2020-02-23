#' Plot a pedigree (list) for the forrel GUI
#'
#' @param x a \code{\link[pedtools]{ped}} object or a list of such
#' @param available a list of individuals available for genotyping (will be red)
#'
#' @seealso \code{\link[pedtools]{plotPedList}}
#'
#' @importFrom graphics plot
#'
#' @export
custom_ped_plot <- function(x, available = c()) {
  genotyped <- get_genotyped_ids(x)

  if (pedtools::is.pedList(x)) {
    plot_arg_list <- lapply(x, function(p) {
      list(x = p,
           col = list(red = intersect(available, labels(p))),
           shaded = intersect(genotyped, labels(p)))
    })
    pedtools::plotPedList(plot_arg_list,
                          frames = FALSE)
  } else {
    plot(x,
         col = list(red = intersect(available, labels(x))),
         shaded = intersect(genotyped, labels(x)))
  }
}


#' Read a pedigree from a file for the forrel GUI
#'
#' Wraps a \code{\link[pedtools]{readPed}} call so that invalid pedigree files
#' don't make shiny crash.
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

#' Get pedigree labels
#'
#' Same as \code{\link[pedtools]{relabel}} but works on pedigree lists
#'
#' @param x a \code{\link[pedtools]{ped}} object or a list of such
#'
#' @return a character vector containing the ID labels of all pedigree members
#'
#' @seealso \code{\link[pedtools]{relabel}}
#'
#' @export
custom_ped_labels <- function(x) {
  if (pedtools::is.pedList(x))
    as.character(unlist(lapply(x, custom_ped_labels)))
  else
    labels(x)
}

#' Get genotyped individuals in a pedigree
#'
#' @param x a \code{\link[pedtools]{ped}} object or a list of such
#'
#' @return a character vector containing the ID labels of all genotyped pedigree
#'   members
#'
#' @export
get_genotyped_ids <- function(x) {
  if (pedtools::is.pedList(x)) {
    as.character(unlist(lapply(x, get_genotyped_ids)))
  } else {
    ids <- labels(x)
    ids[as.vector(lapply(ids, function(id) { is_genotyped(x, id) }),
                  mode = "logical")]
  }
}

is_genotyped <- function(x, id) {
  any(!is.na(pedtools::getAlleles(x, ids = c(id))))
}

#' Attach markers metadata to pedigree
#'
#' @param x a \code{\link[pedtools]{ped}} object or a list of such
#' @param freqt a \code{\link[fafreqs]{freqt}} object
#'
#' @return the pedigree (or pedList) with the specified markers attached
#' @export
custom_ped_set_markers <- function(x, freqt) {
  if (pedtools::is.pedList(x)) {
    lapply(x, function (p) {
      custom_ped_set_markers(p, freqt)
    })
  } else {
    pedtools::setMarkers(x, locusAttributes = fafreqs::to_pedtools_locusAttributes(freqt))
  }
}
