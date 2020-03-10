library(shiny)
library(fafreqs)
library(gezellig)

pedigree_tab <- function() {
  tabPanel(
    title = "Pedigrees",
    fluidRow(
      column(
        width = 6,
        fileInput("ped_claim_file", "Claim pedigree", width = "100%")
      ),
      column(
        width = 6,
        fileInput("ped_true_file", "True pedigree", width = "100%")
      )
    )
  )
}

data_tab <- function() {
  tabPanel(
    title = "Data",
    fluidRow(
      ## Database
      column(
        width = 4,
        tags$h4("Frequency database"),
        textOutput("frequency_db_description"),
        helpText("The frequency database determines which for which markers the exclusion power will be calculated. You may define it using one of the three options below."),
        fafreqs_widget_input(
          "frequency_db",
          allow_marker_filtering = FALSE,
          allow_scaling = FALSE,
          allow_rare_allele = FALSE
        )
      ),

      ## Reference data
      column(
        width = 4,
        tags$h4("Reference data"),
        textOutput("reference_data_description"),
        helpText("Loading reference data will make the calculation conditional on it and thus faster."),
        fileInput("familias_reference_file",
                  "Load a familias case data file")
      ),

      ## Genotyped individuals
      column(
        width = 4,
        checkboxGroupInput(
          "available_for_genotyping",
          "Individuals available for genotyping"
        )
      )
    )
  )
}

markers_tab <- function() {
  tabPanel(
    title = "Markers",
    fluidRow(
      column(
        width = 12,
        ti_input("marker_settings")
      )
    )
  )
}

settings_tab <- function() {
  tabPanel(
    title = "Settings",
    fluidRow(
      column(
        width = 4,
        tags$h4("Simulation settings"),
        numericInput("simulation_threshold",
                     "Simulation threshold",
                     value = -1,
                     min = -1,
                     step = 1),
        helpText("The exclusion power for markers with more than this many alleles will be obtained by simulation, as opposed to an exact calculation. Enter -1 or leave empty to never simulate. You can go back to the 'Markers' tab to check which markers will be simulated."),
        numericInput("nsims",
                     "Number of simulations",
                     value = 10,
                     min = 1,
                     step = 1)
      )
    )
  )
}

results_tab <- function() {
  tabPanel(
    title = "Results",
    actionButton("calculate_button", "Calculate", class = "btn-primary"),
    verbatimTextOutput("ep_results_total"),
    tableOutput("ep_results")
  )
}


function(request) {
  fluidPage(
    title = "Exclusion power",
    fluidRow(
      column(8, h1("Exclusion power")),
      column(4, tags$h1(bookmarkButton("Save workspace", icon = icon("floppy-disk", lib = "glyphicon")),
                        class = "text-right"))
    ),
    sidebarLayout(
      mainPanel(
        tabsetPanel(
          pedigree_tab(),
          data_tab(),
          markers_tab(),
          settings_tab(),
          results_tab(),
          id = "tabs"
        )
      ),
      sidebarPanel(
        verticalLayout(
          tags$h5("Claim pedigree"),
          plotOutput("ped_claim_plot"),
          tags$h5("True pedigree"),
          plotOutput("ped_true_plot")
        )
      )
    ),
    includeCSS("www/forrelshiny.css")
  )
}
