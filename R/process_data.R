#' Make percentiles for chart
#'
#' @param .data tibble
#' @param var variable to take the mean and median of
#' @param n number of ntiles, defaults to 100 for percentiles
#' @param ... grouping variables, optional
#'
#' @return tibble
#' @export
#' @importFrom dplyr group_by mutate summarize ungroup ntile
#' @importFrom stats median
#' @examples
make_percentiles <- function(.data, var, n = 100, ...) {

  .data %>%
    group_by(...) %>%
    mutate(percentile = ntile({{ var }}, n)) %>%
    group_by(..., percentile) %>%
    summarize(mean = mean( {{var}} , na.rm = TRUE ),
              median = median( {{var}} , na.rm = TRUE)) %>%
    ungroup()

}


#' Make age buckets
#'
#' @param .data tibble
#' @param var age variable
#'
#' @return tibble
#' @export
#' @importFrom dplyr case_when
#' @examples
make_age_buckets <- function(.data, var){

  .data %>%
    mutate(
      age_bucket = dplyr::case_when(
        {{ var }} >= 0  & {{ var }} < 20 ~ "Under 20",
        {{ var }} >= 20 & {{ var }} < 30 ~ "20-29",
        {{ var }} >= 30 & {{ var }} < 40 ~ "30-39",
        {{ var }} >= 40 & {{ var }} < 50 ~ "40-49",
        {{ var }} >= 50 & {{ var }} < 60 ~ "50-59",
        {{ var }} >= 60                  ~ "Over 60"
      )
    )
}


#' Convert race / ethnicity to standard set
#'
#' @param .data tibble
#' @param var race variable
#'
#' @return tibble
#' @export
#' @importFrom dplyr case_when
#' @importFrom stringr str_to_title
#' @examples
#' \dontrun{
#' cps %>% clean_race_ethnicity(racehispanic)
#' acs %>% clean_race_ethnicity(racehispanic)
#' }
clean_race_ethnicity <- function(.data, var) {

  .data %>%
    mutate(
      race_ethnicity = dplyr::case_when(
        {{ var }} == 1 ~ "White",
        {{ var }} == 2 ~ "Black",
        {{ var }} == 3 ~ "Hispanic",
        {{ var }} == 4 ~ "Asian",
        {{ var }} == 5 ~ "Other",
        is.character( {{ var }} ) ~ stringr::str_to_title( {{ var }} ),
        TRUE ~ NA_character_
      )
    )
}


#' Convert education data to title case
#'
#' @param .data tibble
#' @param var education variable
#'
#' @return tibble
#' @export
#' @importFrom stringr str_to_title
#' @examples
#' \dontrun{
#' cps %>% clean_education(education)
#' acs %>% clean_education(education)
#' }
clean_education <- function(.data, var) {
  .data %>%
    mutate(
      education = stringr::str_to_title( {{ var }} )
    )
}

#' Clean unemployment variable
#'
#' @param .data a tibble
#' @param var employment variable name, typically `employmentstatus``
#'
#' @return a tibble
#' @export
#' @importFrom dplyr pull
#'
#' @examples
#' \dontrun{
#' cps %>% clean_employment(employmentstatus)
#' acs %>% clean_employment(employmentstatus)
#' }
clean_employment <- function(.data, var) {

  if(.data %>% pull({{ var }}) %>% is.numeric())
  .data %>%
    mutate(
      employmentstatus = case_when(
        {{ var }} == 0 ~ "not in labor force",
        {{ var }} == 1 ~ "unemployed",
        {{ var }} == 2 ~ "employed",
        {{ var }} == 3 ~ "in military",
        TRUE           ~ NA_character_
      )

    )

}

#' Process cleaned ACS/CPS data for shiny app
#'
#' @param .data tibble
#' @param input input from shiny
#'
#' @return tibble
#' @export
#'
#' @examples
#' @importFrom dplyr filter
#' # only works inside a shiny app
#' \dontrun{
#' cps %>% process_data(input)
#' acs %>% process_data(input)
#' }
process_data <- function(.data, input) {
  .data %>%
    make_age_buckets(age) %>%
    clean_race_ethnicity(racehispanic) %>%
    clean_education(education) %>%
    filter(
      if (input$comp_edu == "All")  TRUE else education == input$comp_edu,
      if (input$comp_race == "All") TRUE else race_ethnicity == input$comp_race,
      if (input$comp_age == "All")  TRUE else age_bucket == input$comp_age,
      if (input$comp_sex == 2)  TRUE else is_male == input$comp_sex # 2 means All
    )

}

#' Make unemployment metric
#'
#' @param .data tibble
#' @param var unemployment variable
#' @param ... grouping variables
#' @param na.rm whether to remove null values from calc, defaults to true
#'
#' @return tibble
#' @export
#' @importFrom dplyr pull
#' @examples
#' \dontrun{
#' cps %>% calc_unemployment_rate(employmentstatus)
#' acs %>% calc_unemployment_rate(employmentstatus)
#' }
calc_unemployment_rate <- function(.data, var, ..., na.rm = TRUE) {

  if (is.numeric(.data %>% pull({{ var }}))){
    .data %>%
      group_by(...) %>%
      summarize(
        unemployment_rate = sum({{ var }} == 1, na.rm = na.rm) /
            sum({{ var }} %in% c(1,2), na.rm = na.rm)
        )
  } else {
    .data %>%
      group_by(...) %>%
      summarize(
        unemployment_rate = sum({{ var }} == "unemployed", na.rm = na.rm) /
          sum({{ var }} %in% c("unemployed", "employed"), na.rm = na.rm)
      )
  }

}


