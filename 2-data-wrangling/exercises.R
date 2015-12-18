# PREP: LIBRARIES AND DATA ----------------------------------------------------

## Uncomment and run these lines if you haven't installed these packages yet. 
# install.packages('dplyr')
# install.packages('tidyr')
# install.packages('ggplot2')

library(dplyr)
library(tidyr)
library(ggplot2)

# Use Session -> Set Working Directory -> Choose Directory to navigate to 
# the folder in which your files are stored. 

trips = read.csv('2013-05-14_neighborhoods.csv') %>% tbl_df
areas = read.csv('area_info.csv') %>% tbl_df

# 0. BASIC PIPING -------------------------------------------------------------

# 0.1 Create a logarithmic histogram of fare amounts in three different ways. 

## First, use the 'nested function method', e.g. plot(table(x)). 
## Second, use the 'multiple-assignment method', e.g. y = table(x); plot(y)
## Finally, use piping, e.g. x %>% table %>% plot

# In all three approaches, you will need the log(x,b) funcion, which takes
# the entrywise logarithm base b of x, and the function cut(x,n), which cuts 
# a numeric vector x into n bins.  

# SOLUTION 1
plot(table(cut(log(trips$fare_amount),500)))

# SOLUTION 2
x = log(trips$fare_amount)
y = cut(x,500)
z = table(y)
plot(z)

# SOLUTION 3
trips$fare_amount %>% log %>% cut(500) %>% table %>% plot

# 1. EXPLORING A DATA SET -----------------------------------------------------




# 2. LINEAR REGRESSION --------------------------------------------------------
# 3. JOINING AND AGGREGATION --------------------------------------------------
## 3.1 EXERCISE ---------------------------------
# Use dplyr to create a column called trip_id, which contains a unique integer 
# for each row of trips. 
### 3.1 SOLUTION 1 ------------------------------ 
trips <- trips %>% mutate(trip_id = row_number())
### 3.1 SOLUTION 2 ------------------------------
trips %>% mutate(dummy = 1, trip_id = cumsum(dummy)) %>%
	select(-dummy)
## 3.2 EXERCISE ---------------------------------

## In this exercise, you'll implement the OD heatmap in another way. 
## Use the following flow:
### Select the pdistrict and ddistrict columns of trips
### Join with the areas table, using pdistrict as the join key
### Rename the new column 'pborough'
### Join with the areas table again, using ddistrict as the join key
### Rename the new column 'dborough'
### Count up by pborough and dborough
### Filter out any nas
### Reshape into 'matrix format', with origins as rows and destinations as columns
### Assign the result to the variable 'm'

## Your result should look like this: 

# > m
# 
# 		 pborough Bronx Brooklyn Manhattan Queens Staten Island
# 1         Bronx   142        2        80     12             0
# 2      Brooklyn    16     4857      3311    458             2
# 3     Manhattan  1491    14159    412111  14680            56
# 4        Queens   308     2579     14790   5708            16
# 5 Staten Island     0        0         2      1             4

## Some useful functions will include left_join, rename, count, and spread. 
## 3.2 SOLUTION ---------------------------------

m <- trips %>% 
	select(pdistrict, ddistrict) %>%
	left_join(areas, by = c('pdistrict' = 'id')) %>%
	rename(pborough = borough) %>% # distinguish pborough from dborough below
	left_join(areas, by = c('ddistrict' = 'id')) %>%
	rename(dborough = borough) %>% # distinguish dborough from pborough above 
	count(pborough, dborough) %>% # df of counts
	filter(!is.na(dborough),!is.na(pborough)) %>%
	spread(key = dborough, value = n, fill = 0)

## 3.2 VISUALIZATION ----------------------------
# Now visualize the results by running the code below: 

m <- m %>% select(-pborough) %>% data.matrix
rownames(m) <- colnames(m)
heatmap(m, symm = TRUE, scale = 'row')

# JOINING MULTIPLE DATA SETS --------------------------------------------------