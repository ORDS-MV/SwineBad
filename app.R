library(shiny)

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

if (interactive()) {
  
ui <- fluidPage(
    # Application title
    titlePanel("Kulturhackathon 2022 - Projekt Badeanzeiger"),
    sliderInput("date", "date of arrival:", 
                min = 1910, max = 1932, value=1920, sep = "",animate = TRUE),
    plotOutput("Plotyplot")
)

server <- function(input, output) {
    output$Plotyplot <- renderPlot({
      
      data$year <- format(as.Date(data$Datum, format="%d/%m/%Y"),"%Y")
      data1 <- data[data$year==input$date,]
      
      ggplot() +
        geom_polygon(data = germany_tab,
                     aes(x = long, y = lat, group = group),
                     fill = "white",
                     colour = "gray80") +
        geom_segment(data=data1,color="#d73027",
                     aes(xend=sw_long, yend=sw_lat, x = longitude, y = latitude),
                     arrow = arrow(length = unit(3, "mm"))) + 
        geom_point(data = data1,
                   aes(x = longitude, y = latitude))+
        theme_minimal()+
        coord_map()
      })
}

shinyApp(ui = ui, server = server)
}
