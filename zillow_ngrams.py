#!/usr/bin/env python
# -*- coding: utf-8 -*-
# module: zillow_ngrams.py
# this function create ngrams of words for sample of zillow homes for modeling

import nltk
import re
import pandas as pd
import codecs
import random
from nolla_lang_detect import detect_language
from replace_spanish import replace_spanish
from remove_html import strip_tags



# define
def ngrams(infile, outprefix, sample=0, n=20000):

    # periods (to save abbrevs)
    period = re.compile(r'(\s)+(\w\.)+')
    # all non alphanumeric
    symbols = re.compile(r'(\W+)', re.U)
    # pure numeric and numeric/alpha combos
    numeric = re.compile(r'(\d+|\w+\d+|\d+\w+|\d+\w+\d+|\w+\d+\w+)(\s)', re.I|re.U)
    # separators (any whitespace)
    seps = re.compile(r'\s+')
    # lone non digit numbers in mid line
    lone = re.compile(r'(?<=\s)(\D)(?=\s)', re.I|re.U)
    # get stopwords
    stops = set(nltk.corpus.stopwords.words("english"))
    spanish_stops = set(nltk.corpus.stopwords.words("spanish"))
    # get stemmers
    stemmer = nltk.stem.porter.PorterStemmer()
        
    ## cleaner (order matters)
    # edited code original from:
    # https://github.com/TaddyLab/yelp/blob/master/code/tokenize.py
    def clean(text): 
        text = text.lower()
        text = strip_tags(text)
        h = period.match(text) # find any abbreviations (like p.v.c.)
        if h:
            text = text.replace('.','') # remove periods if found
        text = symbols.sub(' ', text)
        text = numeric.sub(' ', text)
        text = lone.sub(' ', text)
        text = seps.sub(' ', text)
    
        return text
    
    
    ## set seed
    random.seed(1789)

    ## create a tag for samples
    if sample == 1:
        samp_tag = "_sample"
    else:
        samp_tag = ''
        
    ## create utf-8 compatible codec files
    corpus_clean = codecs.open('%s_corpus_clean%s.txt' % (outprefix, samp_tag), 'w', encoding = 'utf-8')
    uni_out = codecs.open('%s_uni%s.txt' % (outprefix, samp_tag), 'w', encoding = 'utf-8')
    bi_out = codecs.open('%s_bi%s.txt' % (outprefix, samp_tag), 'w', encoding = 'utf-8')
    tri_out = codecs.open('%s_tri%s.txt' % (outprefix, samp_tag), 'w', encoding = 'utf-8')
    uni_fd_out = codecs.open('%s_uni_fd%s.txt' % (outprefix, samp_tag), 'w', encoding = 'utf-8')
    bi_fd_out = codecs.open('%s_bi_fd%s.txt' % (outprefix, samp_tag), 'w', encoding = 'utf-8')
    tri_fd_out = codecs.open('%s_tri_fd%s.txt' % (outprefix, samp_tag), 'w', encoding = 'utf-8')

    ## import file
    f = codecs.open('%s' % infile)
    
    ## import data using pandas package
    # -names- is to label the columns
    # -header- makes the first observation the header 
    data = pd.read_csv(f, names = ['pid','text'], header = 0, encoding = 'ISO-8859-1') # utf-8 encoding can't read spanish characters
    f.close()
    
    ## save text data
    # sample data, if enabled
    if sample == 1 and len(data) > n: # must have more data than the sample draw, @n
        draw = random.sample(data.index, n) # random sample using dataframe indeces, save to @draw
        data = data.ix[draw].reset_index() # .ix selects from list of indeces in @draw, reset_index() resets the index back to 0,1,2...
    # store text
    text = data['text']
    
    uni_fd = nltk.FreqDist()
    bi_fd = nltk.FreqDist()
    tri_fd = nltk.FreqDist() 
    
    
    # create output file of tokens by household (aka by row/obs) and make corpus
    # CRUCIAL LINE: .encode('ascii', 'ignore') makes python IGNORE any ascii errors for printing
    i = 0 # initialize i
    for line in text:
        txt = clean(line)
        txt = txt.encode('ascii','ignore') 
        language = detect_language(txt)
        
        # ORDER MATTERS
        if language != 'english':
            print i, language
        if language == 'english':
            tkns = [w for w in txt.split() if len(w) > 2 ] # only > 2 letter words 
            tkns = [w for w in tkns if not w in stops]
            tkns = [replace_spanish(w) for w in tkns]
            tkns = [stemmer.stem(w) for w in tkns]
        if language == 'spanish':
            tkns = [w for w in txt.split() if len(w) > 2 ] # only > 2 letter words
            tkns = [w for w in tkns if not w in spanish_stops]
            tkns = [replace_spanish(w) for w in tkns]
            tkns = [stemmer.stem(w) for w in tkns]
        if language == 'bilingual':
            tkns = [w for w in txt.split() if len(w) > 2 ] # only > 2 letter words
            tkns = [w for w in tkns if not w in spanish_stops]
            tkns = [w for w in tkns if not w in stops]
            tkns = [replace_spanish(w) for w in tkns]
            tkns = [stemmer.stem(w) for w in tkns]
              
        doc = nltk.Text(tkns) # construct the whole doc
        bigrams = nltk.bigrams(doc) # find bigrams
        trigrams = nltk.trigrams(doc)	# find trigrams
        
        counter = tkns.count # minor speedup
        tkncnt = dict((w,counter(w)) for w in set(tkns))   
        bi_counter = bigrams.count # count bigrams
        bi_cnt = dict((w,bi_counter(w)) for w in set(bigrams))
        tri_counter = trigrams.count # minor speedup
        tri_cnt = dict((w,tri_counter(w)) for w in set(trigrams))
        
        # get pid
        pid = data['pid'][i]   
    
        for g in tkns:
            uni_fd.inc(g)
        for g in bigrams:
            bi_fd.inc(g)
        for g in trigrams:
            tri_fd.inc(g)
        
        """
        The code:
            
            w = ''
            for n in g:
                w += n + ' '
            w = w.strip()
            
        is used to make the ngrams > 1 output nicer. we get...
            'robust and'
        instead of...
            (u'robust', u'and')
        """
        
        for w in tkncnt:
            corpus_clean.write(u"{0} ".format(w)) 
            uni_out.write(u"%-15s \t %-10s \t %-15s \t %10s \t %8s\r\n" % (pid,i+1,w,tkncnt[w],language)) 
        for g in bi_cnt:
            w = ''
            for n in g:
                w += n + ' '
            w = w.strip()
            bi_out.write(u"%-15s \t %-10s \t %-25s \t %10s \t %8s\r\n" % (pid,i+1,w,bi_cnt[g],language))
        for g in tri_cnt:
            w = ''
            for n in g:
                w += n + ' '
            w = w.strip()
            tri_out.write(u"%-15s \t %-10s \t %-35s \t %10s \t %8s\r\n" % (pid,i+1,w,tri_cnt[g],language))    
             		
        i += 1 
        if i % 1000 == 0:
            print '*** iter %d ***' % i
                     
    ## tokenize the corpus
    for w in uni_fd:
        uni_fd_out.write(u"%-35s \t %4s\r\n" % (w,uni_fd[w]))
    for g in bi_fd:
        w = ''
        for n in g:
            w += n + ' '
        w = w.strip()
        bi_fd_out.write(u"%-35s \t %4s\r\n" % (w,bi_fd[g]))
    for g in tri_fd:
        w = ''
        for n in g:
            w += n + ' '
        w = w.strip()
        tri_fd_out.write(u"%-35s \t %4s\r\n" % (w,tri_fd[g]))

    print "\n\n **** ngrams completed for '%s' with prefix '%s%s' ****" % (infile, outprefix, samp_tag) 
 

    
    corpus_clean.close()
    uni_out.close()    
    bi_out.close()
    tri_out.close()
    uni_fd_out.close()
    bi_fd_out.close()  
    tri_fd_out.close() 
    
