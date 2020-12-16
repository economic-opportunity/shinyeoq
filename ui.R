ui <- navbarPage("EOQ Demo v0",
  # set theme
  theme = shinytheme("yeti"),

  tabPanel("Comparison to Peers",
           sidebarLayout(
             sidebarPanel(
               h3("Your wage info"),
               numericInput("user_wage",
                            h4("Your annual wage:"),
                            value = 20000),
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
                           choices = sexes)#,
               # actionBttn("calculate", "Create comparison group",
               #            style = "bordered", icon = icon("sliders"), color = "primary")
             ),

             # Show a plot of the generated distribution
             mainPanel(
               tabsetPanel(type = "tabs",
                           tabPanel("Wages",
                                    textOutput("wage_text"),
                                    plotOutput("wage_histogram"),
                                    plotOutput("wage_decile_plot"),
                                    plotOutput("wage_ecdf")
                           ),
                           tabPanel("Unemployment rate",
                                    DTOutput("unemployment_table")
                           ),
                           tabPanel("Hours worked",
                                    DTOutput("hours_table")))

               )
             )

           ),
  tabPanel("Geographic Comparison",
           plotlyOutput("plotly_demo")
  ),
  navbarMenu("More")
  # Sidebar with a slider input for number of bins
  )
