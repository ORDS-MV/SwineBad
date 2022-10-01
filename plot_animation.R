library(tidyverse)
library(rgdal)
library(gifski)
library(gganimate)
library(lubridate)

df <- read_csv("data.csv")
coord <- read_csv("coord.csv")

df %>%
  left_join(coord, by=c("Wohnort"="Ort")) %>%
  mutate(sw_lat=53.916667,sw_long=14.25) %>%
  mutate(year=year(Datum))->
  data

# Download data from https://hub.arcgis.com/datasets/ae25571c60d94ce5b7fcbf74e27c00e0/about

germany <- readOGR("./vg2500_geo84/vg2500_bld.shp", use_iconv = TRUE, encoding = "UTF-8")
germany_tab <- broom::tidy(germany)

# Download data from https://www.efrainmaps.es/english-version/free-downloads/europe/

europe <- readOGR("./europe/Europe.shp", use_iconv = TRUE, encoding = "UTF-8")
europe_tab <- broom::tidy(europe)

ggplot() +
  geom_polygon(data = germany_tab,
               aes(x = long, y = lat, group = group),
               fill = "white",
               colour = "gray80") +
  geom_segment(data=data,color="#d73027",
               aes(xend=sw_long, yend=sw_lat, x = longitude, y = latitude),
               arrow = arrow(length = unit(3, "mm"))) + 
  geom_point(data = data,
             aes(x = longitude, y = latitude)) +
  theme_minimal() +
  coord_map() + 
  transition_states(year) +
  guides(color='none', size=guide_legend('# of courses')) + 
  theme(legend.position = 'top',
        legend.box = "vertical",
        axis.title=element_blank(),
        panel.grid = element_blank(),
        axis.text = element_blank()) +
  labs(title = 'Jahr: {closest_state}') -> p.deu

pp.deu <- animate(p.deu, renderer = gifski_renderer(file="swinemunde.gif"))

ggplot() +
  geom_polygon(data = europe_tab,
               aes(x = long, y = lat, group = group),
               fill = "white",
               colour = "gray80") +
  geom_segment(data=data,color="#d73027",
               aes(xend=sw_long, yend=sw_lat, x = longitude, y = latitude),
               arrow = arrow(length = unit(3, "mm"))) + 
  geom_point(data = data,
             aes(x = longitude, y = latitude)) +
  theme_minimal() +
  coord_map() + 
  transition_states(year) +
  guides(color='none', size=guide_legend('# of courses')) + 
  theme(legend.position = 'top',
        legend.box = "vertical",
        axis.title=element_blank(),
        panel.grid = element_blank(),
        axis.text = element_blank()) +
  labs(title = 'Jahr: {closest_state}') -> p.eu

pp.eu <- animate(p.eu, renderer = gifski_renderer(file="swinemunde.gif"))