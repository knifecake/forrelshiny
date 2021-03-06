#' GUI launcher
#'
#' Launches the Shiny-based graphical user interface for the exclusion power
#' functionality.
#'
#' @export
epGUI <- function() {
  shiny::runApp(system.file("exclusion_power_ui", package = "forrelshiny"))
}
