ui <- fluidPage(

  # set theme
  theme = shinytheme("yeti"),

  # Application title
  titlePanel("EOQ Demo v0"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      h3("Your wage info"),
      numericInput("user_wage",
                   h4("Your hourly wage:"),
                   value = 10),
      h3("Comparison group"),
      selectInput("comp_edu",
                  h4("Comparison education level:"),
                  choices = edu_levels),
      selectInput("comp_race",
                  h4("Your race/ethnicity:"),
                  selected = "All",
                  choices = races_ethnicities),
      # sliderInput("comp_age",
      #             h4("Your age range:"),
      #             min = 0, max = 100,
      #             value = c(40,60)),
      selectInput("comp_age",
                  h4("Your age bracket:"),
                  selected = "All",
                  choices = age_ranges),
      selectInput("comp_sex",
                  h4("Sex:"),
                  selected = "All",
                  choices = c("All" = 2, "Female" = 0, "Male" = 1)),
      actionBttn("calculate", "Create comparison group",
                 style = "bordered", icon = icon("sliders"), color = "primary")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Wages",
                           textOutput("cps_text"),
                           plotOutput("cps_histogram"),
                           plotOutput("cps_decile_plot"),
                           plotOutput("cps_ecdf")
                  ),
                  tabPanel("Unemployment rate",
                           plotOutput("unemployment_rate")
                  ),
                  tabPanel("Hours worked",
                           plotOutput("hours_worked"))

      )

    )
  )
)
