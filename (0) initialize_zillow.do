* initialize zillow data
* Created by: Danton Noriega, Georgetown University (Feb 2013)
* This .do file does the following:
*	- makes a master list of property IDs with addresses etc
* 	- stacks all the property attibute data and then merges the master property list

*clear all
set more off
pause off

global dir "D:/Dan's Workspace/Zillow/"
cd "$dir"

local import_yn = 1 // toggle importing of data

/* clear data sets and import */
if (`import_yn' == 1) {
	!rmdir "data" /s /q
	!mkdir "data"
	
	foreach dataset in "data_wo_descriptions" ///
	"data_fields72_75" ///
	"data_descriptions" {
	
		disp "importing `dataset'"
		import delimited "D:/Work/Research/Zillow/raw_data/`dataset'.txt", clear
		
		* make all string lowercase and trim leading blanks
		foreach var of varlist _all {
			capture confirm numeric variable `var' // check to see if string type
			if (!_rc) disp "numeric"
			else {
				replace `var' = lower(`var')	// if no error return (i.e. string), then replace with lower
				replace `var' = trim(`var')
			}
		
		save "data/`dataset'", replace
		}
	}
}

/* take the zillow text files and import (if toggled) to stata then append (stack) */
local k = 1
	
/* save one dataset of just property IDs and addresses etc */
foreach dataset in "data_wo_descriptions" ///
"data_fields72_75" ///
"data_descriptions" {
	
	if ("`dataset'" == "data_wo_descriptions") {
		do "$github\(0.1) zillow_property_list.do"
	}
	
	if (`k' == 1) {
		use "data/`dataset'", clear
		keep propertyid attributevalue propertyattributetypedisplayname propertyattributetypeid
		save "data/zillow_stacked", replace
	}
	else {	
		use "data/`dataset'", clear
		keep propertyid attributevalue propertyattributetypedisplayname propertyattributetypeid
		append using "data/zillow_stacked"
		save "data/zillow_stacked", replace
	}
	
	local k = `k' + 1
	
}

* sort data and check for obvious duplicates
sort propertyattributetypeid propertyattributetypedisplayname attributevalue propertyid	
duplicates drop // drop any duplicate obs
tempfile hold
save `hold', replace


* merge data, drop problem ids, then reshape
use `hold', clear
merge m:1 propertyid using "data/list_of_removed_properties", nogen // tag the problem ids
drop if inputerror == 1 // drop the nonunique/input error properties
drop inputerror // drop the input error variable

merge m:1 propertyid using "data/zillow_property_list" // merge property addresses
drop if _merge == 1 // drop properties that have no known address (there are useless)
drop _merge

sort propertyattributetypeid propertyattributetypedisplayname attributevalue propertyid


* rename variables
rename propertyid pid
rename propertyattributetypeid atype
rename propertyattributetypedisplayname aname
rename attributevalue avalue
rename sellingpricedollarcnt sellprice

label variable pid "Property ID"
label variable atype "property Attribute TYPE id"
label variable aname "property Attribute type display NAME"
label variable avalue "Attribute VALUE"


* final duplicates check
duplicates drop

save "data/zillow_stacked_merged", replace




