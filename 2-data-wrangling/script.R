
### LOADING THE DATA ###

# Let's read in the dataset describing NYC taxi trips on May 14, 2013. 
# Don't forget to start by navigating to the directory where you've saved the CSV file.
# We'll set stringsAsFactors to FALSE just to make sure nothing gets converted to a factor variable that we don't want.
trips = read.csv("2013-05-14_neighborhoods.csv",stringsAsFactors=F) 
# This might take a few seconds since it's a fairly large file.

# As usual, the first thing we want to do any time we load a new dataset is look at what we just loaded.
str(trips)
# We have 490,347 observations of 21 variables.


### 0. CHAINING AND OTHER PRELIMINARIES ###
### ___________________________________ ###

# Before we get to wrangling our data, let's start by learning a few tricks built in to the dplyr package that will make all of our data wrangling tasks easier.

# First we'll need to load the dplyr package
# If you haven't already installed the dplyr package, you should do that first
install.packages("dplyr")
# Then load the package
library(dplyr)

# The first trick that will make our lives a bit easier is to convert our data frame to a special kind of data frame called a "tbl_df"
trips = tbl_df(trips)

# tbl_df's operate in exactly the same way as regular data frames. The advantage is that they display in the console in a more compact format so you can safely glimpse the data frame without printing all 490,000 rows.

# The second trick that we'll use throughout the rest of today's session is chaining.

# Chaining helps us keep our code and workspace clean. Let's learn how it works.

###-------------

# Let's look at an example of how chaining can make our code more legible.

# Let's say we want to calculate the standard deviation of the taxi fare amount in our data.

# We know how to calculate the standard deviation using baseR. It's just the square root of the average squared difference from the mean.
# (Let's pretend for now that R doesn't provide the sd() function for this very purpose)
sqrt(mean((trips$fare_amount - mean(trips$fare_amount))^2))

# But that's a bit of a mess, with lots of open and closed parentheses to keep track of.

# We could use chaining to make this code more legible and write-able.
# We'll start with the squared differences from the mean.
(trips$fare_amount - mean(trips$fare_amount))^2 
# Then we'll take the mean of that expression
(trips$fare_amount - mean(trips$fare_amount))^2 %>% mean()
# Finally we'll take that entire expression and take the square root of it.
(trips$fare_amount - mean(trips$fare_amount))^2 %>% mean() %>% sqrt()

# Notice that we didn't store any of the intermediate expressions. This is another advantage of chaining.

###-------------
# Here's another example. 
# Suppose we want to compute a histogram of the number of passengers on each trip. 
# In words, we want to:
## Take the passenger_count column of trips.
trips$passenger_count
## Then use the table() function to count the number of trips for each count.
trips$passenger_count %>% table()
## Then plot() the result.
trips$passenger_count %>% table() %>% plot()

# Chaining makes it easy to complete these steps in a legible way without storing intermediate objects.

# Furthermore, if we first looked at the table and then decided we want to plot it, we can just use chaining to tack on the plot() function, rather than having to add it "around" our original expression.
plot(table(trips$passenger_count))


# Chaining requires a bit more typing, but is more legible and easier on your computer's memory than storing intermediate objects. 

# OK, now let's wrange some data.


### 1. EXPLORING AND SUMMARIZING DATA SET ###
### _____________________________________ ###

# The first thing we typically want to do with any dataset is data exploration.
# We saw on Tuesday how the summary() function can provide some useful summary statistics for any data frame.
summary(trips)

# That's pretty helpful. But what if we want to compute aggregate statistics at a more granular level.

# How can we answer the question, "What are the mean and median fare amounts by number of passengers?"

# To answer that question, we'll need to learn our first set of dplyr verbs: group_by and summarize.

###-------------

# Ok, now we're ready to go back and answer our question: what is the mean and median fare by number of passengers.
# First, we can find the mean.
# We take trips, group it by passenger_count, and then summarize the mean fare_amount within each group.
trips %>%
  group_by(passenger_count) %>%
  summarize(fare_mean = mean(fare_amount))

# Note that this chained set of commands creates a new data frame. We could choose to assign this object to a name.
mean_fare_by_passenger_count = trips %>%
  group_by(passenger_count) %>%
  summarize(fare_mean = mean(fare_amount))

mean_fare_by_passenger_count

# When doing data exploration, we may choose not to store the object. It may be sufficient to print it to the console.

# Just out of curiosity, what happens if we use group_by without summarize?
trips %>%
  group_by(passenger_count)
# Interesting, it looks the same as trips, but it is a grouped data frame.
# We could save this as its own object.
grouped_trips = trips %>%
  group_by(passenger_count)
# Then if we apply summarize to the new object, and it returns aggregate statistics for each group.
grouped_trips %>%
  summarize(fare_mean = mean(fare_amount))

# Another question: What if we use summarize without group_by?
trips %>%
  summarize(fare_mean = mean(fare_amount))
# Cool. It just yields an overall aggregate statistic on the un-grouped data frame.

# Something interesting just happened: When we apply summarize to trips, it yields the overall mean. But when we apply the same summarize statement to grouped_trips, it yields grouped means.
# What if we want to get the overall fare mean from grouped_trips? We can use ungroup().
grouped_trips %>%
  ungroup()
# Ungroup removes all groups. Now we can calculate the overall mean with summarize.
grouped_trips %>%
  ungroup() %>%
  summarize(fare_mean = mean(fare_amount))

# Ok, back to the task at hand:
# So far we've only calculated mean, but we also wanted median.
# We can just add another argument within summarize, separated by commas, to create another column.
# I like to write each new column on a separate line of code.
trips %>%
  group_by(passenger_count) %>%
  summarize(
    fare_mean = mean(fare_amount),
    fare_median = median(fare_amount)
  )

# Notice anything weird about the mean and median?
# It seems a lot higher for trips with 0 passengers.
# But what is a trip with 0 passengers?

# Let's add a column "n" to our data frame showing how many trips are in dataset for each passenger count.

# We can use the n() function which is a helper verb for summarize that reports the "n" of each group.

trips %>%
  group_by(passenger_count) %>%
  summarize(
    fare_mean = mean(fare_amount),
    fare_median = median(fare_amount),
    n = n()
  )

# Ok, that explains it. There are only 3 trips with 0 passengers. Maybe they were coding errors.

# What if don't want to include these weird trips in our summary table?

# We learned one way to do this on Tuesday using the subset() function. dplyr provides a similar function called filter().
# Let's explore these functions

###-------------

# Ok, let's filter trips before computing our summary stats.
# We'll include only trips where passenger_count is not zero.
trips %>%
	filter(passenger_count != 0)

# Good - our new data frame has 3 fewer rows.
# Let's double-check it did what we wanted.
summary(trips$passenger_count)

# Now let's calculate our summary table for this subset of the data. We'll just tack on the same commands we used before.
trips %>%
  filter(passenger_count != 0) %>%
  group_by(passenger_count) %>%
  summarize(
    fare_mean = mean(fare_amount),
    fare_median = median(fare_amount),
    n = n()
  )

# In this case, because we are only filtering based on one condition, we could have also used subset.
trips %>%
  subset(passenger_count != 0) %>%
  group_by(passenger_count) %>%
  summarize(
    fare_mean = mean(fare_amount),
    fare_median = median(fare_amount),
    n = n()
  )

# Also, we chose to filter out the 0's before we calculated our summary stats.
# But we could have calculated summary stats and then filtered, with the same results (Warning: may not always be the case)
# Notice how easy it is to slide the filter statement "down the chain"
trips %>%
  group_by(passenger_count) %>%
  summarize(
    fare_mean = mean(fare_amount),
    fare_median = median(fare_amount),
    n = n()
  ) %>%
  filter(passenger_count != 0)


# Now that we've got some summary stats, we might have some other questions as we continue our data exploratin.
# What number of passengers tend to give the largest fares?
# To answer this, we need to learn how to sort our data frame.
# To sort, we use the arrange() verb from dplyr.

###-------------


# Let's sort our summary table by fare_mean
# We'll just add an arrange clause at the end of the chain.

trips %>%
  filter(passenger_count != 0) %>%
  group_by(passenger_count) %>%
  summarize(
    fare_mean = mean(fare_amount),
    fare_median = median(fare_amount),
    n = n()
  ) %>%
  arrange(fare_mean)

# This sorted our summary data in ascending order of fare_mean.
# We can see that trips with 1 passenger have the lowest average fare.

# It might be convenient at this point to save our summary stats as an object since we are just planning to sort the data frame by various columns.
trips_summary = trips %>%
  filter(passenger_count != 0) %>%
  group_by(passenger_count) %>%
  summarize(
    fare_mean = mean(fare_amount),
    fare_median = median(fare_amount),
    n = n()
  )

trips_summary %>%
  arrange(fare_mean)

# What if we wanted to sort in descending order of fare_mean?
# We can use desc()
trips_summary %>%
  arrange(desc(fare_mean))

# Since we observe that the fare median is often 9.5, we could sort by fare median and then by descending order of n.
trips_summary %>%
  arrange(fare_median, desc(n))

# Ok, we've learned a bunch of dplyr verbs that helped us compute aggregate statistics (group_by, summarize), filter our data (filter), and sort our data (arrange).

# Let's practice!
# Complete Exercise 1 working on your own or with the person sitting next to you.

# ______

# Now let's move on to data wrangling for some more formal data analysis.


### 2. PREPPING DATA FOR ANALYSIS ###
### ----------------------------- ###

# ______

# But first let's learn how we can derive new columns/covariates.

# Let's say we want to build a linear regression model to see if we can predict tip percentage based on passenger count and fare amount

# Right now we have 21 columns. We only need two of them (passenger_count and fare_amount). We also need to create a tip percentage column.

# Since we only need a few of our existing columns, let's just work with those ones - the full dataset is a bit unwieldy.

# We can use the select() function.

# ______

# Ok, let's select just the passenger count, fare amount, and also tip amount, which we'll need to calculate the tip percentage.

trips %>%
  select(passenger_count,fare_amount,tip_amount)

# Now we can see all three columns we are dealing with.

# Ok, we are almost ready to supply this data frame to lm().
# But we're missing our dependent variable!

# We know we want a new column that calculates tip percentage by dividing tip amount by fare amount.

# We could do this using baseR
trips$tip_percent = trips$tip_amount / trips$fare_amount

# But dplyr provides the mutate() verb to create new columns.
# mutate() has some advantages over the baseR approach.

# Before we explore those advantages, let's use select to remove that tip_percent column we just created.

trips = trips %>%
  select(-tip_percent)

# ______

# Let's use dplyr to create a new tip_percent column.
trips %>%
  select(passenger_count,fare_amount,tip_amount) %>%
  mutate(tip_percent = tip_amount / fare_amount)

# Let's see what the new column looks like
trips %>%
  select(passenger_count,fare_amount,tip_amount) %>%
  mutate(tip_percent = tip_amount / fare_amount) %>%
  summary()

# Ok, there's a bit of a weird outlier, but everything else looks good.

# Let's save our linear regression data and remove tip_amount, which we don't need anymore.
linregdata = trips %>%
  select(passenger_count,fare_amount,tip_amount) %>%
  mutate(tip_percent = tip_amount / fare_amount) %>%
  select(-tip_amount)

# Now we'll run the linear regression and see how it looks.
mod = lm(tip_percent ~ ., data=linregdata)
summary(mod)

# 3. ORIGIN-DESTINATION MATRIX --------------------------------------------
# One good question for a data set like this is: what 'trip patterns' tend to 
# be most common? One answer to this question is an origin-destination (OD) 
# matrix, in which the ij-th entry counts the number of trips from origin i to 
# destination j. Let's explore how to create an OD matrix using functions from 
# tidyr, a great companion to dplyr for reshaping data sets. 

# First, we'll create an OD matrix on the district-number level. We'll use the 
# pdistrict and ddistrict columns. Let's take a look: 

trips %>% select(pdistrict, ddistrict) %>% glimpse

# Looks like we've got some NAs; how many? We can find out using our old friends
# select() and filter(). Note the use of the 'or' operator | in the filter 
# call. 

trips %>% select(pdistrict, ddistrict) %>% 
	filter(is.na(pdistrict) | is.na(ddistrict)) %>%
	summarise(n = n())

# So, there are about 16K NA missing data rows out of almost 500K observations; 
# not too bad. We'll need to filter them out later. 

# Ok, now we're ready to make that matrix. The first tool we'll want is the 
# count function, which is a convenient shortcut for situations where you would 
# use groupby() and n() to count objects by category. To illustrate, note that 
# we could rewrite the last block of code using count: 

trips %>% select(pdistrict, ddistrict) %>% 
	filter(is.na(pdistrict) | is.na(ddistrict)) %>%
	count

# For a more interesting usage, let's look at how many trips there were for each
# O-D pair
trips %>% count(pdistrict,ddistrict)
# Not bad, but let's filter out those NAs. It's probably easiest to do this 
# before doing anything else: 

trips %>% 
	filter(!is.na(pdistrict),
		   !is.na(ddistrict)) %>%
	count(pdistrict, ddistrict)

# Our data is in 'long' or 'tidy' format, where each possible value of pdistrict
# and ddistrict has its own row. This is inefficient, but great in many 
# applications because there are few columns, filtering is easy, etc. Data in 
# this format is not very efficient, but it is pretty easy to work with because 
# there are only 3 columns, easy filtering, etc. However, we want 'wide' format,
# in which each value of ddistrict will have its own column. To do this, we'll
# use the tidyr function spread(). In this basic usage, we just tell spread() 
# which column to 'spread out' ddistrict and use n for the values in the resulting
# columns.  We'll go into more detail on spread() below. 

library(tidyr)
trips %>% 
	filter(!is.na(pdistrict),
		   !is.na(ddistrict)) %>%
	count(pdistrict, ddistrict) %>%
	spread(ddistrict,n)

# Pretty good, but we should use 0s instead of NAs for pairs with no trips. We 
# can do this using spread()'s fill parameter. 

trips %>% 
	filter(!is.na(pdistrict),
		   !is.na(ddistrict)) %>%
	count(pdistrict, ddistrict) %>%
	spread(ddistrict,n, fill = 0)

# This is a good start, but we have a data overload problem: there's just too 
# much here to handle! It would be more interpretable if we could group by 
# borough instead of by individual district. To do that, we'll need to 
# add two columns for the pickup borough and dropoff borough. This information
# is coded in pdistrict and ddistrict, but we need to access it using 
# joins. 

# --------------------------------------------------------------------------
# A cleaner approach is to bin by a more interpretable set of origins and 
# destinations. Each district number corresponds to a borough. We'd like to 
# look up the borough for each district number and make an OD matrix by 
# borough instead. To get the borough, we'll use tidyr verbs and joins.  

# First, let's load in the table that maps district codes to boroughs: 
areas = read.csv('area_info.csv', stringsAsFactors=F) %>% tbl_df

# What do we have here? 
str(areas)

# Exactly two columns: the first is the district code and the second is the 
# borough. 

# Ok, now let's grab just the columns we need from trips: 
trips %>% 
	select(pdistrict, ddistrict)

# Here we could filter out the NAs, but we're going to instead classify them as 
# 'Unknown' and incorporate them into our final output.Continuing, we need to 
# add a unique id column for each trip, you'll see why in a moment. An easy way 
# to make a unique ID is the row_number() function, which does exactly what you 
# think it does (on ungrouped data). 

trips %>% 
	select(pdistrict, ddistrict) %>%
	mutate(trip_id = row_number()) 

# Now we're ready to use our first tidyr verb, gather(). We'd like to get a new
# df where the first column tells us whether the row is a pickup or a dropoff, 
# the second tells us the trip_id, and the third gives the district number.
	
trips %>% 
	select(pdistrict, ddistrict) %>%
	mutate(trip_id = row_number()) %>%
	gather(p_or_d, district, -trip_id)

# How to read the gather call: convert all columns except trip_id into label 
# or 'key' columns. Make a new column called 'p_or_d' to code the labels, 
# and call the column of values 'district'.

# So, what does our new data frame look like? We can see what's going on a bit 
# better if we sort the data on trip_id:

trips %>% 
	select(pdistrict, ddistrict) %>%
	mutate(trip_id = row_number()) %>%
	gather(p_or_d, district, -trip_id) %>%
	arrange(trip_id)

# Each trip has a row corresponding to pickup and another corresponding to 
# dropoff. 

# Now we are ready to join. First, let's see what happens if we use a left join.
# We need to tell dplyr that the 'district' column of trips is supposed to match
# the 'id' column of areas. 

trips %>% 
	select(pdistrict, ddistrict) %>%
	mutate(trip_id = row_number()) %>%
	gather(p_or_d, district, -trip_id) %>%
	left_join(areas, by = c('district' = 'id'))

# Looks like we got a bunch of NAs, which makes sense, since we had a bunch of
# NAs in the district column. That's ok for now. If we wanted to drop all 
# entries with NAs in either trips or areas, we could use an inner_join instead. 

# So we've done our join, and we want to get our data back into a more familiar
# format. To do this, let's use the spread() function, which is the inverse of 
# gather(). First, let's drop the district column, since we don't need it 
# anymore: 

trips %>% 
	select(pdistrict, ddistrict) %>%
	mutate(trip_id = row_number()) %>%
	gather(p_or_d, district, -trip_id) %>%
	left_join(areas, by = c('district' = 'id')) %>%
	select(-district)

# Now we're ready to spread(). We want to use the values of p_or_d to code two
# new columns, with values that come from borough. Since we have the trip_id 
# column, spread() knows to keep those entries together -- that's why we needed
# it in the first place. 

trips %>% 
	select(pdistrict, ddistrict) %>%
	mutate(trip_id = row_number()) %>%
	gather(p_or_d, district, -trip_id) %>%
	left_join(areas, by = c('district' = 'id')) %>%
	select(-district) %>%
	spread(key = p_or_d, value = borough)

# Great, now we are ready to count again. However, our column names are out of
# date (they're not districts anymore), so let's rename them using an 
# intuitive function: 

trips %>% 
	select(pdistrict, ddistrict) %>%
	mutate(trip_id = row_number()) %>%
	gather(p_or_d, district, -trip_id) %>%
	left_join(areas, by = c('district' = 'id')) %>%
	select(-district) %>%
	spread(key = p_or_d, value = borough) %>%
	rename(pborough = pdistrict, dborough = ddistrict)

# Ok, ready to count! 
trips %>% 
	select(pdistrict, ddistrict) %>%
	mutate(trip_id = row_number()) %>%
	gather(p_or_d, district, -trip_id) %>%
	left_join(areas, by = c('district' = 'id')) %>%
	select(-district) %>%
	spread(key = p_or_d, value = borough) %>%
	rename(pborough = pdistrict, dborough = ddistrict) %>%
	count(pborough, dborough)

# Note that we still have some NAs. We could filter them out using familiar 
# methods, or we could use the 'fill' parameter of spread to write 'Unknown' 
# there instead: 

trips %>% 
	select(pdistrict, ddistrict) %>%
	mutate(trip_id = row_number()) %>%
	gather(p_or_d, district, -trip_id) %>%
	left_join(areas, by = c('district' = 'id')) %>%
	select(-district) %>%
	spread(key = p_or_d, value = borough, fill = 'Unknown') %>%
	rename(pborough = pdistrict, dborough = ddistrict) %>%
	count(pborough, dborough)

# Finally, we can get this into 'matrix form' by spreading again. We want
# dborough to be the columns, and the values to be n. 

trips %>% 
	select(pdistrict, ddistrict) %>%
	mutate(trip_id = row_number()) %>%
	gather(p_or_d, district, -trip_id) %>%
	left_join(areas, by = c('district' = 'id')) %>%
	select(-district) %>%
	spread(key = p_or_d, value = borough, fill = 'Unknown') %>%
	rename(pborough = pdistrict, dborough = ddistrict) %>%
	count(pborough, dborough) %>%
	spread(key = dborough, value = n, fill = 0)

# That's what we wanted! For the sake of visualization, we'll save this as an 
# object m: 

m = trips %>% 
	select(pdistrict, ddistrict) %>%
	mutate(trip_id = row_number()) %>%
	gather(p_or_d, district, -trip_id) %>%
	left_join(areas, by = c('district' = 'id')) %>%
	select(-district) %>%
	spread(key = p_or_d, value = borough, fill = 'Unknown') %>%
	rename(pborough = pdistrict, dborough = ddistrict) %>%
	count(pborough, dborough) %>%
	spread(key = dborough, value = n, fill = 0)

# And then we'll use the code below to draw a heatmap. 

m = m %>% select(-pborough) %>% data.matrix
rownames(m) = colnames(m)
heatmap(m, symm = TRUE, scale = 'row')

# Each row corresponds to an origin, and each column to a destination. We see that 
# most trips tend to stay within the same borough, but that almost all 
# have a high likelihood to end in Manhattan. 