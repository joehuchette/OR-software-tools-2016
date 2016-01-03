# PREP: LIBRARIES AND DATA ----------------------------------------------------

# Remember that you can run a chunk of code in RStudio by selecting it with your cursor and then hitting Command + Enter (OS X) or Ctrl + Enter (Windows).

## Uncomment and run these lines if you haven't installed these packages yet. 
# install.packages('dplyr')
# install.packages('tidyr')
# install.packages('ggplot2')

library(dplyr)
library(tidyr)
library(ggplot2)

# Use Session -> Set Working Directory -> Choose Directory to navigate to 
# the folder in which your data sets are stored. If the two commands below execute successfully, you'll know you've done it right.  

trips = read.csv('2013-05-14_neighborhoods.csv') %>% tbl_df
areas = read.csv('area_info.csv') %>% tbl_df

# 0. CHAINING -------------------------------------------------------------
# In this exercise, we'll get some basic practice with chaining by creating 
# a one-line histogram of fare amounts. 

# EXERCISE 0.1 ------------------------------------------------------------

# Create a logarithmic histogram of fare amounts in three different ways. 

## First, use the 'nested function method', e.g. plot(table(x)). 
## Second, use the 'multiple-assignment method', e.g. y = table(x); plot(y)
## Finally, use chaining, e.g. x %>% table %>% plot

# In all three approaches, you will need the log(x,b) function, which takes
# the entrywise logarithm base b of x, and the function cut(x,n), which cuts 
# a numeric vector x into n bins. For this exercise, use n = 200 bins. 

# You should observe a relatively smooth distribution with a strange spike at a 
# specific value. We'll come back to that. 

# SOLUTION 0.1 -----------------------------------------------------------

# SOLUTION 1
plot(table(cut(log(trips$fare_amount),200)))

# SOLUTION 2
x = log(trips$fare_amount)
y = cut(x,200)
z = table(y)
plot(z)

# SOLUTION 3
trips$fare_amount %>% log %>% cut(200) %>% table %>% plot

# 1. EXPLORING A DATA SET -----------------------------------------------------
# Remember that funny spike in the graph from EXERCISE 0.1? In this exercise, 
# we'll figure out what that spike represents and how to isolate it in the data.  

# EXERCISE 1.1 ------------------------------------------------------------
# Determine the value at which the spike occurs. One approach would be to use 
# your code from EXERCISE 0.1, removing the log and plot calls, and inspecting 
# the output for the location of the spike. 

# SOLUTION 1.1 ------------------------------------------------------------

trips$fare_amount %>% cut(200) %>% table # spike is in (51.7, 54].

# Isolate the value 
trips %>% filter(fare_amount > 51.7, 
				 fare_amount <= 54) %>%
	select(fare_amount) %>%
	table # it's 52

# EXERCISE 1.2 ------------------------------------------------------------
# In the last exercise, you found that a disproportionately high number of 
# trips had fare of $52.00. In this exercise, we'll try to figure out why. 
# Filter trips to only include values of 52 for fare_amount. 
# Call the summary() function to get a quick summary of the filtered data. 
# Check for patterns -- see anything interesting or unusual in the summary? 
# Some possibly helpful summary sections include tolls_amount and rate_code. 
# Once you've identified a column to explore, use functions like groupby(), 
# summarise(), or count() to isolate the 'strange' trips. You may also want to 
# check out the file rate_code_map.csv, which explains what each rate code means.
# What is your explanation for the concentration of trips costing $52.00? 

# SOLUTION 1.2 -----------------------------------------------------------

# Summarise the filtered data: 
trips %>% filter(fare_amount == 52) %>%
	summary

# I chose to look at rate_code: how does that break out? 

trips %>% filter(fare_amount == 52) %>%
	group_by(rate_code) %>%
	summarise(n = n())

# or:

trips %>% filter(fare_amount == 52) %>%
	count(rate_code)

# How does that compare to the whole data set? 
trips %>% count(rate_code)

# Ok, so a vast majority of these $52.00 trips have rate_code == 2, which 
# indicates JFK, one of two major airports in the area. 

# 2. LINEAR REGRESSION --------------------------------------------------------

# 3. OD MATRIX ------------------------------------------------------------

# EXERCISE 3.1 ------------------------------------------------------------
# Implement the OD matrix using a different workflow. Follow the steps below:
## Select the pdistrict and ddistrict columns of trips
## Join with the areas table, using pdistrict as the join key
## Rename the new column 'pborough'
## Join with the areas table again, using ddistrict as the join key
### Rename the new column 'dborough'
## Count up by pborough and dborough
## Filter out any nas
## Reshape into 'matrix format', with origins as rows and destinations as columns
## Assign the result to the variable 'm'

## Your result should look like this: 

# > m
# 
# 		 pborough Bronx Brooklyn Manhattan Queens Staten Island
# 1         Bronx   142        2        80     12             0
# 2      Brooklyn    16     4857      3311    458             2
# 3     Manhattan  1491    14159    412111  14680            56
# 4        Queens   308     2579     14790   5708            16
# 5 Staten Island     0        0         2      1             4

# Some useful functions will include left_join, rename, count, and spread. 
# Once you're done, you can visualize the result as a heatmap by running 
# the code below: 

m <- m %>% select(-pborough) %>% data.matrix
rownames(m) <- colnames(m)
heatmap(m, symm = TRUE, scale = 'row')

# SOLUTION 3.1 ------------------------------------------------------------

m <- trips %>% 
	select(pdistrict, ddistrict) %>%
	left_join(areas, by = c('pdistrict' = 'id')) %>%
	rename(pborough = borough) %>% # distinguish pborough from dborough below
	left_join(areas, by = c('ddistrict' = 'id')) %>%
	rename(dborough = borough) %>% # distinguish dborough from pborough above 
	count(pborough, dborough) %>% # df of counts
	filter(!is.na(dborough),!is.na(pborough)) %>%
	spread(key = dborough, value = n, fill = 0)


m <- m %>% select(-pborough) %>% data.matrix
rownames(m) <- colnames(m)
heatmap(m, symm = TRUE, scale = 'row')
