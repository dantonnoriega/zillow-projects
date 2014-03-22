* (3.2) zillow_lpm
*	- this program imports the python outputs (zillow and greenhomes list)
*	- makes a rough linear prob model to help find relationships between words
*		and green homes.

set matsize 11000, perm
clear all
set more off

global dir "D:\Dan's Workspace\GitHub Repository\zillow_projects\data"
cd "$dir"


* ----------------- *
* 	Zillow Data		*
* ----------------- *

**** IMPORT AND RENAME 
import delimited "zillow_tkns.txt", clear
local varnames = "pid i word count"

* rename variables
local j = 1
forval k = 1/4 {
	local q : word `k' of `varnames'
	disp "`k' `q'"
	rename v`k' `q'
}

* trim strings
replace word = trim(word)
format %25s word


**** TAG GREEN IN ZILLOW DATA
* tag houses that have "solar" or "effici" as a word
gen green = regexm(word, "[ ](solar)[ ]")
replace green = regexm(word, "(effici)")

* save the main data set, collapse, and tag "solar" households
tempfile zillow
save `zillow', replace

collapse (max) green, by(i)

tempfile tags
save `tags', replace

use `zillow', clear
drop green
merge m:1 i using `tags', nogen

gen zillow = 1 // dummy variable that distinguishes data 
save `zillow', replace // we append this data later



* ------------------------- *
* 	  Green Homes Data		*
* ------------------------- *
**** IMPORT AND RENAME 
import delimited "green_tkns.txt", clear
local varnames = "i word count green"

* rename variables
local j = 1
forval k = 1/4 {
	local q : word `k' of `varnames'
	disp "`k' `q'"
	rename v`k' `q'
}

* trim strings
replace word = trim(word)
format %25s word
gen zillow = 0 // distinguish the data



* ------------------------ *
* 	get and merge corpuses *
* ------------------------ *
append using `zillow'

* create new ids
egen id = group(i zillow)
drop i // no longer useful

tempfile temp
save `temp', replace
collapse (sum) count, by(word)
sum count, detail

* create trimming loop
while `r(p10)' - `r(p1)' < 5 {
	sum count, detail
	drop if count <= `r(p1)'
	}

drop if count >= `r(p99)' // drop very common words
drop count // keep just the words

tempfile trim
save `trim', replace

use `temp', clear
merge m:1 word using `trim'
keep if _merge == 3 // trim unwanted words
drop _merge

* generate word dummies
sort word
tab word, gen(_word)


* ---------------- *
* 	Run LPM		   *
* ---------------- *
local x = "_word2 - _word`r(r)'"
logit green `x', vce(robust)

outreg2 using "D:\Dan's Workspace\Zillow\spreadsheets\zillow_outreg.xlsx", wide 10pct excel replace











