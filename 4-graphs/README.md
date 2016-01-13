# Networks in R
This course covers the excellent `igraph` package, used to create, analyse and visualize networks in R. We will apply these tools to analyse the taxi rides in New York city, and to study Manhattan's routing network.

## Pre-assignment
### Git update
Please update your git repository to get the latest version of everything. To do so, go to your repository and:

```
  git pull
```

## Packages
We will use the new packages `igraph` and `RColorBrewer`. Please install them using the following commands:

```
install.packages("igraph")
install.packages("RColorBrewer")
```

## Assignment
First, start R and set your working directory to the 4-graphs folder of the git repository. Then, run the following commands

```
library(igraph)
set.seed(144)
max(betweenness(erdos.renyi.game(100, 0.5)))
```

Please submit the output of this R input (one line) in a .txt file on stellar.

## Questions?
Please email Sébastien Martin (semartin@mit.edu).
