library(tidyverse)
library(lubridate)

dat <- read_csv("temperatur-greifswald.csv")

dat <- dat %>% 
  filter(between(lubridate::year(Zeitstempel), 1910, 1930))
         
write.csv(dat,
          "temperatur-greifswald.csv",
          row.names = FALSE)
