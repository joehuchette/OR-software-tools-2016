

# 0. Prelims and Chaining -------------------------------------------------

## Let's load the data and check it out a bit. 
trips = read.csv("2013-05-14_neighborhoods.csv", stringsAsFactors = FALSE)
str(trips)

## install and load in dplyr
install.packages("dplyr")
library(dplyr)

## convert to local dataframe -- nicer for exploratory analysis
trips = tbl_df(trips)

## Let's compute the standard deviation of fare_amount. First we'll use nested functions:
sqrt(mean((trips$fare_amount - mean(trips$fare_amount))^2))

## Now we'll use chaining:
(trips$fare_amount - mean(trips$fare_amount))^2 %>% mean() %>% sqrt()

## Could leave off the parentheses for single-argument functions
(trips$fare_amount - mean(trips$fare_amount))^2 %>% mean %>% sqrt

## One-line histogram of passenger count
trips$passenger_count %>% table() %>% plot()



# 1. Exploring and Summarizing a Data Set ---------------------------------

## Quick summary statistics using summary()

## But what if we want something more specific or customized? Let's use group_by() and summarize()

## Compute mean of fare_amount by passenger_count

## Assign the result to a new df

## Groupby() without summarize()

## Assign the result to a new df

## Now summarize() -- same result as above

## Summarize without groupby()

## Ungrouping

## Easily add a column for median

## Easily add a column for counts using n()

## Filter out observations with passenger_count = 0

## Sort by fare_mean

## Sort in descending order, or by multiple criteria

## Go to exercises.R and complete exercises 1.0-1.2

# 2. Prepping Data for Analysis -------------------------------------------

## Select just passenger_count, fare_amount, and tip_amount columns

## Compute tip percentage using baseR

## Remove tip percentage using select()

## Compute tip percentage using dplyr

## Check out the results

## Save as a new df

## Run linear regression and examine results

# 3. Origin-Destination Matrix --------------------------------------------
##







