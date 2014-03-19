program define removesym
        version 12.1

        syntax varlist [in] [, blanks SYMbol(string) SUBstitute(string) BASICsym EXTendedsym ALLsym NUMbers LETters QUOTes SPAnish MAC]
		
        di "variable list: `varlist'"
        
        * check if an option has been selected
        if ("`blanks'" == "" && "`symbol'" == "" && "`basicsym'" == "" && "`extendedsym'" == "" && "`allsym'" == "" && "`numbers'" == "" && "`letters'" == "" && "`quotes'" == "" && "`spanish'" == "") local nopts = 1
		else local nopts = 0
		
		* check if something is being substituted
		if (missing("`substitute'")) disp "substitute option disabled"	
		else if ("`substitute'" == "space") {
			disp "substitute option enabled. subbing in blank space."
			local substitute " "
		}
		else disp "substitute option enabled. subbing: `substitute'"
		
		* check if "mac" option is enable. this alters the spanish, extendedsym, and allsym ascii codes
		if ("`mac'" == "mac") local pc = 0
		else local pc = 1
		
		if (`nopts' != 1) {
			
			* remove blanks
			if ("`blanks'" == "blanks") {
				di "entered `blanks'"  		
				di "removed: blanks"
				
				foreach v of varlist `varlist' {
					quietly replace `v' = subinstr(`v'," ","`substitute'",.) `in'		        
				}
			}
			
			* remove specific symbols
			if ("`symbol'" != "") {
				di "entered symbol"        
				
				foreach q of local symbol {
					di "removed: `q'"
					
					foreach v of varlist `varlist' {						
						quietly replace `v' = subinstr(`v',"`q'","`substitute'",.) `in'		        
					}
				}
			}
			
			
			* remove numbers
			if ("`numbers'" == "numbers") {
				di "entered numbers"
				local numbers = "0 1 2 3 4 5 6 7 8 9"
				foreach q of local numbers {
					di "removed: `q'"
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',"`q'","`substitute'",.) `in'		        
					}
				}

			}
			
			* remove letters
			if ("`letters'" == "letters") {
				di "entered letters"
				local letters = "a b c d e f g h i j k l m n o p q r s t u v w x y z"
				foreach q of local letters {
					di "removed: `q'"
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',"`q'","`substitute'",.) `in'		        
					}
				}
			}
			
			
			* (pc version) remove spanish characters, replace with english
			if ("`spanish'" == "spanish" & `pc' == 1) {
				di "entered spanish"
				local letters = "char(225) char(233) char(237) char(241) char(243) char(250) char(252)"
				local sletters = "char(191) char(161)"
				local switch = "a e i n o u u"
				local i = 0
				foreach q of local letters {
					local i = `i' + 1
					local p : word `i' of `switch'
					di "replaced " `q' " with `p'"
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',`q',"`p'",.) `in'       
					}
				}
				
				foreach q of local sletters {
					di "removed: " `q'
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',`q',"",.) `in'       
					}
				}
			}
			
			
<<<<<<< HEAD
			* (pc version) remove any quotation marks
			if("`quotes'" == "quotes" & `pc' == 1) {
=======
			if ("`basicsym'" == "basicsym") {
				di "entered basicsym"
>>>>>>> FETCH_HEAD
				
				di "entered quotes"
				
				local quotes = "char(34) char(39) char(96) char(145) char(146) char(147) char(148)"
				foreach q of local quotes {
					di "removed: " `q'
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',`q',"`substitute'",.) `in'		        
					}
				}					
			}
			
			* (mac version) remove spanish characters, replace with english
			if ("`spanish'" == "spanish" & `pc' == 0) {
				di "entered spanish"
				local letters = "char(135) char(142) char(146) char(150) char(151) char(156) char(159)"
				local sletters = "char(192) char(193)"
				local switch = "a e i n o u u"
				local i = 0
				foreach q of local letters {
					local i = `i' + 1
					local p : word `i' of `switch'
					di "replaced " `q' " with `p'"
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',`q',"`p'",.) `in'       
					}
				}
				
				foreach q of local sletters {
					di "removed: " `q'
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',`q',"",.) `in'       
					}
				}
			}
			
			
			* (mac version) remove any quotation marks
			if("`quotes'" == "quotes" & `pc' == 0) {
				
				di "entered quotes"
				
				local quotes = "char(34) char(39) char(96) char(171) char(247) char(253)"
				foreach q of local quotes {
					di "removed: " `q'
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',`q',"`substitute'",.) `in'		        
					}
				}
				
				forval q = 210/213 {
					di "removed: " char(`q')
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',char(`q'),"`substitute'",.) `in'		        
					}
				}					
			}
			
			* remove printable ascii (basicsym)
			if ("`basicsym'" == "basicsym") {
				di "entered basicsym (printable ascii)"
				
				forval q = 33/47 {
					di "removed: " char(`q')
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',char(`q'),"`substitute'",.) `in'		        
					}
				}
				
				forval q = 58/64 {
					di "removed: " char(`q')
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',char(`q'),"`substitute'",.) `in'		        
					}
				}
				
				forval q = 91/96 {
					di "removed: " char(`q')
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',char(`q'),"`substitute'",.) `in'		        
					}
				}
				
				forval q = 123/127 {
					di "removed: " char(`q')
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',char(`q'),"`substitute'",.) `in'		        
					}
				}	
				
			}
				
				
			* remove extended symbols
			if ("`extendedsym'" == "extendedsym") {
				di "entered extendedsym"	        				
				
				forval q = 128/255 {
					di "removed: " char(`q')
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',char(`q'),"`substitute'",.) `in'		        
					}
				}
			}
			
			
			* remove all sym
			if ("`allsym'" == "allsym") {
				di "entered allsym"	        				
				
				forval q = 33/47 {
					disp "`q'"
					di "removed: " char(`q')
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',char(`q'),"`substitute'",.) `in'		        
					}
				}
				
				forval q = 58/64 {
					disp "`q'"
					di "removed: " char(`q')
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',char(`q'),"`substitute'",.) `in'		        
					}
				}
				
				forval q = 91/96 {
					disp "`q'"
					di "removed: " char(`q')
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',char(`q'),"`substitute'",.) `in'		        
					}
				}
				
				forval q = 123/255 {
					disp "`q'"
					di "removed: " char(`q')
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',char(`q'),"`substitute'",.) `in'		        
					}
				}
			}
		}
		
		
		
		* remove printable ascii
		if (`nopts' == 1) {
			di "entered nopts. removing printable ascii symbols, including spaces."	        				
				
			forval q = 32/47 {
				di "removed: " char(`q')
				foreach v of varlist `varlist' {
					quietly replace `v' = subinstr(`v',char(`q'),"`substitute'",.) `in'		        
				}
			}
			
			forval q = 58/64 {
				di "removed: " char(`q')
				foreach v of varlist `varlist' {
					quietly replace `v' = subinstr(`v',char(`q'),"`substitute'",.) `in'		        
				}
			}
			
			forval q = 91/96 {
				di "removed: " char(`q')
				foreach v of varlist `varlist' {
					quietly replace `v' = subinstr(`v',char(`q'),"`substitute'",.) `in'		        
				}
			}
			
			forval q = 123/127 {
				di "removed: " char(`q')
				foreach v of varlist `varlist' {
					quietly replace `v' = subinstr(`v',char(`q'),"`substitute'",.) `in'		        
				}
			}			
			
		}
end        
