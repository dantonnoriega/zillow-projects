#!/usr/bin/env python
# -*- coding: utf-8 -*-

import nltk
import os
import re
import pandas as pd
import codecs


#os.chdir("D:\Dan's Workspace\GitHub Repository\zillow_projects\data")
os.chdir("D:\Dan's Workspace\Zillow\data")

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

## create utf-8 compatible codec files
corpus_clean = codecs.open('corpus_clean.txt', 'w', encoding = 'utf-8')
corpus_tknzd = codecs.open('corpus_tknzd.txt', 'w', encoding = 'utf-8')
tkns_bypid = codecs.open('tkns_bypid.txt', 'w', encoding = 'utf-8')

## import csv file
csvfile = open('atype76.csv','r')

## import data using pandas package
# -names- is to label the columns
# -header- makes the first observation the header 
data = pd.read_csv(csvfile, names = ['pid','text'], header = 0, encoding='iso-8859-1')
csvfile.close()
text = data['text']  

corpus_fd = nltk.FreqDist()

# create output file of tokens by household (aka by row/obs) and make corpus
i = 0 # initialize i
for line in text:
    txt = clean(line) 
    tkns = [w for w in txt.split() if len(w) > 2 ] # only > 2 letter words
    tkns = [w for w in tkns if not w in stops]
    tkns = [stemmer.stem(w) for w in tkns]
    counter = tkns.count # minor speedup
    tkncnt = dict((w,counter(w)) for w in set(tkns))
    pid = data['pid'][i]
    
    for w in tkns:
        corpus_fd.inc(w)
     
    for w in tkncnt:       
        tkns_bypid.write(u'%-15s \t %-10s \t %-25s \t %10s\r\n' % (pid,i+1,w,tkncnt[w]))       
        corpus_clean.write(u"{0} ".format(w))
    i += 1
    print i

# tokenize the corpus
for w in corpus_fd:
    corpus_tknzd.write(u'%-15s \t %4s\r\n' % (w, corpus_fd[w]))
   
tkns_bypid.close()
corpus_tknzd.close()
corpus_clean.close()


## create bigrams

corpus = nltk.Text(w for w in open('corpus_clean.txt', 'r').read().split())
bigrams = nltk.bigrams(corpus)
trigrams = nltk.trigrams(corpus)

## corpus analysis
corpus.concordance("solar")
corpus.count("solar")

    