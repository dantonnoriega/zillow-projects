### (6) zillow_sample_100.R
### This code loads the permutations created in '(5) zillow_freq_match'
###     then draws samples of them from the full data set

# source '(5) zillow_freq_match'
source("/Users/dnoriega/Documents/Github/zillow_projects/(5) zillow_freq_match.R", echo = T)
#source("/home/dn95/research/zillow/(5) zillow_freq_match.R", echo = T) # for unix

# speed up reading files
big.read <- function(x) {
    tabnrows <- read.table(x, as.is = TRUE, nrows = 3)
    classes <- sapply(tabnrows, class)
    tabAll <-  read.table(x, as.is = TRUE, colClasses = classes, 
                          comment.char = "")
    return(data.table(tabAll))
}


stime <- proc.time()

## import unigram and bigrams by household
#setwd("/home/dn95/research/zillow/data") # unix cluster
setwd("/Volumes/UNTITLED/") # unix cluster
files <- c("zillow_bi.txt","zillow_uni.txt") # unix cluster
#setwd("/Users/dnoriega/Dropbox/SolarHedonic/text analysis/data")
#files <- c("zillow_bi_sample.txt","zillow_uni_sample.txt")
f <- lapply(files, big.read)

## create objects and reduce the data sets
bi <- f[[1]]
uni <- f[[2]]
listings <- data.table(read.csv("atype76_raw.csv", as.is = T, colClasses = c("integer","character"), header = T))

bi <- data.table(bi$V1,paste(bi$V3,bi$V4))
uni <- data.table(uni$V1,uni$V3)

## name the data sets
lapply(list(bi,uni), function(x) setnames(x, names(x), c("hhid","ngram")))

### BIGRAMS
## run through each bigram, sampling 100 (or all if < 100) from the whole list of homes
bi.samp <- function (x) {
    
    freq <- bi.m$freq[bi.m$ngram %in% x] # get word frequency
    word <- x
    
    match <- bi[bi$ngram %in% word] # find subset of all matching words
    n <- min(nrow(match),100) # how many samples to draw
    samp <- match[sample(1:nrow(match),n)] # sample the subset n times

    return(samp)  
}

# find set of samples `s`.
s <- lapply(bi.m$ngram, bi.samp) # create a list where each element is the sample draw
bi.s <- data.table(do.call(rbind, s)) # stack the sample draws





### UNIGRAMS
## first, remove the "greyed out" words from uni.m "upgrad","system","remodel","electr"
uni.m <- uni.m[!(uni.m$ngram %in% c("upgrad","system","remodel","electr"))]

uni.samp <- function (x) {
    
    freq <- uni.m$freq[uni.m$ngram %in% x] # get word frequency
    word <- x
    
    match <- uni[uni$ngram %in% word] # find subset of all matching words
    samp <- match[sample(1:nrow(match),min(nrow(match),100))] # sample n = min(100,nrow(s))
       
    return(samp)   
}

# find set of samples `s`.
s <- lapply(uni.m$ngram, uni.samp) # create a list where each element is the sample draw
uni.s <- data.table(do.call(rbind, s)) # stack the sample draws




## find unique hhids
hhid.u <- unique(sort(c(bi.s$hhid,uni.s$hhid)))


## match hhids to listings and get subset
listings.m <- listings[listings$pid %in% hhid.u]

# write listings
#setwd("/home/dn95/research/zillow/data") # unix cluster
setwd("/Users/dnoriega/Dropbox/SolarHedonic/text analysis/")
write.csv(listings.m, "zillow_sampled_listings_raw.csv", quote = FALSE, row.names = F)

stime <- proc.time() - stime
print(stime)


