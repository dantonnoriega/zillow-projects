## replace spanish characters
# Code from:
# https://mail.python.org/pipermail/python-es/2011-February/029462.html
# EDITED BY: Danton Noriega, March 2014
def replace_spanish(string):

    d = {    
    u'\xc1':u'A',
    u'\xc9':u'E',
    u'\xcd':u'I',
    u'\xd3':u'O',
    u'\xda':u'U',
    u'\xdc':u'U',
    u'\xd1':u'N',
    u'\xc7':u'C',
    u'\xed':u'i',
    u'\xf3':u'o',
    u'\xf1':u'n',
    u'\xe7':u'c',
    u'\xba':u'',
    u'\xb0':u'',
    u'\x3a':u'',
    u'\xe1':u'a',
    u'\xe2':u'a',
    u'\xe3':u'a',
    u'\xe4':u'a',
    u'\xe5':u'a',
    u'\xe8':u'e',
    u'\xe9':u'e',
    u'\xea':u'e',
    u'\xeb':u'e',
    u'\xec':u'i',
    u'\xed':u'i',
    u'\xee':u'i',
    u'\xef':u'i',
    u'\xf2':u'o',
    u'\xf3':u'o',
    u'\xf4':u'o',
    u'\xf5':u'o',
    u'\xf0':u'o',
    u'\xf9':u'u',
    u'\xfa':u'u',
    u'\xfb':u'u',
    u'\xfc':u'u',
    u'\xe5':u'a'
    }
    new_string = string
    for c in d.keys():
        new_string = new_string.replace(c,d[c])   
    return new_string