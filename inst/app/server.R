server <- function(input, output) {

  user_yearly_wage <- reactive({

    input$user_wage * average_work_hours_per_year

  })

  cps_filtered_df <- eventReactive(input$calculate, {

    cps %>%
      process_data(input) %>%
      make_percentiles(hourlywage, 100)

  })

  cps_decile_df <- reactive({
    cps_filtered_df() %>%
      mutate(decile = ntile(mean, 10)) %>%
      group_by(decile) %>%
      summarize(mean_wage = mean(mean))
  })

  user_percentile <- reactive({

    cps_filtered_df() %>%
      filter(mean >= input$user_wage) %>%
      pull(percentile) %>%
      min() %>%
      # avoiding infinite
      min(., 100)

  })



  output$cps_histogram <- renderPlot({

    validate(
      need(input$user_wage, "Please select your wage.")
    )

    cps_filtered_df() %>%
      ggplot(aes(mean)) +
      geom_histogram() +
      geom_vline(xintercept = input$user_wage)

  })

  output$cps_decile_plot <- renderPlot({

    validate(
      need(input$user_wage, "Please select your wage.")
    )


    cps_decile_df() %>%
      mutate(has_user_higher_wage = mean_wage <= input$user_wage) %>%
      ggplot(aes(decile, mean_wage, fill = has_user_higher_wage)) +
      geom_col() +
      geom_text(aes(label = round(mean_wage, 1)),
                nudge_y = 1) +
      coord_flip()

  })

  output$cps_ecdf <- renderPlot({

    validate(
      need(input$user_wage, "Please select your wage.")
    )

    cps_filtered_df() %>%
      ggplot() +
      geom_line(aes(mean, percentile)) +
      geom_point(aes(input$user_wage, user_percentile()))

  })

  output$cps_text <- renderPrint({
    glue::glue("Your wage is higher than ", user_percentile(), "% of the comparison group.")
  })



}
