library(shiny)

library(tidyverse)
library(rgdal)
library(gifski)
library(gganimate)
library(lubridate)
library(sf)

df <- read_csv("data2.csv")
coord <- read_csv("coord.csv")

df %>%
  left_join(coord, by=c("Wohnort"="Ort")) %>%
  mutate(sw_lat=53.916667,sw_long=14.25) %>%
  mutate(year=year(Datum))->
  data

# Download data from https://hub.arcgis.com/datasets/ae25571c60d94ce5b7fcbf74e27c00e0/about

st_read("./europe/Europe.shp") %>%
  st_transform(crs = '+proj=aeqd +lat_0=53.6 +lon_0=12.7') %>%
  st_simplify(preserveTopology = FALSE, dTolerance = 10000) ->
  europa
  

if (interactive()) {
  
ui <- fluidPage(

    titlePanel("Kulturhackathon 2022 - Projekt SwineBad"),
    img(src = "Swinemuende_vor_100_Jahren.jpg", height=200),
    img(src = "Badanzeiger_Titelpage.png", height=200),
    sliderInput("date", "date of arrival:",
                min =as.Date("1910-06-06","%Y-%m-%d"),
                max =as.Date("1932-12-31","%Y-%m-%d"),
                value=as.Date("1910-01-01"),
                timeFormat="%Y-%m-%d",
                animate = TRUE),
    plotOutput("Plotyplot"),
    img(src = "KH_code_expedition.png", height=100),
    img(src = "ords-sticker-hex-mv.png", height=100),
)

server <- function(input, output) {
    output$Plotyplot <- renderPlot({
      
#      data$year <- format(as.Date(data$Datum, format="%Y-%m-%d"),"%Y")
      data1 <- data[data$Datum==input$date,]
      
      ggplot(europa)+
        geom_sf(fill="beige") + 
        annotate("point", y=53.916667,x=14.25, colour = "red", size = 1) +
        geom_segment(data=data1,color="#d73027",
                     aes(xend=sw_long, yend=sw_lat, x = longitude, y = latitude),
                     arrow = arrow(length = unit(3, "mm"))) + 
        coord_sf(xlim = c(0, 30), ylim = c(40, 60), expand = FALSE, crs = 4326) +
        theme_minimal()+
        theme(axis.title.x=element_blank(),
              axis.title.y=element_blank())
      })
}

shinyApp(ui = ui, server = server)
}
