## zillow word tag

start.time <- proc.time()

#setwd("/Users/dnoriega/Documents/Github/zillow_projects/data") # mac
setwd("D:/Dan's Workspace/Zillow/data") # pc

## set up multicore usage
registerDoMC(detectCores())

## functions
# trim leading and trailing whitespace
trim <- function(x) {
	gsub("^\\s+|\\s+$", "", x, perl=TRUE)
}

# input table
inputdata <- function(y) {
	x = read.table(y, as.is = TRUE, sep = "\t")
	x <- x[,c(1,3)] # subset dataframe x all rows, columns 1 and 3  
	names(x) <- c("id","word") # rename data variable names
	x.sample <- x[sample(nrow(x),size=100), 1:ncol(x)] # sample n = 100 from all rows in both columns
	x$word <- trim(x$word) # trim whitespace from words
	return(x)
}

## input data
# get corpus (all hhids and decriptions)
#corpus <- read.csv("/Users/dnoriega/Dropbox/SolarHedonic/Dan/text analysis/atype76.csv", header = TRUE)
corpus <- read.csv("atype76.csv", header = TRUE)
corpus.sample <- corpus[sample(nrow(corpus),size=10000), 1:ncol(corpus)] # sample n = 100 from all rows in both columns
corpus.sample <- data.frame(corpus.sample[do.call(order, corpus.sample), ], row.names = seq_along(1:dim(corpus.sample)[1])) # order data frame by first column (pid)

# get ngram data
unigrams <- inputdata("zillow_uni.txt")
bigrams <- inputdata("zillow_bi.txt")
 
# words of interest
words = read.table("zillow_words_of_interest.txt",sep="\n")
words <- c(t(as.matrix(words))) # combine a transpose of matrix column text data

## find all households with words of interest then remove duplicates hhids and match hhids to corpus
hhid <- data.frame() # initialize empty data frame 

hhid1 <- subset(unigrams, match(unigrams$word,words,nomatch=0) > 0) # match unigrams
hhid2 <- subset(bigrams, match(bigrams$word,words,nomatch=0) > 0) # match bigrams
hhid <- rbind(hhid1,hhid2) # stack matched data sets
hhid <- unique(sort(hhid$id)) # remove duplicates and sort

## match hhids to corpus, extract descriptions
hhid.match <- data.frame() # initialize empty data frame
stime <- proc.time()
hhid.match <- subset(corpus, match(corpus$pid,hhid,nomatch=0) > 0)
stime <- proc.time() - stime
print(stime)


write.csv(hhid.match,"zillow_word_tag.csv", row.names = FALSE)
write.csv(hhid.match,"D:/Dan's Workspace/Zillow/spreadsheets/zillow_word_tag.csv", row.names = FALSE)

start.time <- proc.time() - start.time
print(start.time)



