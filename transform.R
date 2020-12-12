#

# libs --------------------------------------------------------------------

library(tidyverse)
library(janitor)
library(shinythemes)
library(shinydashboard)
library(shinyeoq)

# load --------------------------------------------------------------------

dropbox_data_filepath <- "~/Dropbox/Economic Opportunity Project/Data/Comparison to Peers/Outputs"
acs_dropbox_filepath <- file.path(dropbox_data_filepath, "ACS_Cleaned.csv.zip")
cps_dropbox_filepath <- file.path(dropbox_data_filepath, "CPS_Cleaned.zip")


cps <- read_csv(cps_dropbox_filepath) %>%
  janitor::clean_names()

acs <- read_csv(acs_dropbox_filepath) %>%
  janitor::clean_names()

# transform ---------------------------------------------------------------


grp_vars <- c("age_bucket", "education", "race_ethnicity", "is_male")

acs_summarized <- acs %>%
  make_age_buckets(age) %>%
  clean_race_ethnicity(racehispanic) %>%
  make_percentiles(!!!grp_vars)
