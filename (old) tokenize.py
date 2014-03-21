#!/usr/bin/env python
# -*- coding: utf-8 -*-
## python map for word counts

# Import Modules
import nltk
import os
import re

os.chdir("D:\Dan's Workspace\GitHub Repository\zillow_projects\data")
#os.chdir("D:\Dan's Workspace\Zillow\data")

# periods (to save abbrevs)
period = re.compile(r'(\A|\s)(\w\.)+')
# all non alphanumeric
symbols = re.compile(r'(\W+)', re.U)
# pure numeric and numeric/alpha combos
numeric = re.compile(r'(\d+|\w+\d+|\d+\w+|\d+\w+\d+|\w+\d+\w+)(\s|\Z)', re.I|re.U)
# separators (any whitespace)
seps = re.compile(r'\s+')
# lone non digit numbers
lone = re.compile(r'(?<=\s)(\D)(?=\s|\Z)', re.I|re.U)
# get stopwords
stops = set(nltk.corpus.stopwords.words("english"))
# get stemmers
stemmer = nltk.stem.porter.PorterStemmer()

## cleaner (order matters)
def clean(text): 
    text = text.lower()
    h = period.match(text) # find any abbreviations (like p.v.c.)
    if h:
        text = text.replace('.','') # remove periods if found
    text = symbols.sub(' ', text)
    text = numeric.sub(' ', text)
    text = lone.sub(' ', text)
    text = seps.sub(' ', text)

    return text
    
wordlist = open("wordlist.txt",'w') # output file where words are saved        
f = open("atype76_raw.txt", 'r')
i = 0

for line in f:
    i += 1
    txt = clean(line)            
    tkns = [w for w in txt.split() if len(w) > 2 ] # only > 2 letter words
    tkns = [w for w in tkns if not w in stops]
    tkns = [stemmer.stem(w) for w in tkns]
    counter = tkns.count # minor speedup
    tkncnt = dict((w,counter(w)) for w in set(tkns))
     

    for w in tkncnt:       
        wordlist.write(u"{0}\t{1}\t{2}\n".format(i,w,tkncnt[w]))       
    print i
    
