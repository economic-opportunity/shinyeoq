

# libs --------------------------------------------------------------------

library(shiny)
library(tidyverse)
library(janitor)
library(shinythemes)
library(shinyWidgets)
library(plotly)
library(rjson)


# funcs -------------------------------------------------------------------

source("funcs.R")

# load --------------------------------------------------------------------

# dfs <- tribble(
#   ~source, ~link, ~tmp_file, ~file_name,
#   "acs", "https://www.dropbox.com/s/sg2pjcbr0iyzzvw/ACS_Cleaned.zip?dl=1", file.path(tmp_dir,  "asc.csv.zip"),
#   "cps", "https://www.dropbox.com/s/zgqsb2ckw69putb/CPS_Cleaned.zip?dl=1", file.path(tmp_dir,  "cps.csv.zip"),
#   "bls", "https://www.dropbox.com/s/tj1awlw825bqwcp/lau_15-20.csv.zip?dl=1", file.path(tmp_dir,  "bls.csv.zip"),
# )


acs_dropbox_link <- "https://www.dropbox.com/s/sg2pjcbr0iyzzvw/ACS_Cleaned.zip?dl=1"
cps_dropbox_link <- "https://www.dropbox.com/s/zgqsb2ckw69putb/CPS_Cleaned.zip?dl=1"
bls_dropbox_link <- "https://www.dropbox.com/s/agt6mj16d52flhj/lau_unemp_max_month.csv?dl=1"

tmp_dir <- tempdir()

acs_tmp <- file.path(tmp_dir, "asc.csv.zip")
cps_tmp <- file.path(tmp_dir, "cps.csv.zip")

download.file(acs_dropbox_link, acs_tmp)
download.file(cps_dropbox_link, cps_tmp)

cps <- read_csv(cps_tmp) %>%
  janitor::clean_names()

acs <- read_csv(acs_tmp) %>%
  janitor::clean_names()

bls <- read_csv(bls_dropbox_link)

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
#
g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa'),
  showlakes = TRUE,
  lakecolor = toRGB('white')
)
fig <- plot_ly()
fig <- fig %>%
  add_trace(
  type="choropleth",
  geojson=counties,
  locations=bls$fips,
  z=bls$value,
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
                     month = max(bls$period_name),
                     year = max(bls$year))
)

fig <- fig %>% layout(
  geo = g
)

# options -----------------------------------------------------------------

# set ggplot theme
ggplot2::theme_set(tidyquant::theme_tq())
