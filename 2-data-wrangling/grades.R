grades = data.frame(student = c("Phil","Alex","Phil","Alex"),test = c("Midterm","Midterm","Final","Final"),grade=c(88,91,82,70))

library(dplyr)
library(tidyr)

grades %>% spread(test,grade) %>% gather(test_type,score,-student)
