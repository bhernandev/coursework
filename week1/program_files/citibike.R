library(tidyverse)
library(lubridate)

########################################
# READ AND TRANSFORM THE DATA
########################################

# read one month of data
trips <- read_csv('201402-citibike-tripdata.csv')

# replace spaces in column names with underscores
names(trips) <- gsub(' ', '_', names(trips))

# convert dates strings to dates
# trips <- mutate(trips, starttime = mdy_hms(starttime), stoptime = mdy_hms(stoptime))

# recode gender as a factor 0->"Unknown", 1->"Male", 2->"Female"
trips <- mutate(trips, gender = factor(gender, levels=c(0,1,2), labels = c("Unknown","Male","Female")))


########################################
# YOUR SOLUTIONS BELOW
########################################

# count the number of trips (= rows in the data frame)
count(trips)

# find the earliest and latest birth years (see help for max and min to deal with NAs)
min(as.numeric(trips$birth_year), na.rm = TRUE)
max(as.numeric(trips$birth_year), na.rm = TRUE)

# use filter and grepl to find all trips that either start or end on broadway
filter(trips, grepl('Broadway', start_station_name) | grepl('Broadway', end_station_name))

# do the same, but find all trips that both start and end on broadway
filter(trips, grepl('Broadway', start_station_name) & grepl('Broadway', end_station_name))

# find all unique station names
union(trips$start_station_name, trips$end_station_name)

# count the number of trips by gender
group_by(trips, gender) %>% count()

# compute the average trip time by gender
group_by(trips, gender) %>% summarize(avg_trip_time = mean(tripduration))

# comment on whether there's a (statistically) significant difference
# There is not a statistically significant difference.

# find the 10 most frequent station-to-station trips
select(trips, start_station_id, end_station_id) %>% group_by(start_station_id, end_station_id) %>% summarize(count = n()) %>% ungroup() %>% filter(rank(desc(count)) < 10)

# find the top 3 end stations for trips starting from each start station
select(trips, start_station_id, end_station_id) %>% group_by(start_station_id, end_station_id) %>% summarize(count = n()) %>% ungroup() %>% group_by(start_station_id) %>%  filter(rank(desc(count)) < 4)

# find the top 3 most common station-to-station trips by gender
select(trips, start_station_id, end_station_id, gender) %>% group_by(start_station_id, end_station_id, gender) %>% summarize(count = n()) %>% ungroup() %>% group_by(gender) %>% filter(rank(desc(count)) < 4) %>% arrange(gender, desc(count))

# find the day with the most trips
# tip: first add a column for year/month/day without time of day (use as.Date or floor_date from the lubridate package)
select(trips, stoptime) %>% filter(!is.na(stoptime)) %>% mutate(date = as.Date(stoptime)) %>% group_by(date) %>% summarize(count = n()) %>% arrange(desc(count)) %>% filter(row_number() == 1)

# compute the average number of trips taken during each of the 24 hours of the day across the entire month
select(trips, starttime) %>% filter(!is.na(starttime)) %>% mutate(hour = hour(starttime)) %>% mutate(date = as.Date(starttime)) %>% group_by(hour, date) %>% summarize(count = n()) %>% ungroup() %>% group_by(hour) %>% summarize(avg = mean(count))

# what time(s) of day tend to be peak hour(s)?
select(trips, starttime) %>% filter(!is.na(starttime)) %>% mutate(hour = hour(starttime)) %>% mutate(date = as.Date(starttime)) %>% group_by(hour, date) %>% summarize(count = n()) %>% ungroup() %>% group_by(hour) %>% summarize(avg = mean(count)) %>% arrange(desc(avg))
