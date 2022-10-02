library(tidyverse)

dat <- read_csv("data.csv")

df <- dat %>% 
  group_by(Wohnort, Datum) %>% 
  summarize(Anzahl = n())

write.csv(df, "data2.csv", row.names = FALSE)
