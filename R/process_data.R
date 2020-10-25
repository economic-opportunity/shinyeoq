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
#' @examples
make_percentiles <- function(.data, var, n = 100, ...) {

  .data %>%
    group_by(...) %>%
    mutate(percentile = ntile({{ var }}, n)) %>%
    group_by(..., percentile) %>%
    summarize(mean = mean( {{var}} , na.rm = TRUE ),
              median = stats::median( {{var}} , na.rm = TRUE)) %>%
    ungroup()

}


#' Make age buckets
#'
#' @param .data
#' @param var
#' @param ...
#'
#' @return
#' @export
#' @importFrom dplyr case_when
#' @examples
make_age_buckets <- function(.data, var, ...){

  .data %>%
    mutate(
      age_bucket = dplyr::case_when(
        {{ var }} >= 0 & {{ var }} < 20 ~ "Under 20",
        {{ var }} >= 20 & {{ var }} < 30 ~ "20-29",
        {{ var }} >= 30 & {{ var }} < 40 ~ "30-39",
        {{ var }} >= 40 & {{ var }} < 50 ~ "40-49",
        {{ var }} >= 50 & {{ var }} < 60 ~ "50-59",
        {{ var }} >= 60 & {{ var }} < 1000 ~ "Over 60"
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
make_race_ethnicity <- function(.data, var) {

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
#' @param .data
#' @param var
#'
#' @return
#' @export
#' @importFrom stringr str_to_title

#' @examples
make_education <- function(.data, var) {
  .data %>%
    mutate(
      education = stringr::str_to_title( {{ var }} )
    )
}


#' Process cleaned ACS/CPS data for shiny app
#'
#' @param .data tibble
#'
#' @return tibble
#' @export
#'
#' @examples
process_data <- function(.data, input) {
  .data %>%
    make_age_buckets(age) %>%
    make_race_ethnicity(racehispanic) %>%
    make_education(education) %>%
    filter(
      if (input$comp_edu == "All")  TRUE else education == input$comp_edu,
      if (input$comp_race == "All") TRUE else race_ethnicity == input$comp_race,
      if (input$comp_age == "All")  TRUE else age_bucket == input$comp_age,
      if (input$comp_sex == 2)  TRUE else is_male == input$comp_sex # 2 means All
    )

}
