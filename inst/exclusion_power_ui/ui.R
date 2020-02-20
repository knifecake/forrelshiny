library(shiny)

pedigree_tab <- tabPanel(
  title = 'Pedigrees',
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

data_tab <- tabPanel('Data')

markers_tab <- tabPanel('Markers')

results_tab <- tabPanel('Results')


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
