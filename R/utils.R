# concat ---------------------------------------
#' concatenate unique list of characters
#'
#' @export
concat <- function(x) {
  paste(sort(unique(x)), collapse = ", ")
}

# firstup ---------------------------------------
#' Capitalize characters
#'
#' @export
firstup <- function(x) {
  x <- tolower(x)
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  return(x)
}

# runShiny ---------------------------------------
#' Run shiny app made using cuspra package functions
#'
#' @export
runShiny <- function() {
  appDir <- here::here("app")
  # system.file("app", package = "cuspra")
  if (appDir == "") {
    stop(
      "Could not find example directory. Try re-installing `cuspra`.",
      call. = FALSE
    )
  }
  shiny::runApp(appDir, display.mode = "normal")
}
