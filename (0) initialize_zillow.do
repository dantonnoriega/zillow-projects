* initialize zillow data
* Created by: Danton Noriega, Georgetown University (Feb 2013)

clear all
set more off

global dir "D:/Dan's Workspace/Zillow/"
cd "$dir"

!rmdir "data sets" /s /q
!mkdir "data sets" /s /q

/* take the zillow text files and import to stata */
foreach dataset in "data_descriptions" ///
"data_fields72_75" ///
"data_wo_descriptions" {
	disp "importing `dataset'"
	import delimited "D:/Work/Research/Zillow/raw_data/`dataset'.txt", clear
	save "data sets/`dataset'.txt", replace
}
