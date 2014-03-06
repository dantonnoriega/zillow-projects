* (1) zillow_trimdown.do
* this code times down the zillow data to useable observations
* 	(1) merge data with analysis table. we then remove unneeded variables. 
*	(2) split data into numeric and string values
*	(3) take the numeric data set and use it to tag unlikely single-family homes (SFH)

set more off
clear programs
do "D:/Dan's Workspace/GitHub Repository/zillow_projects/removesym.ado"
global dir "D:/Dan's Workspace/Zillow/"
cd "$dir"




**** (1)
import excel "$dir/spreadsheets/zillow variable analysis table.xlsx", clear sheet("Sheet1") firstrow case(lower)
drop remove
save "data/zillow_analysis_table", replace

use "data/zillow_stacked_merged", clear
merge m:1 atype using "data/zillow_analysis_table", nogen

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

save "data/zillow_numeric", replace

use `hold', clear
keep if destring == 0
duplicates drop

save "data/zillow_strings", replace




**** (3)
* see /spreadsheets/zillow variable analysis table.xlsx for info
use  "data/zillow_numeric", clear

gen tag = 0
replace tag = 1 if avalue <=0
replace tag = 1 if avalue > 12 & atype ==  2
replace tag = 1 if !inrange(avalue,.5,7) & atype ==  3
replace tag = 1 if avalue > 20 & atype ==  4
replace tag = 1 if avalue > 5 & atype ==  7
replace tag = 1 if !inrange(avalue,1600,2014) & atype ==  9
replace tag = 1 if !inrange(avalue,1600,2014) & atype ==  10
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

save  "data/zillow_numeric_trimmed", replace

* tabulate the data (less atype = 5 -- sq ft)
use "data/zillow_numeric_trimmed", clear
log using "D:\Dan's Workspace\Zillow\spreadsheets\tab_by_atype_trimmed", text replace
describe
egen tag = tag(pid)
count if tag == 1
scalar N = `r(N)'
disp _n(3) "There are " N " unique households that are potentially single family homes." _n(2)
drop tag
drop if atype == 5 | atype == 6
bysort atype: tab avalue
log close

* remove "not constant" variables from data set
use "data/zillow_numeric_trimmed", clear
drop aname 	

* reshape data
reshape wide avalue, i(pid) j(atype)


* drop household with variables that clearly indicate "NOT single family homes"
drop if avalue45 == 1 		// drop if "have doorman"
drop if avalue91 == 1		// drop if "over 55 living community"
drop if avalue92 == 1 		// drop if "assisted living"
drop if !missing(avalue32) 	// assumed that if you have multiple "units" then not SFH (probably some larger property)
drop if !missing(avalue36)	 // assumed that if you live on a "floor", then you are not in a SFH.
drop if unitprefix != "na"	 // drop if listed as a unit. likely that SFH are not considered "units"
drop if unitnumber != "na"	 // drop if listing a unit number. again, likely SFH don't have this.
drop if housenumber == "na" // drop if there is no housenumber. can't find.
drop if streetname == "list_only" // no way to identify where this property is
drop avalue45 avalue91 avalue92 avalue32 avalue36 unitprefix unitnumber // dropped now useless variables

* remove all "na" from string variables
foreach var of varlist _all {
	capture confirm numeric variable `var' // check to see if string type
	
	if (!_rc) disp "numeric"
	else {
		replace `var' = ""	if `var' == "na"
		if ("`var'" == "postalcode") replace `var' = "" if `var' == "0"
		if ("`var'" == "zipplusfour") replace `var' = "" if `var' == "0"
	}
}

* drop homes that would be impossible or difficult to locate
drop if missing(avalue9)
drop if missing(city)
drop if missing(streetname)
drop if missing(state)

order pid sell* house* street* city state postal* zip* avalue*
sort postalcode state city streetsuffix streetname housenumber
save "data/zillow_numeric_wide", replace


