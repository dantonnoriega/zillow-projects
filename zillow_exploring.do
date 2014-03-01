* exploring the data

*clear all
set more off

use "D:\Dan's Workspace\Zillow\data sets\zillow_stacked_merged.dta", clear
cd "D:\Dan's Workspace\Zillow\spreadsheets"

log using tab_by_atype, text replace

forval i = 1/99 {
	disp _n(4) "**** `i' ****" _n(4)
	if (inrange(`i',72,76) | `i' == 5 | `i' == 6 | `i' == 72) disp "SKIP: atype `i' has too many unique values"
	else tab avalue if atype == `i'
}

log close
