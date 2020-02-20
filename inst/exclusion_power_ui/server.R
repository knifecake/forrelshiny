library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  # Load pedigrees
  ped_claim <- reactive({
    validate(need(input$ped_claim_file, "Please select a claim pedigree"))

    custom_read_ped(input$ped_claim_file$datapath)
  })

  ped_true <- reactive({
    validate(need(input$ped_true_file, "Please select a true pedigree"))

    custom_read_ped(input$ped_true_file$datapath)
  })

  # Render pedigree plots
  output$ped_claim_plot <- renderPlot({
    custom_ped_plot(ped_claim(), available = input$available_for_genotyping)
  })

  output$ped_true_plot <- renderPlot({
    custom_ped_plot(ped_true(), available = input$available_for_genotyping)
  })

  # Update individuals available for genotyping list
  observe({
    req(ped_claim())

    updateCheckboxGroupInput(session,
      "available_for_genotyping",
      choices = custom_ped_labels(ped_claim())
    )
  })
})
