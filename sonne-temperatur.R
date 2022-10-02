library(tidyverse)
library(ggforce)   # draw circle
library(rgdal)
library(gifski)
library(gganimate)

sonne <- read_csv("temperatur-greifswald.csv")
dat <- read_csv("data.csv")

sonne.circ <- sonne %>% 
  mutate(x0 = 0) %>% 
  mutate(y0 = 0) %>%
  mutate(r  = 1) %>% 
  rename(Datum = Zeitstempel) %>% 
  # data imputation
  mutate(Wert = if_else(is.na(Wert), 23, Wert))

dat.sonne <- dat %>% 
  left_join(sonne.circ, by = "Datum")

ggplot() +
  geom_circle(data = dat.sonne,
              aes(x0 = x0, y0 = y0, r = r,
                  fill = Wert)) +
  theme_minimal() +
  transition_manual(Zeitstempel) +
  scale_fill_gradient2(low="navy", mid="yellow", high="red", 
                       midpoint=0,
                       limits=range(sonne.circ$Wert)) +
  guides(fill='none') + 
  theme(legend.position = 'top',
        legend.box = "vertical",
        axis.title=element_blank(),
        panel.grid = element_blank(),
        axis.text = element_blank()) +
  labs(title = 'Datum: {closest_state}') -> p

pp <- animate(p, renderer = gifski_renderer(file="sonne.gif"))
