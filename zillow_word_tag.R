## zillow word tag
library(data.table)

start.time <- proc.time()

#setwd("/Users/dnoriega/Documents/Github/zillow_projects/data") # mac
setwd("D:/Dan's Workspace/Zillow/data") # pc

## functions
# trim leading and trailing whitespace
trim <- function(x) {
	gsub("^\\s+|\\s+$", "", x, perl=TRUE)
}

# input table
inputdata <- function(y) {
	x <- big.read(y)
	x <- x[,c(1,3)] # subset dataframe x all rows, columns 1 and 3  
	names(x) <- c("id","ngram") # rename data variable names
	x$ngram <- trim(x$ngram) # trim whitespace from words
	return(x)
}

big.read <- function(x) {
    tabnrows <- read.table(x, sep ="\t", as.is = TRUE, nrows = 3)
    classes <- sapply(tabnrows, class)
    tabAll <-  read.table(x, sep ="\t", as.is = TRUE, colClasses = classes, comment.char = "")
    return(tabAll)
}

## input data
## get corpus (all hhids and descriptions)
system.time(corpus <- read.csv("atype76.csv", header = TRUE, 
	colClasses = c("integer","character"), comment.char="", nrows = 1608699))
corpus$avalue <- trim(corpus$avalue)
corpus <- data.table(corpus)

system.time(zillow.fd <- big.read("zillow_bi_fd.txt"))
names(zillow.fd) <- c("ngram","total")
zillow.fd$ngram <- trim(zillow.fd$ngram)


## get ngram data
system.time(bigrams <- inputdata("zillow_bi.txt"))

## create data tables
zillow.fd <- data.table(zillow.fd, key = "ngram")
bigrams <- data.table(bigrams, key = "ngram")

## merge and shrink
system.time( m.data <- merge(bigrams, zillow.fd, by = "ngram")) # merge both data sets
m.data <- m.data[order(-m.data$total), ] # order the data by total
bigrams <- subset(m.data, total < 50000 & total > 10 ) # update bigrams; remove the subset of data with very high counts

# take split word list `strsplit(bigrams$ngram, "\\s")`
#	 unlist then convert to matrix of 2 cols, then to data frame
bi.split = data.frame(matrix(unlist(strsplit(bigrams$ngram, "\\s")), ncol = 2, byrow = T), 
	stringsAsFactors = FALSE )
names(bi.split) <- c("b1","b2")
attach(bi.split)

## words of interest
words <- read.table("zillow_words_of_interest.txt",sep="\n",as.is = TRUE)
words <- c(as.matrix(words))

## find all households with words of interest then remove duplicates hhids and match hhids to corpus
words.match <- rbind(bigrams[which(b1 %in% words), ], bigrams[which(b2 %in% words), ], bigrams[ bigrams$ngram %in% words, ])
hhid <- unique(sort(words.match$id)) # remove duplicate hhids and sort
woi <- unique(words.match$ngram) # removed duplicate bigrams and sort
woi <- sort(woi)

## output bigrams of interest
write.csv(woi,"zillow_bigrams_list.csv", row.names = FALSE, quote = FALSE)
write.csv(woi,"C:/Users/dng/Dropbox/SolarHedonic/Dan/zillow_bigrams_list.csv", row.names = FALSE, quote = FALSE)

## match hhids to corpus, extract descriptions
stime <- proc.time()
hhid.match <- corpus[ corpus$pid %in% hhid , ] 
stime <- proc.time() - stime
print(stime)

write.csv(hhid.match,"zillow_bigrams_tag.csv", row.names = FALSE, quote = FALSE)
write.csv(hhid.match,"C:/Users/dng/Dropbox/SolarHedonic/Dan/zillow_bigrams_tag.csv", row.names = FALSE, quote = FALSE)

start.time <- proc.time() - start.time
print(start.time)



