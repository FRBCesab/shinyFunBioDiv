suppressPackageStartupMessages({
  require(shiny)
  require(shinythemes)
  require(sf)
  require(DT)
  require(plotly)
  require(leaflet)
  require(htmltools)
  require(markdown)
})

meta <- utils::read.csv("data/meta.csv")
shp <- sf::st_read("data/points.shp")
bounds <- sf::st_bbox(shp)
pal <- leaflet::colorFactor("viridis", domain = NULL)
keepPal <- pal(sort(unique(shp$Study_ID)))
names(keepPal) <- sort(unique(shp$Study_ID))
stablePal <- function(x) {
  return(as.character(keepPal[x]))
}

# choices for ag_practices
div_choices <- c(
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
pest_choices <- sort(unique(unlist(strsplit(meta$Resp_pest, ", "))))
NE_choices <- sort(unique(unlist(strsplit(meta$Resp_NE, ", "))))

# choices for covariates
# orga_choices <- sort(unique(meta$Organic))
# orga_choices <- orga_choices[!orga_choices %in% c("", "unknown")]
# till_choices <- sort(unique(meta$Tillage))
# till_choices <- till_choices[!till_choices %in% c("", "unknown")]
# nqty_choices <- sort(unique(meta$N_qty))
# nqty_choices <- nqty_choices[!nqty_choices %in% c("", "unknown")]
# tfi_choices <- sort(unique(meta$TFI))
# yield_choices <- sort(unique(meta$Yield))
covchoices <- c("measured", "structured")

ctype_choices <- sort(unique(meta$Crop_type))


# all choices

choices <- list(
  "none" = c(),
  "Div_measures" = div_choices,
  "Resp_pest" = pest_choices,
  "Resp_NE" = NE_choices,
  "Crop_type" = ctype_choices,
  "Organic" = covchoices,
  "Tillage" = covchoices,
  "N_qty" = covchoices,
  "TFI" = covchoices,
  "Yield" = covchoices
)

ctab <- utils::read.csv("data/cont_table.csv")
ctab$Pestcat <- factor(
  ctab$Pestcat,
  levels = c(
    "1_insect",
    "1_pathogen",
    "1_weed",
    "2_insect",
    "2_pathogen",
    "2_weed",
    "2_insect, pathogen",
    "2_insect, weed",
    "2_pathogen, weed",
    "3_insect, pathogen, weed"
  )
)
