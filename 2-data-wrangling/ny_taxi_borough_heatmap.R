library(dplyr)
library(tidyr)
library(ggplot2)

# change as needed
setwd("~/Google Drive/orc/iap/2-data-wrangling")

# read the data and convert to local df just in case
trips <- read.csv('2013-05-14_neighborhoods.csv') %>% tbl_df
areas <- read.csv('area_info.csv') %>% tbl_df

write.csv(areas, 'area_info.csv', row.names = FALSE)


# mini-assignment: use dplyr to create a unique id column
trips <- trips %>% mutate(trip_id = row_number()) 

# alternative: 
trips %>% mutate(dummy = 1, trip_id = cumsum(dummy)) %>%
	select(-dummy) %>% glimpse

# Path 1: use gather and a single join
m <- trips %>% 
	select(pdistrict, ddistrict) %>%
	mutate(trip_id = row_number()) %>%
	gather(p_or_d, district, -trip_id) %>%
	left_join(areas, by = c('district' = 'id')) %>%
	select(trip_id, p_or_d, borough) %>%
	spread(key = p_or_d, value = borough) %>%
	rename(pborough = pdistrict, dborough = ddistrict) %>%
	filter(!is.na(dborough), !is.na(pborough)) %>%
	count(pborough, dborough) %>%
	spread(key = dborough, value = n, fill = 0) # convert to `matrix shaped' df


# Visualize
m <- m %>% select(-pborough) %>% data.matrix
rownames(m) <- colnames(m)
heatmap(m, symm = TRUE, scale = 'row')

# Path 2: two joins and a call to rename
m <- trips %>% 
	select(pdistrict, ddistrict) %>%
	left_join(areas, by = c('pdistrict' = 'id')) %>%
	rename(pborough = borough) %>% # distinguish pborough from dborough below
	left_join(areas, by = c('ddistrict' = 'id')) %>%
	rename(dborough = borough) %>% # distinguish dborough from pborough above 
	count(pborough, dborough) %>% # df of counts
	filter(!is.na(dborough),!is.na(pborough)) %>%
	spread(key = dborough, value = n, fill = 0)

# Visualize
m <- m %>% select(-pborough) %>% data.matrix
rownames(m) <- colnames(m)
heatmap(m, symm = TRUE, scale = 'row')

# how to read: light colors mean that most of that row's traffic 
# goes to the corresponding column. E.g. Most the most popular 
# destination from the Bronx is the Bronx again, but Manhattan
# is also a very popular destination. On the other hand, 
# almost all trips from Manhattan stay in Manhattan. 

# Unfortunately, the version of this done by district rather than 
# borough isn't really legible. 