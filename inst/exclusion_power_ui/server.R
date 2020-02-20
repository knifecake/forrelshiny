library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  # Load pedigrees
  ped_claim <- reactive({
    validate(need(input$ped_true_file, "Please select a claim pedigree"))

    custom_read_ped(input$ped_claim_file$datapath)
  })

  ped_true <- reactive({
    validate(need(input$ped_true_file, "Please select a true pedigree"))

    custom_read_ped(input$ped_true_file$datapath)
  })

  # Render pedigree plots
  output$ped_claim_plot <- renderPlot({
    custom_ped_plot(ped_claim())
  })

  output$ped_true_plot <- renderPlot({
    custom_ped_plot(ped_true())
  })
})
