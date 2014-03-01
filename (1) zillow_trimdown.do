* this code times down the zillow data to useable observations
* 	(1) merge data with analysis table. we then remove unneeded variables. 
*	(2) split data into numeric and string values
*	(3) take the numeric data set and use it to tag unlikely single-family homes

set more off
clear programs
do "D:/Dan's Workspace/GitHub Repository/zillow_projects/removesym.ado"
global dir "D:/Dan's Workspace/Zillow/"
cd "$dir"




**** (1)
import excel "$dir/spreadsheets/zillow variable analysis table.xlsx", clear sheet("Sheet1") firstrow case(lower)
drop remove
save "data sets/zillow_analysis_table", replace

use "data sets/zillow_stacked_merged", clear
merge m:1 atype using "data sets/zillow_analysis_table", nogen

* keep "crucial" variables
destring crucial, replace
keep if crucial == 1
drop crucial




**** (2) Now we:
*- remove missing pid
*- convert "" "na" "yes" then destring
*- split the data set into two: one we can destring and one we cannot

drop if missing(pid) 	// drop obs with no pid
replace avalue = "" if avalue == "na"
replace avalue = "1" if avalue == "yes"

tempfile hold
save `hold', replace 	// save master data set

drop if destring == 0	 // drop pure string variables
drop destring
destring avalue, replace // destring "avalue"

tempfile hold1
save `hold1', replace	 // save the destringed data set

* we tag pid with conflicting NUMERIC entries for atype and drop these conflicts. these are likely errors.
* they also make it impossible to reshape the data
duplicates tag pid atype, gen(tag)
keep if tag == 1
keep pid atype tag
collapse (max) tag, by(pid atype)
drop tag

* take the list of tagged houses, merge to the file, the drop
tempfile tagged
save `tagged', replace

use `hold1', clear
merge m:1 pid atype using `tagged'	 // merge the list of problematic pid's
drop if _merge == 3 					// drop them
drop _merge

save "data sets/zillow_numeric", replace

use `hold', clear
keep if destring == 0
duplicates drop

save "data sets/zillow_strings", replace




**** (3)
* see /spreadsheets/zillow variable analysis table.xlsx for info
use  "data sets/zillow_numeric", clear

gen tag = 0
replace tag = 1 if avalue <=0
replace tag = 1 if avalue > 12 & atype ==  2
replace tag = 1 if avalue > 7 & atype ==  3
replace tag = 1 if avalue > 20 & atype ==  4
replace tag = 1 if avalue > 5 & atype ==  7
replace tag = 1 if avalue < 1600 & atype ==  9
replace tag = 1 if avalue < 1600 & atype ==  10
replace tag = 1 if avalue > 10 & atype ==  32
replace tag = 1 if avalue > 9 & atype ==  36

tempfile hold2
save `hold2', replace

* find and make a list of unlikely single-family households
collapse (max) tag, by(pid) 
keep if tag == 1
drop tag

tempfile tagged1
save `tagged1', replace

use `hold2', clear
merge m:1 pid using `tagged1'
drop if _merge == 3 // purge the set of unlikelies
drop _merge tag

save  "data sets/zillow_numeric_trimmed", replace

* tabulate the data (less atype = 5 -- sq ft)
use "data sets/zillow_numeric_trimmed", clear
log using "D:\Dan's Workspace\Zillow\spreadsheets\tab_by_atype_trimmed", text replace
describe
egen tag = tag(pid)
count if tag == 1
scalar N = `r(N)'
disp _n(3) "There are " N " unique households that are potentially single family homes." _n(2)
drop tag
drop if atype == 5
bysort atype: tab avalue
log close

* remove "not constant" variables from data set
use "data sets/zillow_numeric_trimmed", clear
drop aname 	

* reshape data
reshape wide avalue, i(pid) j(atype)
save "data sets/zillow_numeric_wide", replace


