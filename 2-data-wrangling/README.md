# Session 2: Data Wrangling in R. 

Welcome to the second session of 15.S60! In this session, we'll discuss tools for data exploration, cleaning, and manipulation using state-of-the-art packages for the `R` programming language. 

## Installing Software

Before Thursday's session, please fire up RStudio and run the following commands in the console window: 

    install.packages('dplyr')
    install.packages('tidyr')

You should see some messages confirming that the software has installed correctly. If so, you are good to go -- that's all the software you'll need for Thursday. 

## Files in this Directory

### Keeping Current

To ensure that you have the most current versions of all files, please fire up a terminal, navigate to the directory into which you cloned the full set of materials for 15.S60, and run `git pull`. 

### Main Files
You'll see a number of files in this directory. The ones you'll need for Thursday are:

- `presentation.R`: this is the outline we'll be using as we code through examples together. We recommend that you open up your local version of this file and follow along. 
- `exercises.R`: After each main presentation section, you'll break off and work on your own or with a neighbor to work through a few more examples. This file contains both the prompts and solutions. 

You may also be interested in checking out `script.R` -- the complete script Alex and Phil used as reference for the coding portion of the presentation -- and `grades.R`, a very short script that illustrates `spread()` and `gather()` from tidyr on the toy data set shown on the slides. 

## Additional Resources

`dplyr` and `tidyr` are well-established packages within the `R` community, and there are many resources to use for reference and further learning. Some of our favorites are below. 

- Tutorials by Hadley Wickham for `dplyr` [basics](https://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html), [advanced grouped operations](https://cran.r-project.org/web/packages/dplyr/vignettes/window-functions.html), and [database interface](https://cran.r-project.org/web/packages/dplyr/vignettes/databases.html).
- Third-party [tutorial](http://www.dataschool.io/dplyr-tutorial-for-faster-data-manipulation-in-r/) (including docs and a video) for using `dplyr`
- [Principles](http://vita.had.co.nz/papers/tidy-data.pdf) and [practice](https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html) of tidy data using `tidyr`
- (Detailed) [cheatsheet](https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf?version=0.99.687&mode=desktop) for `dplyr` and `tidyr` 
- [Comparative discussion](http://stackoverflow.com/questions/21435339/data-table-vs-dplyr-can-one-do-something-well-the-other-cant-or-does-poorly) of `dplyr` and `data.table`, an alternative package with higher performance but more challenging syntax.  