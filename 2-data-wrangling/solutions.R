
### EXERCISE 1. EXPLORING TRIP DISTANCES ###
### ------------------------------------ ###

# In this exercise, we'll explore the origin-destination pairs with the longest average trip distance.

# EX. 1.1: Calculating summary stats #
# Use the group_by() and summarize() functions to calculate aggregate statistics for each O-D pair. The three columns you create should be:
# 1) "avgdist": The average trip distance along that O-D path.
# 2) "totaldist": The total number of files traveled by taxis on this day over that O-D path.
# 3) "n": The # of trips taken along that O-D path.
# Note: Origins are indicated by the pickup district (pdistrict) and destinations are indicated by the dropoff district (ddistrict)

# Hint: You may need to use the sum() function at some point.

# Tip: If there is ever a function, like "sum", that you don't know how to use, you can access the help documentation for that function by typing it into the console preceded by a question mark, like so:
?sum

trips %>%
  group_by(pdistrict,ddistrict) %>%
  summarize(
    avgdist = mean(trip_distance),
    totaldist = sum(trip_distance),
    n = n()
  )


# EX. 1.2 : Removing missing data #
# Some trips have missing data on either the pdistrict or the ddistrict, as indicated by "NA".
# We're not interested in so-called O-D pairs where one of the endpoints is unknown.
# Filter those pairs out of your table.

# Hint: You will need to use either the is.na() function with the negation operator "!", or the na.omit() function.

trips %>%
  group_by(pdistrict,ddistrict) %>%
  summarize(
    avgdist = mean(trip_distance),
    totaldist = sum(trip_distance),
    n = n()
  ) %>%
  filter(!is.na(pdistrict),!is.na(ddistrict))


# EX. 1.3: Investigating the longest trips #
# Among O-D paths that had at least 50 trips that day, which directed path had the highest average trip distance?

# HINT: If your data frame is grouped, arrange() will sort within those groups. If you want to sort the full table, you will need to ungroup() before you sort.
trips %>%
  group_by(pdistrict,ddistrict) %>%
  summarize(
    avgdist = mean(trip_distance),
    totaldist = sum(trip_distance),
    n = n()
  ) %>%
  filter(!is.na(pdistrict),!is.na(ddistrict),n>=50) %>%
  ungroup %>%
  arrange(desc(avgdist))

# ANSWER: pdistrict 162, ddistrict 8

# What was the average distance of those trips?
# ANSWER: 21.5 miles

# How many trips were made along that directed path?
# ANSWER: 51 trips

# How many total miles did taxis travel along that path in that direction?
# ANSWER: 1097 miles




# Notice that district 162 shows up frequently as a pickup or dropoff point for long trips.
# Any guesses what district this is? 




# WRAPPING UP #
# Run the following command to store your statistics table as OD_stats since we're going to use it for Exercise 3.

OD_stats = trips %>%
  group_by(pdistrict,ddistrict) %>%
  summarize(
    avgdist = mean(trip_distance),
    totaldist = sum(trip_distance),
    n = n()
  ) %>%
  filter(!is.na(pdistrict),!is.na(ddistrict),n>=50) %>%
  ungroup %>%
  arrange(desc(avgdist))

### -------------- ###
### END EXERCISE 1 ###


### EXERCISE 2. EXPLORING TRIP SPEED ###
### -------------------------------- ###

# In this exercise, we'll add trip duration and average speed columns to our dataset and compare them with trip distance

# EX 2.0: Working with datetime data #
# There are a wide range of tools in R to deal with datetime data.
# The primary built-in data types for datetime data, in increasing order of powerfulness, are: Date, POSIXct, and POSIXlt
# For instance, we could convert a datetime column like pickup_datetime to a Date, but it would lose all time information
as.Date(trips$pickup_datetime) %>% head()

# POSIXct and POSIXlt both keep date and time information and are very similar, but POSIXlt is not compatible with dplyr, so we'll stick with POSIXct for the rest of this exercise.
as.POSIXct(trips$pickup_datetime) %>% head()
as.POSIXlt(trips$pickup_datetime) %>% head()

# TIP: These data type conversions worked out of the box for us because our column happens to be formatted in one of the default formats that R recognizes. Otherwise, we would have had to use a "format" argument to specify the format.
# The help documentation for all of these functions is quite helpful!


# Let's use mutate to convert pickup_datetime and dropoff_datetime to POSIXct columns.
# We'll also create a column called "trip_duration" which is the difference between pickup and dropoff time.
# Because this is a somewhat computationally intensive command, let's store the new data frame as "trips2"
# Run the following lines of code:
trips2 = trips %>%
  mutate(
    pickup_datetime = as.POSIXct(pickup_datetime),
    dropoff_datetime = as.POSIXct(dropoff_datetime),
    trip_duration = dropoff_datetime - pickup_datetime
  )

# EX. 2.1: Calculating average trip speed #
# Look at the three mutated columns in trips2 using select.
trips2 %>%
  select(pickup_datetime,dropoff_datetime,trip_duration)

# The trip_duration column has a weird data type called "difftime". What units is the duration measured in?
# ANSWER: Seconds


# Use mutate to do the following:
# 1) Convert the "trip_duration" column to minutes.
# 2) Add an "avgtripspeed" column in miles per hour. If trip duration is 0, set avgtripspeed to -1.
# HINT: You will need to convert trip_duration to a numeric variable using as.numeric() before you can convert to minutes.
# HINT: You may need the ifelse() function when creating "avgtripspeed".
trips2 %>%
  mutate(
    trip_duration = as.numeric(dropoff_datetime - pickup_datetime) / 60,
    avgtripspeed = ifelse(trip_duration > 0, trip_distance / (trip_duration / 60), -1)
    ) %>%
  select(trip_duration, avgtripspeed)

# For better viewing, select only the two columns you "mutated".
# CAUTION: Be careful using select when saving over an existing object. We often use select to display better to the console, but we can accidentally delete columns if we use it when storing data frames.


# What is the average trip duration across all trips?
# ANSWER: 13.04 minutes

# What is the average trip speed across all trips?
# ANSWER: 14.04 miles per hour



# EX. 2.2: Investigating the fastest trips #
# Among O-D paths with at least 50 trips, which O-D pair has the highest average trip speed?
trips2 %>%
  mutate(
    trip_duration = as.numeric(dropoff_datetime - pickup_datetime) / 60,
    avgtripspeed = ifelse(trip_duration > 0, trip_distance / (trip_duration / 60), -1)
  ) %>%
  group_by(pdistrict,ddistrict) %>%
  summarize(
    avgduration = mean(trip_duration),
    avgspeed = mean(avgtripspeed),
    n = n()
  ) %>%
  filter(n >= 50) %>%
  ungroup %>%
  arrange(desc(avgspeed))

# ANSWER: pdistrict 168, ddistrict 168

# Which O-D path has the longest average duration among those with at least 50 trips?

trips2 %>%
  mutate(
    trip_duration = as.numeric(dropoff_datetime - pickup_datetime) / 60,
    avgtripspeed = ifelse(trip_duration > 0, trip_distance / (trip_duration / 60), -1)
  ) %>%
  group_by(pdistrict,ddistrict) %>%
  summarize(
    avgduration = mean(trip_duration),
    avgspeed = mean(avgtripspeed),
    n = n()
  ) %>%
  filter(n >= 50) %>%
  ungroup %>%
  arrange(desc(avgduration))

# ANSWER: pdistrict 162, ddistrict 279


# Oof, that's a long trip from the airport.


# If you've gotten this far, try the Ex. 2 challenge below.

# But FIRST, one more thing:
# Let's save a table with the average duration and speed for O-D pairs with at least 50 trips. We'll use this in Exercise 3.
# We don't need the n column

OD_speeds = trips2 %>%
  mutate(
    trip_duration = as.numeric(dropoff_datetime - pickup_datetime) / 60,
    avgtripspeed = ifelse(trip_duration > 0, trip_distance / (trip_duration / 60), -1)
  ) %>%
  group_by(pdistrict,ddistrict) %>%
  summarize(
    avgduration = mean(trip_duration),
    avgspeed = mean(avgtripspeed),
    n = n()
  ) %>%
  filter(n >= 50) %>%
  ungroup %>%
  arrange(desc(avgspeed)) %>%
  select(-n)


# EX. 2 CHALLENGE: Window Functions #
# What percentage of all trips do the most common O-D paths account for?

# To answer this question, create a "pct_trips" column in OD_stats that shows what percentage of all trips were made over each O-D pair.
# One way to do this is by finding sum(trips$n) and using this scalar value as the denominator in our mutate function.
sum(OD_stats$n) #441870
OD_stats %>%
  mutate(pct_trips = n / 441870)

# A more elegant approach would be to use a window function.
# When we've used mutate() so far, we have always populated each element of the new column by using a function of only scalars and the elements of that same row from other columns.
# But sometimes we want the values of our new column to be functions of an entire column.
# For instance, when creating pct_trips, it would be nice to be able to use sum(n) rather than hard-coding the scalar value.
# Well, we're in luck! It turns out mutate() is smart enough to be able to take functions of an entire column. These are called "window functions".

# Use mutate to create pct_trips using n/sum(n)
OD_stats %>%
  mutate(
    pct_trips = n/sum(n)
  )

# What O-D pair accounts for the highest percentage of trips and what is the percentage?
# What is the average trip distance for those trips?
OD_stats %>%
  mutate(
    pct_trips = n/sum(n)
  ) %>%
  arrange(desc(pct_trips))

# ANSWER: pdistrict 289, ddistrict 289. Avg distance = 1.037 miles




# Did you get the same pct_trips values as before?

# What happens if you group by pdistrict and ddistrict before you create pct_trips?

OD_stats %>%
  group_by(pdistrict,ddistrict) %>%
  mutate(
    pct_trips = n/sum(n)
  ) %>%
  arrange(desc(pct_trips))

# Now do you get the same pct_trips values as before?
# How do you explain the values you get?
# HINT: Make sure you look at what groups your data frame has.


# EXPLANATION: When using window functions, mutate pays attention to existing groups in the data frame.
# For this reason, you may want to ungroup() the data before applying the mutate() function.


### -------------- ###
### END EXERCISE 2 ###


### EXERCISE 3. PUTTING IT ALL TOGETHER ###
### ----------------------------------- ###

# EX. 3.1: Joining distance and speed stats #
# Let's merge OD_stats and OD_speeds to get an overall stats table called "allODstats". Keep only rows that exist in both tables.
# Notice that we are joining on multiple columns.
# By default, dplyr will join on all columns whose names match exactly.
allODstats = OD_stats %>% inner_join(OD_speeds)

# Take a look at allODstats to make sure the join worked the way you wanted.
allODstats

# Note: We could have gone back to the beginning and used one summarize to create this same table. But we just learned how to join, so why not try it out!




# EX. 3.2: Correlation between distance, speed, and duration #
# What do you predict is the correlation between average distance and average duration?

# Now use the cor() function to find the correlation between average distance and average duration.
# HINT: cor(a,b) returns the correlation between vector a and vector b.
cor(allODstats$avgdist,allODstats$avgduration)

# Is there a strong positive or negative correlation? Does it match your prediction?

# ANSWER: Strong positive correlation: 0.94


# Now check the correlation between avg trip distance and avg speed over each O-D path.
cor(allODstats$avgdist,allODstats$avgspeed)

# What is the correlation? Is this what you expected?

# ANSWER: Correlation = 0.23, pretty low



# EX 3.3: A different O-D matrix #
# Create an O-D matrix with average trip speed populating the cells of the matrix, instead of count.
# You will only need three columns from allODstats: pdistrict, ddistrict, and avgspeed
allODstats %>%
  select(pdistrict,ddistrict,avgspeed) %>%
  spread(key = ddistrict,value = avgspeed)

# We have the same problem as before when we did this by district. To fix that problem, try the challenge below.


# EX 3 CHALLENGE: A different O-D matrix, borough edition #
# Create the same O-D matrix as in exercise 3.3, but by borough rather than district.

mspeed = trips2 %>%
  mutate(
    trip_duration = as.numeric(dropoff_datetime - pickup_datetime) / 60,
    avgtripspeed = ifelse(trip_duration > 0, trip_distance / (trip_duration / 60), -1),
    trip_id = row_number()
  ) %>%
  select(trip_id,pdistrict,ddistrict,avgtripspeed) %>%
  gather(p_or_d,district,pdistrict:ddistrict) %>%
  left_join(areas, by = c('district' = 'id')) %>%
  select(-district) %>%
  spread(key = p_or_d, value = borough, fill = "Unknown") %>%
  group_by(pborough = pdistrict, dborough = ddistrict) %>%
  summarize(avgspeed = mean(avgtripspeed)) %>%
  spread(key = dborough, value = avgspeed)

# If you save the matrix as mspeed, you can use the code below to plot a heatmap:
mspeed = mspeed %>% select(-pborough) %>% data.matrix
rownames(mspeed) = colnames(mspeed)
heatmap(mspeed, symm = TRUE, scale = 'row')

