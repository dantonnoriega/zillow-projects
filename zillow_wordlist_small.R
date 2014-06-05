library(data.table)

setwd("/Users/dnoriega/Dropbox/SolarHedonic/text analysis/data")

files <- c("s99.txt","zillow_words_of_interest.txt","zillow_logit_wordlist.txt")
f <- lapply(files, function(x) read.table(x, sep = "\n", col.names = "ngram", 
    colClasses = "character"))
f <- lapply(f, data.table)

s <- f[[1]]
z.woi <- f[[2]]
z.logit <- f[[3]]

ss <- data.table(matrix(unlist(strsplit(s$ngram, split = "\\s")), ncol = 2, 
    byrow = TRUE))

setnames(ss, old = names(ss), new=c("b1","b2"))
attach(ss)
woi <- rbind(s[b1 %in% z.woi$ngram, ], s[b2 %in% z.woi$ngram, ])
woi <- unique(x)

setwd("/Users/dnoriega/Dropbox/SolarHedonic/text analysis/")

write.csv(woi, "zillow_wordlist_small.csv", quote = FALSE, row.names = F)
