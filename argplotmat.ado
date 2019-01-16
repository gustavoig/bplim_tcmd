program define argplotmat, rclass

syntax varlist, [verbose]

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin argplotmat.ado ----------------------------"
	di ""
	di "Creates a matrix of missing values for each variable by timevar"
}
******************************************************************************************

local tvar = "`varlist'"
quietly ds
local variables = "`r(varlist)'"
local vars: list variables-tvar

quietly levelsof(`tvar'), local(levels)
local varcount: word count `vars'
local levelcount: word count `levels'

mat A = J(`varcount',`levelcount',0)

local i = 1
foreach var in `vars' {
	local j = 1
	foreach item in `levels' {	
		quietly count if `tvar' == `item'
		local tot = r(N)
		if "`verbose'" == "verbose" {
			di ""
			di "Observations of `var' in `item': `tot'"
		}
		quietly count if `tvar' == `item' & missing(`var')
		local miss = r(N)
		if "`verbose'" == "verbose" {
			di ""
			di "Missing values of `var' in `item': `miss'"
		}
		mat A[`i',`j'] = `miss'/`tot'
		local j = `j'+1
	}
	local i = `i' + 1
}

mat rownames A = `vars'
mat colnames A = `levels'
plotmatrix, m(A) c(green) ylabel(,angle(0)) blw(vvvthick) maxticks(200) //split(0 0.2 0.4 0.6 0.8 1)


return matrix pl = A


if "`verbose'" == "verbose" {
	di ""
	di "Returned matrix: pl"

}

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ end argplotmat.ado ----------------------------"
}
******************************************************************************************

end
