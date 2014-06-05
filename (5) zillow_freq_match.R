### (5) zillow_freq_match.R
### this takes the "words of interest" list and matches it to the overall bi and uni
###      gram frequency distributions
stime <- proc.time()

library(gtools)
library(data.table)

setwd("/Users/dnoriega/Dropbox/SolarHedonic/text analysis/data")

# speed up reading files
big.read <- function(x) {
    tabnrows <- read.table(x, as.is = TRUE, nrows = 3)
    classes <- sapply(tabnrows, class)
    tabAll <-  read.table(x, as.is = TRUE, colClasses = classes, 
                          comment.char = "")
    return(data.table(tabAll))
}

## import data and split up
#files <- c("zillow_bi_fd_sample.txt","zillow_bi_words_of_interest.txt","zillow_uni_fd_sample.txt",
#        "zillow_uni_words_of_interest.txt")## import data and split up
files <- c("zillow_bi_fd.txt","zillow_bi_words_of_interest.txt","zillow_uni_fd.txt",
           "zillow_uni_words_of_interest.txt")
f <- lapply(files, big.read)

## rename objects and bind the bigram text column vectors 
##  (so they're bigrams -- faster than trimming everything)
bi.fd <- data.table(paste(f[[1]]$V1,f[[1]]$V2),f[[1]]$V3)
bi.woi <- data.table(paste(f[[2]]$V1,f[[2]]$V2))
uni.fd <- f[[3]]
uni.woi <- f[[4]]

## set column names. the .fd's have two columns. the .woi's only have one.
lapply(list(bi.fd, uni.fd), function(x) setnames(x, names(x), c("ngram","freq")))
lapply(list(bi.woi, uni.woi), function(x) setnames(x, names(x), c("ngram")))

#### SECTION 1: match unigrams
# .m = matched
uni.m <- uni.fd[uni.fd$ngram %in% uni.woi$ngram]


#### SECTION 2: match bigrams and PERMUTED unigrams
bi.m <- bi.fd[bi.fd$ngram %in% bi.woi$ngram] # match existing bigrams

## permutations
n = dim(uni.woi)[1]
r = 2
p <- permutations(n,r,uni.woi$ngram)
bi.p <- data.table(paste(p[,1],p[,2])) 
setnames(bi.p, names(bi.p), c("ngram")) # set names (helps with matching data tables quickly)
bi.m <- rbind(bi.m, bi.fd[bi.fd$ngram %in% bi.p$ngram]) # stack the bigrams
bi.m <- unique(bi.m) # remove duplicates

# write the files
#setwd("/Users/dnoriega/Dropbox/SolarHedonic/text analysis/")
#write.csv(uni.m, "zillow_woi_unigram_freq.txt", quote = FALSE, row.names = F)
#write.csv(bi.m, "zillow_woi_bigram_freq.txt", quote = FALSE, row.names = F)

stime <- proc.time() - stime
print(stime)
