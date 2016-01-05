

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

## Let's check out the structure of trips to see which columns we should use: 

## look at the pdistrict and ddistrict columns. Each row is the id of the pickup and dropoff location for an individual trip. 

## Count rows with an NA in either column: 

## Use count as an easy replacement for group_by() %>% summarize(n = n()) 

## Count up trips for each OD pair

## Let's filter out the NAs in both columns

## Ok, tidyr time! Let's load it up. 

## Spread the data by ddistrict, using n as values. Each value of ddistrict will be a new column

## Use 0 for any missing entries by supplying a fill param for spread

## Let's group by borough instead. The result will look like this: 

#        pborough Bronx Brooklyn Manhattan Queens Staten Island Unknown
# 1         Bronx   142        2        80     12             0       7
# 2      Brooklyn    16     4857      3311    458             2      26
# 3     Manhattan  1491    14159    412111  14680            56    1660
# 4        Queens   308     2579     14790   5708            16     356
# 5 Staten Island     0        0         2      1             4       0
# 6       Unknown     9       20       490     60             2   12932


## Pull in areas table so we can group by borough

## Let's take a look. id column matches pdistrict and ddistrict

## Back to trips, grab pdistrict and ddistrict columns

## add a unique trip_id

## We have two columns that match the id column of the area table, but we need just one. gather() will fix this for us by converting to long format. 

## easier to see if we sort on trip_id

## we have just one column of district ids, so we are ready to join

## don't need district column any more

## spread it back out; want a pdistrict and ddistrict columns again

## column names are out of date, rename them

## Ok,we have our data in the right shape for counting

## Use 'Unknown' for the NAs by supplying a fill param to spread

## Spread out one more time to get matrix format; each dborough should be a column

## Assign result to variable m

## visualize as a heatmap
m = m %>% select(-pborough) %>% data.matrix
rownames(m) = colnames(m)
heatmap(m, symm = TRUE, scale = 'row')


