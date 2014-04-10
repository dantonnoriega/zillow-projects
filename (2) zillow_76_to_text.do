* (2) zillow_76_to_text.do
* this code does a quick clean of atype 76
* 	(1) merge final list of properties. keep only atype 76. remove all non alpha-numeric characters. replaces with spaces.
*	(2) export text file

clear all
set more off

do "D:/Dan's Workspace/GitHub Repository/zillow_projects/removesym.ado"
global dir "D:/Dan's Workspace/Zillow/"
cd "$dir"

**** (1)
use "$dir/data/zillow_stacked_merged", clear
merge m:1 pid using "$dir/data/zillow_property_list_final"
keep if _merge == 3
keep if atype == 76
drop _merge
keep pid avalue
replace avalue = trim(avalue)
drop if missing(avalue)

* export the data, raw
export delimited pid avalue using "$dir/data/atype76_raw.csv", replace

* use stata to clean string var "avalue"
removesym avalue, ext
replace avalue = trim(avalue)
tempfile keep76
drop if missing(avalue)
save `keep76', replace

* save clean data set
save "$dir/data/atype76", replace

/*
* export houses with words "solar" and "effici"
use "$dir/data/atype76", clear
gen tag = regexm(avalue, "[ ](solar)[ ]")
replace tag = regexm(avalue, "(effici)")
keep if tag == 1
drop tag
export delimited pid avalue using "$dir/data/zillow_w_solar_tag.csv", replace
*/

* quit Stata
exit, STATA clear
