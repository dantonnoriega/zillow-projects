#!/usr/bin/env python
# -*- coding: utf-8 -*-

## (3.1) tokenize_greenhomes
## this code tokenizes words for a list of KNOWN green homes

import nltk
import os
import re
import pandas as pd
import codecs

os.chdir("D:\Dan's Workspace\GitHub Repository\zillow_projects\data")
#os.chdir("D:\Dan's Workspace\Zillow\data")

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

# cleaner (order matters)
def clean(text): 
    text = text.lower()
    text = symbols.sub(' ', text)
    text = lone.sub(' ', text)
    text = numeric.sub(' ', text)
    text = seps.sub(' ', text)
    return text

# create utf-8 compatible codec files
green_corpus = codecs.open('green_corpus.txt', 'w', encoding = 'utf-8')
green_corpus_tknzd = codecs.open('green_corpus_tknzd.txt', 'w', encoding = 'utf-8')
green_tkns = codecs.open('green_tkns.txt', 'w', encoding = 'utf-8')

# import csv file
csvfile = open('listing_of_green_homes.csv','rb')

# import data using pandas package
# -names- is to label the columns
# -header- makes the first observation the header 
data = pd.read_csv(csvfile, encoding='iso-8859-1')   
csvfile.close()
text = data['Description']

fd = nltk.FreqDist()

# create output file of tokens by household (aka by row/obs) and make corpus
i = 0 # initialize i
for line in text:
    txt = clean(line) 
    tkns = [w for w in txt.split() if len(w) > 2 ] # only > 2 letter words
    tkns = [w for w in tkns if not w in stops]
    tkns = [stemmer.stem(w) for w in tkns]
    counter = tkns.count # minor speedup
    tkncnt = dict((w,counter(w)) for w in set(tkns))
    
    for w in tkns:
        fd.inc(w)
     
    for w in tkncnt:
        green_tkns.write(u'%-10s \t %-25s \t %10s \t %1s\r\n' % (i+1,w,tkncnt[w],1))       
        green_corpus.write(u"{0} ".format(w))
    i += 1
    print i

# tokenize the corpus
for w in fd:
    green_corpus_tknzd.write(u'%-15s \t %4s\r\n' % (w, fd[w]))
   
green_tkns.close()
green_corpus.close()
green_corpus_tknzd.close()
