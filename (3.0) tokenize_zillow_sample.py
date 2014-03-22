#!/usr/bin/env python
# -*- coding: utf-8 -*-

## (3.0) tokenize_sample
## this code tokenizes words for sample of zillow homes for modeling


import nltk
import os
import re
import pandas as pd
import codecs


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

## create utf-8 compatible codec files
corpus_clean = codecs.open('corpus_clean.txt', 'w', encoding = 'utf-8')
uni_fd = codecs.open('uni_fd.txt', 'w', encoding = 'utf-8')
bi = codecs.open('bi.txt', 'w', encoding = 'utf-8')
tri = codecs.open('tri.txt', 'w', encoding = 'utf-8')
bi_fd = codecs.open('bi_fd.txt', 'w', encoding = 'utf-8')
tri_fd = codecs.open('tri_fd.txt', 'w', encoding = 'utf-8')
uni = codecs.open('uni.txt', 'w', encoding = 'utf-8')

## import file
f = open('atype76.csv','r')

## import data using pandas package
# -names- is to label the columns
# -header- makes the first observation the header 
data = pd.read_csv(f, names = ['pid','text'], header = 0, encoding='iso-8859-1')
f.close()
text = data['text']

uni_fd = nltk.FreqDist()
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
    
    counter = tkns.count # minor speedup
    tkncnt = dict((w,counter(w)) for w in set(tkns))   
    bi_counter = bigrams.count # count bigrams
    bi_cnt = dict((w,bi_counter(w)) for w in set(bigrams))
    tri_counter = trigrams.count # minor speedup
    tri_cnt = dict((w,tri_counter(w)) for w in set(trigrams))
    pid = data['pid'][i]   

    for w in tkns:
       uni_fd.inc(w)
    for w in bigrams:
        bi_fd.inc(w)
    for w in trigrams:
        tri_fd.inc(w)
        
    for w in tkncnt:       
        uni.write(u'%-15s \t %-10s \t %-25s \t %10s\r\n' % (pid,i+1,w,tkncnt[w]))       
        corpus_clean.write(u"{0} ".format(w)) 
    for w in bi_cnt:       
        bi.write(u'%-15s \t %-10s \t %-25s \t %10s\r\n' % (pid,i+1,w,bi_cnt[w]))
    for w in tri_cnt:       
        tri.write(u'%-15s \t %-10s \t %-25s \t %10s\r\n' % (pid,i+1,w,tri_cnt[w]))       
		
    i += 1
    print i

# tokenize the corpus
for w in bi_fd:
    bi_fd.write(u'%-15s \t %4s\r\n' % (w, bi_fd[w]))
for w in tri_fd:
    tri_fd.write(u'%-15s \t %4s\r\n' % (w, tri_fd[w]))
for w in uni_fd:
    uni_fd.write(u'%-15s \t %4s\r\n' % (w,uni_fd[w]))
   
uni.close()
uni_fd.close()
corpus_clean.close()
bi_fd.close()  
tri_fd.close()  
tri.close()
bi.close()

    