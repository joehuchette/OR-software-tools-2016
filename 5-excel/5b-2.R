# IAP 2016
# 15.S60 Software Tools for Operations Research
# Lecture 5b: Machine Learning in R
#############

################################################
## CLASSIFICATION AND REGRESSION TREES (CART) ##
################################################

# First install package rpart and load the library
install.packages("rpart")
install.packages("rpart.plot")
library(rpart)
library(rpart.plot)

# Build a CART model
Titanic.CART = rpart(Survived ~ Class + Age + Sex, data = TitanicTrain, method = "class", control = rpart.control(minbucket = 10))

# Plot the tree. For all trees, if the conditional at the
# top is true, go to the left.
prp(Titanic.CART)

# Make prediction on the test set
Titanic.CARTpredTest = predict(Titanic.CART, newdata = TitanicTest, type = "class")

# Create the confusion matrix
table(TitanicTest$Survived, Titanic.CARTpredTest) 

# Calculate accuracy
(table(TitanicTest$Survived, Titanic.CARTpredTest) %>% diag %>% sum) / nrow(TitanicTest)

# We can also use CART for continuous outcomes
trips.CART = rpart(tip_amount ~ fare_amount, data = trips.train, method = "anova", control = rpart.control(minsplit = 5))
prp(trips.CART)

# Create a vector of predictions
predict(trips.CART)


###################
## RANDOM FOREST ##
###################

# Install package randomForest and load the library
install.packages("randomForest")
library(randomForest)

# Build a random forest model for the Titanic dataset
Titanic.forest = randomForest(Survived ~ Class + Age + Sex, data = TitanicTrain, nodesize = 10, ntree = 200)

# Warning message! - random forest needs to predict a factor
str(TitanicTrain$Survived)
TitanicTrain$Survived <- factor(TitanicTrain$Survived)
TitanicTest$Survived <- factor(TitanicTest$Survived)

# Let's try again!
Titanic.forest = randomForest(Survived ~ Class + Age + Sex, data = TitanicTrain, nodesize = 10, ntree = 200)

# Make predictions on the test set

Titanic.forestPred = predict(Titanic.forest, newdata = TitanicTest)
table(TitanicTest$Survived, Titanic.forestPred)


# Check accuracy
(table(TitanicTest$Survived, Titanic.forestPred) %>% diag %>% sum) / nrow(TitanicTest)



################
## ASSIGNMENT ##
################

# Let's compare the performance of CART and random
# forest on the LettersBinary dataset

# 1) Build a CART model on the training data. Set the
#    minbucket parameter to 25. Then test it on the 
#    testing set, create a confusion matrix, and determine
#    the accuracy.

letters.formula <- formula(Letter ~ x1 + x2 + x3 + x4 + x5 + x6 + x7 + x8 + x9 + x10 + x11 + x12 + x13 + x14 + x15 + x16)





# 2) Do the same as above for random forest. Use nodesize
#    = 25 and ntree = 200.





# EXTRA ASSIGNMENT:

# *1) Try different ways of control the tree growth. Look 
#     at the rpart.control help page. Try giving your model 
#     values for cp or maxdepth.

# *2) Try different values of ntree in your randomForest 
#     model. Try setting it to a very low number, and a 
#     very high number. How do the prediction results 
#     compare?


















