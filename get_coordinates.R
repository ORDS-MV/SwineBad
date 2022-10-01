require(tidyverse)
require(httr)

coordinates <- read_csv("coord.csv")

get_place_id_coords <- function(ort) {
  result <- GET(paste0("https://nominatim.openstreetmap.org/search.php?format=geojson&q=", ort))
  cresult <- content(result)
  place_id <- cresult$features[[1]]$properties$place_id
  osm_coords <- cresult$features[[1]]$geometry$coordinates
  
  tibble(place_id=place_id, lat=osm_coords[[2]], lon=osm_coords[[1]])
}

get_wikidata_url <- function(place_id) {
  result <- GET(paste0("https://nominatim.openstreetmap.org/details.php?format=json&place_id=", place_id))
  cresult <- content(result)
  wikidata_id <- cresult$extratags$wikidata
  wikidata_url <- paste0("https://www.wikidata.org/wiki/", wikidata_id)
  
  tibble(wikidata_id=wikidata_id, wikidata_url=wikidata_url)
}

coordinates <- coordinates %>%
  as_tibble() %>% 
  mutate(place_id_coords = pmap(list(Ort), get_place_id_coords))  %>%
  unnest(c('place_id_coords')) %>%
  mutate(wikidata_id_url = pmap(list(place_id), get_wikidata_url))  %>%
  unnest(c('wikidata_id_url'))
