program define tccheck2

syntax varlist, tvar(string) pvar(string) [by(string)] [step(real 1)] [langle(int 0)] [yangle(int 0)] [den(int 1)] [flow(string)] [thr(real 30)] [fillin] [save(string)] [verbose]

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin tccheck2.ado ----------------------------"
	di ""
	di "Creates graphs with the evolution of a collapsed variable over time, drawing areas for potential inconsistent patterns of type 2"
}
******************************************************************************************

quietly xtset `pvar' `tvar'

// balance the panel if specified by the user

if "`fillin'" == "fillin" {
	fillin `pvar' `tvar'
	quietly replace `varlist' = 0 if missing(`varlist')
}

// save graphs in path specified by the user

if `"`save'"' != "" {
	if `"`save'"' == "cwd" {
		local path: pwd
	}
	else {
		local path = `"`save'"'
	}
}
else {
	local path ""
}

if "`path'" != "" {
	capture mkdir `"`path'/tcgraphs2"'
}
	

preserve

	// collapse data by timevar and categorical var if specified by the user
	
	if "`by'" != "" {
	
		if "`verbose'" == "verbose" {
			di ""
			di "Generating relative flows"
		}
		
		capture confirm var `by'
		if "`flow'" == "" {
			quietly gcollapse (mean) `varlist', by(`tvar' `by')
			local var = "`varlist'"
		}
		else {
			quietly gcollapse (`flow') `varlist', by(`tvar' `by')
			local var = "`varlist'"
		}
		quietly drop if missing(`by')
		
		//replace `var' = 0 if missing(`var')

		// gen relative flows
		
		tempvar relvar dummy pattern increase totdummy
		
		if `den' == 1 {
			bysort `by' (`tvar'): gen double `relvar' = 100*(`var'[_n]-`var'[_n-1])/(`var'[_n-1])
		}
		else {
			bysort `by' (`tvar'): gen double `relvar' = 100*(`var'[_n]-`var'[_n-1])/(abs(`var'[_n]+`var'[_n-1])/2)
		}

		if "`verbose'" == "verbose" {
			di ""
			di "Generating dummy variable for relative flows above the threshold"
		}
		

		quietly gen `dummy' = (abs(`relvar')>`thr' & !missing(`relvar'))
		bysort `by': gegen `totdummy' = total(`dummy')
		
		if "`verbose'" == "verbose" {
			di ""
			di "Creating graphs ....."
		}
		
		quietly sum `tvar'
		local min = r(min)
		local max = r(max)
		
		quietly count if `totdummy' > 0
		if `r(N)' == 0 {
			//di "No time inconsistencies found"
			quietly glevelsof(`by'), local(nivel)
			local labe : value label `by'
			foreach sub in `nivel' {
				if "`labe'" != "" {
					local f`sub' : label `labe' `sub'
				}
				else {
					local f`sub' = "`sub'"
				}
				quietly line `var' `tvar' if `by' == `sub', xlabel(`min'(`step')`max', angle(`langle')) ylabel(, angle(`yangle')) ytitle("") title("`f`sub''")
				quietly graph save tc2_`var'_`by'_`sub', replace
				if "`path'" != "" {
					quietly graph export `"`path'/tcgraphs2/`var'_`by'_`sub'.png"', replace
				}
			}
		}
		else {
			quietly glevelsof(`by') if `totdummy' == 0, local(nivel)
			local labe : value label `by'
			foreach sub in `nivel' {
				if "`labe'" != "" {
					local f`sub' : label `labe' `sub'
				}
				else {
					local f`sub' = "`sub'"
				}
				quietly line `var' `tvar' if `by' == `sub', xlabel(`min'(`step')`max', angle(`langle')) ylabel(, angle(`yangle'))  ytitle("") title("`f`sub''")
				quietly graph save tc2_`var'_`by'_`sub', replace
				if "`path'" != "" {
					quietly graph export `"`path'/tcgraphs2/`var'_`by'_`sub'.png"', replace
				}		
			}
			quietly keep if `totdummy' > 0 & !missing(`totdummy')
			quietly graphcom21 `dummy' `relvar' `var', tvar(`tvar') pvar(`pvar') by(`by') step(`step') langle(`langle') yangle(`yangle') path(`path')
		}
	}
	else {
	
		if "`verbose'" == "verbose" {
			di ""
			di "Generating relative flows"
		}
		
		if "`flow'" == "" {
			quietly gcollapse (mean) `varlist', by(`tvar')
			local var = "`varlist'"
		}
		else {
			quietly gcollapse (`flow') `varlist', by(`tvar')
			local var = "`varlist'"
		}
		tempvar relvar dummy pattern increase totdummy
		
		if `den' == 1 {
			sort `tvar'
			quietly gen double `relvar' = 100*(`var'[_n]-`var'[_n-1])/(`var'[_n-1])
		}
		else {
			sort `tvar'
			quietly gen double `relvar' = 100*(`var'[_n]-`var'[_n-1])/(abs(`var'[_n]+`var'[_n-1])/2)
		}

		if "`verbose'" == "verbose" {
			di ""
			di "Generating dummy variable for relative flows above the threshold"
		}
		
		quietly gen `dummy' = (abs(`relvar')>`thr' & !missing(`relvar'))
		quietly gegen `totdummy' = total(`dummy')
		
		if "`verbose'" == "verbose" {
			di ""
			di "Creating graphs ....."
		}
		
		quietly sum `tvar'
		local min = r(min)
		local max = r(max)
		
		quietly count if `totdummy' > 0
		if `r(N)' == 0 {
			//di "No time inconsistencies found"
			local f: variable label `var'
			quietly line `var' `tvar', xlabel(`min'(`step')`max', angle(`langle')) ylabel(, angle(`yangle')) ytitle("") title("`f'")
			quietly graph export graphs/tc2_`var'.png, replace
			if "`path'" != "" {
				quietly graph export `"`path'/tcgraphs2/`var'.png"', replace
			}
		}
		else {
			local f: variable label `var'
			quietly line `var' `tvar', xlabel(`min'(`step')`max', angle(`langle')) ylabel(, angle(`yangle'))  ytitle("") title("`f'")
			quietly graph export graphs/tc2_`var'.png, replace
			if "`path'" != "" {
				quietly graph export `"`path'/tcgraphs2/`var'.png"', replace
			}		
			quietly graphcom22 `dummy' `relvar' `var', tvar(`tvar') pvar(`pvar') step(`step') langle(`langle') yangle(`yangle') path(`path')
		}
	}

	



restore	

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ end tccheck1.ado ----------------------------"
}
******************************************************************************************
	
end



program define graphcom21

syntax varlist , tvar(string) pvar(string) [by(string)] [step(int 1)] [langle(int 0)] [yangle(int 0)] [path(string)]

tokenize `varlist'
	
	quietly sum `tvar'
	local min = r(min)
	local max = r(max)
	
	quietly glevelsof(`by'), local(levels)
	local lbe : value label `by'
	foreach item in `levels' {
		if "`lbe'" != "" {
			local f`item' : label `lbe' `item'
		}
		else {
			local f`item' = "`item'"
		}
		//di "level `f`item''"
		//di "---------------"
		preserve
			// keep problematic observations
			quietly keep if `1' == 1 & `by' == `item'
			//di "levelsof(`tvar') if `by' == `item'"
			quietly levelsof(`tvar') if `by' == `item'
			
			
			// gen dummy for increase in relative flow 
			tempvar increase pattern 
			quietly gen `increase' = 1 if `2'>0 & !missing(`2')
			quietly replace `increase' = 0 if `2'<0 & !missing(`2')
			
			// drop observations where there are no changes
			quietly drop if missing(`increase')
				
			// generate pattern for problematic observations (increase(decrease) in the current year and decrease(increase) in the next observation) 
			quietly bysort `by' (`tvar'): gen `pattern' = (`increase'[_n]!=`increase'[_n+1] & !missing(`increase'[_n+1])) 
			//di "levelsof(`tvar') if `by' == `item' & `pattern' == 1"
			quietly levelsof(`tvar') if `by' == `item' & `pattern' == 1, local(niv)
			if "`niv'" != "" {
				di ""
				quietly count if `by' == `item' 
				local i = 0
				forvalues j=1/`r(N)' {
					if `pattern'[`j'] == 1 & `by' == `item' {    // & nipc == ""
						local prtyy`j' = `tvar'[`j']
						//di "prtyy: `prtyy`j''"
					}
						
					if "`prtyy`j''" != "" {
						local i = `i' + 1
						
						// locals for period boundaries (previous year and year of the next problematic observation)
						local prtpreyy`i' = `tvar'[`j']-1
						//di "prevyy: `prtpreyy`i''"
						local prtnextyy`i' = `tvar'[`j'+1]
						//di "nextyy: `prtnextyy`i''"
						
						// colors for different patterns (eltblue for increases in current year and eltgreen for decreases in current year)
						if `increase'[`j'] == 1 & `by' == `item' {
							local color`i' = "eltblue"
							local pat`i' = "solid"
						}
						else if `increase'[`j'] == 0 & `by' == `item' {
							local color`i' = "eltgreen"
							local pat`i' = "dash"
						}	
						local areas_count = `i'
					}
					
					
				}
			}
		else {
			local areas_count = ""
		}
		restore


		// generatting xlines between period boundaries for problematic years
		if "`areas_count'" != "" {
			forvalues j = 1/`areas_count' {
				forvalues i = `prtpreyy`j''(0.01)`prtnextyy`j'' {
					local xline`j' `xline`j'' `i'
				}
			local xline_command = `"`xline_command'"' + `" xline(`xline`j'', lcolor("`color`j''") lpattern("`pat`j''"))"'

			}

			// graph
			//local title "`by' = `item'"
			quietly line `3' `tvar' if `by' == `item', `xline_command' xlabel(`min'(`step')`max', angle(`langle')) ylabel(, angle(`yangle')) ytitle("") title("`f`item''")
			quietly graph save tc2_`3'_`by'_`item', replace
			if "`path'" != "" {
				quietly graph export `"`path'/tcgraphs2/`3'_`by'_`item'.png"', replace
			}		
		}
		else {
			//di "No time inconsistencies found"
			quietly line `3' `tvar' if `by' == `item', xlabel(`min'(`step')`max', angle(`langle')) ylabel(, angle(`yangle')) ytitle("") title("`f`item''") 
			quietly graph save tc2_`3'_`by'_`item', replace
			if "`path'" != "" {
				quietly graph export `"`path'/tcgraphs2/`3'_`by'_`item'.png"', replace
			}		
		}
	}


end

program define graphcom22

syntax varlist , tvar(string) pvar(string) [step(int 1)] [langle(int 0)] [yangle(int 0)] [path(string)]

tokenize `varlist'
	
	quietly sum `tvar'
	local min = r(min)
	local max = r(max)
	
	preserve
		// keep problematic observations
		quietly keep if `1' == 1 
		//di "levelsof(`tvar') if `by' == `item'"
		//quietly levelsof(`tvar') if `by' == `item'
		
		
		// gen dummy for increase in relative flow 
		tempvar increase pattern 
		quietly gen `increase' = 1 if `2'>0 & !missing(`2')
		quietly replace `increase' = 0 if `2'<0 & !missing(`2')
		
		// drop observations where there are no changes
		quietly drop if missing(`increase')
			
		// generate pattern for problematic observations (increase(decrease) in the current year and decrease(increase) in the next observation) 
		sort `tvar'
		quietly gen `pattern' = (`increase'[_n]!=`increase'[_n+1] & !missing(`increase'[_n+1])) 
		//di "levelsof(`tvar') if `by' == `item' & `pattern' == 1"
		quietly levelsof(`tvar') if `pattern' == 1, local(niv)
		if "`niv'" != "" {
			di ""
			quietly count 
			local i = 0
			forvalues j=1/`r(N)' {
				if `pattern'[`j'] == 1 {    // & nipc == ""
					local prtyy`j' = `tvar'[`j']
					//di "prtyy: `prtyy`j''"
				}
					
				if "`prtyy`j''" != "" {
					local i = `i' + 1
					
					// locals for period boundaries (previous year and year of the next problematic observation)
					local prtpreyy`i' = `tvar'[`j']-1
					//di "prevyy: `prtpreyy`i''"
					local prtnextyy`i' = `tvar'[`j'+1]
					//di "nextyy: `prtnextyy`i''"
					
					// colors for different patterns (eltblue for increases in current year and eltgreen for decreases in current year)
					if `increase'[`j'] == 1 {
						local color`i' = "eltblue"
						local pat`i' = "solid"
					}
					else if `increase'[`j'] == 0 {
						local color`i' = "eltgreen"
						local pat`i' = "dash"
					}	
					local areas_count = `i'
				}
				
				
			}
		}
		else {
			local areas_count = ""
		}
	restore


	// generatting xlines between period boundaries for problematic years
	if "`areas_count'" != "" {
		forvalues j = 1/`areas_count' {
			forvalues i = `prtpreyy`j''(0.01)`prtnextyy`j'' {
				local xline`j' `xline`j'' `i'
			}
		local xline_command = `"`xline_command'"' + `" xline(`xline`j'', lcolor("`color`j''") lpattern("`pat`j''"))"'

		}

		// graph
		//local title "`by' = `item'"
		local f: variable lable `3'
		quietly line `3' `tvar', `xline_command' xlabel(`min'(`step')`max', angle(`langle')) ylabel(, angle(`yangle')) ytitle("") title("`f'")
		quietly graph export graphs/tc2_`3'.png, replace
		if "`path'" != "" {
			quietly graph export `"`path'/tcgraphs2/`3'.png"', replace
		}		
	}
	else {
		//di "No time inconsistencies found"
		local f: variable lable `3'
		quietly line `3' `tvar', xlabel(`min'(`step')`max', angle(`langle')) ylabel(, angle(`yangle')) ytitle("") title("`f'") 
		quietly graph export graphs/tc2_`3'.png, replace
		if "`path'" != "" {
			quietly graph export `"`path'/tcgraphs2/`3'.png"', replace
		}		
	}



end
