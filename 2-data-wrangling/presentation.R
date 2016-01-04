

# 0. Prelims and Chaining -------------------------------------------------

## Let's load the data and check it out a bit. 

## install and load in dplyr

## convert to local dataframe -- nicer for exploratory analysis

## Let's compute the standard deviation of fare_amount. First we'll use nested functions:

## Now we'll use chaining:

## Could leave off the parentheses for single-argument functions

## One-line histogram of passenger count



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
## An OD matrix has the ij-th entry as the number of trips from origin i to destination j. Our strategy is to count up by the relevant groups and then reshape the data using tidyr

## Let's take a look at the pdistrict and ddistrict columns

## Count rows with an NA in either column: 

## Use count as an easy replacement for group_by() %>% summarize(n = n()) 

## Count up trips for each OD pair

## Let's filter out the NAs

## Ok, tidyr time!

## Spread the data by ddistrict, using n as values

## Use 0 for any missing entries

## 







