* zillow_76_to_text.do
* this code does a quick clean of atype 76
* 	(1) keep only atype 76. remove all non alpha-numeric characters. replaces with spaces.
*	(2) export text file

clear all
set more off

do "D:\Dan's Workspace\GitHub Repository\zillow_projects\removesym.ado"
global dir "D:\Dan's Workspace\Zillow\"
cd "$dir"

**** (1)
use "$dir/data/zillow_stacked_merged", clear
keep if atype == 76

removesym avalue, sym(<br/>) sub(space) //remove html symbols
removesym avalue, allsym sub(space)
replace avalue = trim(avalue)
tempfile keep76
save `keep76', replace
drop if missing(avalue)

save "$dir/data/atype76", replace

outfile avalue using "$dir/data/atype76.txt", replace noquote wide
