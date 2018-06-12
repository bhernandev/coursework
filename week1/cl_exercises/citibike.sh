#!/bin/bash
#
# add your solution after each of the 10 comments below
#

# count the number of unique stations
cut -d, -f4,8 201402_trip_data.csv | tr , '\n' | tail -n +3 | sort | uniq | wc -l

# count the number of unique bikes
cut -d, -f12 201402_trip_data.csv | tail -n +2 | sort | uniq | wc -l

# count the number of trips per day
cut -d, -f3 201402_trip_data.csv | tail -n +2 | cut -d' ' -f1 | sort | uniq -c

# find the day with the most rides
cut -d, -f3 201402_trip_data.csv | tail -n +2 | cut -d' ' -f1 | sort | uniq -c | sort -nr | head -n1

# find the day with the fewest rides
cut -d, -f3 201402_trip_data.csv | tail -n +2 | cut -d' ' -f1 | sort | uniq -c | sort -n | head -n1

# find the id of the bike with the most rides
cut -d, -f12 201402_trip_data.csv | tail -n +2 | sort | uniq -c | sort -nr | head -n1

# count the number of rides by gender and birth year
cut -d, -f14,15 201402_trip_data.csv | tail -n +2 | sort | uniq -c | head -n -1

# count the number of trips that start on cross streets that both contain numbers (e.g., "1 Ave & E 15 St", "E 39 St & 2 Ave", ...)
cut -d, -f5,9 201402_trip_data.csv | tail -n +2 | grep '[0-9].*&.*[0-9]' | wc -l

# compute the average trip duration
