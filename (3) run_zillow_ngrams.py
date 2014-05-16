#!/usr/bin/env python
# -*- coding: utf-8 -*-

## execute function zillow_ngrams() for particular zillow files
import os
from zillow_ngrams import ngrams # import ngrams() from module 'zillow_ngrams'

# take random samples of raw data set for testing
os.chdir("D:/Dan's Workspace/GitHub Repository/zillow_projects/data")
ngrams("D:/Dan's Workspace/Zillow/data/atype76.csv", 'zillow',1,20000)

# construct ngrams from green homes listings
ngrams("green_homes_list.csv",'green',0)

# construct ngrams from full set and save small sample sets as well
os.chdir("D:/Dan's Workspace/Zillow/data/") # change the directory for large files
ngrams("atype76.csv", 'zillow',0)
ngrams("D:/Dan's Workspace/Zillow/data/atype76.csv", 'zillow',1,20000)
ngrams("green_homes_list.csv",'green',0)


