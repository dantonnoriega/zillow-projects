#!/usr/bin/env python
# -*- coding: utf-8 -*-
## python map for word counts

# Import Modules
import sys
import re
import os
import time

os.chdir("D:/Dan's Workspace/Zillow/")

# all non alphanumeric
symbols = re.compile(r'(\W+)', re.U)
# pure numeric
numeric = re.compile(r'(?<=\s)(\d+|\w\d+|\d+\w)(?=\s)', re.I|re.U)
# stop words
swrd = re.compile(r'(?<=\s)(d|re|m|ve|s|n|to|a|the|an|and|or|in|at|with|for|are|is|the|if|of|at|but|and|or)(?=\s|\Z)', re.I|re.U)
# separators (any whitespace)
seps = re.compile(r'\s+')
# lone non digit numbers
lone = re.compile(r'(?<=\s)(\D)(?=\s)', re.I|re.U)

# cleaner (order matters)
def clean(text): 
    text = text.lower()
    text = symbols.sub(' ', text)
    text = numeric.sub(' ', text)
    text = swrd.sub(' ', text)
    text = seps.sub(' ', text)
    return text
    
wordlist = open("data/wordlist76.txt",'w') # output file where words are saved    
f = open("data/atype76.txt", 'r')
i = 0

for line in f:
    print 'RAW: ',line, '\n'
    i += 1
    txt = clean(line)
    print 'CLEANED: ',txt, '\n\n'
    
    tkns = [ w for w in txt.split() if len(w) > 2 ] # only > 2 letter words
    counter = tkns.count # minor speedup
    tkncnt = dict((w,counter(w)) for w in set(tkns))

    for w in tkncnt:
        try:
            wordlist.write(u"{0}\t{1}\t{2}\n".format(i,w,tkncnt[w]))
        except UnicodeEncodeError, e:
            print 'error in write'
            sys.stderr.write(str(e))
            pass
    

