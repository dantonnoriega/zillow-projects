#!/usr/bin/env python
#coding:utf-8
# Author: Alejandro Nolla - z0mbiehunt3r
# Purpose: Example for detecting language using a stopwords based approach
# Created: 15/05/13
# Edited by Danton Noriega: 3/22/2014

try:
    from nltk import wordpunct_tokenize
    from nltk.corpus import stopwords
except ImportError:
    print '[!] You need to install nltk (http://nltk.org/index.html)'



#----------------------------------------------------------------------
def _calculate_languages_ratios(text):
    """
    Calculate probability of given text to be written in several languages and
    return a dictionary that looks like {'french': 2, 'spanish': 4, 'english': 0}
    
    @param text: Text whose language want to be detected
    @type text: str
    
    @return: Dictionary with languages and unique stopwords seen in analyzed text
    @rtype: dict
    """

    languages_ratios = {}

    '''
    nltk.wordpunct_tokenize() splits all punctuations into separate tokens
    
    >>> wordpunct_tokenize("That's thirty minutes away. I'll be there in ten.")
    ['That', "'", 's', 'thirty', 'minutes', 'away', '.', 'I', "'", 'll', 'be', 'there', 'in', 'ten', '.']
    '''

    tokens = wordpunct_tokenize(text)
    words = [word.lower() for word in tokens]
    NLTKlanguages=['spanish','english']
    # Compute per language included in nltk number of unique stopwords appearing in analyzed text
    for language in NLTKlanguages:
        stopwords_set = set(stopwords.words(language))
        words_set = set(words)
        common_elements = words_set.intersection(stopwords_set)

        languages_ratios[language] = len(common_elements) # language "score"

    return languages_ratios


#----------------------------------------------------------------------
def detect_language(text):
    """
    Calculate probability of given text to be written in several languages and
    return the highest scored.
    
    It uses a stopwords based approach, counting how many unique stopwords
    are seen in analyzed text.
    
    @param text: Text whose language want to be detected
    @type text: str
    
    @return: Most scored language guessed
    @rtype: str
    """

    ratios = _calculate_languages_ratios(text)
    """
    @max(a, key = a.get) will return the max integer value of dict a
    e.g.
        a = {'a':3, 'b':4}
        x = max(a, key=a.get)
        print x
        >>> b
    """
    # most_rated_language = max(ratios, key=ratios.get) # unused: not enough text
    ## EDIT by Danton
    # this compares english to spanish counts
    
    count = ratios['english'] + ratios['spanish']
    
    if ratios['english'] > 0 and ratios['spanish'] > 0 and count > 10: 
        if ratios['english']/ratios['spanish'] >= 2:
            return 'english'
        if ratios['spanish']/ratios['english'] >= 2:
            for k,v in ratios.iteritems():
                print k,v
            return 'spanish'
        else:
            for k,v in ratios.iteritems():
                print k,v
            return 'bilingual' 
                   
    elif count < 11:
        return 'english' ## defaul to english
    else:
        if ratios['spanish'] == 0:
            return 'english'
        if ratios['english'] == 0:
            return 'spanish'
        
    



if __name__=='__main__':

    text = '''
    There's a passage I got memorized. Ezekiel 25:17. "The path of the righteous man is beset on all sides\
    by the inequities of the selfish and the tyranny of evil men. Blessed is he who, in the name of charity\
    and good will, shepherds the weak through the valley of the darkness, for he is truly his brother's keeper\
    and the finder of lost children. And I will strike down upon thee with great vengeance and furious anger\
    those who attempt to poison and destroy My brothers. And you will know I am the Lord when I lay My vengeance\
    upon you." Now... I been sayin' that shit for years. And if you ever heard it, that meant your ass. You'd\
    be dead right now. I never gave much thought to what it meant. I just thought it was a cold-blooded thing\
    to say to a motherfucker before I popped a cap in his ass. But I saw some shit this mornin' made me think\
    twice. See, now I'm thinking: maybe it means you're the evil man. And I'm the righteous man. And Mr.\
    9mm here... he's the shepherd protecting my righteous ass in the valley of darkness. Or it could mean\
    you're the righteous man and I'm the shepherd and it's the world that's evil and selfish. And I'd like\
    that. But that shit ain't the truth. The truth is you're the weak. And I'm the tyranny of evil men.\
    But I'm tryin', Ringo. I'm tryin' real hard to be the shepherd.
    '''

    language = detect_language(text)

    print language