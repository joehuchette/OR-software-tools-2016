library(dplyr)
library(tidyr)

# change as needed
setwd("~/Google Drive/orc/IAP_2016")

# read the data and convert to local df just in case
trips <- read.csv('2013-05-14_neighborhoods.csv') %>% tbl_df
areas <- read.csv('area_info.csv') %>% tbl_df

m <- trips %>% 
	rename(id = pdistrict) %>% # use pdistrict as lookup key
	left_join(areas, by = 'id') %>%
	rename(pborough = borough) %>% # distinguish pborough from dborough below
	rename(pdistrict = id, id = ddistrict) %>% # now use ddistrict as lookup key
	left_join(areas, by = 'id') %>%
	rename(dborough = borough) %>% # distinguish dborough from pborough above 
	count(pborough, dborough) %>% # df of counts
	filter(!is.na(dborough),!is.na(pborough)) %>%
	spread(key = dborough, value = n, fill = 0) %>% # convert to `matrix shaped' df
	select(-pborough) %>%
	data.matrix() # now construct the matrix

rownames(m) <- colnames(m) # need this for readable heatmap
m %>% heatmap(scale = 'row', symm = T) # create the heatmap

# how to read: light colors mean that most of that row's traffic 
# goes to the corresponding column. E.g. Most the most popular 
# destination from the Bronx is the Bronx again, but Manhattan
# is also a very popular destination. On the other hand, 
# almost all trips from Manhattan stay in Manhattan. 

# Unfortunately, the version of this done by district rather than 
# borough isn't really legible. 