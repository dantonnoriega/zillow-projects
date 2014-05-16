## zillow word tag
library(foreach)
library(doMC)
library(xlsx)
setwd("/Users/dnoriega/Documents/Github/zillow_projects/data")


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
corpus = read.csv("/Users/dnoriega/Dropbox/SolarHedonic/Dan/text analysis/atype76.csv", header = TRUE)
corpus.sample <- corpus[sample(nrow(corpus),size=10000), 1:ncol(corpus)] # sample n = 100 from all rows in both columns
corpus.sample <- data.frame(corpus.sample[do.call(order, corpus.sample), ], row.names = seq_along(1:dim(corpus.sample)[1])) # order data frame by first column (pid)

# get ngram data
unigrams <- inputdata("zillow_uni_sample.txt")
bigrams <- inputdata("zillow_bi_sample.txt")
 
# words of interest
words = read.table("zillow_words_of_interest.txt",sep="\n")
words <- c(t(as.matrix(words))) # combine a transpose of matrix column text data

## find all households with words of interest then remove duplicates hhids and match hhids to corpus
hhid <- data.frame() # initialize empty data frame 

for(i in words) hhid = rbind(hhid,subset(unigrams, word == i)) # rowbind all subsets of words
for(i in words) hhid = rbind(hhid,subset(bigrams, word == i)) # rowbind all subsets of words

hhid <- unique(sort(hhid$id)) # remove duplicates and sort
hhid.sample <- sample(hhid,100)

## match hhids to corpus, extract descriptions
hhid.match <- data.frame()


### MC TEST
corpus.upper <- corpus[1:100,]
hhid.samp <- corpus.upper[sample(nrow(corpus.upper),10),1]

ptime <- proc.time()
hhid.match <- foreach(i = iter(hhid.samp), .combine = rbind) %dopar% {
	print(i)
	matched <- subset(corpus.upper, pid == i)
	return(matched)
}
ptime <- proc.time() - ptime
print(ptime)
write.xlsx(hhid.match,"zillow_word_tag.xlsx",row.names = FALSE)

hhid.match2 <- data.frame()
stime <- proc.time()
hhid.match <- foreach(i = iter(hhid.samp), .combine = rbind) %do% {
	print(i)
	matched <- subset(corpus.upper, pid == i)
	return(matched)
}
stime <- proc.time() - stime
print(stime)


