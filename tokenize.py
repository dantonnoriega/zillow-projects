#!/usr/bin/env python
# -*- coding: utf-8 -*-
## python map for word counts

# Import Modules
import re
import os

os.chdir("D:/Dan's Workspace/Zillow/")

# all non alphanumeric
symbols = re.compile(r'(\W+)', re.U)
# pure numeric and numeric/alpha combos
numeric = re.compile(r'(\d+|\w+\d+|\d+\w+|\d+\w+\d+|\w+\d+\w+)(\s|\Z)', re.I|re.U)
# stop words
swrd = re.compile(r'(?<=\s)(to|a|the|an|in|at|with|for|are|is|if|of|at|but|and|or)(?=\s)', re.I|re.U)
# separators (any whitespace)
seps = re.compile(r'\s+')
# lone non digit numbers
lone = re.compile(r'(?<=\s)(\D)(?=\s|\Z)', re.I|re.U)

# cleaner (order matters)
def clean(text): 
    text = text.lower()
    text = symbols.sub(' ', text)
    text = swrd.sub(' ', text)
    text = lone.sub(' ', text)
    text = numeric.sub(' ', text)
    text = seps.sub(' ', text)
    return text
    
wordlist76 = open("data/wordlist76.txt",'w') # output file where words are saved        
f = open("data/atype76.txt", 'r')
i = 0

for line in f:
    #print 'RAW: ',line, '\n'
    i += 1
    txt = clean(line)            
    tkns = [w for w in txt.split() if len(w) > 2 ] # only > 2 letter words
    counter = tkns.count # minor speedup
    tkncnt = dict((w,counter(w)) for w in set(tkns))
     

    for w in tkncnt:       
        wordlist76.write(u"{0}\t{1}\t{2}\n".format(i,w,tkncnt[w]))       
    print i
    
