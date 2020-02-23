#' Generate marker settings table from a pedigree
#'
#' @param x a \code{\link[pedtools]{ped}} object or a list of such. If given a
#'   list it only considers marker data in the first component.
#' @param included_markers a list of markers which will be included in the calculation
#' @param mutation_settings a list of mutation models corresponding to each marker
#' @param allele_counts a list of the number of alleles that each marker may take
#' @param simulation_threshold the number of alleles after which calculations are simulated
#'
#' @return a \code{data.frame} with the columns Marker, Mutations, Sex-linked?
#'   and Include in calculation? derived from the marker metadata in the
#'   pedigree
#'
#' @export
get_marker_settings_table <- function(x, included_markers, mutation_settings, allele_counts, simulation_threshold) {
  if (pedtools::is.pedList(x))
    x = x[[1]]

  markers <- get_marker_names(x)
  mutations <- mutation_settings  # replicate(length(markers), "auto")
  sex_linked <- unlist(lapply(x$MARKERS, pedtools::chrom))
  included <- included_markers # replicate(length(markers), TRUE)
  comments <- unlist(lapply(allele_counts, function(n) {
    if (n > simulation_threshold) {
      "Will be simulated."
    } else {
      ""
    }
  }))

  data.frame(
    "Marker" = markers,
    "Mutations" = mutations,
    `Sex-linked?` = sex_linked,
    `Include in calculation?` = included,
    "Comments" = comments,
    check.names = FALSE
  )
}


#' Apply marker settings to a pedigree
#'
#' @param x a \code{\link[pedtools]{ped}} object or a list of such
#' @param mst a \code{data.frame} with the structure of a marker settings table
#'
#' @return an updated version of \code{x} to reflect the applied settings
#' @export
apply_marker_settings <- function(x, mst) {
  if (pedtools::is.pedList(x)) {
    lapply(x, function(p) {
      apply_marker_settings(p, mst)
    })
  } else {
    for (i in 1:nrow(mst)) {
      x <- pedtools::setLocusAttributes(x,
                                        markers = c(mst[i, "Marker"]),
                                        locusAttributes = list(
                                          chrom = mst[i, "Sex-linked?"]))
    }

    x
  }
}

#' Get a list of marker names from a pedigree
#'
#' @param x a \code{\link[pedtools]{ped}} object or a list of such
#'
#' @return a character vector containing the names of the markers attached to
#'   \code{x}. If \code{x} is a list of pedigrees, only the markers attached to
#'   the first component are used.
#' @export
get_marker_names <- function(x) {
  if (pedtools::is.pedList(x)) {
    x = x[[1]]
  }

  unlist(lapply(x$MARKERS, pedtools::name))
}
