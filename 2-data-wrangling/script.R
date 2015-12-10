setwd("/Users/Alex/Documents/mitorc/2-iap2015/OR-software-tools-2016/2-data-wrangling/")

taxidata = read.csv("2013-05-14_neighborhoods.csv",stringsAsFactors=F)

str(taxidata)

library(dplyr)
library(tidyr)
library(ggplot2)

ggplot(taxidata,aes(x=passenger_count)) + geom_histogram()

taxidata %>% count(passenger_count)

ggplot(taxidata,aes(x=trip_distance)) + geom_histogram(binwidth=0.5)

taxidata %>% ggplot(aes(x=trip_distance,y=tip_amount)) + geom_point()


### EXAMPLE 1: Aggregate Statistics ###

(taxidata$fare_amount - mean(taxidata$fare_amount))^2 %>% mean() %>% sqrt()

sqrt(mean((taxidata$fare_amount - mean(taxidata$fare_amount))^2))

taxidata$passenger_count %>% table() %>% plot()

taxidata %>%
  group_by(passenger_count) %>%
  summarize(
    faremean = mean(fare_amount),
    faremedian = median(fare_amount),
    fare75 = quantile(fare_amount,0.75)
  )

taxidata %>% count(passenger_count)

table(taxidata$passenger_count)



### EXAMPLE 2: Linear Regression ###

### EXAMPLE 3: O-D Matrix ###


### EXAMPLE 4: Joins ###

