* dict_wordlist_merge.do
* in this program we:
*	(1) import the yawl and WinEdt Spanish wordlist (http://www.cs.duke.edu/csed/data/yawl-0.3.2/)
*	(2) merge it to the zillow wordlist

set more off
pause on
global dir "D:/Dan's Workspace/Zillow/"
cd "$dir"


**** (1)
import delimited "D:\Dan's Workspace\GitHub Repository\zillow_projects\Wordlists\yawl.txt", clear
rename v1 word
save "$dir/data/yawl_wordlist", replace

import delimited "D:\Dan's Workspace\GitHub Repository\zillow_projects\Wordlists\lemario-general-del-espanol.txt", clear 
rename v1 word
save "$dir/data/olea_lemario", replace

use "$dir/data/wordlist76_collapsed", clear
merge 1:1 word using "$dir/data/yawl_wordlist"
sort _merge
drop if _merge == 2
rename _merge _merge1

merge 1:1 word using "$dir/data/olea_lemario"
sort _merge
drop if _merge == 2
gsort -_merge -count -word

drop if _merge == 1 & _merge1 == 1
drop if count < 3 // drop if low counts
