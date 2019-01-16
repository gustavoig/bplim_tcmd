// This program splits the string option merge in the program check_consistency into different options (file type key [obs_keep keep1 keep2])


program define readtccheck, rclass


syntax, tccheck(string) [verbose]
//di `"tcheck: `tccheck'"'

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin readtccheck.ado ----------------------------"
}
******************************************************************************************

// Errors 

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Errors for vars"
}
******************************************************************************************

if regexm(`"`tccheck'"', "vars") == 0 {
	di as error "You must provide one or more variables for option tccheck"
	error 1
}
else {
	if "`verbose'" == "verbose" {
		di ""
		di "No error to report in option vars"
	}
}


// Spliting tccheck into options 

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Spliting tccheck into options"
}
******************************************************************************************

local i = 1
local case = 0
while `case' == 0 {
	gettoken first tccheck: tccheck, parse(") ")
	local op`i' = `"`first'"'
	if length(`"`first'"')==0 {
		local case = 1
	}
	local i = `i' + 1
}

local lim = `i'-2

local words = "vars unit by step langle yangle den flow thr save rows ptrn"
foreach item in `words' {
	forvalues i=1/`lim' {
		local prev = `i' - 1
		if mod(`i',2) == 0 {
			local op = `"`op`prev''"' + `"`op`i''"'
			if regexm(`"`op'"',"`item'") == 1 {
				local `item' = `"`op'"'
			}
		}
	}
	if length(`"``item''"') == 0 {
		local `item' = "none"
	}
}


// Program getopt, to get the inputs inside parenthesis (defined at the bottom)

local words = "vars unit by step langle yangle den flow thr save rows ptrn"
foreach item in `words' {
	if length(`"``item''"') == 4 {
		local `item' = "none"
	}
	else if length(`"``item''"') > 4 {
		getopt `"``item''"'
		local `item' = "`r(opt)'"
	}

}

// Replacing "," by space in vars

local wordsl = "vars"
foreach item in `wordsl' {
	if `"``item''"' != "none" {
		local `item' = subinstr(`"``item''"',","," ",500)
	}
}


// Errors
// vars graph unit by step langle yangle den flow thr save rows ptrn
************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Input errors for options vars graph unit by step langle yangle den flow thr save rows ptrn"
}
******************************************************************************************

* vars

capture confirm variable `vars'
if _rc != 0 {
	di as error "One or more variable for option vars were not found in the dataset"
	error 1
}
else {
	if "`verbose'" == "verbose" {
		di ""
		di "No input errors for option vars"
	}
}

* graph 

/*
if "`graph'" != "none" & "`graph'" != "rel" {
	di as error "option graph only allows rel as an input"
	error 1
}
else {
	if "`verbose'" == "verbose" {
		di ""
		di "No input errors for option graph found"
	}
}
*/
* unit

if "`unit'" != "none" {
	local lenunit = length("`unit'")
	if `lenunit' != 4 {
		di as error "Arguments for unit must be of the type 10^#,  with 1 < # < 9"
		error 1
	}
	local f = substr("`unit'",1,2)
	if "`f'" != "10" {
		di as error "Arguments for unit must be of the type 10^#"
		error 1
	}
	local f = substr("`unit'",3,1)
	if "`f'" != "^" {
		di as error "Arguments for unit must be of the type 10^#"
		error 1
	}
	local t = substr("`unit'",4,1)
	if regexm("123456789","`t'") == 0 {
		di as error "Arguments for unit must be of the type 10^#. If # = 0, please do not specify this option"
		error 1
	}
}
else {
	if "`verbose'" == "verbose" {
		di ""
		di "No input errors for option unit found"
	}
}

* by

if "`by'" != "none" {
	capture confirm variable `by'
	if _rc != 0 {
		di as error "one or more variables for option by were not found in the dataset"
		error 1
	}
}
else {
	if "`verbose'" == "verbose" {
		di ""
		di "No input errors for option by found"
	}
}

* langle yangle den rows ptrn

local items_error = 0
local num = "0123456789"
local items = "langle yangle den rows ptrn"
foreach item in `items' {
	if "``item''" != "none" {
		local lenitem = length("``item''")
			forvalues i = 1/`lenitem' {
				local single = substr("``item''",`i',1)
				if regexm("`num'","`single'") == 0 {
					di as error "Arguments for option `item' must be integers"
					error 1
			}
		}
	}
}
if `items_error' == 0 & "`verbose'" == "verbose" {
	di ""
	di "No input errors for options langle, yangle, den, rows and ptrn found"
}

* step thr

local items_error = 0
local numplus = "0123456789./"
local items = "step thr"
foreach item in `items' {
	if "``item''" != "none" {
		local lenitem = length("``item''")
			forvalues i = 1/`lenitem' {
				local single = substr("``item''",`i',1)
				if regexm("`numplus'","`single'") == 0 {
					di as error "Option `item' only allows real inputs"
					error 1
			}
		}
	}
}
if `items_error' == 0 & "`verbose'" == "verbose" {
	di ""
	di "No input errors for options step and thr found"
}





return local vars = `"`vars'"'
//return local graph = `"`graph'"'
return local unit = `"`unit'"'
return local by = `"`by'"'
return local step = `"`step'"'
return local langle = `"`langle'"'
return local yangle = `"`yangle'"'
return local den = `"`den'"'
return local flow = `"`flow'"'
return local thr = `"`thr'"'
return local save = `"`save'"'
return local rows = `"`rows'"'
return local ptrn = `"`ptrn'"'


************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "Returned locals:"
	di ""
	di `"local vars		: `vars'"'
//	di `"local graph	: `graph'"'
	di `"local unit		: `unit'"'
	di `"local by	: `by'"'
	di `"local step	: `step'"'
	di `"local langle	: `langle'"'
	di `"local yangle	: `yangle'"'
	di `"local den		: `den'"'
	di `"local flow	: `flow'"'
	di `"local thr	: `thr'"'
	di `"local save	: `save'"'
	di `"local rows	: `rows'"'
	di `"local ptrn	: `ptrn'"'
}
******************************************************************************************



************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ end readtccheck.ado ------------------------------"
}
******************************************************************************************

end


program define getopt, rclass

args arg

gettoken first arg: arg, parse("(")
gettoken second arg: arg, parse("(")
gettoken third arg: arg, parse(")")

return local opt = `"`third'"'

end
