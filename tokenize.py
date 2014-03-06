#!/usr/bin/env python
## python map for word counts

# Import Modules
import sys
import re
import json
import codecs

cd "D:\Dan's Workspace\Zillow\"

# all non alphanumeric
symbols = re.compile(r'(\W+)', re.U)
# pure numeric
numeric = re.compile(r'(?<=\s)(\d+|\w\d+|\d+\w)(?=\s)', re.I|re.U)
# stop words
swrd = re.compile(r'(?<=\s)(d|re|m|ve|s|n|to|a|the|an|and|or|in|at|with|for|are|is|the|if|of|at|but|and|or)(?=\s)', re.I|re.U)
# suffix strip
# suffix = re.compile(r'(?<=\w)(s|ings*|ives*|ly|led*|i*ed|i*es|ers*)(?=\s)')
# separators (any whitespace)
seps = re.compile(r'\s+')

# cleaner (order matters)
def clean(text): 
    text = u' ' +  text.lower() + u' '
    text = symbols.sub(r' \1 ', text)
    text = numeric.sub(' ', text)
    text = swrd.sub(' ', text)
    #text = suffix.sub('', text)
    text = seps.sub(' ', text)
    return text
    
    
fin = codecs.open("data/atype76.txt", 'w', encoding='utf-8')
i = 0