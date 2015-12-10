setwd("/Users/Alex/Documents/mitorc/2-iap2015/OR-software-tools-2016/2-data-wrangling/")

taxidata = read.csv("2013-05-14_neighborhoods.csv",stringsAsFactors=F)

str(taxidata)

library(dplyr)
library(ggplot2)

ggplot(taxidata,aes(x=passenger_count)) + geom_histogram()

taxidata %>% count(passenger_count)

ggplot(taxidata,aes(x=trip_distance)) + geom_histogram(binwidth=0.5)

taxidata %>% ggplot(aes(x=trip_distance,y=tip_amount)) + geom_point()
taxidata %>% ggplot(aes(x=fare_amount,y=tip_amount)) + geom_point()

# For display purposes
taxidata = tbl_df(taxidata)

### EXAMPLE 1: Aggregate Statistics ###

### Chaining

# Calculating standard deviation - No nesting
sqrt(mean((taxidata$fare_amount - mean(taxidata$fare_amount))^2))

(taxidata$fare_amount - mean(taxidata$fare_amount))^2 %>% mean() %>% sqrt()


# Histogram - no intermediate step
taxidata$passenger_count %>% table() %>% plot()

### Creating aggregate stats table

# Create mean column
taxidata %>%
  group_by(passenger_count) %>%
  summarize(faremean = mean(fare_amount))
# Introduce group_by and summarize on a slide


# Add median column in same step
taxidata %>%
  group_by(passenger_count) %>%
  summarize(
    faremean = mean(fare_amount),
    faremedian = median(fare_amount)
  )

# Why is mean so much higher for passenger count 0?
table(taxidata$passenger_count)
taxidata %>% count(passenger_count)
# Introduce count?

# Notice only 3 trips had 0 passenger count
# Let's just filter out trips with 0 passengers
taxidata %>%
  group_by(passenger_count) %>%
  summarize(
    faremean = mean(fare_amount),
    faremedian = median(fare_amount)
  ) %>%
  filter(passenger_count != 0)
# Introduce filter?

# Let's sort by faremean
taxidata %>%
  group_by(passenger_count) %>%
  summarize(
    faremean = mean(fare_amount),
    faremedian = median(fare_amount)
  ) %>%
  filter(passenger_count != 0) %>%
  arrange(faremean)

# Now what if I want descending order by faremean
taxidata %>%
  group_by(passenger_count) %>%
  summarize(
    faremean = mean(fare_amount),
    faremedian = median(fare_amount)
  ) %>%
  filter(passenger_count != 0) %>%
  arrange(desc(faremean))

## ADD ASSIGNMENT for Section 1
# Create log histogram of fare amount
# Introduce cut function

# Maybe have them make a function that calculates a statistical summary

### EXAMPLE 2: Linear Regression ###
# Predict tip percentage based on passenger count and fare amount

# First let's just take the columns we actually will need. This will be cleaner.
taxidata %>%
  select(passenger_count,fare_amount,tip_amount)
# Introduce select

# Now let's create a column for tip percent
# We'll use the mutate verb
# BaseR
taxidata$tip_percent = taxidata$tip_amount / taxidata$fare_amount

# Dplyr
taxidata %>%
  select(passenger_count,fare_amount,tip_amount) %>%
  mutate(tip_percent = tip_amount / fare_amount)

# Let's see what the new column looks like
taxidata %>%
  select(passenger_count,fare_amount,tip_amount) %>%
  mutate(tip_percent = tip_amount / fare_amount) %>%
  summary()
#Introduce mutate

# Let's save that and remove tip_amount, which we don't need anymore
linregdata = taxidata %>%
  select(passenger_count,fare_amount,tip_amount) %>%
  mutate(tip_percent = tip_amount / fare_amount) %>%
  select(-tip_amount)

mod = lm(tip_percent ~ ., data=linregdata)
summary(mod)

# Add assignment

### EXAMPLE 3: O-D Matrix ###
# Let's create a matrix where rows are origins, columns are destinations, and each cell contains the number of trips for that O-D pair

library(tidyr)

# Let's look at how many trips there were for each O-D pair
taxidata %>% count(pdistrict,ddistrict)
# Introduce count function

#Let's remove NA's
taxidata %>%
  count(pdistrict,ddistrict) %>%
  filter(
    !is.na(pdistrict),
    !is.na(ddistrict)
  )

# Our data is long format, but we want columns for ddistrict rather than repeated rows.
# Data in this format is not very efficient, but it is pretty easy to work with because there are only 3 columns, easy filtering, etc. For more reading on this topic...
taxidata %>%
  count(pdistrict,ddistrict) %>%
  filter(
    !is.na(pdistrict),
    !is.na(ddistrict)
  ) %>%
  spread(ddistrict,n)

# We can tell tidyr to use something other than NA to fill when it doesn't have a value
taxidata %>%
  count(pdistrict,ddistrict) %>%
  filter(
    !is.na(pdistrict),
    !is.na(ddistrict)
  ) %>%
  spread(ddistrict,n,fill=0)

taxidata %>%
  count(pdistrict,ddistrict) %>%
  filter(
    !is.na(pdistrict),
    !is.na(ddistrict)
  ) %>%
  ggplot(aes(x=pdistrict,y=ddistrict)) + geom_point(aes(size=n,alpha=n))

taxidata %>%
  count(pdistrict,ddistrict) %>%
  filter(
    !is.na(pdistrict),
    !is.na(ddistrict)
  ) %>%
 ungroup %>%
  arrange(desc(n))

### EXAMPLE 3: Rate codes vs. passenger counts

# Rate code mapping
# rate_code_map = data.frame(RateClass = c("Standard rate", "JFK", "Newark", "Nassau or Westchester", "Negotiated fare", "Group ride"), Code = 1:6)
# 
# write.csv(rate_code_map,"rate_code_map.csv",row.names = F)
rate_code_map = read.csv("rate_code_map.csv",stringsAsFactors = F)

# Rename version
taxidata %>%
  select(passenger_count,rate_code) %>%
  rename(Code = rate_code)
#Simpler version
taxidata %>%
  select(passenger_count,Code=rate_code)

# Introduce select naming and rename
taxidata %>%
  select(passenger_count,Code=rate_code) %>%
  left_join(rate_code_map)

# Now let's count by passenger_count and RateClass
taxidata %>%
  select(passenger_count,Code=rate_code) %>%
  left_join(rate_code_map) %>%
  count(passenger_count,RateClass)

# Now let's look at a cross-table grid
taxidata %>%
  select(passenger_count,Code=rate_code) %>%
  left_join(rate_code_map) %>%
  count(passenger_count,RateClass) %>%
  spread(passenger_count,n,fill=0)
  
# Sometimes you want to save an intermediate df after joining if the join takes a long time to run


## ASSIGNMENT: Map neighborhood names and creat O-D Matrix

