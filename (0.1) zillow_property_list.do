* (0.1) zillow_property_list.do
* this program is used to make a unique property list
* this is done by doing the following...
*	(1) removing duplicate properties
* 	(2) removing any spaces and extra symbols in "housenumber" and "streetsuffix"
*	(3) isolating problematic properties. often there are non numbers in the numeric categories.
*	(4) broaden criterion and refine again

*clear all
set more off
pause off
use "D:\Dan's Workspace\Zillow\data\data_wo_descriptions.dta", clear



**** (1)	
clear programs
do "D:\Dan's Workspace\GitHub Repository\zillow_projects/removesym.ado"
keep propertyid sellingpricedollarcnt housenumber street* unit* ///
	city state postalcode zipplusfour
removesym postalcode unitnumber, blanks sym(. -)
removesym streetname streetdirectionsuffix streetdirectionprefix streetsuffix, allsym numbers
replace postalcode = "0" + postalcode if length(postalcode) == 4 //standardize 4 digit postalcodes (missing leading zero)
duplicates drop // drop any duplicates using ALL variables

tempfile hold
save `hold', replace // save unrefined set of data with most duplicates dropped (almost all unique)
pause 

* take the unrefined set and save the unproblematic households (duplicates less "zipplusfour")
duplicates tag propertyid housenumber streetname streetsuffix unitnumber city state postalcode, gen(tag)
drop if tag > 0
tempfile hold1
save `hold1', replace // save first set of unique properties
pause



**** (2)
* take the complement of the unrefined set `hold' and refine search
use `hold', clear // load unrefined set
duplicates tag propertyid housenumber streetname streetsuffix unitnumber city state postalcode, gen(tag)
drop if tag == 0
drop tag
pause



**** (3)
* now we get into the nitty gritty details
removesym housenumber postalcode zipplusfour, allsym let quotes
destring housenumber zipplusfour, replace // convert to numbers to remove leading zeros
* adjust a VERY small subsample of potential data entry mistakes
* 	we take those that are EXACTLY but missing zipplusfour
duplicates drop propertyid housenumber streetname streetsuffix unitnumber city state postalcode zipplusfour, force
duplicates tag propertyid housenumber streetname streetsuffix unitnumber city state postalcode, gen(tag)
pause
drop if tag > 0 & missing(zipplusfour)
pause 

tostring housenumber zipplusfour, replace // back to strings to stay consistent

tempfile hold2
save `hold2', replace // save small subset of houses
append using `hold1' // append the totally unique houses
drop tag

save "data/zillow_property_list", replace



**** (4)
/* the key to all these codes is that we NEVER drop an observation unless we
	can GUARANTEE that there is a DUPLICATE. thus, we don't lose the property ID. */
* keep totally unique ids
use "data/zillow_property_list", clear
duplicates tag propertyid, gen(tag)
drop if tag > 0
drop tag
tempfile unqids
save `unqids', replace // save unique ids 
pause

* narrow down to duplicate propertyid
use "data/zillow_property_list", clear
duplicates tag propertyid, gen(tag)
drop if tag == 0 // this leaves us with ONLY duplicates
drop tag
tempfile prblmid
save `prblmid', replace // save the problematic ids
pause

removesym postalcode zipplusfour housenumber, allsym let quotes // remove all non-numbers
destring housenumber zipplusfour, replace //move to numbers to remove leading zeros
replace zipplusfour = 0 if missing(zipplusfour) | zipplusfour == 0
replace housenumber = 0 if missing(housenumber)
pause

* drop certain duplicates. use all CRUCIAL information (exclude "streetsuffix")
duplicates drop propertyid housenumber streetname unitnumber city state postalcode zipplusfour, force
duplicates tag propertyid housenumber streetname unitnumber city state postalcode zipplusfour, gen(tag) // check drops
pause
drop tag

* drop "city" criterion (source of mismatch). tag possible input errors using "zipplusfour".
duplicates tag propertyid housenumber streetname unitnumber state postalcode zipplusfour, gen(inputerror)
replace inputerror = 1 if postalcode == "" | state == "" | city == "" // tag obvious input errors, like missing "state"

* now, bit by bit, we chip down the set to the likely correct properties
duplicates tag propertyid housenumber streetname unitnumber state postalcode, gen(tag) // remove "zipplusfour"
pause
drop if zipplusfour == 0 & tag & !inputerror // "inputerror" filters our those with matching -1 zipplusfour
drop tag

/* 
* more specific removals. risky
duplicates tag propertyid housenumber unitnumber state postalcode, gen(tag) // remove "streetname"
pause
drop if zipplusfour == 0 & tag & !inputerror
drop tag

duplicates tag propertyid unitnumber postalcode state, gen(tag) // remove "streetname" "housenumber"
pause
drop if zipplusfour == 0 & tag & !inputerror
drop tag
*/

* save the refined, but supicious, houses
tempfile prblmrfd
tostring housenumber zipplusfour, replace // make consistent
save `prblmrfd', replace
duplicates tag propertyid, gen(tag)
drop if tag > 0
drop tag inputerror
tempfile hold3
save `hold3', replace // save the refined, supicious, but perhaps useful ids


* NO WAY TO RESOLVE THIS SET. export the unresolved list then remove them from our property list.
use `prblmrfd', clear
duplicates tag propertyid, gen(tag)
drop if tag == 0
drop tag
replace inputerror = 1
label variable inputerror "= 1 if property is suspected of input error"
!rmdir "spreadsheets"
!mkdir "spreadsheets"
export excel using "spreadsheets/list of removed properties", firstrow(variables) replace //export problematic ids
keep propertyid inputerror
collapse (max) inputerror, by(propertyid)
save "data/list_of_removed_properties", replace


* now we stack the final, complete list.
use `hold3', clear
append using `unqids'

* final duplicates check
duplicates drop

* save
save "data/zillow_property_list", replace

