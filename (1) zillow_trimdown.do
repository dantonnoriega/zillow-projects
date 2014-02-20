* this code searches for any relevant terms in atype 76
* 	(1) keep only atype 76. remove all non alpha-numeric characters. replaces with spaces.
*	(2) search for the word "single".

set more off
clear programs
do "D:\Dan's Workspace\GitHub Repository\zillow_projects/removesym.ado"
global dir "D:/Dan's Workspace/Zillow/"
cd "$dir"

**** (1)
use "data sets/zillow_stacked_merged", clear
keep if atype == 76

* remove html symbols
removesym avalue, sym(<br/>) sub(space)
removesym avalue, allsym sub(space)
replace avalue = trim(avalue)
tempfile keep76
save `keep76', replace


**** (2)
use `keep76', clear

* tag if the word "single" is found.
* idea stolen from http://www.stata.com/statalist/archive/2012-03/msg00906.html
gen fam = 0
gen single = 0
gen single_fam = 0
gen single_fam2 = 0
replace fam = regexm(avalue, "family")
replace single = regexm(avalue, "single")
replace single_fam = regexm(avalue, "single[ ]*family")
replace single_fam2 = regexm(avalue, "(s.ngl.)[ ]*(f.m.l.)")
sort single_fam
save "data sets/zillow_single_fam", replace
