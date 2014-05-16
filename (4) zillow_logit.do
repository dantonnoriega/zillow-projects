* (4) zillow_lpm
*	- this program imports the python outputs (zillow and greenhomes list)
*	- makes a rough linear prob model to help find relationships between words
*		and green homes.

clear all
set matsize 11000, perm
set maxvar 32767, perm
set segmentsize 128m, perm
set max_memory ., perm
set more off

global dir "D:\Dan's Workspace\GitHub Repository\zillow_projects\data"
cd "$dir"
log using "log (4) zillow_logit.txt", replace

* ----------------- *
* 	Zillow Data		*
* ----------------- *

**** IMPORT AND RENAME 
import delimited "zillow_bi_sample.txt", clear
local varnames = "pid i ngram count lang"
local n : word count `varnames'

* rename variables
local j = 1
forval k = 1/`n' {
	local q : word `k' of `varnames'
	disp "`k' `q'"
	rename v`k' `q'
}

* trim strings
replace ngram = trim(ngram)
format %25s ngram
drop lang

/*
**** TAG GREEN IN ZILLOW DATA
* tag houses that have "solar" or "effici" as a ngram
gen green = regexm(ngram, "[ ](solar)[ ]")
replace green = regexm(ngram, "(effici)")

* save the main data set, collapse, and tag "solar" households
tempfile zillow
save `zillow', replace

collapse (max) green, by(i)

tempfile tags
save `tags', replace

use `zillow', clear
drop green
merge m:1 i using `tags', nogen
*/


gen green = 0
gen zillow = 1 // dummy variable that distinguishes data 
tempfile zillow
save `zillow', replace // we append this data later



* ------------------------- *
* 	  Green Homes Data		*
* ------------------------- *
**** IMPORT AND RENAME 
import delimited "green_bi_sample.txt", clear
local varnames = "pid i ngram count lang"
local n : word count `varnames'

* rename variables
local j = 1
forval k = 1/`n' {
	local q : word `k' of `varnames'
	disp "`k' `q'"
	rename v`k' `q'
}
* trim strings
replace ngram = trim(ngram)
format %25s ngram
gen zillow = 0 // distinguish the data
gen green = 1
drop lang



* ------------------------ *
* 	get and merge corpuses *
* ------------------------ *
append using `zillow'

* create new ids
egen id = group(i zillow)
drop i // no longer useful

tempfile temp
save `temp', replace
collapse (sum) count, by(ngram)
/*
* create trimming loop
while `r(p10)' - `r(p1)' < 5 {
	sum count, detail
	drop if count <= `r(p1)'
	}
*/

drop if count < 10
drop if count > 200 // drop very common words
drop count // keep just the words

tempfile trim
save `trim', replace

use `temp', clear
merge m:1 ngram using `trim'
keep if _merge == 3 // trim unwanted words
drop _merge

* generate ngram dummies
sort ngram
tab ngram, gen(_ngram)
disp "there are " `r(r)' " unique obs."

* ---------------- *
* 	Run Logit Test *
* ---------------- *
local x = "_ngram2 - _ngram`r(r)'"
logit green `x', vce(robust)
log close

outreg2 using "D:\Dan's Workspace\Zillow\spreadsheets\zillow_outreg.xlsx", wide 10pct excel label replace

exit, STATA clear







