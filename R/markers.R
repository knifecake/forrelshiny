#' Generate marker settings table from a pedigree
#'
#' @param x a \code{\link[pedtools]{ped}} object or a list of such. If given a
#'   list it only considers marker data in the first component.
#'
#' @return a \code{data.frame} with the columns Marker, Mutations, Sex-linked?
#'   and Include in calculation? derived from the marker metadata in the
#'   pedigree
#'
#' @export
get_marker_settings_table <- function(x) {
  if (pedtools::is.pedList(x))
    get_marker_settings_table(x[[1]])
  else {
    markers <- unlist(lapply(x$MARKERS, pedtools::name))
    mutations <- replicate(length(markers), "auto")
    sex_linked <- unlist(lapply(x$MARKERS,
                                function(m) { !is.na(pedtools::chrom(m)) && pedtools::chrom(m) == 23 }))
    included <- replicate(length(markers), TRUE)

    data.frame(
      "Marker" = markers,
      "Mutations" = mutations,
      `Sex-linked?` = sex_linked,
      `Include in calculation?` = included,
      check.names = FALSE
    )
  }
}
