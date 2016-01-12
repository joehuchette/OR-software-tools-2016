###
# Before you start
###

# Make sure you have the needed packages installed and loaded:
# If you did the pre-assignment, they should be installed
# install.packages("ggplot2")
# install.packages("ggmap")
# install.packages("tidyr")
# install.packages("dplyr")
library(ggplot2)
library(ggmap)
library(tidyr)
library(dplyr)
# you should also hve the areas and trips data files in your working directory
# most likely because you are in the data subdir of the git repository

# TO follow along you'll need the trips and neighborhoods data:
trips = read.csv("2013-05-14_neighborhoods.csv", stringsAsFactors = F) %>% tbl_df()
areas = read.csv("area_info.csv",stringsAsFactors = F) %>% tbl_df()

###
# Part 0: why ggplot2?
###

# Let's remember some of the plots we saw today and yesterday:
data(anscombe)
a1 = lm(y1 ~ x1, data = anscombe)
a2 = lm(y2 ~ x2, data = anscombe)
a3 = lm(y3 ~ x3, data = anscombe)
a4 = lm(y4 ~ x4, data = anscombe)
par(mfrow=c(2,2)) # grid of plots so we can see the whole quartet at once
plot(anscombe$x1, anscombe$y1)
abline(a1)
plot(anscombe$x2, anscombe$y2)
abline(a2)
plot(anscombe$x3, anscombe$y3)
abline(a3)
plot(anscombe$x4, anscombe$y4)
abline(a4)

trips$passenger_count %>% table() %>% plot()

trips$passenger_count %>% hist()

odmat = trips %>% 
  select(pdistrict, ddistrict) %>%
  mutate(trip_id = row_number()) %>%
  gather(key = p_or_d, value = district, pdistrict, ddistrict) %>%
  left_join(areas, by = c('district' = 'id')) %>%
  select(-district) %>%
  spread(key = p_or_d, value = borough, fill = 'Unknown') %>%
  rename(pborough = pdistrict, dborough = ddistrict) %>%
  count(pborough, dborough) %>%
  spread(key = dborough, value = n, fill = 0)
odmat = odmat %>% select(-pborough) %>% data.matrix
rownames(odmat) = colnames(odmat)
heatmap(odmat, symm = TRUE, scale = 'row')


# Not the most beautiful, right?
# And notice that we used a set of disparate commands:
# plot (which means different things in different places),
# hist, heatmap, abline, etc.
# In base R, each plotting command has different syntax,
# and we use different commands for creating and modifying plots.
# As we discussed Thursday, we prefer for our code to be legible 
# and for the tools we use to have internal compatibility.
# Once again, Hadley Wickham to the rescue: enter ggplot

###
# Part 1: Basics of ggplot2
###


# "A grammar of graphics is a tool that enables us to concisely 
# describe the components of a graphic. Such a grammar allows us to
# move beyond named graphics (e.g., the "scatterplot")
# and gain insight into the deep structure that 
# underlies statistical graphics." - Hadley Wickham

# A visualization is a mapping from data to visual properties.
# In ggplot we specify these explicitly.
# 
# ggplot plots have 3 basic components:
# - the data that the plot will use
# - the mapping from data to visual properties
# - the geometry that will be drawn with these visual properties

# We'll use the trips data set to explore basic plots in ggplots.
# Make sure you've loaded it up
# trips = read.csv("2013-05-14_neighborhoods.csv", stringsAsFactors = F) %>% tbl_df()
# We don't want to plot half a million points, so for now we'll use a smaller sample

# Let's explore trip length vs fare as a scatterplot

# What if we want blue points?

# or blue sqaures?
# see the available shapes: http://www.cookbook-r.com/Graphs/Shapes_and_line_types/

# easy to add titles and labels


## Exercise 1
# Make a scatterplot of fare vs tip
# Make sure your plot is nicely labeled and play with point color, shape, etc
# Solution:


# What if we want the size of the points to have meaning, e.g.
# to represent passenger count? 


# Before we move on, some important points:

# 1: where to specify properties
# properties in the geom_() overwrite those in ggplot():

# properties can have their own aesthetic which also takes precedence:


# 2: we can save plots
# easiest way is with ggsave, which saves the last plot by default

# it accepts various options, see ?ggsave

# 3: chaining!
# You may have noticed that ggplot takes a data frame as its first argument
# If you were here Thursday, you're probably wondering if we can chain
# The answer is yes, and it's super cool
# Maybe we're concerned that our trips.small data frame got (un)lucky when sampling
# 500 rows from the bigger data frame
# Easy to chain sample_n and ggplot

# execute that several times to get different results


# By now you've seen the flavor of ggplot, but we've only made one type of plot
# namely scatterplots, using geom_point()
# Changing the type of plot is as simple as changing the geom used
# E.g. we could make the above a line plot, though it'll look terrible:


## Exercise 2
# Use chaining to make a line plot of passenger count vs average fare
# This will require some commands learned last Thursday
# Recall group_by and summarize
# Bonus: Filter out any trips with 0 passengers or 0 tip
# Solution

# Let's explore some other geoms_ now
# There are lots and we won't cover them all.
# Check out http://docs.ggplot2.org/current/

# The above plot is okay but doesn't make a ton of sense as a line plot
# The lines falsely imply continuity
# Let's try a bar plot

# notice we changed the options passed to aes. What happens if we don't?
# Wow, this looks very different! Maybe that line plot was misleading.
# We could try a boxplot as well.


# We'll now explore tip percentages via histograms
# First let's make the tip percentage column

# Histograms follow the pattern we've seen so far

# What happened? Huge outliers:

# Maybe most people don't tip that much?

# Fewer than 1/100 tip > 35%, so let's just cut to no more than 50% tip

# So that's interesting! Good thing we looked at our data!

# Maybe cash and credit card payments lead to different tipping habits?
# Let's check
# First we can make two histograms, one for each type of payment, using facets:

# we can also overlay histograms using transparency and different colors

# oops, these are stacked, not overlaid
# to overlay, use position=identity and set transparency with alpha



## Exercise 3
# Create a column mult_pass which is true/false for whether
# passenger_count > 1
# Make side-by-side and overlaid histograms exploring fare paid vs mult_pass
# Make sure the bin width is something reasonable
# Try stacking the histograms vertically by using
# mult_pass ~ . instead of . ~ mult_pass
# bonus: do some filtering to get more meaningful results
# Solution


# heatmaps. Remember this?
heatmap(odmat, symm = TRUE, scale = 'row')
# how can we make something similar with ggplot?
# first we have to convert our data into the right format
# we want 3 colums of pborough, dborough, count
# to include rows with 0 count we spread/gather an extra time
# not the most elegant, but it works

# well, it's cleaner than the base R version but
# doesn't show much since there are so many trips
# from Manhattan to Manhattan. Let's take logs.


###
# Section 2: maps
###

# show a map of nyc
nyc <- get_map(location = c(lon = -73.9, lat = 40.7), zoom = 11)
ggmap(nyc)

# okay, let's put the pickups on this map

# what went wrong? Missing data? Let's check for NAs

# actually no NAs, but some clearly incorrect values

# these are outside the map window and get dropped

# first we need a function to get valid trips
# don't want any trips outside NYC

## Exercise 4
# Plot the dropoff locations on the map of NYC. Use some transparency to improve
# readability in Manhattan. Color the points by trip distance.
# bonus: use get_map to get a map zoomed in on a particular area of NYC
# Solution

# So this is pretty cool, but for color-blind people like me it's hard to tell
# the difference between the light blue on the trip_distance scale
# and the transparency we've used. Let's change the color scale.


# So far in maps we've just focused on pickups, not dropoffs
# What if we want maps of both, side by side?

### 
# Section 3: Explore your data
###

# Visualization can be extremely useful for learning when your model
# does well and when it does not, or even finding interesting features
# of your model.

# Thursday we tried to predict tip percentage based on distance driven,
# which didn't work so well. But we've seen that but for the non-tippers,
# tipping actuall looks fairly regular. Today we'll take the easier task 
# of examining raw tips based on distance, conditioned on there being a tip.



# note: we can also stabilize the axes with the functions
# xlim and ylim, but doing so will drop data outside the axes



# we see the trend line and confidence interval thereof
# by default it's a 95% confidence interval
# can change the method, other options include loess and
# glm, family = "binomial" for logistic regression
# Of course we can change sizes and colors as we've done before

## Exercise 5
# Plot the loess trend. Change the size, color, etc. for enhanced clarity.
# bonus: fix the axis scales
# Make several plots with different random samples from the whole trips table.
# Do you notice anything interesting for trips of about 1 mile in length?
# Solution


# visual exploration of time-of-day trends
# first parse the pickup times to get the pickup second
# counting from the beginning of 2013-05-14
# this will take a minute to run

# let's also bucket by minute


# first time of day trend: likelihood of getting a tip
# limit to card payments since we saw cash payments
# supposedly never include a tip
# we'll need to make some helper columns


# That was a line plot in hope of a nice trend, 
# but it's too messy. The scatterplot might be better:


# looks like there's something interesting going on around 4am
# some minutes have all tips, some very low percentages?
# Maybe we don't have enough data for these early morning
# minutes, so if e.g. only one pickup happens in a minute
# the got_tip percentage will be 0/1?

# By itself that's cool! Let's zoom in on the early morning

# So we're a little data-poor right around 4am
# But for most dead-of-night minutes we have at least
# 15 trips

# we can try bucketing by hour and seeing what that looks like


# what's going on here? I don't know. One thought is that
# maybe flat-rate trips don't get tips at the same rate?
# let's split by the type of trip
# can do this directly by rate code or by $52 fares


# can see better if we focus on just rate codes
# 1 (standard) and 2 (jfk)
# The other rate codes don't have enough data to be 
# meaningful off-peak hours


# This makes us think everyone is cranky early morning
# But particularly standard fare people?
# JFKers generally tip a little less?
# We could also make the above plot per-minute and
# Look at the LOESS trend


## Exercise 6
# Explore visually how distance traveled changes with
# time of day
