#!/usr/bin/env python

import nltk
import os
import re


os.chdir("D:\Dan's Workspace\GitHub Repository\zillow_projects")
#os.chdir("D:\Dan's Workspace\Zillow\data")

# all non alphanumeric
numeric = re.compile(r'(\d+|\w+\d+|\d+\w+|\d+\w+\d+|\w+\d+\w+)(\s|\Z)', re.I|re.U)
# lone non digit numbers
lone = re.compile(r'(?<=\s)(\D)(?=\s|\Z)', re.I|re.U)
# get stopwords
stops = set(nltk.corpus.stopwords.words("english"))
# get stemmers
stemmer = nltk.stem.porter.PorterStemmer()

# cleaner (order matters)
def clean(text): 
    text = numeric.sub(' ', text)
    text = lone.sub(' ', text)
    return text
    


# import file
raw = open('atype76.txt','r') 

# convert to text (read()) and then clean (clean())
f = clean(raw.read()) 
raw.close()

# split the data into tokens
f = f.split() # split the read file (.read() converts the object)

# remove stops (keep if in f but not in stops)
f = [w for w in f if not w in stops]

f_stemmed = [stemmer.stem(w) for w in f]
 
# create frequency distribution object
fd = nltk.FreqDist(f)
fd_stemmed = nltk.FreqDist(f_stemmed)
    
for word in fd.keys():
    print word, fd[word]
    print word, fd_stemmed[word]
