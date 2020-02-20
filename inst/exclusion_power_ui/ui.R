pedigree_tab <- tabPanel('Pedigrees')

data_tab <- tabPanel('Data')

markers_tab <- tabPanel('Markers')

results_tab <- tabPanel('Results')


shinyUI(fluidPage(
  titlePanel("Exclusion power"),

  tabsetPanel(
    pedigree_tab,
    data_tab,
    markers_tab,
    results_tab
  )
))
