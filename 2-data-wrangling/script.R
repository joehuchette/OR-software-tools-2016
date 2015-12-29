
# PREP --------------------------------------------------------------------

# setwd("/Users/Alex/Documents/mitorc/2-iap2015/OR-software-tools-2016/2-data-wrangling/")

# Load key packages
library(dplyr)
library(ggplot2)

# Read in the data
trips = read.csv("2013-05-14_neighborhoods.csv",stringsAsFactors=F) %>% tbl_df
areas = read.csv('area_info.csv', stringsAsFactors=F) %>% tbl_df

# Check what we have
str(trips)
str(areas)

# 0. CHAINING -------------------------------------------------------------

# Chaining helps us keep our code and workspace clean. Let's work through some
# quick examples.

# EX 0.1 ------------------------------------------------------------------
# For example, suppose we want to calculate the standard deviation of a 
# numeric vector. First, here's a 'nested functions' approach to solving this 
# problem: 

sqrt(mean((trips$fare_amount - mean(trips$fare_amount))^2))

# Next, here's a 'intermediate assignment' approach using intermediate vectors:

m = mean(trips$fare_amount)
devs = trips$fare_amount - m
devs2 = devs^2
var = mean(devs2)
sqrt(var)

# Finally, here's a chaining approach: it's a bit more to type, but it's easier
# to read than the 'nested functions' approach and avoids intermediate assignments.

(trips$fare_amount - mean(trips$fare_amount))^2 %>% mean() %>% sqrt()

# EX. 0.2 -----------------------------------------------------------------
# Suppose we want to compute a histogram for a numeric column. Let's work through 
# the multiple-assignment approach together. In words, we want to:
## Take the passenger_count column of trips
## Then use the table() function to count the number of trips for each count
## Then plot() the result

# SOL. 0.2: -----
plot(table(trips$passenger_count))

# EX. 0.3 -----------------------------------------------------------------
# Ok, now let's execute the same task using chaining: 

# SOL. 0.3: -----
trips$passenger_count %>% table() %>% plot()

# EXERCISE 0.0 ------------------------------------------------------------
# Go to EXERCISES 0.0 in the file exercises.R, where you'll expand on 
# this last example. 



# 1. EXPLORING AND SUMMARIZING DATA SET -----------------------------------

### EXAMPLE 1: Aggregate Statistics ###

### Aggregation

# Create mean column
trips %>%
  group_by(passenger_count) %>%
  summarize(faremean = mean(fare_amount))
# Introduce group_by and summarize on a slide


# Add median column in same step
trips %>%
  group_by(passenger_count) %>%
  summarize(
    faremean = mean(fare_amount),
    faremedian = median(fare_amount)
  )

# Why is mean so much higher for passenger count 0?
table(trips$passenger_count)
trips %>% count(passenger_count)
# Introduce count?

# Notice only 3 trips had 0 passenger count
# Let's just filter out trips with 0 passengers
trips %>%
  group_by(passenger_count) %>%
  summarize(
    faremean = mean(fare_amount),
    faremedian = median(fare_amount)
  ) %>%
  filter(passenger_count != 0)
# Introduce filter?

# Let's sort by faremean
trips %>%
  group_by(passenger_count) %>%
  summarize(
    faremean = mean(fare_amount),
    faremedian = median(fare_amount)
  ) %>%
  filter(passenger_count != 0) %>%
  arrange(faremean)

# Now what if I want descending order by faremean
trips %>%
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
trips %>%
  select(passenger_count,fare_amount,tip_amount)
# Introduce select

# Now let's create a column for tip percent
# We'll use the mutate verb
# BaseR
trips$tip_percent = trips$tip_amount / trips$fare_amount

# Dplyr
trips %>%
  select(passenger_count,fare_amount,tip_amount) %>%
  mutate(tip_percent = tip_amount / fare_amount)

# Let's see what the new column looks like
trips %>%
  select(passenger_count,fare_amount,tip_amount) %>%
  mutate(tip_percent = tip_amount / fare_amount) %>%
  summary()
#Introduce mutate

# Let's save that and remove tip_amount, which we don't need anymore
linregdata = trips %>%
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
trips %>% count(pdistrict,ddistrict)
# Introduce count function

#Let's remove NA's
trips %>%
  count(pdistrict,ddistrict) %>%
  filter(
    !is.na(pdistrict),
    !is.na(ddistrict)
  )

# Our data is long format, but we want columns for ddistrict rather than repeated rows.
# Data in this format is not very efficient, but it is pretty easy to work with because there are only 3 columns, easy filtering, etc. For more reading on this topic...
trips %>%
  count(pdistrict,ddistrict) %>%
  filter(
    !is.na(pdistrict),
    !is.na(ddistrict)
  ) %>%
  spread(ddistrict,n)

# We can tell tidyr to use something other than NA to fill when it doesn't have a value
trips %>%
  count(pdistrict,ddistrict) %>%
  filter(
    !is.na(pdistrict),
    !is.na(ddistrict)
  ) %>%
  spread(ddistrict,n,fill=0)

trips %>%
  count(pdistrict,ddistrict) %>%
  filter(
    !is.na(pdistrict),
    !is.na(ddistrict)
  ) %>%
  ggplot(aes(x=pdistrict,y=ddistrict)) + geom_point(aes(size=n,alpha=n))

trips %>%
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
trips %>%
  select(passenger_count,rate_code) %>%
  rename(Code = rate_code)
#Simpler version
trips %>%
  select(passenger_count,Code=rate_code)

# Introduce select naming and rename
trips %>%
  select(passenger_count,Code=rate_code) %>%
  left_join(rate_code_map)

# Now let's count by passenger_count and RateClass
trips %>%
  select(passenger_count,Code=rate_code) %>%
  left_join(rate_code_map) %>%
  count(passenger_count,RateClass)

# Now let's look at a cross-table grid
trips %>%
  select(passenger_count,Code=rate_code) %>%
  left_join(rate_code_map) %>%
  count(passenger_count,RateClass) %>%
  spread(passenger_count,n,fill=0)
  
# Sometimes you want to save an intermediate df after joining if the join takes a long time to run


## ASSIGNMENT: Map neighborhood names and creat O-D Matrix

