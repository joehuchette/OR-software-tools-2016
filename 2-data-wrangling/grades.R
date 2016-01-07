# This script contains all the code shown in the slides for the Data Wrangling in R session.

grades = data.frame(student = c("Phil","Alex","Phil","Alex"),test = c("Midterm","Midterm","Final","Final"),grade=c(88,91,82,70))

library(dplyr)

# AGGREGATE STATISTICS
# In dplyr
grades %>%
  group_by(student) %>%
  summarize(avgrade = mean(grade))

# In baseR
tapply(grades$grade, grades$student, mean)

# Multiple statistics
grades %>%
  group_by(student) %>%
  summarize(
    avgrade = mean(grade),
    mediangrade = median(grade)
  )

# FILTER
# dplyr: filter()
grades %>%
  filter(
    test == "Final",
    grade < 80
  )

# baseR: subset()
subset(grades, (test == "Final") & (grade < 80) )



# ARRANGE
# Ascending order
grades %>% arrange(grade)

# Descending order
grades %>% arrange(desc(grade))

# Multiple columns
grades %>% arrange(student, desc(grade))



# SELECT
# Include ...
grades %>% select(student,grade)

# Or exclude
grades %>% select(-test)

# Rename in the same step
grades %>% select(name = student, grade)

# RENAME
grades %>% rename(score = grade)



# MUTATE
grades %>%
  mutate(weight = ifelse(test=="Final", 0.7, 0.3))

grades %>%
  mutate(
    weight = ifelse(test=="Final", 0.7, 0.3),
    wtgrade = grade*weight
  )


## TIDYR ##
library(tidyr)

# SPREAD #
grades %>% spread(test,grade) 

grades.wide = grades %>% spread(test,grade) 

# GATHER #
grades.wide %>% gather(test_type,score,-student)



## JOINS ##

grades_anonymous = data.frame(ID = c(1,3,1,3),test = c("Midterm","Midterm","Final","Final"),grade=c(88,91,82,70))

students = data.frame(ID = c(1,2), student = c("Phil","Joe"))

# left_join
left_join(grades_anonymous, students)

# inner_join
inner_join(grades_anonymous, students)



## OTHER ##

# COUNT
grades %>% count(student)

grades %>%
  filter(grade > 75) %>%
  count(student,grade)


# WINDOW FUNCTIONS
grades %>%
  group_by(student) %>%
  mutate(avg = mean(grade))


