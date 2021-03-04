#

# libs --------------------------------------------------------------------

library(tidyverse)
library(janitor)
library(shinythemes)
library(shinydashboard)

# load --------------------------------------------------------------------

dropbox_data_filepath <- "~/Dropbox/Economic Opportunity Project/Data/Comparison to Peers/Outputs"
acs_dropbox_filepath <- file.path(dropbox_data_filepath, "ACS_Cleaned.csv.zip")
cps_dropbox_filepath <- file.path(dropbox_data_filepath, "CPS_Cleaned.zip")
individual_job_link <- "https://www.dropbox.com/s/7fz2vry626o78y4/individual_job.csv?dl=1"

cps <- read_csv(cps_dropbox_filepath) %>%
  janitor::clean_names()

acs <- read_csv(acs_dropbox_filepath) %>%
  janitor::clean_names()

individual_job <- read_csv(individual_job_link) %>%
  janitor::clean_names()

# transform ---------------------------------------------------------------

grp_vars <- c("age_bucket", "education", "race_ethnicity", "is_male")

acs_summarized <- acs %>%
  make_age_buckets(age) %>%
  clean_race_ethnicity(racehispanic) %>%
  clean_education(education) %>%
  make_percentiles(totalwage, age_bucket, education, race_ethnicity, is_male)

cps_wage <- cps %>%
  make_age_buckets(age) %>%
  clean_race_ethnicity(racehispanic) %>%
  clean_education(education) %>%
  make_percentiles(totalwage, age_bucket, education, race_ethnicity, is_male)


# write clean files -------------------------------------------------------
#
# acs_summarized %>%
#   write_csv(file.path(acs_dropbox_filepath, "acs_wage.csv"))


