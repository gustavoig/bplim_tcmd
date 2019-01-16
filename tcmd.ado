*! 0.1.0 Gustavo Iglésias 13dec2018
* Programmed by Gustavo Iglésias
* Dependencies:
* panelstat (version 3.46 27nov2018)
* markstat (version 2.2.0 7may2018)
* package matrixtools
* gtools
* plotmatrix




// Characterization of a panel dataset
// pvar = panel variable
// tvar = time variable
// unit = display unit for graphs in levels and the output of flows
// graph: specify rel for relative changes in mean and median for graphs
// rep: specify sep if you want the time analysis for each variable to have its own html file


program define tcmd

syntax varlist (min=2 max=2) [if], [ nobasic keepmd tccheck(string) verbose]

version 15

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin tcmd.ado ----------------------------"
}
******************************************************************************************

prog drop _all

if "`if'" != "" {
	global if_condition = "`if'"
	keep `if'
}

local pvar: word 1 of `varlist'
local tvar: word 2 of `varlist'

quietly xtset `pvar' `tvar'

capture label language en


// rownames to use when using ado exceltomata 
levelsof(`tvar'), local(levels)
local lc: word count `levels'
forvalues i=1/`lc' {
	local rown = "`rown'" + " `i'" 
}
//di "`rown'"

// Program readtccheck

************************************* verbose ********************************************
if "`verbose'" == "verbose"  & "`tccheck'" != "" {
	di ""
	di "Program readtccheck"
	di ""
}
******************************************************************************************



if "`basic'" == "" {

	if "`tccheck'" != "" {
		readtccheck, tccheck(`tccheck') `verbose'
		local vars = "`r(vars)'"
	}

	if "`verbose'" == "verbose" {
		di "Displaying default statistics for dataset"
	}
	capture file close myfile

	// ` !    
	// ' ?
	// " §
	// ! £
	// § @


	// Number of observations

	file open  myfile using "write.stmd", write text replace

	file write myfile "<meta charset=§utf-8§/>" _n
	file write myfile _n
	file write myfile "# <span style=§color:black§>**Characterization of the panel dataset `s §${S_FN}§`**</span>" _n
	file write myfile _n
	file write myfile "## Date: `s §`c(current_date)'§`"_n
	file write myfile "## Time: `s §`c(current_time)'§`"_n

	file write myfile "!!!s/" _n
	file write myfile "quietly xtset `pvar' `tvar'" _n
	file write myfile "quietly count" _n
	file write myfile "di §N: !r(N)?§" _n
	file write myfile "!!!" _n
	file write myfile _n

	file write myfile "!!!s/" _n
	file write myfile "local lc = `lc'" _n
	file write myfile "capture mkdir graphs" _n
	file write myfile "!!!" _n


	***** Default *****

	* Visualization of the panel
	
	// Program argplotmat

	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Program argplotmat"
		di ""
	}
	******************************************************************************************

	file write myfile "### Missing values by `tvar'" _n

	file write myfile _n
	file write myfile "!!!s/" _n
	file write myfile "quietly argplotmat `tvar', `verbose'" _n
	file write myfile "quietly graph export graphs/matplot.png, replace" _n
	file write myfile "!!!" _n
	file write myfile "£[](graphs/matplot.png){width=§50%§}" _n
	file write myfile _n

	/*
	file write myfile "!!!{r/}" _n
	file write myfile "library(tidyverse)" _n
	file write myfile "library(haven)" _n
	file write myfile "library(naniar)" _n
	file write myfile "stata_dta <- read_dta(file = §C:\\Users\\bpu060275\\Desktop\\test_t\\test_pstat.dta§)" _n
	file write myfile "dados<-stata_dta[,c(§ano§,§B001§,§B004§)]" _n
	file write myfile "dados@ano<-as.factor(dados@ano)" _n
	file write myfile "gg_miss_fct(dados, fct = ano)" _n 
	file write myfile "ggsave(§graph.PNG§)" _n
	file write myfile "!!!" _n

	file write myfile _n

	file write myfile "£[](graph.PNG){width=§40%§}" _n
	*/

	* top 10 patterns in the data
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Top 10 patterns in the data"
		di ""
		di "command: quietly panelstat `pvar' `tvar', nosum pattern excel(graphs/pattern, replace)"
		di ""
	}
	******************************************************************************************

	file write myfile _n
	file write myfile "### Top 10 patterns in the data" _n
	file write myfile _n
	file write myfile "!!!s/" _n
	file write myfile "quietly panelstat `pvar' `tvar', nosum pattern excel(graphs/pattern, replace)" _n
	file write myfile "preserve" _n
	file write myfile "import excel graphs/pattern.xlsx, cellrange(A4:B13) clear" _n
	file write myfile "rename A Pattern" _n
	file write myfile "rename B Frequency" _n
	file write myfile "list, abbreviate(10)" _n
	file write myfile "restore" _n
	file write myfile "capture rm graphs/pattern.xlsx" _n
	file write myfile "di §§" _n
	file write myfile "di §Note: 1 if observation is in the dataset; 0 otherwise§" _n
	file write myfile "!!!" _n
	file write myfile _n


	* Time changes - incumbents, entrants and exits
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Time changes - incumbents, entrants and exits"
		di ""
		di "command: quietly panelstat `pvar' `tvar', nosum demog excel(graphs/demog, replace)"
		di ""
	}
	******************************************************************************************

	file write myfile _n
	file write myfile "### Time changes - incumbents, entrants and exits" _n
	file write myfile _n
	file write myfile "!!!s/" _n
	file write myfile "quietly panelstat `pvar' `tvar', nosum demog excel(graphs/demog, replace)" _n
	file write myfile "local fr = 3+!lc?" _n
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Program exceltomata"
		di ""
	}
	******************************************************************************************
	
	file write myfile "exceltomata, file(graphs/demog.xlsx) ir(4) fr(!fr?) ic(1) fc(10) ii(3) `verbose'" _n
	file write myfile "capture rm graphs/demog.xlsx" _n
	file write myfile "matrix A = r(x)" _n
	file write myfile "matrix colnames A = time total inc1 entry first reent inc2 exit last reexit" _n
	file write myfile "matrix rownames A = `rown'" _n
	file write myfile "matprint A, decimals(0,0,0)" _n
	file write myfile "di §§" _n
	file write myfile "di §time - time period§" _n
	file write myfile "di §total - total number of individuals at time t§" _n
	file write myfile "di §inc1 - number of individuals at t that are also present at t-1§" _n
	file write myfile "di §entry - number of individuals at t that are not present at t-1§" _n
	file write myfile "di §first - number of individuals at t who show up for the first time at t§" _n
	file write myfile "di §reent - number of individuals at t that are reentering at time t§" _n
	file write myfile "di §inc2 - number of individuals at t that are also present at t+1§" _n
	file write myfile "di §exit - number of individuals at t that are not present at t+1§" _n
	file write myfile "di §last - number of individuals at t that are not present at any future time§" _n
	file write myfile "di §reexit - number of individuals at t not present at t+1 that appear in later times§" _n

	file write myfile "!!!" _n
	file write myfile _n



	* gaps

	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Gaps"
		di ""
		di "command: quietly panelstat `pvar' `tvar', nosum gaps keepmaxgap(maxgap) keepngaps(ngaps)"
		di ""
	}
	******************************************************************************************

	file write myfile "!!!s/" _n
	file write myfile "quietly panelstat `pvar' `tvar', nosum gaps keepmaxgap(maxgap) keepngaps(ngaps)" _n
	file write myfile "!!!" _n

	file write myfile _n
	file write myfile "### Number of gaps" _n
	file write myfile _n
	file write myfile "!!!s/" _n
	file write myfile "tab ngaps" _n
	file write myfile "!!!" _n
	file write myfile _n


	file write myfile _n
	file write myfile "### Maximum number of gaps" _n
	file write myfile _n
	file write myfile "!!!s/" _n
	file write myfile "tab maxgap" _n
	file write myfile "quietly drop ngaps maxgap" _n
	file write myfile "!!!" _n
	file write myfile _n

	file write myfile _n



	* Matrices for _wiv_var
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Distribution of all observations"
		di ""
		di "command: (for each var) quietly panelstat `pvar' `tvar', nosum wiv(var, keep)"
		di ""
	}
	******************************************************************************************

	file write myfile "### Distribution of all observations" _n
	file write myfile _n

	file write myfile "!!!s/" _n
	file write myfile "local i = 1" _n
	file write myfile "quietly ds" _n
	file write myfile "local variables = §!r(varlist)?§" _n
	file write myfile "local not = §`pvar' `tvar'§" _n
	file write myfile "local vars: list variables-not" _n
	file write myfile "quietly foreach var in !vars? {" _n
	file write myfile "quietly panelstat `pvar' `tvar', nosum wiv(!var?, keep)" _n
	
	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Program tcompmat"
		di ""
	}
	******************************************************************************************
	
	file write myfile "quietly tcompmat _wiv_!var?, levels(1 2 3 4 5 6 7 8) `verbose'" _n
	file write myfile "quietly mat m!var? = r(x)" _n
	file write myfile "quietly if !i? == 1 {" _n
	file write myfile "quietly mat A = m!var?" _n
	file write myfile "}" _n
	file write myfile "quietly else {" _n
	file write myfile "quietly mat A = A\m!var?" _n
	file write myfile "}" _n
	file write myfile "quietly local i = !i? + 1" _n
	file write myfile "quietly drop _wiv_!var?" _n
	file write myfile "}" _n


	file write myfile _n


	file write myfile "mat colnames A = s_nonmiss s_missing allmissing onevalue timeinv_nm timeinv_wm timevar_nm timevar_wm" _n
	file write myfile "mat rownames A = !vars?" _n
	file write myfile "matprint A, decimals(0,0,0)" _n

	file write myfile _n

	file write myfile "di §§" _n 
	file write myfile "di §s_nonmiss - singleton observation with nonmissing value of the variable§" _n 
	file write myfile "di §s_missing - singleton observation with missing value for the variable§" _n 
	file write myfile "di §allmissing - non-singleton with all missing values of the variable§" _n 
	file write myfile "di §onevalue - non-singleton with only one valid value of the variable§" _n 
	file write myfile "di §timeinv_nm - non-singleton with time-invariant values and nonmissing values for the variable§" _n 
	file write myfile "di §timeinv_wm - non-singleton with time-invariant values and missing values for the variable§" _n 
	file write myfile "di §timevar_nm - non-singleton with time-variant values and nonmissing values for the variable§" _n 
	file write myfile "di §timevar_wm - non-singleton with time-variant values and missing values for the variable§" _n 
	file write myfile "!!!" _n

	file close myfile

	filefilter write.stmd write1.stmd, from(!) to(\LQ) replace
	filefilter write1.stmd write2.stmd, from(?) to(\RQ) replace
	filefilter write2.stmd write3.stmd , from(§) to(\Q) replace
	filefilter write3.stmd write4.stmd, from(£) to(!) replace
	filefilter write4.stmd tcmd.stmd, from(@) to(\$) replace

	************************************* verbose ********************************************
	if "`verbose'" == "verbose" {
		di ""
		di "Using command markstat to create html file tcmd"
	}
	******************************************************************************************

	markstat using tcmd


	capture rm write.stmd
	capture rm write1.stmd
	capture rm write2.stmd
	capture rm write3.stmd
	capture rm write4.stmd
	capture rm demog.xlsx
	capture rm pattern.xlsx
	capture rm tcmd.smcl
	if "`keepmd'" != "keepmd" {
		capture rm tcmd.stmd
	}
	
	if `"`tccheck'"' != "" {
		readtccheck, tccheck(`tccheck') `verbose'
		local vars = "`r(vars)'"
		foreach var in `vars' {
		
			************************************* verbose ********************************************
			if "`verbose'" == "verbose" {
				di ""
				di "Program write_var"
				di ""
			}
			******************************************************************************************
			
			write_var `var', pvar(`pvar') tvar(`tvar') tccheck(`tccheck') `keepmd' `verbose'
		}
	}
}

else {
	if `"`tccheck'"' != "" {
		readtccheck, tccheck(`tccheck') `verbose'
		local vars = "`r(vars)'"
		foreach var in `vars' {
			
			************************************* verbose ********************************************
			if "`verbose'" == "verbose" {
				di ""
				di "Program write_var"
				di ""
			}
			******************************************************************************************
			
			write_var `var', pvar(`pvar') tvar(`tvar') tccheck(`tccheck') `keepmd' `verbose'
		}
	}
}

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ end tcmd.ado ----------------------------"
}
******************************************************************************************

end


// Creating column names

/*
local fvar: word 1 of `varlist'
forvalues i = 1/8 {
	local lab`i':label (`fvar') `i'		
	local colnames = `"`colnames'"' + `" "`lab`i''""'
}
*/
