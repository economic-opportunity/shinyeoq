test_that("make_percentiles returns percentiles", {
  expect_equal(
    tibble::tibble(x = 1:1000, y = 1:1000) %>%
      make_percentiles(y) %>%
      dplyr::pull(percentile) %>%
      length(),
    100)
})

test_that("make_percentiles calculates mean properly", {
  expect_equal(
    tibble::tibble(x = 1:1000, y = 1:1000) %>%
      make_percentiles(y) %>%
      dplyr::pull(mean) %>%
      mean(),
    500.5)
})


test_that("age_buckets returns 6 buckets", {
  expect_equal(
    tibble::tibble(x = seq.int(10, 60, 10)) %>%
      make_age_buckets(x) %>%
      dplyr::pull(age_bucket),
    c("Under 20", "20-29", "30-39",
      "40-49", "50-59", "Over 60")
  )


})
