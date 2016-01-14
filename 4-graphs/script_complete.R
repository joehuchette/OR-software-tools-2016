###
# Before you start
###

# Make sure you have the needed packages installed and loaded:
# If you did the pre-assignment and the previous classes, they should be installed

install.packages("tidyr")
install.packages("dplyr")
install.packages("igraph")
install.packages("RColorBrewer")
install.packages("ggplot2")
install.packages("ggmap")

##################################################################
# Section 1 -- Data Wrangling to Construct Networks in R
##################################################################

library(tidyr)
library(dplyr)
library(ggplot2)
library(ggmap)

# Go to your data folder, you should have the following CSV files:
# 2013-05-14_neighborhoods.csv and area_info_full.csv
# If you do not have them, just use git pull to update your repository

# Let's start by loading the trips and neighborhoods data (this should take a few seconds)
trips <- read.csv("2013-05-14_neighborhoods.csv", stringsAsFactors = F) %>% tbl_df()

trips %>% head

# The two columns "pdistrict" and "ddistrict" represent the pick-up and drop-off neighborhood
# These neighborhoods are grouped into 5 boroughs: "Manhattan", "Bronx", "Brooklyn", "Queens", "Staten Island"
# All these districts can be visualize at http://nyc.pediacities.com/New_York_City_Neighborhoods

# We want to study the relationships between these districts. We consider that two districts are "linked"
# if there exists a taxi ride between them during the day. We want to study the resulting networks, where the nodes
# are the districts and the edges are the rides. This network can give a lot of insights on the dynamics of the city.

# Information about the districts has been compiled into the CSV file "area_info_full.csv"
# Let's open it 

districts <- read.csv("area_info_full.csv", stringsAsFactors = F) %>% tbl_df()

districts %>% head()

# The districts are currently sorted alphabeticaly, we can use the arrange dplyr word to sort them by borough first

districts <- districts %>% arrange(borough_id)
districts %>% head()

# Let's use our previous ggmap plotting class to visualize the centroids of these neighborhoods

nyc <- get_map(location = c(lon = -73.9, lat = 40.7), zoom = 10)
ggmap(nyc)  + 
  geom_point(data = districts, aes(x = centroid_lon, y = centroid_lat))

# An edge represents the existence of a ride between two districts
# first, we need to filter out the NA values of the rides that are outside of NYC

trips %>%
  filter(!is.na(pdistrict),
         !is.na(ddistrict))

# Then, we use the group_by/summarize strategy to group the rides by pick-up and drop-off districts

edges <- trips %>%
  filter(!is.na(pdistrict),
         !is.na(ddistrict)) %>%
  group_by(pdistrict, ddistrict) %>%
  summarize(count = n()) 

# An edges has 3 values: pick-up district, drop-off district and number of rides
edges

# Now we can construct our graph with graph.data.frame() from igraph.
library(igraph)  
g <- graph.data.frame(edges, directed=T, districts)

# The first line says we have a directed graph (D) with named vertices (N).
# The attributes list shows all vertex and edge attributes. The first
# entry in ()'s is whether vertex (v) or edge (e) attribute, and the second
# is the type of attribute: character (c) or numeric (n).
g

# Easy to access vertex and edge sequences and metadata
head(V(g))
head(V(g)$district_name)
head(E(g))
head(E(g)$count)

# Let's compute some basic properties of the network (more metrics coming
# later in the module)
ecount(g)
vcount(g)
graph.density(g)

##################################################################
# Exercise 1 : Create the network of NYC's districts, with the following rules:
# - each vertex is a district
# - there is an edge if and only if there are more taxi trips between the two districts
#   than the average number of taxi trips between two districts
#   (hint: use filter to subset the edges)
# What is the new density ?

# Solution:
# computing the average number of taxi trips between two districts
mean.trips = nrow(trips)/(nrow(districts)*(nrow(districts) - 1))

# creating the edges using the

edges2 <- trips %>%
  filter(!is.na(pdistrict),
         !is.na(ddistrict)) %>%
  group_by(pdistrict, ddistrict) %>%
  summarize(count = n())  %>%
  filter(count >= mean.trips)

g2 <- graph.data.frame(edges2, directed=T, districts)
ecount(g2)
graph.density(g2)

##################################################################
# Section 2 -- Visualization and analysis
##################################################################


# Let's start out by seeing what exactly is returned when we run a
# graph layout algorithm. Of course, we have longitude/latitude information
# for the districts, so we're doing this more as an exercise in looking at
# graph layout algorithms. Later in the section we'll layout nodes based on
# geography.

layout1 <- layout.fruchterman.reingold(g)
dim(layout1)
head(layout1)

# It's just a set of 2-d points, one for each vertex. We could get a
# higher-dimensional layout with the "dim" parameter. Force-directed
# layouts are typically optimized from a random starting location, so
# we would expect a different layout if we ran it again (this is one of
# the complaints people have with these sorts of layouts). We could use
# set.seed() to ensure the same value for multiple runs of the algorithm.
layout1 <- layout.fruchterman.reingold(g)
head(layout1)

# igraph has a lot of built-in plotting tools. Unfortunately they do not use the ggplot syntax.
#We can plot with our selected layout with the plot() function.
plot(g, layout=layout1)  # Can cancel with escape key

# If takes a long time to plot the graph to the R display, we can
# instead plot it to a file and then open the file.
png("plot1.png")
plot(g, layout=layout1)
dev.off()


# Most first attempts at plotting a graph look pretty bad. We need to
# do the following:
# 1) Remove the vertex names
# 2) Make the vertices smaller
# 3) Remove the arrowheads 
# We'll need to look at ?igraph.plotting to figure out how to do this
?igraph.plotting
plot(g, layout=layout1, vertex.size=3, edge.arrow.mode=0, vertex.label=NA)

# We have our first information: a lot of districts do not have any ride. Let's see which one they are
alone = V(g)[degree(g) == 0]
df = data.frame(lon=alone$centroid_lon, lat=alone$centroid_lat)
ggmap(nyc)  + 
  geom_point(data=df,aes(x = lon, y = lat))

# It seems fair, Staten Island is quite remote, and we did not expect any cab to be able to teleport
# We should really remove these nodes
g <-delete.vertices(g, alone)

# Now let's try to plot our graph with different layouts
layout1 = layout.fruchterman.reingold(g)
plot(g, layout=layout1, vertex.size=3, edge.arrow.mode=0, vertex.label=NA)
plot(g, layout=layout.random(g), vertex.size=3, edge.arrow.mode=0, vertex.label=NA)

# It's still hard to see what is going on. Notice that a lot of nodes are self-connected

# So far we set all the plotting properties vertex.size, vertex.label,
# and edge.arrow.mode to single values, meaning that value applied for
# all vertices/edges. We can also set values dynamically based on
# vertex/edge metadata, providing one value for each node or edge.
# First, let's use a color based on metadata. We will use a different color for each borough

# Let's choose some good colors -- we'll get a palette
# with 5 colors from RColorBrewer, which has carefully selected palettes
# where all the colors look good together. 

library(RColorBrewer)
display.brewer.all()

# use brewer.pal to subset the palette smartly
display.brewer.pal(5, "Set1")

#we will assing a different color to each borough
colors <- brewer.pal(5, "Set1")
legends = c("Manhattan", "Bronx", "Brooklyn", "Queens", "Staten Island")

# red= Manhattan, blue=Bronx, Green=Brooklyn, purple=Queens, orange=Staten Island
plot(g, layout=layout1, vertex.size=3, edge.arrow.mode=0, vertex.label=NA, vertex.color=colors[V(g)$borough_id])

# another way to do it is to add the attribute to the vertex itself:
V(g)$color=colors[V(g)$borough_id]
plot(g, layout=layout1, vertex.size=3, edge.arrow.mode=0, vertex.label=NA)


# Without surprise, Manhattan really is in the center of our district network. Staten Island is completely peripherical

# Let's try it with our reduced network
g2 <-delete.vertices(g2, V(g2)[degree(g2) == 0])
plot(g2, layout=layout.auto, vertex.size=3, edge.arrow.mode=0, vertex.label=NA, vertex.color=colors[V(g2)$borough_id])

# The new absent is the Bronx.

# One difficulty with plotting graphs is there being a mass of edges. One
# approach would be to remove low-volume edges as we did before, change their width or add transparency

edge.start <- get.edges(g, 1:ecount(g))[,1]
E(g)$color <- adjustcolor(V(g)$color[edge.start], alpha.f=.2) 

g %>% plot(layout=layout1, vertex.label=NA, vertex.size=3, edge.arrow.mode=0, edge.width = 1)


##################################################################
# Exercise 2: use the layout layout.circle to have clearer view of the edges
# Change the size of the nodes to depend on their degree (use degree(g) to have the list)
# Experiment with edge color/transparency/width to have a good-looking visualization
# Where are the two airports ?

## Solution
# First plot with the circle layout
g %>% plot(layout=layout.circle(g), vertex.label=NA, edge.arrow.mode=0, edge.width = 1)

# Change the node size to depend on the degree
V(g)$size <- degree(g)/10

# Is red or purple (Manhattan or Queens) the main color ? => change edge width to depend on trip count
E(g)$width <- log(1+E(g)$count)

#result
g %>% plot(layout=layout.circle(g), vertex.label=NA, edge.arrow.mode=0)


######
# Geographic layout
#  We are given the latitude and longitude of each neighborhood centroid. Let's use them to have a better layout


# A layout is just a nx2 matrix giving the position for each node
layout1

# We already have the latitude and longitude column, we just use cbind to put them together

geoLayout <- cbind(V(g)$centroid_lon, V(g)$centroid_lat)

# Let's plot this!
g %>% plot(layout=geoLayout, vertex.label=NA, edge.arrow.mode=0)

# Our previous parameters still apply! Her we would like to reduce the vertex size a bit
V(g)$size <-degree(g)/20
g %>% plot(layout=geoLayout, vertex.label=NA, edge.arrow.mode=0)

# Notice how a lot of rides are going from the JFK airport to the airport ? 
# Maybe they represent errors in the dataset, or a customer that enters and leaves immediately the taxi

# Visualization is a good way to learn a lot about your network. In the case of large networks, 
# each layout can provide different insights on the network dynamics, but when there is a "natural" one,
# it is usually preferable



##################################################################
# Section 3 -- Network Metrics
##################################################################
# Let's start out by computing some global network metrics.

# graph.density is the proportion of possible edges present
graph.density(g)

#reciprocity is the proportion of links that are bidirectional
reciprocity(g)

# assortativity.degree is the correlation of degrees of linked nodes
assortativity.degree(g)



# Now let's look at the distribution of some of the vertex and edge
# metrics.

#degree: number of neighbors
hist(degree(g))
head(sort(degree(g), decreasing=TRUE))

# print the names of the districts with highest degree => use names to get the vertices names
V(g)[names(head(sort(degree(g), decreasing=TRUE)))]$district_name


#closeness: inverse of sum of shortest path to other nodes
hist(closeness(g))
head(sort(closeness(g), decreasing=TRUE))
V(g)[names(head(sort(closeness(g), decreasing=TRUE)))]$district_name

#betweenness: number of s.p. containing vertex
hist(betweenness(g))
table(betweenness(g) == 0)
head(sort(betweenness(g), decreasing=TRUE))
V(g)[names(head(sort(betweenness(g), decreasing=TRUE)))]$district_name

#page rank: a score based on the neighbors scores
page.rank(g)
hist(page.rank(g)$vector)
head(sort(page.rank(g)$vector, decreasing=TRUE))
V(g)[names(head(sort(page.rank(g)$vector, decreasing=TRUE)))]$district_name

# transitivity: probability that two neighbors of a node are connected
hist(transitivity(g, "local"))

plot(transitivity(g,"local"),degree(g))

# transitivity() doesn't return a named vector, so we'll need to do a bit
# more work to figure out the districts with the largest transitivity.
# sort() returns the largest transitivities, but we will instead use
# order(), which returns the indices of the nodes with the largest
# transitivities.
head(order(transitivity(g, "local"), decreasing=TRUE))
transitivity(g, "local")[37]
transitivity(g, "local")[40]

# We can use the indices from order() to look up node names or degrees.
V(g)$district_name[head(order(transitivity(g, "local"), decreasing=TRUE))]
degree(g)[head(order(transitivity(g, "local"), decreasing=TRUE))]

# what are the nodes with the lowest transitivity ?
V(g)$district_name[head(order(transitivity(g, "local"), decreasing=FALSE))]
degree(g)[head(order(transitivity(g, "local"), decreasing=FALSE))]

# Makes sense: the hub nodes are connected to all the small nodes and thus have a low transitivity

# Edge betweenness is one of the most important edge metrics
# it's the number of shortest paths containing each edge
hist(edge.betweenness(g))
E(g)[head(order(edge.betweenness(g), decreasing=TRUE))]
V(g)[c("266","97")]$district_name

# One really common thing to do with vertex or edge metrics is to add
# them to a regression model that predicts some feature of the vertices
# or edges. The igraph network metric functions return vectors containing
# the metric so we can build a data frame with all the metrics we need
# as well as our outcome data that we've stored as vertex and edge
# metadata.

##################################################################
# Exercise 3: This network was interesting, but all the metrics showed us how centralized and dense it was.
# let's limit this density and construct a network representing the main affinities of the different districts
# we will link two districts with a direct edge if the second district is one of the 3 main destinations 
# from the first district.

# Start from the beginning. When constructing the edges, use the "slice" words after 
# ordering the rows number of trips. Hint: you should group the edges by pickup district first

edges3 <- trips %>%
  filter(!is.na(pdistrict),
         !is.na(ddistrict)) %>%
  group_by(pdistrict, ddistrict) %>%
  summarize(count = n()) %>%
  group_by(pdistrict) %>%
  arrange(desc(count)) %>%
  slice(1:3) %>%
  ungroup()

g3 <- graph.data.frame(edges3, directed=T, districts)

# Now study the new graph with visualizations and different statistics. Are the core districts still the same ?

#Some visualization
g3 <-delete.vertices(g3, V(g3)[degree(g3) == 0])
plot(g3, layout=layout.auto, vertex.size=3, edge.arrow.mode=0, vertex.label=NA, vertex.color=colors[V(g3)$borough_id])
# Manhattan is still central! A lot of nodes have self loops. Perhaps errors in the database or people doing short trips

graph.density(g3)
reciprocity(g3)
head(sort(degree(g3), decreasing=TRUE))
V(g)[names(head(sort(degree(g3), decreasing=TRUE)))]$district_name
V(g)[names(head(sort(betweenness(g3), decreasing=TRUE)))]$district_name
V(g)[names(head(sort(page.rank(g3)$vector, decreasing=TRUE)))]$district_name

# Notice that page-rank is now giving the expected results


##################################################################
# Section 4 -- Community detection
##################################################################

# One of the many modularity-maximizing algorithms in spinglass.community
comm <- spinglass.community(g)
comm
str(comm)
table(comm$membership)

#Let's visualize these communities on a map
df = data.frame(lon=V(g)$centroid_lon, lat=V(g)$centroid_lat, group=factor(comm$membership))
ggmap(nyc)  + 
  geom_point(data=df,aes(x = lon, y = lat, color=group))


#It seems to work fine, the community algorithm was able to detect geographical correlations
# Would that work on our other network g3 ?

is.connected(g)
is.connected(g3)
g4 = decompose(g3)[[1]]
is.connected(g4)
comm <- spinglass.community(g4)
comm

df = data.frame(lon=V(g4)$centroid_lon, lat=V(g4)$centroid_lat, group=factor(comm$membership))
ggmap(nyc)  + 
  geom_point(data=df,aes(x = lon, y = lat, color=group))



