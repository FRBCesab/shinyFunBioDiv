# Read and pre-process the metadata
# The input file is originally at :
# https://docs.google.com/spreadsheets/d/1Lz-IBQAPd8RykPj57Nf1Tutb_fQlXg4fG461i29BYIM
# Creates two files for the shiny app
#   app/data/meta.csv : simplified and corrected metadata
#   app/data/poly.shp : shapefile with convex hull of sites per dataset

# load the needed package and functions
devtools::load_all()

## A. METADATA
# A.1 Load metadata
meta <- readxl::read_xlsx(
  here::here("data", "FunBioDiv_MetaData_Data.xlsx"),
  sheet = 1,
  skip = 2
)
# might be good to automatized the loading in GoogleDrive
# library(googledrive)
# dl <- drive_download(
# as_id("https://docs.google.com/spreadsheets/d/17ZhE3nxqtGYNzeADMzU02YzfKU9H9f5j/edit#gid=1748893795"),
#  path = 'temp1.xlsx',
#  overwrite = TRUE,
#  type = "xlsx")
# or https://googlesheets4.tidyverse.org/

# dim(meta)
# names(meta)

# A.2 Select relevant variables
keep <- c(1, 4, 5, 6, 10:17, 20)
meta <- meta[, keep]
lab <- c(
  "Type",
  "service_plant",
  "cultivar_mixture",
  "intercropping",
  "cover_crop",
  "agroforestry",
  "crop_rotation",
  "natural_habitats",
  "crop_diversity"
)
names(meta)[4:12] <- lab


# A.3 Simplify the metadata
# pre-processing for years
all_years <- strsplit(meta$Year, ";")
small_year <- data.frame(
  "ID" = rep(meta$Study_ID, sapply(all_years, length)),
  "yr" = as.numeric(unlist(all_years))
)

# replace 'Pest control' to avoid overlap with 'Pest'
meta$Response_variables <- gsub(
  "Pest control -",
  "P. control -",
  meta$Response_variables
)

# simplify the dataset with one line per Study_ID
smalldf <- data.frame(
  "Study_ID" = sort(unique(meta$Study_ID)),
  "Years" = tapply(small_year$yr, small_year$ID, concat),
  "Country" = tapply(firstup(meta$Country), meta$Study_ID, concat),
  "Type" = tapply(firstup(meta$Type), meta$Study_ID, concat),
  "Resp_variable" = tapply(meta$Response_variables, meta$Study_ID, concat)
)

# get the practices
df_practices <- meta[5:12]
df_practices[is.na(df_practices)] <- "no"
ind <- which(df_practices == "yes", arr.ind = TRUE)
smallag <- data.frame(
  "ID" = meta$Study_ID[ind[, 1]],
  "practices" = names(df_practices)[ind[, 2]]
)
practices <- tapply(smallag$practices, smallag$ID, concat)

smalldf$Ag_practices <- as.character(
  practices[match(smalldf$Study_ID, names(practices))]
)


# A.4 Export the metadata
write.csv(
  smalldf,
  file = here::here("app", "data", "meta.csv"),
  row.names = FALSE
)


## B. Spatial coordinates
# B.1 Load GPS coordinates
library(sf)
gis <- readxl::read_xlsx(
  here::here("data", "FunBioDiv_MetaData_Data.xlsx"),
  sheet = 2,
  skip = 2
)

# B.2 Clean the messy coordinates
gis$X <- as.numeric(gis$X)
gis$Y <- as.numeric(gis$Y)

# invert latitude / longitude in OSCAR project
gis$longitude <- ifelse(gis$Study_ID %in% "OSCAR", gis$Y, gis$X)
gis$latitude <- ifelse(gis$Study_ID %in% "OSCAR", gis$X, gis$Y)

# issue some are not in WGS84, let's try the most commun
# epsg 4326 (WGS84),
# epsg 3035 (ETRS89_LAEA projection),
# epsg 5698 (LAMB93_IGN69_D066)
proj <- ifelse(gis$longitude > 180, "LAMB93", "WGS84")

# transform LAMB93 to WGS84
lamb93 <- gis[proj %in% "LAMB93", c("longitude", "latitude")]
shp_5698 <- st_as_sf(lamb93, coords = c("longitude", "latitude"), crs = 5698)
shp_4326 <- st_transform(shp_5698, crs = 4326)
coo_4326 <- st_coordinates(shp_4326)
gis[proj %in% "LAMB93", c("longitude", "latitude")] <- coo_4326


# B3. Alter coordinates to safeguard privacy
# plot(gis$longitude, gis$latitude)
fullcoo <- complete.cases(gis[, c("longitude", "latitude")])
gis_points <- gis[fullcoo, c("Study_ID", "longitude", "latitude")]
# remove duplicates (so that it doesn't appear twice when jittered)
gis_points <- gis_points[!duplicated(gis_points), ]
# round and jitter coordinates for privacy reason
gis_points$lon <- jitter(round(gis_points$longitude, 1), amount = 0.05)
gis_points$lat <- jitter(round(gis_points$latitude, 1), amount = 0.05)


# B4. Create sf object
mpt <- match(gis_points$Study_ID, smalldf$Study_ID)
gis_points$Type <- smalldf$Type[mpt]
gis_points$Resp.var <- smalldf$Resp_variable[mpt]
gis_points$Practice <- smalldf$Ag_practices[mpt]

shp <- st_as_sf(
  gis_points[, c("Study_ID", "lon", "lat", "Type", "Resp.var", "Practice")],
  coords = c("lon", "lat"),
  crs = 4326
)

# check visualization
# mapview::mapview(shp, zcol = "Study_ID")

# B5. Export shapefile
st_write(
  shp,
  dsn = here::here("app", "data", "points.shp"),
  layer = "points.shp",
  driver = "ESRI Shapefile",
  append = FALSE
)

# no need to calculate convex hull anymore
# B4. calculate convex hull
# so far, simple with sf function, but could also use
# grDevices::chull(gis$X, gis$Y)
# alphahull::ahull(x, y = NULL, alpha)
# list_hull <- list()
# for (i in unique(gis$Study_ID)) {
#   coo <- gis[gis$Study_ID == i, c("longitude", "latitude")]
#   coo <- coo[complete.cases(coo), ]
#   if (nrow(coo) > 0) {
#     # if we need more precise concave hull
#     # hulli <- st_concave_hull(st_multipoint(as.matrix(coo), dim = "XY"), 0.3)
#     hulli <- st_convex_hull(st_multipoint(as.matrix(coo), dim = "XY"))
#     list_hull[[i]] <- hulli
#   }
# }

# # B.5 Combine polygon and metadata
# shp_poly <- st_sf(
#   smalldf[match(names(list_hull), smalldf$Study_ID), ],
#   geometry = st_sfc(list_hull),
#   crs = 4326
# )

# names(shp_poly)[c(1, 5, 6)] <- c("Study.ID", "Resp.var", "Practice")
# plot(gis$longitude, gis$latitude)
# plot(shp_poly, add = TRUE)
