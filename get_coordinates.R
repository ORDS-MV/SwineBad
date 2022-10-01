require(tidyverse)
require(httr)

coordinates <- read_csv("coord.csv")

get_place_id_coords <- function(ort) {
  result <- GET(paste0("https://nominatim.openstreetmap.org/search.php?format=geojson&q=", ort))
  cresult <- content(result)
  place_id <- cresult$features[[1]]$properties$place_id
  osm_coords <- cresult$features[[1]]$geometry$coordinates
  
  return(place_id, osm_coords)
}

get_wikidata_url <- function(place_id) {
  result <- GET(paste0("https://nominatim.openstreetmap.org/details.php?format=json&place_id=", place_id))
  cresult <- content(result)
  wikidata_id <- cresult$extratags$wikidata
  wikidata_url <- paste0("https://www.wikidata.org/wiki/", wikidata_id)
  
  return(wikidata_url)
}

# coordinates %>%
#   rowwise() %>%
#   summarise(place_id=get_place_id(Ort))
