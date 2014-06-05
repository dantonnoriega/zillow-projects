#!/usr/bin/env python
# -*- coding: utf-8 -*-

## execute function zillow_ngrams() for particular zillow files
import os
from zillow_ngrams import ngrams # import ngrams() from module 'zillow_ngrams'

# set the output directory
os.chdir("/Volumes/UNTITLED")

# take random samples of raw data set for testing
#ngrams("D:/Dan's Workspace/Zillow/data/atype76.csv", 'zillow',1,20000)

# construct ngrams from green homes listings
ngrams("/Users/dnoriega/Dropbox/SolarHedonic/text analysis/data/green_homes_list.csv",'green',0)

# construct ngrams from full set and save small sample sets as well
ngrams("/Users/dnoriega/Dropbox/SolarHedonic/text analysis/data/atype76_raw.csv", 'zillow',0)