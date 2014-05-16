clear all
set more off

import excel "/Users/dnoriega/Documents/Github/zillow_projects/data/zillow_outreg.xlsx", sheet("Sheet1")

gen word = regexs(2) if regexm(B,"(ngram==)(.*)")
gen sig = regexs(1) if regexm(C,"[.]*([\*]*)$")

drop if missing(sig)
drop A B C sig

drop if missing(word)

export delimited using "/Users/dnoriega/Documents/Github/zillow_projects/data/zillow_logit_wordlist.txt", delimiter(tab) replace
export excel using "/Users/dnoriega/Documents/Github/zillow_projects/data/zillow_logit_wordlist.xlsx", replace
