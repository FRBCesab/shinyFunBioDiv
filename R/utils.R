# concat ---------------------------------------
#' concatenate unique list of characters
#'
#' @export
concat <- function(x) {
  #remove empty string
  x <- x[x != ""]
  paste(sort(unique(x)), collapse = ", ")
}


# minmax ---------------------------------------
#' concatenate minimum and maximum
#'
#' @export
minmax <- function(x, na.rm = TRUE) {
  if (all(!is.na(x)) | any(!is.na(x)) & na.rm) {
    if (min(x, na.rm = na.rm) < max(x, na.rm = na.rm)) {
      out <- paste(min(x, na.rm = na.rm), max(x, na.rm = na.rm), sep = " - ")
    } else {
      out <- min(x, na.rm = na.rm)
    }
  } else {
    out <- NA
  }
  return(out)
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
