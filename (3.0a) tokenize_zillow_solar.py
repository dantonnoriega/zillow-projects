#!/usr/bin/env python
# -*- coding: utf-8 -*-

## (3.0a) tokenize_zillow_solar
## this captures common bigrams and trigrams in any homes that listed "solar"


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
zillow_bi = codecs.open('zillow_bi.txt', 'w', encoding = 'utf-8')
zillow_tri = codecs.open('zillow_tri.txt', 'w', encoding = 'utf-8')
zillow_bi_fd = codecs.open('zillow_bi_fd.txt', 'w', encoding = 'utf-8')
zillow_tri_fd = codecs.open('zillow_tri_fd.txt', 'w', encoding = 'utf-8')

## import file
f = open('zillow_w_solar_tag.csv','r')

## import data using pandas package
# -names- is to label the columns
# -header- makes the first observation the header 
data = pd.read_csv(f, names = ['pid','text'], header = 0, encoding='iso-8859-1')
f.close()
text = data['text']

bi_fd = nltk.FreqDist()
tri_fd = nltk.FreqDist()
# create output file of tokens by household (aka by row/obs) and make corpus
i = 0 # initialize i
for line in text:
    txt = clean(line) 
    tkns = [w for w in txt.split() if len(w) > 2 ] # only > 2 letter words
    tkns = [w for w in tkns if not w in stops]
    tkns = [stemmer.stem(w) for w in tkns]
    doc = nltk.Text(tkns)
    bigrams = nltk.bigrams(doc) # find bigrams
    trigrams = nltk.trigrams(doc)	# find trigrams
    bi_counter = bigrams.count # count bigrams
    bi_cnt = dict((w,bi_counter(w)) for w in set(bigrams))
    tri_counter = trigrams.count # minor speedup
    tri_cnt = dict((w,tri_counter(w)) for w in set(trigrams))
    
    for w in bigrams:
        bi_fd.inc(w)
    for w in trigrams:
        tri_fd.inc(w)
     
    for w in bi_cnt:       
        zillow_bi.write(u'%-10s \t %-40s \t %10s\r\n' % (i+1,w,bi_cnt[w]))
    for w in tri_cnt:       
        zillow_tri.write(u' %-10s \t %-40s \t %10s\r\n' % (i+1,w,tri_cnt[w]))       
		
    i += 1
    print i

# tokenize the corpus
for w in bi_fd:
    zillow_bi_fd.write(u'%-15s \t %4s\r\n' % (w, bi_fd[w]))
for w in tri_fd:
    zillow_tri_fd.write(u'%-15s \t %4s\r\n' % (w, tri_fd[w]))
   
zillow_bi_fd.close()  
zillow_tri_fd.close()  
zillow_tri.close()
zillow_bi.close()

