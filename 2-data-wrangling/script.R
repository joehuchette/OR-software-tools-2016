
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
# Show 'nested function', 'intermediate assignment', and chaining approaches
# to computing the standard deviation of a numeric vector. 

# nested function

# intermediate assignment

# chaining

# SOL. 0.1 ----------------------------------------------------------------

# nested function
sqrt(mean((trips$fare_amount - mean(trips$fare_amount))^2))

# intermediate assignment
m = mean(trips$fare_amount)
devs = trips$fare_amount - m
devs2 = devs^2
var = mean(devs2)
sqrt(var)

# chaining 
(trips$fare_amount - mean(trips$fare_amount))^2 %>% mean() %>% sqrt()

# chaining requires a bit more typing, but is more legible and easier on your 
# computer's memory. 

# EX. 0.2 -----------------------------------------------------------------
# Suppose we want to compute a histogram for a numeric column. Let's work through 
# the multiple-assignment approach together. In words, we want to:
## Take the passenger_count column of trips
## Then use the table() function to count the number of trips for each count
## Then plot() the result


# SOL. 0.2 ----------------------------------------------------------------


plot(table(trips$passenger_count))

# EX. 0.3 -----------------------------------------------------------------
# Ok, now let's execute the same task using chaining: 

# SOL. 0.3: -----
trips$passenger_count %>% table() %>% plot()

# 1. EXPLORING AND SUMMARIZING DATA SET -----------------------------------

# We'll do some informal exploration of the relationship between passenger_count
# and fare_amount. We'll do some more formal analysis in the next section. 

# EX. 1.1 -----------------------------------------------------------------
# Compute the mean of fare_amount. Then compute means of fare_amount and 
# passenger_count simultaneously. What about medians? 

# SOL. 1.1 ----------------------------------------------------------------

# means
trips %>%
	summarise(fare_mean = mean(fare_amount),
			  passenger_mean = mean(passenger_count))

# medians
trips %>%
	summarise(fare_mean = median(fare_amount),
			  passenger_mean = median(passenger_count))

# EX. 1.2 -----------------------------------------------------------------
# Compute means of fare_amount for each number of passengers. What's weird about 
# the result? 

# SOL. 1.2 ----------------------------------------------------------------

trips %>%
  group_by(passenger_count) %>%
  summarize(fare_mean = mean(fare_amount))

# Weird: fare_mean is so much higher for passenger_count = 0

# EX. 1.3 -----------------------------------------------------------------
# Add a column to our table with the count of trips in each category.

# SOL. 1.3 ----------------------------------------------------------------

trips %>%
  group_by(passenger_count) %>%
	summarize(fare_mean = mean(fare_amount),
			  n = n())

# Could get just the counts faster: 
trips %>% count(passenger_count)

# EX. 1.4 -----------------------------------------------------------------
# Reproduce the summary table from the last example, but with passenger_count=0
# trips filtered out. 

# SOL. 1.4 ----------------------------------------------------------------

trips %>%
	filter(passenger_count != 0) %>%
	group_by(passenger_count) %>%
	summarize(faremean = mean(fare_amount),
			  n = n())
  

# EX. 1.5 -----------------------------------------------------------------
# What are the most common number of persons per ride? What number of passengers
# tend to give the largest fares? Let's get some practice sorting. 

# SOL. 1.5 ----------------------------------------------------------------

# Let's sort by fare_mean

tab = trips %>%
	group_by(passenger_count) %>%
	summarize(fare_mean = mean(fare_amount),
			  n = n()) %>%
	filter(passenger_count != 0)

# Ascending order by fare_mean
tab %>% arrange(fare_mean)
# Descending order by fare_mean
tab %>% arrange(desc(fare_mean))


# Let's add a column for tip_mean and sort by that instead.
tab = trips %>%
	group_by(passenger_count) %>%
	summarize(fare_mean = mean(fare_amount),
			  tip_mean = mean(tip_amount),
			  n = n()) %>%
	filter(passenger_count != 0) 

# Ascending order by tip_mean
tab %>% arrange(tip_mean)
# Descending order by tip_mean
tab %>% arrange(desc(tip_mean))

# Note: sorting is intrinsically unstable, but you can you can 'save state' by 
# adding a column for ranks if you'll be using the order in your analysis.   

tab %>% mutate(fare_rank = rank(desc(fare_mean)),
			   tip_rank = rank(desc(tip_mean)),
			   most_common = rank(desc(n))) %>%
	select(passenger_count, fare_rank, tip_rank, most_common)

# So, lone passengers in this data set paid the lowest fares but the highest tips.
# We haven't done any inferential stats here, so this could easily be noise. 

# 2. PREPPING DATA FOR ANALYSIS -------------------------------------------

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

# 3. ORIGIN-DESTINATION MATRIX --------------------------------------------
# In this section, we'll create an origin-destination (OD) matrix. An OD matrix 
# is a matrix where the ij-th entry counts the number of trips from origin i to
# destination j. 
# Here, we'll use functions from tidyr, a great companion to dplyr for reshaping
# data sets. In the exercises, you'll explore a different approach using 
# dplyr functions only. 

# EX. 3.1 -----------------------------------------------------------------
# Create an OD matrix on the district-number level; i.e. the rows are 
# pdistrict (p for pickup) and the columns are ddistrct (d for dropoff).

# SOL. 3.1 ----------------------------------------------------------------

library(tidyr)

# Let's look at how many trips there were for each O-D pair
counts = trips %>% count(pdistrict,ddistrict)
# Introduce count function

counts = counts %>% 
	filter(!is.na(pdistrict),
		   !is.na(ddistrict))

# Our data is in 'long' or 'tidy' format, where each possible value of pdistrict
# and ddistrict has its own row. This is inefficient, but great in many 
# applications because there are few columns, filtering is easy, etc. Data in 
# this format is not very efficient, but it is pretty easy to work with because 
# there are only 3 columns, easy filtering, etc. However, we want 'wide' format,
# in which each value of ddistrict will have its own column. 

counts %>% spread(ddistrict, n)

# Pretty good, but we should use 0s instead of NAs for pairs with no trips. 

counts %>% spread(ddistrict, n, fill=0)  

# This is still pretty hard to read. We can visualize it: 
counts %>% ggplot(aes(x=pdistrict,y=ddistrict)) + 
	geom_point(aes(size=n,alpha=n))
# but it's still unclear what to make of this. 

# EX. 3.2 -----------------------------------------------------------------
# A cleaner approach is to bin by a more interpretable set of origins and 
# destinations. Each district number corresponds to a borough. We'd like to 
# look up the borough for each district number and make an OD matrix by 
# borough instead. To get the borough, we'll need to use joins. 

# SOL. 3.2 ----------------------------------------------------------------
# This one needs some talking-through. Our strategy is to: 
## Grab only the columns we need
## Add a unique id for each trip using the row_number() function
## Convert to long format using gather, a tidyr function
## Join using to the areas data set to get the borough for each district
## Grab only the columns we need and 'spread' into matrix format
## Rename and clean up

m <- trips %>% 
	select(pdistrict, ddistrict) %>%
	mutate(trip_id = row_number()) %>%
	gather(p_or_d, district, -trip_id) %>%
	left_join(areas, by = c('district' = 'id')) %>%
	select(trip_id, p_or_d, borough) %>%
	spread(key = p_or_d, value = borough) %>%
	rename(pborough = pdistrict, dborough = ddistrict) %>%
	filter(!is.na(dborough), !is.na(pborough)) %>%
	count(pborough, dborough) %>%
	spread(key = dborough, value = n, fill = 0) # convert to `matrix shaped' df

m

# This is also a bit easier to visualize: 

m <- m %>% select(-pborough) %>% data.matrix
rownames(m) <- colnames(m)
heatmap(m, symm = TRUE, scale = 'row')

