#!/usr/bin/env python
# -*- coding: utf-8 -*-

## zillow_ngrams
## this function tokenizes words for sample of zillow homes for modeling

def ngrams(infile, outprefix):
    import sys
    import nltk
    import re
    import pandas as pd
    import codecs
       
    # periods (to save abbrevs)
    period = re.compile(r'(?<=\s)(\w\.)+')
    # all non alphanumeric
    symbols = re.compile(r'(\W+)', re.U)
    # pure numeric and numeric/alpha combos
    numeric = re.compile(r'(\d+|\w+\d+|\d+\w+|\d+\w+\d+|\w+\d+\w+)(\s)', re.I|re.U)
    # separators (any whitespace)
    seps = re.compile(r'\s+')
    # lone non digit numbers
    lone = re.compile(r'(?<=\s)(\D)(?=\s)', re.I|re.U)
    # get stopwords
    stops = set(nltk.corpus.stopwords.words("english"))
    # get stemmers
    stemmer = nltk.stem.porter.PorterStemmer()
    
    ## eliminate accents
    def del_accents(line):

        d = {    
        '\xc1':'A',
        '\xc9':'E',
        '\xcd':'I',
        '\xd3':'O',
        '\xda':'U',
        '\xdc':'U',
        '\xd1':'N',
        '\xc7':'C',
        '\xed':'i',
        '\xf3':'o',
        '\xf1':'n',
        '\xe7':'c',
        '\xba':'',
        '\xb0':'',
        '\x3a':'',
        '\xe1':'a',
        '\xe2':'a',
        '\xe3':'a',
        '\xe4':'a',
        '\xe5':'a',
        '\xe8':'e',
        '\xe9':'e',
        '\xea':'e',
        '\xeb':'e',
        '\xec':'i',
        '\xed':'i',
        '\xee':'i',
        '\xef':'i',
        '\xf2':'o',
        '\xf3':'o',
        '\xf4':'o',
        '\xf5':'o',
        '\xf0':'o',
        '\xf9':'u',
        '\xfa':'u',
        '\xfb':'u',
        '\xfc':'u',
        '\xe5':'a'
        }

        new_line = line
        for c in d.keys():
            new_line = new_line.replace(c,d[c])
    
        return new_line
        
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
    
    ## create ISO-8859-1 compatible codec files
    corpus_clean = codecs.open('%s_corpus_clean.txt' % outprefix, 'w', encoding = 'utf-8')
    uni = codecs.open('%s_uni.txt' % outprefix, 'w', encoding = 'utf-8')
    bi = codecs.open('%s_bi.txt' % outprefix, 'w', encoding = 'utf-8')
    tri = codecs.open('%s_tri.txt' % outprefix, 'w', encoding = 'utf-8')
    uni_fd_out = codecs.open('%s_uni_fd.txt' % outprefix, 'w', encoding = 'utf-8')
    bi_fd_out = codecs.open('%s_bi_fd.txt' % outprefix, 'w', encoding = 'utf-8')
    tri_fd_out = codecs.open('%s_tri_fd.txt' % outprefix, 'w', encoding = 'utf-8')
    
    ## import file
    f = codecs.open('%s' % infile)
    
    ## import data using pandas package
    # -names- is to label the columns
    # -header- makes the first observation the header 
    data = pd.read_csv(f, names = ['pid','text'], header = 0, encoding = 'ISO-8859-1')
    f.close()
    text = data['text']
    
    uni_fd = nltk.FreqDist()
    bi_fd = nltk.FreqDist()
    tri_fd = nltk.FreqDist() 
    
    
    # create output file of tokens by household (aka by row/obs) and make corpus
    i = 0 # initialize i
    for line in text:
        try:
            txt = clean(line) 
            # here, we delete accents (del_accent) but must encode to utf-8 before doing so (w.encode('utf-8')
            tkns = [del_accents(w.encode('utf-8')) for w in txt.split() if len(w) > 2 ] # only > 2 letter words 
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
                try:       
                    uni.write(u"%-15s \t %-10s \t %-25s \t %10s\r\n" % (pid,i+1,w,tkncnt[w]))
                    corpus_clean.write(u"{0} ".format(w))        
                except UnicodeEncodeError, e: ## this is to deal with encoding errors
                    print e
                    print 'error in write'
                    sys.stderr.write(str(e))
                    pass
            for w in bi_cnt:
                try:       
                    bi.write(u"%-15s \t %-10s \t %-25s \t %10s\r\n" % (pid,i+1,w,bi_cnt[w]))
                except UnicodeEncodeError, e:
                    print 'error in write'
                    sys.stderr.write(str(e))
                    pass
            for w in tri_cnt:       
                try:
                    tri.write(u"%-15s \t %-10s \t %-25s \t %10s\r\n" % (pid,i+1,w,tri_cnt[w]))    
                except UnicodeEncodeError, e:
                    print 'error in write'
                    sys.stderr.write(str(e))
                    pass   
      		
            i += 1
            print i
            
        except:
            e = sys.exc_info()[0]
            sys.stderr.write("\nreview reader error: %s\n"%str(e))
            
    ## tokenize the corpus
    for w in bi_fd:
        try:
            bi_fd_out.write(u"%-15s \t %4s\r\n" % (w, bi_fd[w]))
        except UnicodeEncodeError, e:
            print 'error in write'
            sys.stderr.write(str(e))
            pass
    for w in tri_fd:
        try:
            tri_fd_out.write(u"%-15s \t %4s\r\n" % (w, tri_fd[w]))
        except UnicodeEncodeError, e:
            print 'error in write'
            sys.stderr.write(str(e))
            pass
    for w in uni_fd:
        try:
            uni_fd_out.write(u"%-15s \t %4s\r\n" % (w,uni_fd[w]))
        except UnicodeEncodeError, e:
            print 'error in write'
            sys.stderr.write(str(e))
            pass
    
    corpus_clean.close()
    uni.close()    
    bi.close()
    tri.close()
    uni_fd_out.close()
    bi_fd_out.close()  
    tri_fd_out.close()
    print "ngrams completed for %s with prefix %s" % (infile, outprefix) 

    
import os
os.chdir("D:\Dan's Workspace\GitHub Repository\zillow_projects\data")    
ngrams('atype76_sample.csv', 'zillow')