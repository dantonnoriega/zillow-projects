### (0) initialize_zillow.R
### import raw zillow data and remove duplicates
library(data.table)

## set working directory to output data
setwd("D:/Dan's Workspace/Zillow/data/")

## set the root for the location of the raw data
##  also, set the names of the files to be imported
raw_dir <- "D:/Work/Research/Zillow/raw_data/"
files <- c("data_descriptions.txt","data_wo_descriptions.txt")

## sample5rows of each data set to explore
samp5rows <- lapply(paste0(raw_dir, files), fread, nrows = 50)