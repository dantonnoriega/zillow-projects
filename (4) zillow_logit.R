## glmnet for data set
library(doParallel)
library(glmnet)
library(data.table)

setwd("D:/Dan's Workspace/Zillow/data")

## functions
# trim leading and trailing whitespace
trim <- function(x) {
    gsub("^\\s+|\\s+$", "", x, perl=TRUE)
}

big.read <- function(x) {
    tabnrows <- read.table(x, sep ="\t", as.is = TRUE, nrows = 3)
    classes <- sapply(tabnrows, class)
    tabAll <-  read.table(x, sep ="\t", as.is = TRUE, colClasses = classes, comment.char = "")
    return(tabAll)
}

## set timer
start.timer <- proc.time()

## import data
system.time( zillow.data <- big.read("zillow_bi.txt"))
system.time( CAgreen.data <- big.read("green_bi.txt"))
zillow.data <- zillow.data[,c(-2,-5)]
CAgreen.data <- CAgreen.data[,c(-2,-5)]

## create new variables
zillow.data$green <- as.vector(0)
CAgreen.data$green <- as.vector(1)

## add names
names(zillow.data) <- unlist(strsplit("pid ngram count green", split = " "))
names(CAgreen.data) <- unlist(strsplit("pid ngram count green", split = " "))


## get the frequency distribution
system.time(zillow.fd <- big.read("zillow_bi_fd.txt"))
names(zillow.fd) <- c("ngram","total")

## trim and create factors
zillow.data$ngram <- trim(zillow.data$ngram)
CAgreen.data$ngram <- trim(CAgreen.data$ngram)
zillow.fd$ngram <- trim(zillow.fd$ngram)


## create data tables
dt.c <- data.table(CAgreen.data, key = "ngram")
dt.z.fd <- data.table(zillow.fd, key = "ngram")
dt.z <- data.table(zillow.data, key = "ngram")

## merge and shrink
system.time( m.data <- merge(dt.z, dt.z.fd, by = "ngram")) # merge both data sets
m.data <- m.data[order(-m.data$total), ] # order the data by total
m.sub <- subset(m.data, total < 50000 & total > 10) # remove the subset of data with very high counts
m.sub <- m.sub[ , total:=NULL]
m.sub <- rbind(dt.c, m.sub, use.names = TRUE) # stack zillow bi with CA bi
m.sub$ngram <- as.factor(m.sub$ngram) # needed for matrix.model

## at unique identifier
# from http://stackoverflow.com/questions/13566562/creating-an-unique-id-in-r
m.sub <- transform(m.sub, i = as.numeric(interaction(dt.s$pid, dt.s$green, drop = TRUE))) 

## sort data
m.sort <- m.sub[order(m.sub$i), ] # sort by hhid
m.sort <- m.sort[rep(1:nrow(m.sort), m.sort$count), ] # expand by counts then remove counts
m.sort <- m.sort[ , count:=NULL]

## create matrices for use in glm
x <- xtabs(~ i + ngram, m.sort, sparse = TRUE) # get sparse matrix for data
y <- m.sub[ , list(green = max(green)), by = i]
y <- y[order(y$i), ]
y <- y[, i:=NULL]
y <- y[,2]
y <- as.matrix(y)

## run parallel glm model (option `parallel = TRUE`)
# registerDoParallel(12)
# s.time <- proc.time()
# m1 <- cv.glmnet(x, y, family = "binomial", type.measure="auc", parallel = TRUE)
# s.time <- proc.time() - s.time
# print(s.time)
# print(m1)
# 
# s.time <- proc.time()
# m1 <- cv.glmnet(x, y, family = "binomial", type.measure="auc")
# s.time <- proc.time() - s.time
# print(s.time)
# print(m1)

s.time <- proc.time()
m2 <- glmnet(x, y, family = "binomial")
s.time <- proc.time() - s.time
print(s.time)
print(m2)

## find significant words
r<-predict(m2,type="nonzero") #create vector of significant beta's

j <- 0L

s.out <- function(a) {
    
    sig <- colnames(x)[a] # display significant bigrams

    if(!is.null(a)) {
        h <- "C:/Users/dng/Dropbox/SolarHedonic/Dan/glmnet results/"
        write.table(sig, file = paste("glmnet results/s",j,".txt",sep=""), 
                quote = FALSE, row.names = FALSE, col.names = FALSE, sep = "\n")
        write.table(sig, file = paste(h,"s",j,".txt", sep=""), 
                quote = FALSE, row.names = FALSE, col.names = FALSE, sep = "\n")
        j <<- j + 1
    } 
    
}

output <- lapply(r, s.out)

end.timer <- proc.time() - start.timer
print(end.timer)