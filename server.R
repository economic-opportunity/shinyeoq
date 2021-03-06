server <- function(input, output) {

  user_yearly_wage <- reactive({

    input$user_wage * average_work_hours_per_year

  })

  wage_filtered_df <- reactive({

    acs_wage %>%
      process_comp_data(input)

  })

  unemployment_filtered_df <- reactive({
    acs_unemployment %>%
      process_comp_data(input)
  })

  hours_filtered_df <- reactive({
    cps_hours %>%
      process_comp_data(input)
  })

  individual_job_filtered_df <- reactive({
    individual_job %>%
      process_individual_data(input)
  })

  wage_decile_df <- reactive({
    wage_filtered_df() %>%
      mutate(decile = ntile(mean, 10)) %>%
      group_by(decile) %>%
      summarize(mean_wage = mean(mean))
  })

  user_percentile <- reactive({

    wage_filtered_df() %>%
      filter(mean >= input$user_wage) %>%
      pull(percentile) %>%
      # avoiding infinite
      min(., na.rm = TRUE) %>%
      min(., 100)

  })

  output$wage_histogram <- renderPlot({

    validate(
      need(input$user_wage, "Please select your wage.")
    )

    wage_filtered_df() %>%
      ggplot(aes(mean)) +
      geom_histogram() +
      geom_vline(xintercept = input$user_wage)

  })

  output$wage_decile_plot <- renderPlot({

    validate(
      need(input$user_wage, "Please select your wage.")
    )


    wage_decile_df() %>%
      mutate(has_user_higher_wage = mean_wage <= input$user_wage) %>%
      ggplot(aes(decile, mean_wage, fill = has_user_higher_wage)) +
      geom_col() +
      geom_text(aes(label = round(mean_wage, 1)),
                nudge_y = 1) +
      coord_flip()

  })

  output$wage_ecdf <- renderPlot({

    validate(
      need(input$user_wage, "Please select your wage.")
    )

    wage_filtered_df() %>%
      ggplot() +
      geom_line(aes(mean, percentile)) +
      geom_point(aes(input$user_wage, user_percentile()))

  })

  output$wage_text <- renderPrint({
    glue::glue("Your wage is higher than ", user_percentile(), "% of the comparison group.")
  })

  output$unemployment_table <- renderDT({
    unemployment_filtered_df() %>%
      datatable()
  })

  output$hours_table <- renderDT({
    hours_filtered_df() %>%
      datatable()
  })


# individual job ----------------------------------------------------------

  output$individual_job_table <- renderDT({
    individual_job_filtered_df() %>%
      select(industry, likelihood, expectedwage) %>%
      datatable() %>%
      formatPercentage("likelihood") %>%
      formatCurrency("expectedwage")
  })

  output$individual_job_chart <- renderPlotly({
    individual_job_filtered_df() %>%
      plot_ly(
        source = "individual_job_scatter",
        x = ~likelihood, y = ~expectedwage, customdata = ~industry,
        text = ~paste('Industry:', industry,
                      '<br>Likelihood:', scales::percent(likelihood),
                      '<br>Average wage:', scales::dollar(expectedwage)),
        # hovertemplate = "Industry: %{industry}<br>Wage: %{expectedwage:.2f}<br>Likelihood: %{likelihood:p}",
        size = ~likelihood, color = ~expectedwage)
  })

  output$individual_job_detail <- renderDT({

    # get click data from plotly chart
    click_data <- event_data("plotly_click", source = "individual_job_scatter")
    if (is.null(click_data)) return(NULL)

    # get variables clicked in plotly chart
    vars <- c(click_data[["x"]], click_data[["y"]], click_data[["customdata"]])
    selected_industry_from_plotly <- click_data[["customdata"]]

    individual_job_filtered_df() %>%
      filter(
        industry == selected_industry_from_plotly
      ) %>%
      datatable()

  })

# plotly demo -------------------------------------------------------------

  output$plotly_demo <- renderPlotly(
    fig
  )

}
