

# libs --------------------------------------------------------------------

library(shiny)
library(tidyverse)
library(janitor)
library(shinythemes)
library(shinyWidgets)
library(plotly)
library(rjson)
library(DT)
library(eoq)

# funcs -------------------------------------------------------------------

source("funcs.R")

# load --------------------------------------------------------------------

acs_wage_link <- "https://www.dropbox.com/s/3ont5at3gyvzzkn/acs_wage.csv?dl=1"
acs_unemployment_link <- "https://www.dropbox.com/s/lctrdi5pnctljoi/acs_unemployment.csv?dl=1"
bls_fips_unemployment_link <- "https://www.dropbox.com/s/agt6mj16d52flhj/lau_unemp_max_month.csv?dl=1"
cps_hours_link <- "https://www.dropbox.com/s/9fsrakfuhjirjy6/cps_hours.csv?dl=1"
counties_geo_json <- 'https://raw.githubusercontent.com/plotly/datasets/master/geojson-counties-fips.json'
individual_job_link <- "https://www.dropbox.com/s/7fz2vry626o78y4/individual_job.csv?dl=1"

acs_wage <- read_csv(acs_wage_link) %>%
  janitor::clean_names()

acs_unemployment <- read_csv(acs_unemployment_link) %>%
  janitor::clean_names()

bls_fips_unemployment <- read_csv(bls_fips_unemployment_link)

cps_hours <- read_csv(cps_hours_link) %>%
  janitor::clean_names()

counties <- rjson::fromJSON(file = counties_geo_json)

individual_job <- read_csv(individual_job_link) %>%
  janitor::clean_names()

# constants ---------------------------------------------------------------

average_work_hours_per_year <- 1811.16 # https://www.fool.com/careers/2017/12/17/heres-how-many-hours-the-average-american-works-pe.aspx

races_ethnicities <- c("All", "White", "Black", "Asian", "Hispanic", "Other")

age_ranges <- c("All", "Under 25", "25-34", "35-44", "45-54", "55-64", "Over 65")

edu_levels <- c("All", "Less Than High School", "High School",
                "Bachelor's Degree", "Advanced Degree")

sexes <- c("All", "Male", "Female")



# plotly chorlopleth  ----------------------------------------------------
#
g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa'),
  showlakes = TRUE,
  lakecolor = toRGB('white')
)

fig <- plot_ly() %>%
  add_trace(
    type="choropleth",
    geojson=counties,
    locations=bls_fips_unemployment$fips,
    z=bls_fips_unemployment$value,
    colorscale="Viridis",
    zmin=0,
    zmax=12,
    marker=list(line=list(
      width=0)
  )
)

fig <- fig %>% colorbar(title = "Unemployment Rate (%)")
fig <- fig %>% layout(
  title = glue::glue("US Unemployment by County, {month} {year}",
                     month = max(bls_fips_unemployment$period_name),
                     year = max(bls_fips_unemployment$year))
)

fig <- fig %>%
  layout(
    geo = g
  )

# options -----------------------------------------------------------------

# set ggplot theme
ggplot2::theme_set(tidyquant::theme_tq())
