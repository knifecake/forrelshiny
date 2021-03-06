library(shiny)
library(gezellig)

mst_fields <- list(ti_label("Marker"),
                   ti_dropdown("Mutations", c("Auto" = "auto",
                                              "On" = "on",
                                              "Off" = "off")),
                   ti_radio("Sex-linked?", c("Autosomal" = "NA",
                                             "X chrom" = "23")),
                   ti_checkbox("Include in calculation?"),
                   ti_label("Comments"))

# Define server logic required to draw a histogram
function(input, output, session) {
  # Load pedigrees
  ped_claim <- reactive({
    validate(need(input$ped_claim_file, "Please select a claim pedigree"))

    p <- custom_read_ped(input$ped_claim_file$datapath)

    # attach allele frequencies
    p <- tryCatch(custom_ped_set_markers(p, normalise(frequency_db())),
                  error = function(e) { NULL })
    validate(need(!is.null(p), "Invalid frequency database."))

    # attach marker settings
    included_markers <- get_marker_names(p)
    mutation_settings <- replicate(length(included_markers), "auto")
    allele_counts <- unlist(lapply(fafreqs::markers(frequency_db()), function(m) {
      length(fafreqs::alleles(frequency_db(), m))
    }))

    mst <- marker_settings()
    if (isTruthy(mst) && is.data.frame(mst) && length(mst) > 0) {
      p <- apply_marker_settings(p, mst)

      # save metadata not stored in pedigree for the next update
      included_markers <- mst[, "Include in calculation?"]
      mutation_settings <- mst[, "Mutations"]
    }

    # update marker settings table
    new_mst <- get_marker_settings_table(p,
                                         included_markers,
                                         mutation_settings,
                                         allele_counts,
                                         simulation_threshold())

    update_ti(session, "marker_settings",
              fields = mst_fields,
              data = new_mst)

    # attach reference data
    if (isTruthy(input$familias_reference_file)) {
      p <- read_familias_case_data(p, input$familias_reference_file$datapath)
    }

    p
  })

  ped_true <- reactive({
    validate(need(input$ped_true_file, "Please select a true pedigree"))

    custom_read_ped(input$ped_true_file$datapath)
  })

  # Render pedigree plots
  output$ped_claim_plot <- renderPlot({
    custom_ped_plot(ped_claim(),
                    available = input$available_for_genotyping,
                    genotyped = get_genotyped_ids(ped_claim()))
  })

  output$ped_true_plot <- renderPlot({
    custom_ped_plot(ped_true(),
                    available = input$available_for_genotyping,
                    genotyped = get_genotyped_ids(ped_claim()))
  })

  # Update individuals available for genotyping list
  observe({
    req(ped_claim())
    req(ped_true())

    # make sure IDs are on both pedigrees
    ids <- intersect(
      custom_ped_labels(ped_claim()),
      custom_ped_labels(ped_true())
    )

    # remove genotyped individuals
    ids <- setdiff(ids, get_genotyped_ids(ped_claim()))

    updateCheckboxGroupInput(session,
      "available_for_genotyping",
      choices = ids,
      selected = input$available_for_genotyping
    )
  })

  # Load frequency database
  frequency_db <- callModule(fafreqs_widget, "frequency_db")

  # Describe frequency database to help users
  output$frequency_db_description <- renderText({
    fdb <- frequency_db()
    if (isTruthy(fdb)) {
      ms <- markers(fdb)
      sprintf("Frequency data loaded for %d markers: %s.",
              length(markers(fdb)),
              paste(markers(fdb), collapse = ", "))
    } else {
      "Please load frequency data."
    }
  })

  # Describe reference data to help users
  output$reference_data_description <- renderText({
    gids <- get_genotyped_ids(ped_claim())

    if (length(gids) > 0) {
      sprintf("Reference data loaded for individuals %s.",
              paste(gids, collapse = ", "))
    } else {
      "No reference data loaded."
    }

  })

  # Marker settings table
  marker_settings <- callModule(ti, "marker_settings",
                                fields = mst_fields,
                                data = data.frame())

  # Current marker settings table used for the calculation
  current_mst <- reactive({
    included_markers <- get_marker_names(ped_claim())
    mutation_settings <- replicate(length(included_markers), "auto")
    allele_counts <- unlist(lapply(fafreqs::markers(frequency_db()), function(m) {
      length(fafreqs::alleles(frequency_db(), m))
    }))
    get_marker_settings_table(ped_claim(),
                              included_markers,
                              mutation_settings,
                              allele_counts,
                              simulation_threshold())
  })

  # Simulation threshold
  simulation_threshold <- reactive({
    if (isTruthy(input$simulation_threshold) && input$simulation_threshold >= 0) {
      input$simulation_threshold
    } else {
      Inf
    }
  })

  ep_results <- reactiveVal()

  observeEvent(input$calculate_button, {
    isolate({
      withProgress({
        mst <- current_mst()
        ms <- get_marker_names(ped_claim())[mst[, "Include in calculation?"]]

        res <- Map(function(m) {
          ep <- exclusionPower(ped_claim(),
                               ped_true(),
                               ids = input$available_for_genotyping,
                               markers = m,
                               nsim = input$nsims,
                               exactMaxL = simulation_threshold(),
                               verbose = FALSE)
          incProgress(1/length(ms))
          ep
        }, ms)

        eps <- Map(function(ep) { ep$EPtotal }, res)

        ts <- Map(function(ep) { ep$time }, res)

        sim <- Map(function(ep) {
          if (ep$params$exactMaxL >= length(alleles(frequency_db(), ep$params$markers)))
            "No"
          else
            "Yes"
        }, res)

        res <- data.frame("Marker" = ms,
                          "EP" = as.numeric(eps),
                          "Simulated?" = as.character(sim),
                          "Time (s)" = as.numeric(ts),
                          check.names = FALSE)
        # save to reactive values
        ep_results(res)
      },
      message = "Calculating exclusion power...")
    })
  })

  output$ep_results <- renderTable({ ep_results() }, digits = 5)

  output$ep_results_total <- renderText({
    sprintf("Total EP: %f", 1 - prod(1 - ep_results()$EP, na.rm = TRUE))
  })

  onBookmark(function(state) {
    state$values$ep_results <- ep_results()
  })

  onRestore(function(state) {
    ep_results(state$values$ep_results)
  })
}
