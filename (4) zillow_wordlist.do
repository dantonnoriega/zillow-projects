* zillow_wordlist_count.do
* in this program we:
*	(1) count and collapse over each unique word
*	(2) export list

set more off
pause on
global dir "D:/Dan's Workspace/Zillow/"
cd "$dir"

**** (1)
* toggle imports (imprt) and using sample of whole data set (smpl)
local imprt = 1
local smpl = 0

* import or load data
if (`imprt' == 1) {
	import delimited "$dir\data\wordlist76.txt", clear

	drop v1
	rename v2 word
	rename v3 count
	
	* save the wordlist in .dta
	save "$dir/data/wordlist76.dta", replace
	
	* create a 1% sample for coding efficiency
	sample 1
	save "$dir/data/wordlist_sample.dta", replace
}
else if (`smpl' == 1) use "$dir/data/wordlist_sample", clear
else use "$dir/data/wordlist76", clear

* find unique words
egen group = group(word), label // tag unique words
sort group word

collapse (sum) count, by(word)




**** (2)
clear programs
do "D:\Dan's Workspace\GitHub Repository\zillow_projects/removesym.ado"
drop if length(word) < 3 // drop words less than 2
removesym word, numbers

gsort -count -word

if (`smpl' == 1) save "$dir/data/wordlist_sample_collapsed", replace
else save "$dir/data/wordlist76_collapsed", replace

exit, STATA clear
