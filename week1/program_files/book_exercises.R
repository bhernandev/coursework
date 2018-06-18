library(tidyverse)

# Page 151: Question 2a
table2 %>%
  filter(type == "cases")

table4a


# Page 151: Question 2b
table2 %>%
  filter(type == "population")

table4b


# Page 151: Question 2c & 2d
table2_ratio <- table2 %>%
  spread(type, count) %>%
  mutate(ratio = (cases/population) * 10000)


table4a_cases <- table4a %>%
  gather(year, cases, `1999`, `2000`)

table4b_population <- table4b %>%
  gather(year, population, `1999`, `2000`)
  
table4_ratio <- inner_join(table4a_cases, table4b_population, by = c('country', 'year')) %>%
  mutate(ratio = (cases/population) * 10000)
