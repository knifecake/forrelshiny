library(shiny)
library(gezellig)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  # Load pedigrees
  ped_claim <- reactive({
    validate(need(input$ped_claim_file, "Please select a claim pedigree"))

    p <- custom_read_ped(input$ped_claim_file$datapath)

    # attach allele frequencies
    p <- custom_ped_set_markers(p, frequency_db())

    # update marker settings table
    update_ti(session, "marker_settings",
              fields = mst_fields,
              data = get_marker_settings_table(p))

    p
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

  # Load frequency database
  frequency_db <- reactive({
    ft <- callModule(fafreqs_widget, "frequency_db")

    if (isTruthy(ft())) {
      normalise(ft())
    }
  })

  # Marker settings table
  marker_settings <- reactive({
    mst <- callModule(ti, "marker_settings", mst_fields, data.frame())
  })
})

mst_fields <- list(ti_label("Marker"),
                   ti_dropdown("Mutations", c("Auto" = "auto",
                                              "On" = "on",
                                              "Off" = "off")),
                   ti_radio("Sex-linked?", c("Autosomal" = 0,
                                             "X chrom" = 23)),
                   ti_checkbox("Include in calculation?"))
