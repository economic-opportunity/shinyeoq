# libs --------------------------------------------------------------------

library(shiny)
library(tidyverse)
library(janitor)
library(shinythemes)
library(shinyWidgets)
library(shinyeoq)

# load --------------------------------------------------------------------

dropbox_data_filepath <- "~/Dropbox/Economic Opportunity Project/Data/Comparison to Peers/Outputs"
acs_dropbox_filepath <- file.path(dropbox_data_filepath, "ACS_Cleaned.csv.zip")
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

# options -----------------------------------------------------------------

# set ggplot theme
theme_set(tidyquant::theme_tq())
