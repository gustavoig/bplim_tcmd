program define tccheck1

syntax varlist, tvar(string) pvar(string) [by(string)] [step(real 1)] [langle(int 0)] [yangle(int 0)] [den(int 1)] [flow(string)] [thr(real 30)] [fillin] [save(string)] [verbose]

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin tccheck1.ado ----------------------------"
	di ""
	di "Creates graphs with the evolution of a collapsed variable over time, drawing areas for potential inconsistent patterns of type 1"
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
	capture mkdir `"`path'/tcgraphs1"'
}
	

preserve

	// collapse data by timevar and categorical var if specified by the user
	
	if "`verbose'" == "verbose" {
		di ""
		di "Collapsing variable by timevar and categorical variable if specified by the user"
	}
	
	if "`by'" != "" {
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

		if "`verbose'" == "verbose" {
			di ""
			di "Generating relative flows"
		}
		
		tempvar relvar dummy increase totdummy
		
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
				quietly graph save tc1_`var'_`by'_`sub', replace
				if "`path'" != "" {
					quietly graph export `"`path'/tcgraphs1/`var'_`by'_`sub'.png"', replace
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
				quietly graph save tc1_`var'_`by'_`sub', replace
				if "`path'" != "" {
					quietly graph export `"`path'/tcgraphs1/`var'_`by'_`sub'.png"', replace
				}		
			}
			quietly keep if `totdummy' > 0 & !missing(`totdummy')
			quietly graphcom11 `dummy' `relvar' `var', tvar(`tvar') pvar(`pvar') by(`by') step(`step') langle(`langle') yangle(`yangle') path(`path')
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

		//replace `var' = 0 if missing(`var')

		// gen relative flows
		
		tempvar relvar dummy increase totdummy
		
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
			local f: variable label `var'
			//di "No time inconsistencies found"
			quietly line `var' `tvar', xlabel(`min'(`step')`max', angle(`langle')) ylabel(, angle(`yangle')) ytitle("") title("`f'")
			quietly graph export graphs/tc1_`var'.png, replace
			if "`path'" != "" {
				quietly graph export `"`path'/tcgraphs1/`var'.png"', replace
			}
		}
		else {
			local f: variable label `var'
			quietly line `var' `tvar', xlabel(`min'(`step')`max', angle(`langle')) ylabel(, angle(`yangle'))  ytitle("") title("`f'")
			quietly graph export graphs/tc1_`var'.png, replace
			if "`path'" != "" {
				quietly graph export `"`path'/tcgraphs1/`var'.png"', replace
			}
			quietly graphcom12 `dummy' `relvar' `var', tvar(`tvar') pvar(`pvar') step(`step') langle(`langle') yangle(`yangle') path(`path')
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



program define graphcom11

syntax varlist , tvar(string) pvar(string) [by(string)] [step(int 1)] [langle(int 0)] [yangle(int 0)] [path(string)]
	
tokenize `varlist'
	quietly sum `tvar'
	local min = r(min)
	local max = r(max)
	
	glevelsof(`by'), local(levels)
	di "levels: `levels'"
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
			tempvar increase 
			quietly gen `increase' = 1 if `2'>0 & !missing(`2')
			quietly replace `increase' = 0 if `2'<0 & !missing(`2')
			
			// drop observations where there are no changes
			quietly drop if missing(`increase')

			quietly count if `by' == `item' 
			local i = 0
			forvalues j=1/`r(N)' {
				if `increase'[`j'] == 1 & `by' == `item' {    // & nipc == ""
					local prtyy`j' = `tvar'[`j']
					//di "prtyy: `prtyy`j''"
					
					// locals for period boundaries (previous year )
					local prtpreyy`j' = `tvar'[`j']-1
					//di "prevyy: `prtpreyy`i''"
					
					local color`j' = "eltblue"
					local pat`j' = "solid"
				}
				else if `increase'[`j'] == 0 & `by' == `item' {    // & nipc == ""
					local prtyy`j' = `tvar'[`j']
					//di "prtyy: `prtyy`j''"
					
					// locals for period boundaries (previous year )
					local prtpreyy`j' = `tvar'[`j']-1
					//di "prevyy: `prtpreyy`i''"
					
					local color`j' = "eltgreen"
					local pat`j' = "dash"
				}
			local areas_count = `j'
			}
		

		restore


		// generatting xlines between period boundaries for problematic years
		
		forvalues j = 1/`areas_count' {
			forvalues i = `prtpreyy`j''(0.01)`prtyy`j'' {
				local xline`j' `xline`j'' `i'
			}
		local xline_command = `"`xline_command'"' + `" xline(`xline`j'', lcolor("`color`j''") lpattern("`pat`j''"))"'

		}

		// graph
		//local title "`by' = `item'"
		di "by: `by'"
		di "item: `item'"
		quietly line `3' `tvar' if `by' == `item', `xline_command' xlabel(`min'(`step')`max', angle(`langle')) ylabel(, angle(`yangle')) ytitle("") title("`f`item''")
		quietly graph save tc1_`3'_`by'_`item', replace
		if "`path'" != "" {
			quietly graph export `"`path'/tcgraphs1/`3'_`by'_`item'.png"', replace
		}		
	}


end

program define graphcom12

syntax varlist , tvar(string) pvar(string) [step(int 1)] [langle(int 0)] [yangle(int 0)] [path(string)]
	
tokenize `varlist'
	quietly sum `tvar'
	local min = r(min)
	local max = r(max)
	
		//di "level `f`item''"
		//di "---------------"
	preserve
		// keep problematic observations
		quietly keep if `1' == 1 
		//di "levelsof(`tvar') if `by' == `item'"
		//quietly levelsof(`tvar') if `by' == `item'
		
		// gen dummy for increase in relative flow 
		tempvar increase 
		quietly gen `increase' = 1 if `2'>0 & !missing(`2')
		quietly replace `increase' = 0 if `2'<0 & !missing(`2')
		
		// drop observations where there are no changes
		quietly drop if missing(`increase')

		quietly count 
		local i = 0
		forvalues j=1/`r(N)' {
			if `increase'[`j'] == 1 {    // & nipc == ""
				local prtyy`j' = `tvar'[`j']
				//di "prtyy: `prtyy`j''"
				
				// locals for period boundaries (previous year )
				local prtpreyy`j' = `tvar'[`j']-1
				//di "prevyy: `prtpreyy`i''"
				
				local color`j' = "eltblue"
				local pat`j' = "solid"
			}
			else if `increase'[`j'] == 0 {    // & nipc == ""
				local prtyy`j' = `tvar'[`j']
				//di "prtyy: `prtyy`j''"
				
				// locals for period boundaries (previous year )
				local prtpreyy`j' = `tvar'[`j']-1
				//di "prevyy: `prtpreyy`i''"
				
				local color`j' = "eltgreen"
				local pat`j' = "dash"
			}
		local areas_count = `j'
		}
	

	restore


	// generatting xlines between period boundaries for problematic years
	
	forvalues j = 1/`areas_count' {
		forvalues i = `prtpreyy`j''(0.01)`prtyy`j'' {
			local xline`j' `xline`j'' `i'
		}
	local xline_command = `"`xline_command'"' + `" xline(`xline`j'', lcolor("`color`j''") lpattern("`pat`j''"))"'

	}

	// graph
	//local title "`by' = `item'"
	local f: variable label `3'
	quietly line `3' `tvar', `xline_command' xlabel(`min'(`step')`max', angle(`langle')) ylabel(, angle(`yangle')) ytitle("") title("`f'")
	quietly graph export graphs/tc1_`3'.png, replace
	if "`path'" != "" {
		quietly graph export `"`path'/tcgraphs1/`3'.png"', replace
	}		



end
