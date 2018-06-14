########################################
# load libraries
########################################

# load some packages that we'll need
library(tidyverse)
library(scales)
library(lubridate)

# be picky about white backgrounds on our plots
theme_set(theme_bw())

# load RData file output by load_trips.R
load('trips.RData')


########################################
# plot trip data
########################################

# plot the distribution of trip times across all rides
ggplot(data = trips) +
  geom_histogram(mapping = aes(x = tripduration/60), bins=50) +
  scale_x_log10(label = comma, lim = c(1,1000)) +
  scale_y_continuous(label = comma)

# plot the distribution of trip times by rider type
ggplot(data = trips) +
  geom_histogram(mapping = aes(x=tripduration, fill=usertype), position = "dodge") +
  scale_x_log10(label = comma) + 
  scale_y_continuous(label = comma)

# plot the total number of trips over each day
mutate(trips, stopdate = as.Date(stoptime)) %>%
  group_by(stopdate) %>%
  summarize(count = n()) %>%
  ggplot() +
  geom_point(mapping = aes(x=stopdate, y=count))


# plot the total number of trips (on the y axis) by age (on the x axis) and age (indicated with color)
mutate(trips, age = 2014 - birth_year) %>%
  filter(!is.na(age)) %>%
  group_by(age, gender) %>%
  summarize(count = n()) %>%
  ggplot() +
  geom_point(mapping = aes(x=age, y=count, color=gender))
  
# plot the ratio of male to female trips (on the y axis) by age (on the x axis)
# hint: use the spread() function to reshape things to make it easier to compute this ratio
mutate(trips, age = 2014 - birth_year) %>%
  filter(age < 65) %>%
  group_by(age, gender) %>%
  summarize(count = n()) %>%
  spread(gender, count) %>%
  ggplot(mapping = aes(x=age, y=Male/Female)) +
  geom_smooth() +
  geom_point(mapping = aes(x=age, y=Male/Female))

########################################
# plot weather data
########################################
# plot the minimum temperature (on the y axis) over each day (on the x axis)
mutate(weather, date = as.Date(ymd)) %>%
ggplot() +
  geom_point(mapping = aes(x=date, y=tmin), color="purple")

# plot the minimum temperature and maximum temperature (on the y axis, with different colors) over each day (on the x axis)
# hint: try using the gather() function for this to reshape things before plotting
mutate(weather, date = as.Date(ymd)) %>%
gather(extrema, temp, tmin, tmax) %>%
ggplot() +
  geom_point(mapping = aes(x=date, y=temp, color=extrema))

########################################
# plot trip and weather data
########################################

# join trips and weather
trips_with_weather <- inner_join(trips, weather, by="ymd")

# plot the number of trips as a function of the minimum temperature, where each point represents a day
# you'll need to summarize the trips and join to the weather data to do this
trips_with_weather %>%
  group_by(tmin, ymd) %>%
  summarize(count = n()) %>%
  ggplot() +
  geom_point(mapping = aes(x=tmin,y=count))

# repeat this, splitting results by whether there was substantial precipitation or not
# you'll need to decide what constitutes "substantial precipitation" and create a new T/F column to indicate this
cutoff <- quantile(trips_with_weather$prcp, .90)
trips_with_weather %>%
  mutate(israiny = prcp >= cutoff["90%"]) %>%
  group_by(tmin, ymd, israiny) %>%
  summarize(count = n()) %>%
  ggplot() +
  geom_point(mapping = aes(x=tmin, y=count, color=israiny))

# add a smoothed fit on top of the previous plot, using geom_smooth
cutoff <- quantile(trips_with_weather$prcp, c(.90))
trips_with_weather %>%
  mutate(israiny = prcp >= cutoff["90%"]) %>%
  group_by(tmin, ymd, israiny) %>%
  summarize(count = n()) %>%
  ggplot() +
  geom_point(mapping = aes(x=tmin, y=count, color=israiny)) +
  geom_smooth(mapping = aes(x=tmin, y=count))

# compute the average number of trips and standard deviation in number of trips by hour of the day
# hint: use the hour() function from the lubridate package
trips_with_weather %>%
  mutate(hour = hour(stoptime)) %>%
  group_by(ymd, hour) %>%
  summarize(count = n()) %>%
  group_by(hour) %>%
  summarize(avg = mean(count), std = sd(count))

# plot the above
trips_with_weather %>%
  mutate(hour = hour(stoptime)) %>%
  group_by(ymd, hour) %>%
  summarize(count = n()) %>%
  group_by(hour) %>%
  summarize(avg = mean(count), std = sd(count)) %>%
  ggplot(mapping = aes(x=hour, y=avg)) +
  geom_errorbar(mapping = aes(ymin=avg-std, ymax=avg+std), width = .3) +
  geom_point() +
  scale_y_continuous(label=comma)

# plot the above 2
trips_with_weather %>%
  mutate(hour = hour(stoptime)) %>%
  group_by(ymd, hour) %>%
  summarize(count = n()) %>%
  group_by(hour) %>%
  summarize(avg = mean(count), std = sd(count)) %>%
  ggplot(mapping = aes(x=hour, y=avg)) +
  geom_line() +
  geom_ribbon(aes(ymin = avg - std, ymax = avg + std), alpha = 0.2)

# repeat this, but now split the results by day of the week (Monday, Tuesday, ...) or weekday vs. weekend days
# hint: use the wday() function from the lubridate package
trips_with_weather %>%
  mutate(hour = hour(stoptime)) %>%
  mutate(wday = wday(stoptime, label = TRUE)) %>%
  group_by(wday, ymd, hour) %>%
  summarize(count = n()) %>%
  group_by(hour,wday) %>%
  summarize(avg = mean(count), std = sd(count)) %>%
  ggplot(mapping = aes(x=hour, y=avg)) +
  geom_errorbar(mapping = aes(ymin=avg-std, ymax=avg+std), width = .3) + 
  geom_point() +
  scale_y_continuous(label=comma) +
  facet_wrap(~ wday)
