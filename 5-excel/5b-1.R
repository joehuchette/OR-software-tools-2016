# IAP 2016
# 15.S60 Software Tools for Operations Research
# Lecture 5b: Machine Learning in R
#############

#######################
## LINEAR REGRESSION ##
#######################

# First, let's load the trips dataset.  Make sure to navigate to the directory where your csv file is!

setwd("~/Desktop/IAP2016/")
trips = read.csv("2013-05-14_neighborhoods.csv",stringsAsFactors=F) 

str(trips)

trips$vendor_id = factor(trips$vendor_id)
trips$rate_code = factor(trips$rate_code)
trips$store_and_fwd_flag = factor(trips$store_and_fwd_flag)
trips$payment_type = factor(trips$payment_type)

library(dplyr)
library(ggplot2)

trips = tbl_df(trips)

names(trips)
summary(trips)

## Take a small subset out to form the training and testing sets.  We will build a model on the training set ONLY, and then use
## the model that we obtain to make predictions on the test set. Out of sample testing is very important! 
set.seed(119)
trips.train <- trips %>% sample_n(500)
trips.test <- trips %>% sample_n(500)

# Create the linear regression model
lin.mod <- lm(tip_amount ~ fare_amount, data = trips.train)

# Useful outputs of a linear regression model
summary(lin.mod)
lin.mod$coefficients
lin.mod$residuals
confint(lin.mod, level = 0.95)

# We can, for example, check if residuals are normally distributed
hist(lin.mod$residuals)

# We can compute correlations between variables
cor(trips.train$fare_amount, trips.train$tip_amount)

# Quick plot for now
plot(trips.train$fare_amount, trips.train$tip_amount)
abline(lin.mod)

## We can use the predict function to obtain predictions from our linear regression model.  By default, it will give us
## the predictions on the training set that was used to build the model
predict(lin.mod)

# We can compute R^2 manually.  This will come in handy when we look at out of sample R^2.
SSE = (predict(lin.mod) - trips.train$tip_amount)^2 %>% sum 
SST = (mean(trips.train$tip_amount) - trips.train$tip_amount)^2 %>% sum
1 - SSE / SST
# Check that this result is the same as summary(lin.mod)

# We can also use ggplot for a visualization with a confidence interval
p <- ggplot(trips.train, aes(x = fare_amount, y = tip_amount)) + geom_point()
p + geom_smooth(method = "lm", formula = y ~ x)

## Now, let's make predictions on the testing set
test.pred <- predict(lin.mod, newdata = trips.test)
SSE = (test.pred - trips.test$tip_amount)^2 %>% sum
SST = (mean(trips.train$tip_amount) - trips.test$tip_amount)^2 %>% sum
1 - SSE / SST


## Let's see if we can improve our model by adding an additional explanatory variable
trips.train <- trips.train %>% filter(payment_type %in% c("CRD", "CSH")) %>% mutate(crd = as.numeric(payment_type == "CRD"))
trips.test <- trips.test %>% filter(payment_type %in% c("CRD", "CSH"))%>% mutate(crd = as.numeric(payment_type == "CRD"))

lin.mod.2 <- lm(tip_amount ~ fare_amount + crd, data = trips.train)
summary(lin.mod.2)

test.pred.2 <- predict(lin.mod.2, newdata = trips.test)
SSE = (test.pred.2 - trips.test$tip_amount)^2 %>% sum
SST = (mean(trips.train$tip_amount) - trips.test$tip_amount)^2 %>% sum
1 - SSE / SST


#########################
## LOGISTIC REGRESSION ##
#########################

# We'll first load our dataset of interest, the Titanic dataset
TitanicPassengers = read.csv("TitanicPassengers.csv")
str(TitanicPassengers)

# We will split the data into training and testing sets a bit differently this time, so 
# we need a new packages (rememeber - we only need to install the package once, but 
# the library needs to be loaded each time!)
install.packages("caTools")
library(caTools)

# Now split the dataset into training and testing
split <- sample.split(TitanicPassengers$Survived, SplitRatio = 0.6)
TitanicTrain <- TitanicPassengers[split, ]
TitanicTest <- TitanicPassengers[!split, ]


# Run a logistic regression using general linear model
Titanic.logReg = glm(Survived ~ Class + Age + Sex, data = TitanicTrain, family = binomial)
summary(Titanic.logReg)

# Compute predicted probabilities on training data
Titanic.logPred = predict(Titanic.logReg, type = "response")

# Build a classification table to check accuracy on 
# training set. Note that due to randomness of split, 
# classification matrices may be slightly different
table(TitanicTrain$Survived, round(Titanic.logPred))

# We now do the same for the test set
Titanic.logPredTest = predict(Titanic.logReg, newdata = TitanicTest, type = "response")

table(TitanicTest$Survived, round(Titanic.logPredTest))

# Compute percentage correct (overall accuracy)
(table(TitanicTest$Survived, round(Titanic.logPredTest)) %>% diag %>% sum) / nrow(TitanicTest)

# Plot the ROC curve and examine the AUC value
install.packages("ROCR")
library(ROCR)

pred = prediction(Titanic.logPredTest, TitanicTest$Survived)
perf = performance(pred, "tpr", "fpr")
plot(perf)
# And let's compute the auc
as.numeric(performance(pred, "auc")@y.values)

# The AUC value tells us that if the model is given a random positive and a random negative
# example, it can properly differentiate the two 83% of the time.

################
## ASSIGNMENT ##
################

# 1a) Load the dataset LettersBinary.csv and check its structure.

#     Doesn't make much sense, huh? Each observation 
#     in this dataset is a capital letter H or R, in one
#     of a variety of fonts, and distorted in various 
#     ways. The attributes x1 ... x16 are all properties
#     of the resultant transformation.  In this 
#     assignment, we wish to see if these attributes 
#     can be useful predictors of what the original 
#     letter was.

#  b) Split the dataset into training and test sets 
#     such that the training set is comprised of 60% 
#     of the original data.




#  c) Build a logistic regression model to predict 
#     the letter based on the attributes. Then create a 
#     classification matrix and determine the 
#     accuracy of the model on the test set.

letters.formula <- formula(Letter ~ x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10 + x11 + x12 + x13 + x14 + x15 + x16)


#     You can use letters.formula in place of 
#     typing the formula
















