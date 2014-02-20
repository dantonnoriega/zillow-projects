*! version 1.0.0  Oct2013
program define removesym
        version 13.1

        syntax varlist [in] [, blanks SYMbol(string) SUBstitute(string) allsym NUMbers LETters QUOTes]
		
        di "variable list: `varlist'"
        if ("`blanks'" == "" && "`symbol'" == "" && "`allsym'" == "" && "`numbers' == "" && "`letters' == "" && "`quotes'" == "") local nopts = 1
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
			
			
			if ("`allsym'" == "allsym") {
				di "entered allsym"	        
				
				local chrctr = " ~ ! @ # $ % ^ & * ( ) - _ = + { } [ ] | \ : ; < > , . / ? " // define problem characters
				foreach q of local chrctr {
					di "removed: `q'"
					foreach v of varlist `varlist' {
						quietly replace `v' = subinstr(`v',"`q'","`substitute'",.) `in'		        
					}
				}
			}

			if("`quotes'" == "quotes") {
				* remove any quotation marks
				di "entered quotes"
				di "removed: "char(34)
				foreach v of varlist `varlist' {					
					quietly replace `v' = subinstr(`v',char(34),"`substitute'",.) `in'		        
				}
				
				di "removed: '"
				foreach v of varlist `varlist' {
					quietly replace `v' = subinstr(`v',"'","`substitute'",.) `in'		        
				}
				
				di "removed: `"				
				foreach v of varlist `varlist' {
					quietly replace `v' = subinstr(`v',"`","`substitute'",.) `in'		        
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
		}
		
		else {
			di "entered nopts"	        				
			di "removed: blanks"
		 
			foreach v of varlist `varlist' {
				quietly replace `v' = subinstr(`v'," ","`substitute'",.) `in'		        
			}
			
			local chrctr = "~ ! @ # $ % ^ & * ( ) - _ = + { } [ ] | \ : ; < > , . / ?" // define problem characters
			
			foreach q of local chrctr {
				di "removed: `q'"
				foreach v of varlist `varlist' {
					quietly replace `v' = subinstr(`v',"`q'","`substitute'",.) `in'		        
				}
			}	

			* remove any quotation marks
			di "entered quotes"
			di "removed: "char(34)
			foreach v of varlist `varlist' {					
				quietly replace `v' = subinstr(`v',char(34),"`substitute'",.) `in'		        
			}
			
			di "removed: '"
			foreach v of varlist `varlist' {
				quietly replace `v' = subinstr(`v',"'"),"`substitute'",.) `in'		        
			}
			
			di "removed: `"				
			foreach v of varlist `varlist' {

				quietly replace `v' = subinstr(`v',"`","`substitute'",.) `in'		        
			}
		}
end        
