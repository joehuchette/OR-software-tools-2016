# Visualization in R #
Welcome to the visualization module of the 2016 ORC software class! This course primarily covers the basics of ggplot2, an excellent and widely used visualization package for R. We'll also have brief sections on the importance of visualization, exploratory data analysis, and map visualizations.

We'll make liberal use of the concepts covered in the data wrangling module last Thursday. The content and structure of this module are heavily inspired by the 2015 version, but most of the examples are new. In particular, the emphasis on synergies between `dplyr` and `ggplot` is a new addition.

### Pre-assignment ###
This short pre-assignment ensures you have the required packages installed and working. The packages we'll need are `dplyr`, `tidyr`, `ggplot2`, and `ggmap`. You should already have the first two of these installed from Thursday's class. Install any missing packages with the `install.packages` command:
```
install.packages("dplyr")
install.packages("tidyr")
install.packages("ggplot2")
install.packages("ggmap")
```
Note that `ggplot2` recently received an update, so you may want to update via `update.packages()`.

Once you have the packages installed, set your working directory to the data subdirectory of the software tool 2016 repository. We'll test the installs by creating two simple plots; your assignment is to save these plots and post them to Stellar. 

To create the first plot (this may take a minute to run):
```
library(dplyr)
library(ggplot2)
trips <- read.csv("2013-05-14_neighborhoods.csv", stringsAsFactors = F) %>% tbl_df()
ggplot(head(trips), aes(x = trip_distance, y = fare_amount)) + geom_point()
```

To create the second plot:
```
library(ggmap)
mit <- get_map(location="MIT, Cambridge, MA", zoom = 15)
df <- data.frame(lat = 42.3608, lon = -71.0845)
ggmap(mit) + geom_point(data = df, aes(x = lon, y = lat), shape = 8, size = 6, color = "red")
```


### Questions ###
If you have any questions or need help, email Evan Fields at `efields@mit.edu`.
