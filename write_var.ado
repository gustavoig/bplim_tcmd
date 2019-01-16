
program define write_var

syntax varlist, pvar(string) tvar(string) tccheck(string) [keepmd] [verbose]

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin write_var.ado ----------------------------"
	di ""
	di "Time analysis for `varlist'"
}
******************************************************************************************

local var = "`varlist'"


if regexm(`"`tccheck'"',"fillin") == 1 {
	local fillin = "fillin"
	local tccheck = regexr(`"`tccheck'"',"fillin","")
}
else {
	local fillin = ""
}

if regexm(`"`tccheck'"',"rlvc") == 1 {
	local rlvc = "rlvc"
	local tccheck = regexr(`"`tccheck'"',"rlvc","")
}
else {
	local rlvc = ""
}

if "`verbose'" == "verbose" {
	di ""
	di "Program readtccheck"
}

readtccheck, tccheck(`tccheck') `verbose'
/*
if "`r(graph)'" == "none" {
	local graph = ""
}
else {
	local graph = "`r(graph)'"
}*/
if "`r(unit)'" == "none" {
	local unit = 0
}
else {
	local unit = `r(unit)'
}

if "`r(by)'" == "none" {
	local by = ""
}
else {
	local by = "`r(by)'"
}
if "`r(step)'" == "none" {
	local step = 1
}
else {
	local step = `r(step)'
}
if "`r(langle)'" == "none" {
	local langle = 180
}
else {
	local langle = `r(langle)'
}
if "`r(yangle)'" == "none" {
	local yangle = 0
}
else {
	local yangle = `r(yangle)'
}
if "`r(den)'" == "none" {
	local den = 1
}
else {
	local den = `r(den)'
}
if "`r(flow)'" == "none" {
	local flow = ""
}
else {
	local flow = "`r(flow)'"
}
if "`r(thr)'" == "none" {
	local thr = 30
}
else {
	local thr = `r(thr)'
}
if `"`r(save)'"' == "none" {
	local save = "" 
}
else {
	local save = `"`r(save)'"'
}
if "`r(rows)'" == "none" {
	local rows = 3
}
else {
	local rows = `r(rows)'
}
if "`r(ptrn)'" == "none" {
	local ptrn = ""
}
else {
	local ptrn = "`r(ptrn)'"
}

// rownames to use when using ado exceltomata 
levelsof(`tvar'), local(levels)
local lc: word count `levels'
forvalues i=1/`lc' {
	local rown = "`rown'" + " `i'" 
}
//di "`rown'"

local di_unit = "10^`unit'"

capture file close myfile1

// ` !    
// ' ?
// " §
// ! £
// § @


// Number of observations

file open  myfile1 using "`var'_write.stmd", write text replace

file write myfile1 "<meta charset=§utf-8§/>" _n
file write myfile1 _n
local labelvar: var label `var'
file write myfile1 "# <span style=§color:black§>**Time analysis for `labelvar' (`var')**</span>" _n
file write myfile1 _n
file write myfile1 "## Dataset: `s §${S_FN}§`" _n
file write myfile1 "## Date: `s §`c(current_date)'§`"_n
file write myfile1 "## Time: `s §`c(current_time)'§`"_n

file write myfile1 _n
file write myfile1 "!!!s/" _n
file write myfile1 "local lc = `lc'" _n
file write myfile1 "capture mkdir graphs" _n
file write myfile1 "!!!" _n
if "`graph'" == "rel" {
file write myfile1 "### Mean and median over time (%)" _n
}
else {
file write myfile1 "### Mean and median over time (`di_unit')" _n	
}
file write myfile1 _n
file write myfile1 "!!!s/" _n
file write myfile1 "preserve" _n
file write myfile1 "if §`rlvc'§ == §rlvc§ {" _n

if "`verbose'" == "verbose" {
	di ""
	di "Graphs for mean and median over time (relative changes)"
}

file write myfile1 "qui gen double rel_`var'=100*(`var'-l.`var')/(abs(`var'+l.`var')/2)" _n
file write myfile1 "*To avoid near zero differences in the denominator" _n
file write myfile1 "quietly replace rel_`var'=. if abs(`var'+l.`var')<1" _n
file write myfile1 "gcollapse (mean) mean_`var'=rel_`var' (p50) median_`var'=rel_`var', by (`tvar')" _n
file write myfile1 "label var mean_`var' §Mean (%)§" _n
file write myfile1 "label var median_`var' §Median (%)§" _n
file write myfile1 "}" _n
file write myfile1 "else {" _n

if "`verbose'" == "verbose" {
	di ""
	di "Graphs for mean and median over time (levels)"
}

file write myfile1 "gcollapse (mean) mean_`var'=`var' (p50) median_`var'=`var', by (`tvar')"	_n	
file write myfile1 "quietly replace mean_`var' = mean_`var'/10^`unit'"	_n	
file write myfile1 "quietly replace median_`var' = median_`var'/10^`unit'"	_n		
file write myfile1 "label var mean_`var' §Mean§" _n
file write myfile1 "label var median_`var' §Median§" _n
file write myfile1 "}" _n
file write myfile1 "quietly line mean_`var' `tvar'" _n 
file write myfile1 "quietly graph save graphs/mean_`var', replace" _n 
file write myfile1 "quietly line median_`var' `tvar'" _n 
file write myfile1 "quietly graph save graphs/median_`var', replace" _n
file write myfile1 "graph combine §graphs/mean_`var'.gph§ §graphs/median_`var'.gph§" _n
file write myfile1 "quietly graph export graphs/mean_median_`var'.png, replace" _n
file write myfile1 "quietly capture rm graphs/mean_`var'.gph" _n
file write myfile1 "quietly capture rm graphs/median_`var'.gph" _n
file write myfile1 "restore" _n
file write myfile1 "!!!" _n
file write myfile1 _n
file write myfile1 "£[](graphs/mean_median_`var'.png){width=§40%§}" _n
file write myfile1 _n
/*
file write myfile1 "!!!s/" _n
file write myfile1 "capture rm graphs/mean_`var'.gph" _n
file write myfile1 "capture rm graphs/median_`var'.gph" _n
file write myfile1 "capture rm graphs/mean_median_`var'.png" _n
file write myfile1 "!!!" _n
*/
* Relative changes overtime

if "`verbose'" == "verbose" {
	di ""
	di "Relative changes over time"
	di ""
	di "command: quietly panelstat `pvar' `tvar', nosum rel(`var',keep)"
}

file write myfile1 _n
file write myfile1 "### Relative changes over time" _n
file write myfile1 _n
file write myfile1 "!!!s/" _n

file write myfile1 "quietly panelstat `pvar' `tvar', nosum rel(`var',keep)" _n

if "`verbose'" == "verbose" {
	di ""
	di "Program tcompmat"
}

file write myfile1 "tcompmat _rel_L1_`var', levels(1 2 3 4 5 6) `verbose'" _n


// abs freq

file write myfile1 "mat z = r(x)" _n

// total
file write myfile1 "mata : st_matrix(§ztot§, rowsum(st_matrix(§z§)))" _n
file write myfile1 "mat z = z,ztot[1,1]" _n
file write myfile1 "mat z = z?" _n


// rel freq

file write myfile1 "mat y = J(7,1,0)" _n
file write myfile1 "quietly forvalues i = 1/7 {" _n
file write myfile1 "quietly mat y[!i?,1] = z[!i?,1]/z[7,1]*100"	_n
file write myfile1 "}" _n


// cumulative freq

file write myfile1 "mat x = J(6,1,0)" _n
file write myfile1 "local cum = 0" _n
file write myfile1 "quietly forvalues i = 1/6 {" _n
file write myfile1 "quietly mat x[!i?,1] = y[!i?,1] + !cum?" _n
file write myfile1 "quietly local cum = x[!i?,1]" _n
file write myfile1 "}" _n
file write myfile1 "mat x = x\100" _n
file write myfile1 _n

// final matrix

file write myfile1 "mat rel = z,y,x" _n
file write myfile1 `"mat rownames rel = "Positive change" "Negative change" "No change" "Abnormal positive change" "Abnormal negative change" "Missing" "Total""' _n
file write myfile1 "mat colnames rel = Freq. Percent Cum." _n
file write myfile1 "matprint rel, decimals(0,2,2)" _n
file write myfile1 "di §§" _n
file write myfile1 "di §Abnormal relative changes by `tvar'§" _n
file write myfile1 "di §§" _n
file write myfile1 "tab _rel_L1_`var' `tvar' if _rel_L1_`var' == 4 | _rel_L1_`var' == 5" _n
file write myfile1 "quietly drop _rel_L1_`var'" _n
file write myfile1 "!!!" _n

* Time flows

if "`verbose'" == "verbose" {
	di ""
	di "Time flows"
	di ""
	di "command: quietly panelstat `pvar' `tvar', nosum flows(`var', unit) excel(graphs/`var'flow, replace)"
}

file write myfile1 "### Time flows (`di_unit')" _n
file write myfile1 _n
file write myfile1 "!!!s/" _n
file write myfile1 "quietly panelstat `pvar' `tvar', nosum flows(`var', unit) excel(graphs/`var'flow, replace)" _n
file write myfile1 "local fr = 3+!lc?" _n

if "`verbose'" == "verbose" {
	di ""
	di "Program exceltomata"
}

file write myfile1 "exceltomata, file(graphs/`var'flow.xlsx) ir(4) fr(!fr?) ic(1) fc(10) ii(3) `verbose'" _n
file write myfile1 "mat B = r(x)" _n
file write myfile1 "mat B1 = B[.,1..1],B[.,2..10]/10^`unit'" _n
file write myfile1 "matrix colnames B1 = time `var' chg chg_inc expansion contraction entry exit miss_1 miss_2" _n
file write myfile1 "matrix rownames B1 = `rown'" _n
file write myfile1 "matprint B1, decimals(0,2,2)" _n
file write myfile1 "di §§" _n
file write myfile1 "di §Notes:§" _n
file write myfile1 "di §`var' - total sum of `var' at time t§" _n
file write myfile1 "di §chg - sum of `var' at t minus t-1§" _n
file write myfile1 "di §chg_inc - changes from individuals present at t and at t-1 with valid values of `var'§" _n
file write myfile1 "di §  of which:§" _n
file write myfile1 "di §    expansion - positive changes (expansions) from individuals present at t and at t-1§" _n
file write myfile1 "di §    contraction - negative changes (contractions) from individuals present at t and at t-1§" _n
file write myfile1 "di §entry - change resulting from entry (present at t but not at t-1)§" _n
file write myfile1 "di §exit - change resulting from exits (present at t-1 but not at t)§" _n
file write myfile1 "di §miss_1 - change from individuals present at t and t-1 but with missing data at t-1§" _n
file write myfile1 "di §miss_2 - change from individuals present at t and t-1 but with missing data at t§" _n
file write myfile1 "di §`var'[t]=`var'[t-1]+chg, chg=chg_inc+entry+exit+miss_1+miss_2, chg_inc=expansion+contraction§" _n
file write myfile1 "di §§" _n
file write myfile1 "di §Valid observations for `var'§" _n
file write myfile1 "di §§" _n
file write myfile1 "local fr = 3+!lc?" _n

if "`verbose'" == "verbose" {
	di ""
	di "Program exceltomata"
}


file write myfile1 "exceltomata, file(graphs/`var'flow.xlsx) ir(4) fr(!fr?) ic(12) fc(21) ii(3) ij(11) `verbose'" _n
file write myfile1 "capture rm graphs/`var'flow.xlsx" _n
file write myfile1 "matrix C = r(x)" _n
file write myfile1 "matrix colnames C = time n_var n_miss n_inc0 n_exp n_cont n_ent0 n_exi0 n_inc1 n_inc2" _n
file write myfile1 "matrix rownames C = `rown'" _n
file write myfile1 "matprint C, decimals(0,0,0)" _n
file write myfile1 "di §§" _n
file write myfile1 "di §Notes:§" _n
file write myfile1 "di §n_var - total number of nonmissing values of `var' at time t§" _n
file write myfile1 "di §n_miss - number of missing values of `var' at time t§" _n
file write myfile1 "di §n_inc0 - number of observations with nonmissing values at t and t-1 (incumbents)§" _n
file write myfile1 "di §  of which:§" _n
file write myfile1 "di §    n_exp - number of incumbents that increased `var' from time t-1 to t§" _n
file write myfile1 "di §    n_cont - number of incumbents that decreased `var' from time t-1 to t§" _n
file write myfile1 "di §n_ent0 - number of entrants with nonmissing values of `var'§" _n
file write myfile1 "di §n_exi0 - number of exits with nonmissing values of `var'§" _n
file write myfile1 "di §n_inc1 - number of incumbents with missing values of `var' at t-1 only§" _n
file write myfile1 "di §n_inc2 - number of incumbents with missing values of `var' at t only§" _n

file write myfile1 "!!!" _n
file write myfile1 _n

* Regression of var on years

if "`verbose'" == "verbose" {
	di ""
	di "Regression of `var' on `tvar'"
}


file write myfile1 "### Regression of `var' on `tvar'" _n
file write myfile1 _n
file write myfile1 "!!!s/" _n
file write myfile1 "reg `var' i.`tvar', noheader" _n
file write myfile1 "!!!" _n

* Time consistency analysis

if "`verbose'" == "verbose" {
	di ""
	di "Time consistency analysis"
}

if `"`tccheck'"' != "" {

	if "`by'" == "" {
		file write myfile1 "### Time consistency analysis of `var' (`di_unit')" _n
	}
	else {
		if "`flow'" == "" {
			file write myfile1 "### Time consistency analysis of `var' (mean) by `by' (`di_unit')" _n
		}
		else {
			file write myfile1 "### Time consistency analysis of `var' (`flow') by `by' (`di_unit')" _n
		}
	}
	if "`ptrn'" == "" {
		file write myfile1 "#### Pattern 1: captures relative changes above the threshold specified by the user" _n
		file write myfile1 _n
		file write myfile1 "!!!s/"_n
		file write myfile1 "preserve"_n
		file write myfile1 "if `unit' > 0 {" _n
		file write myfile1 "quietly replace `var' = `var'/10^`unit'" _n
		file write myfile1 "}" _n
		
		if "`verbose'" == "verbose" {
			di ""
			di "Program tccheck1"
		}
		
		file write myfile1 "quietly tccheck1 `var', pvar(`pvar') tvar(`tvar') by(`by') step(`step') langle(`langle') yangle(`yangle') flow(`flow') thr(`thr') save(`save') `fillin'  `verbose'" _n
		file write myfile1 "restore"_n
		file write myfile1 "!!!"
		if "`by'" == "" {
			file write myfile1 _n
			file write myfile1 "£[](graphs/tc1_`var'.png)" _n //{width=§40%§}
		}
		else {
			file write myfile1 _n
			file write myfile1 "!!!s/"_n
			file write myfile1 "preserve"_n
			file write myfile1 "quietly drop if missing(`by') " _n
			file write myfile1 "quietly glevelsof(`by'), local(levels)" _n
			file write myfile1 "quietly foreach item in !levels? {" _n
			file write myfile1 `"quietly local gcommand1 = "!gcommand1?" + " tc1_`var'_`by'_!item?.gph""' _n
			file write myfile1 "}"_n
			file write myfile1 "quietly graph combine !gcommand1?, rows(`rows')"_n
			file write myfile1 "quietly graph export graphs/tc1_`var'_`by'.png, replace" _n
			file write myfile1 "quietly foreach item in !levels? {" _n
			file write myfile1 "quietly capture rm tc1_`var'_`by'_!item?.gph" _n
			file write myfile1 "}"_n
			file write myfile1 "restore"_n
			file write myfile1 "!!!"_n
			file write myfile1 "£[](graphs/tc1_`var'_`by'.png)" _n //{width=§40%§}
		}
		
		file write myfile1 _n
		
		file write myfile1 "#### Pattern 2: captures relative increases (decreases) above the threshold followed by a `tvar' (consecutive or non-consecutive) with a relative decrease (increase) above the threshold" _n
		file write myfile1 _n
		file write myfile1 "!!!s/"_n
		file write myfile1 "preserve"_n
		file write myfile1 "if `unit' > 0 {" _n
		file write myfile1 "quietly replace `var' = `var'/10^`unit'" _n
		file write myfile1 "}" _n
			
		if "`verbose'" == "verbose" {
			di ""
			di "Program tccheck2"
		}
				
		file write myfile1 "quietly tccheck2 `var', pvar(`pvar') tvar(`tvar') by(`by') step(`step') langle(`langle') yangle(`yangle') flow(`flow') thr(`thr') save(`save') `fillin' `verbose'" _n
		file write myfile1 "restore"_n
		file write myfile1 "!!!"
		if "`by'" == "" {
			file write myfile1 _n
			file write myfile1 "£[](graphs/tc2_`var'.png)" _n //{width=§40%§}
		}
		else {
			file write myfile1 _n
			file write myfile1 "!!!s/"_n
			file write myfile1 "preserve"_n
			file write myfile1 "quietly drop if missing(`by') " _n
			file write myfile1 "quietly glevelsof(`by'), local(levels)" _n
			file write myfile1 "quietly foreach item in !levels? {" _n
			file write myfile1 `"quietly local gcommand2 = "!gcommand2?" + " tc2_`var'_`by'_!item?.gph""' _n
			file write myfile1 "}"_n
			file write myfile1 "quietly graph combine !gcommand2?, rows(`rows')"_n
			file write myfile1 "quietly graph export graphs/tc2_`var'_`by'.png, replace" _n
			file write myfile1 "quietly foreach item in !levels? {" _n
			file write myfile1 "quietly capture rm tc2_`var'_`by'_!item?.gph" _n
			file write myfile1 "}"_n
			file write myfile1 "restore"_n
			file write myfile1 "!!!"_n
			file write myfile1 "£[](graphs/tc2_`var'_`by'.png)" _n //{width=§40%§}
		}
	}
	else if "`ptrn'" == "1" {
		file write myfile1 "#### Pattern 1: captures relative changes above the threshold specified by the user" _n
		file write myfile1 _n
		file write myfile1 "!!!s/"_n
		file write myfile1 "preserve"_n
		file write myfile1 "if `unit' > 0 {" _n
		file write myfile1 "quietly replace `var' = `var'/10^`unit'" _n
		file write myfile1 "}" _n
				
		if "`verbose'" == "verbose" {
			di ""
			di "Program tccheck1"
		}
		
		file write myfile1 "quietly tccheck1 `var', pvar(`pvar') tvar(`tvar') by(`by') step(`step') langle(`langle') yangle(`yangle') flow(`flow') thr(`thr') save(`save') `fillin' `verbose'" _n
		file write myfile1 "restore"_n
		file write myfile1 "!!!"
		if "`by'" == "" {
			file write myfile1 _n
			file write myfile1 "£[](graphs/tc1_`var'.png)" _n //{width=§40%§}
		}
		else {
			file write myfile1 _n
			file write myfile1 "!!!s/"_n
			file write myfile1 "preserve"_n
			file write myfile1 "quietly drop if missing(`by') " _n
			file write myfile1 "quietly glevelsof(`by'), local(levels)" _n
			file write myfile1 "quietly foreach item in !levels? {" _n
			file write myfile1 `"quietly local gcommand = "!gcommand?" + " tc1_`var'_`by'_!item?.gph""' _n
			file write myfile1 "}"_n
			file write myfile1 "quietly graph combine !gcommand?, rows(`rows')"_n
			file write myfile1 "quietly graph export graphs/tc1_`var'_`by'.png, replace" _n
			file write myfile1 "quietly foreach item in !levels? {" _n
			file write myfile1 "quietly capture rm tc1_`var'_`by'_!item?.gph" _n
			file write myfile1 "}"_n
			file write myfile1 "restore"_n
			file write myfile1 "!!!"_n
			file write myfile1 "£[](graphs/tc1_`var'_`by'.png)" _n //{width=§40%§}
		}
	}
	else if "`ptrn'" == "2" {
		file write myfile1 "#### Pattern 2: captures relative increases (decreases) above the threshold followed by a `tvar' (consecutive or non-consecutive) with a relative decrease (increase) above the threshold" _n
		file write myfile1 _n
		file write myfile1 "!!!s/"_n
		file write myfile1 "preserve"_n
		file write myfile1 "if `unit' > 0 {" _n
		file write myfile1 "quietly replace `var' = `var'/10^`unit'" _n
		file write myfile1 "}" _n
				
		if "`verbose'" == "verbose" {
			di ""
			di "Program tccheck1"
		}
		
		file write myfile1 "quietly tccheck2 `var', pvar(`pvar') tvar(`tvar') by(`by') step(`step') langle(`langle') yangle(`yangle') flow(`flow') thr(`thr') save(`save') `fillin'  `verbose'" _n
		file write myfile1 "restore"_n
		file write myfile1 "!!!"
		if "`by'" == "" {
			file write myfile1 _n
			file write myfile1 "£[](graphs/tc2_`var'.png)" _n //{width=§40%§}
		}
		else {
			file write myfile1 _n
			file write myfile1 "!!!s/"_n
			file write myfile1 "preserve"_n
			file write myfile1 "quietly drop if missing(`by') " _n
			file write myfile1 "quietly glevelsof(`by'), local(levels)" _n
			file write myfile1 "quietly foreach item in !levels? {" _n
			file write myfile1 `"quietly local gcommand = "!gcommand?" + " tc2_`var'_`by'_!item?.gph""' _n
			file write myfile1 "}"_n
			file write myfile1 "quietly graph combine !gcommand?, rows(`rows')"_n
			file write myfile1 "quietly graph export graphs/tc2_`var'_`by'.png, replace" _n
			file write myfile1 "quietly foreach item in !levels? {" _n
			file write myfile1 "quietly capture rm tc2_`var'_`by'_!item?.gph" _n
			file write myfile1 "}"_n
			file write myfile1 "restore"_n
			file write myfile1 "!!!"_n
			file write myfile1 "£[](graphs/tc2_`var'_`by'.png)" _n //{width=§40%§}
		}
	}
}			

file close myfile1

filefilter `var'_write.stmd `var'_write1.stmd, from(!) to(\LQ) replace
filefilter `var'_write1.stmd `var'_write2.stmd, from(?) to(\RQ) replace
filefilter `var'_write2.stmd `var'_write3.stmd , from(§) to(\Q) replace
filefilter `var'_write3.stmd `var'_write4.stmd, from(£) to(!) replace
filefilter `var'_write4.stmd `var'_tmd.stmd, from(@) to(\$) replace

				
if "`verbose'" == "verbose" {
	di ""
	di "Using markstat to create html file `var'_tmd"
}
		

markstat using `var'_tmd


capture rm `var'_write.stmd
capture rm `var'_write1.stmd
capture rm `var'_write2.stmd
capture rm `var'_write3.stmd
capture rm `var'_write4.stmd
capture rm `var'_tmd.smcl
if "`keepmd'" != "keepmd" {
	capture rm `var'_tmd.stmd
}

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ end write_var.ado ----------------------------"
}
******************************************************************************************

end
