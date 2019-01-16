// program to turn a tab matrix with levels for the variables present in the dataset to a matrix with all potential levels (given in the option levels). The potential levels
// not captured by command tab will be missing in the new matrix


program define tcompmat, rclass

syntax varlist, levels(string) [verbose]

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin tcompmat.ado ----------------------------"
	di "Turns a tab matrix with levels for the variables present in the dataset to a matrix with all potential levels. Levels not captured by command tab will be missing in the new matrix"
}
******************************************************************************************



local maxcol = "`levels'"
quietly levelsof(`varlist'), local(col)
local colcount_col: word count `col'
local colcount_maxcol: word count `maxcol'

if `colcount_maxcol' == `colcount_col' {
	quietly tab `varlist', matcell(x)
	mat x = x'

	return matrix  x = x

}
else {
	quietly tab `varlist', matcell(z)
	mat z = z'
	mat x = J(1,`colcount_maxcol',0)
	local i = 1
	foreach item in `col' {
		local j = 1
		foreach el in `maxcol' {
			if `el' == `item' {
				mat x[1,`j'] = z[1,`i']
			}
			local j = `j' + 1
		}
		local i = `i' + 1
	}
	return matrix x = x

}

if "`verbose'" == "verbose" {
	di ""
	di "Returned matrix: x"

}

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ end tcompmat.ado ----------------------------"
}
******************************************************************************************

end
