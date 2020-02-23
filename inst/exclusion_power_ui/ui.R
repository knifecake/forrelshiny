library(shiny)
library(fafreqs)
library(gezellig)

pedigree_tab <- tabPanel(
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

data_tab <- tabPanel(
  title = "Data",
  fluidRow(
    ## Database
    column(
      width = 4,
      tags$h4("Frequency database"),
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

markers_tab <- tabPanel(
  title = "Markers",
  fluidRow(
    column(
      width = 12,
      ti_input("marker_settings")
    )
  ))

results_tab <- tabPanel(
  title = "Results")


shinyUI(fluidPage(
  titlePanel("Exclusion power"),
  sidebarLayout(
    mainPanel(
      tabsetPanel(
        pedigree_tab,
        data_tab,
        markers_tab,
        results_tab
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
))
