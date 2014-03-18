*! version 1.0.0  Oct2013
program define removesym
        version 13.1

        syntax varlist [in] [, blanks SYMbol(string) SUBstitute(string) BASICsym ALLsym NUMbers LETters QUOTes SPAnish]
		
        di "variable list: `varlist'"
        if ("`blanks'" == "" && "`symbol'" == "" && "`basicsym'" == "" && "`allsym'" == "" && "`numbers' == "" && "`letters' == "" && "`quotes'" == "" && "`spanish'" == "") local nopts = 1
		else local nopts = 0
		
		if (missing("`substitute'")) disp "substitute option disabled"
		
		else if ("`substitute'" == "space") {
			disp "substitute option enabled. subbing in blank space."
			local substitute " "
		}
		
		else disp "substitute option enabled. subbing: `substitute'"
		
		if (`nopts' != 1) {

			if ("`blanks'" == "blanks") {
				di "entered `blanks'"  		
				di "removed: blanks"
				
				foreach v of varlist `varlist' {
					quietly replace `v' = subinstr(`v'," ","`substitute'",.) `in'		        
				}
			}
			
			if ("`symbol'" != "") {
				di "entered symbol"        
				
				foreach q of local symbol {
					di "removed: `q'"
					
					foreach v of varlist `varlist' {						
						quietly replace `v' = subinstr(`v',"`q'","`substitute'",.) `in'		        
					}
				}
			}
			

			if("`quotes'" == "quotes") {
				* remove any quotation marks
				di "entered quotes"
				
				local quotes = "char(34) char(39) char(96) char(145) char(146) char(147) char(148)"
				foreach q of local quotes {
					di "removed: " `q'
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',`q',"`substitute'",.) `in'		        
					}
				}					
			}
			
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
			
			if ("`spanish'" == "spanish") {
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
			
			
			if ("`basicsym'" == "basicsym") {
				di "entered basicsym"
				
				local basic = "~ ! ? @ # $ % ^ & * ( ) _ - + = { } [ ] : ; < > , . | \ /"
				foreach q of local basic {
					di "removed: `q'"
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',"`q'","`substitute'",.) `in'		        
					}
				}
				
				local quotes = "char(34) char(39) char(96) char(145) char(146) char(147) char(148)"
				foreach q of local quotes {
					di "removed: " `q'
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',`q',"`substitute'",.) `in'		        
					}
				}
			}
				
			
			if ("`allsym'" == "allsym") {
				di "entered allsym"	        				
				
				* remove all sym
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
				
				forval q = 123/255 {
					di "removed: " char(`q')
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',char(`q'),"`substitute'",.) `in'		        
					}
				}
			}
		}
		
		if (`nopts' == 1) {
			di "entered nopts. removing basic symbols."	        				
				
			* remove all sym
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
			
			forval q = 123/255 {
				di "removed: " char(`q')
				foreach v of varlist `varlist' {
					quietly replace `v' = subinstr(`v',char(`q'),"`substitute'",.) `in'		        
				}
			}				
			
		}
end        
