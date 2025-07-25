suppressPackageStartupMessages({
  require(shiny)
  require(shinythemes)
  require(sf)
  require(DT)
  require(leaflet)
  require(htmltools)
  require(markdown)
})

meta <- utils::read.csv("data/meta.csv")
shp <- sf::st_read("data/points.shp")
bounds <- sf::st_bbox(shp)
pal <- leaflet::colorFactor("viridis", domain = NULL)

choices <- c("none", "Ag_practices", "Resp_variable")

# choices for ag_practices
ag_choices <- c(
  "service_plant",
  "cultivar_mixture",
  "intercropping",
  "cover_crop",
  "agroforestry",
  "crop_rotation",
  "natural_habitats",
  "crop_diversity"
)

# choices for response variables
resp_full <- sort(unique(unlist(strsplit(meta$Resp_variable, ", "))))
resp_cat <- sapply(strsplit(resp_full, " -"), function(x) x[[1]])
var_choices <- sort(unique(c(resp_full, resp_cat)))
