# IAP 2016
# 15.S60 Software Tools for Operations Research
# Lecture 3: Introduction to R

# Script file intro.R
# In this script file, we cover the basics of using R.

###################################################
## RUNNING R AT THE COMMAND LINE, SCRIPTING, AND ##
## SETTING THE WORKING DIRECTORY                 ##
###################################################

# Using the R console (command line):
# - You can type directly into the R console (at '>') and 
#   execute by pressing Enter
# - Previous lines can be accessed using the up and down arrows
# - Tabs can be used for auto-completion
# - Incomplete commands will be further prompted by '+'

# Using R scripts in conjunction with the console:
# - We are currently in a script ("intro.R")
# - Individual lines (or multiple) in this script can be executed 
#   by placing the cursor on the line (or selecting) and typing 
#   Ctrl + r on PC or Cmd + Enter on Mac

# Current working directory
# - We are in a current working directory
# - getwd() tells us the current working directory
getwd()
# - We can move to a different directory with setwd()

################################################
## BASICS: CALCULATIONS, FUNCTIONS, VARIABLES ##
################################################

# You can use R as a calculator.  E.g.:
3^(6-4)
22/7
16^(1/4)

6*9 == 
  
  # What happened with that last one? Check the R console!
  # Let's see if it's equal to 42...
  
  # Use the arrow keys to recall the command and check to see
  # if 54 will give you the answer you expect.
  
  # Other useful functions:
  sqrt(2)
abs(-2)

sin(pi/2)
cos(0)

exp(-1)
(1 - 1/100)^100

log(exp(1))

# The help function can explain certain functions
# What if we forgot if log was base 10 or natural log?
help(log)
?log

# You can save values, calculations, or function outputs to variables
# with either <- or = 
x <- 2^3
y = 6

# Use just the variable name to display the output
x
y

# Note! If you run a script using source(""), output will be 
# suppressed, unless you use the print function
print(x)
print(y)

# Rules for variable names 
# - Can include letters, numbers
# - Can have periods, underscores
# - CANNOT begin with a number
# - Case-sensitive
# - CANNOT use spaces

# Use the ls() function to see what variables are available
ls()

########################################
## VECTORS, MATRICES, AND DATA FRAMES ##
########################################

# Create a vector of numbers from 1 through 10, access an index,
# and sum all of them
z <- seq(1:10)
z <- 1:10 #this also works
z[5]
sum(z)
double_z <- z^2

# Create vectors of airports and capacities
airports = c("BOS", "JFK", "ORD", "SFO", "ATL")
capacities = c(20, 45, 50, 35, 55)

# Place vectors together as a matrix using bind

# bind together as columns
cbind(airports, capacities)

# bind together as rows
rbind(airports, capacities)

# Create a data frame
df1 = data.frame(airports, capacities)

# Add additional runways
capacities = c(3, 2, 5, 1, 3)

# Create another data frame
df2 = data.frame(airports, capacities)

# Append rows of the second data frame to those of the first
df.runways = rbind(df1, df2)

# Check out the class and structure of various variables
class(airports)
str(airports)

class(capacities)
str(capacities)

class(df.runways)
str(df.runways)
# Notice that there are 5 different values for airports.  These 
# fall under different "categories" or "factors"

df.runways

# Use data.frame$col to extract the column col from a data frame
df.runways$airports

# The summary function can often give you useful information 
summary(df.runways)
summary(df.runways$airports)

# Use the subset function to extract rows of interest from 
# a data frame (first argument is the data frame, second
# argument is the criterion on which to select)
runwaysBOS = subset(df.runways, airports=="BOS")
runwaysBOS

# Alternatively, since we know that rows 1 and 6 correspond
# to BOS, we can extract runwaysBOS from df.runways as follows:
runwaysBOS = df.runways[c(1,6), ]

str(runwaysBOS)
# Notice that even though we used subset and runwaysBOS only
# has one factor level for the airports column, the str function
# still tells us that there are 5 levels.  We can fix this using the
# factor function.

runwaysBOS$airports = factor(runwaysBOS$airports)
str(runwaysBOS)

# Find the total runway capacity in Boston
sum(runwaysBOS$capacities)

############################
## WORKING WITH CSV FILES ##
############################

# - Let's open the taxi data. It is found in
#   /my/path/to/OR-software-tools-2016/data/2013-05-14.csv
# - Let's find the path to that file on our own computer.
# -- (Mac) /.../OR-software-tools-2016/data/2013-05-14.csv
# -- (Windows) E:/.../OR-software-tools-2016/data/2013-05-14.csv
#              where "E" is whichever drive we mounted athena using
#              win-sshfs
# Load csv files using read.csv
# header = TRUE is usually ASSUMED, so not strictly necessary
taxi_data = read.csv(file = "/Users/brad-sturt/OR-software-tools-2016/data/2013-05-14.csv", header = TRUE)

# Use names() to extract column names
names(taxi_data)

# Use str to look at details of columns
str(taxi_data)

# Use head() to look at the first several rows
head(taxi_data)

# Use the $ command to look at specific columns
taxi_data$vendor_id
taxi_data$rate_code



####################################################
## BASIC STATISTICS, PLOTTING, AND SUMMARY TABLES ##
####################################################

# Calculate the mean, standard deviation, and other statistics
mean(taxi_data$passenger_count)
sd(taxi_data$passenger_count)
summary(taxi_data$passenger_count)

# Plot fare amount vs trip distance
plot(taxi_data$trip_distance, taxi_data$fare_amount)

# Plot with a title, x- and y-axis labels
plot(taxi_data$trip_distance, taxi_data$fare_amount, main="Fare Amount vs. Trip Distance", xlab = "Trip Distance [mi]", ylab = "Fare Amount [$]")

# For other plots and information about the graphics package
library(help = "graphics")

# Create a table to summarize the data
# Here, we look at mean trip distance, based on the number
# of passengers in the taxi
tapply(taxi_data$trip_distance, taxi_data$passenger_count, mean)

# We can also create a table to look at counts 
table(taxi_data$passenger_count, taxi_data$payment_type)


###############################
## DEALING WITH MISSING DATA ##
###############################

# Often in real datasets we encounter missing data.  For instance,
# in a survey, not all respondents might answer all questions.  Here,
# we will just remove any rows with any missing data (e.g., removing
# respondents who did not answer all questions).  More sophisticated
# methods for dealing with missing data exist, but we will not go
# into detail here.

# Load the CEOmissing dataset. This is just the previous dataset
# with some entries missing.
df_with_missing_entries <- data.frame(age=c(23,35,NA,42,53), 
                                      name=c("Alice", "Bob", "Cindy", "Donald", "Elliot"))

# Use the summary function to see how much missing data there is.
summary(df_with_missing_entries)
str(df_with_missing_entries)

# Let's remove all of the rows where there is an entry missing. (The entry is NA)
# First note that we cannot use '==' to check if an element is an NA
5 == NA
NA == NA

# Instead, we use the is.na() function.
is.na(5)
is.na(NA)

# Now let's only select rows where all of the data is present
df_without_missing_entries = subset(df_with_missing_entries, 
                                    !is.na(age) & !is.na(name))
summary(df_without_missing_entries)
str(df_without_missing_entries)

# Alternatively, we could use the na.omit function
df_without_missing_entries = na.omit(df_with_missing_entries)
summary(df_without_missing_entries)
str(df_without_missing_entries)

################################
## UNDERSTANDING R WORKSPACES ##
################################

# You may save an entire workspace, including variables using the
# following command (alternatively, you can use the Workspace tab
# in the menu bar):
save.image("eg.RData")

# To load, you can run the following:
load("eg.RData")

# You should save the image if you are working on a large project
# and are taking a pause from working on it.  This way, when you
# come back to R, you can just load the workspace and continue
# as before

# You can also save individual variables as follows:
save(df_without_missing_entries, file = "df_without_missing_entries.RData")

# This is useful when the variable is given the result of 
# a computation that takes a lot of time (e.g., loading
# very large data sets, result of running multiple SVMs, etc.)

#################
## ASSIGNMENTS ##
#################

# 1a) Use the help function on seq to assign the variable 'evens'
#     to be the even numbers from 2 through 20, inclusive.



#  b) Propose an alternative way to get 'evens' to be the even 
#     numbers from 2 through 20, inclusive, with perhaps more
#     than one command.  Write down the commands.





##
# 2a) Try out a few other basic statistics and graphing functions

min(taxi_data$trip_distance)
median(taxi_data$trip_distance)
max(taxi_data$trip_distance)

sum(taxi_data$total_amount)

hist(taxi_data$total_amount)
boxplot(taxi_data$total_amount)

#  b) Edit the histogram plot above to ensure that it has a title
#     and that the x-axis is labeled properly

##
# 3) Use the tapply() function on df.runways to obtain a table
#    detailing the total capacity at each airport (Hint: use the sum() function)

