# libs --------------------------------------------------------------------

library(shiny)
library(tidyverse)
library(janitor)
library(shinythemes)
library(shinyWidgets)
library(plotly)
library(rjson)
library(shinyeoq)

# functions ---------------------------------------------------------------

source("R/process_data.R")

# load --------------------------------------------------------------------

dropbox_data_filepath <- "~/Dropbox/Economic Opportunity Project/Data/Comparison to Peers/Outputs"
acs_dropbox_filepath <- file.path(dropbox_data_filepath, "ACS_Cleaned.zip")
cps_dropbox_filepath <- file.path(dropbox_data_filepath, "CPS_Cleaned.zip")


cps <- read_csv(cps_dropbox_filepath) %>%
  janitor::clean_names()

acs <- read_csv(acs_dropbox_filepath) %>%
  janitor::clean_names()

# constants ---------------------------------------------------------------

average_work_hours_per_year <- 1811.16 # https://www.fool.com/careers/2017/12/17/heres-how-many-hours-the-average-american-works-pe.aspx

races_ethnicities <- c("All", "White", "Black", "Asian", "Hispanic", "Other")

age_ranges <- c("All", "Under 20", "20-29", "30-39",
                "40-49", "50-59", "Over 60")

edu_levels <- c("All", "Less Than High School", "High School",
                "Bachelor's Degree", "Advanced Degree")

sexes <- c("All", "Male", "Female")


# plotly chorlopleth  -----------------------------------------------------

unemp_rate_fips <- read_csv("https://raw.githubusercontent.com/plotly/datasets/master/fips-unemp-16.csv")

url <- 'https://raw.githubusercontent.com/plotly/datasets/master/geojson-counties-fips.json'
counties <- rjson::fromJSON(file=url)

g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa'),
  showlakes = TRUE,
  lakecolor = toRGB('white')
)
fig <- plot_ly()
fig <- fig %>% add_trace(
  type="choropleth",
  geojson=counties,
  locations=unemp_rate_fips$fips,
  z=unemp_rate_fips$unemp,
  colorscale="Viridis",
  zmin=0,
  zmax=12,
  marker=list(line=list(
    width=0)
  )
)
fig <- fig %>% colorbar(title = "Unemployment Rate (%)")
fig <- fig %>% layout(
  title = "2016 US Unemployment by County"
)

fig <- fig %>% layout(
  geo = g
)

# options -----------------------------------------------------------------

# set ggplot theme
ggplot2::theme_set(tidyquant::theme_tq())