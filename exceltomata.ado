// program to get excel data to mata

program define exceltomata, rclass

syntax, file(string) [ir(int 1) fr(int 1) ic(int 1) fc(int 1) ii(int 0) ij(int 0) verbose]

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ begin exceltomata.ado ----------------------------"
	di ""
	di "Creates a matrix from an excel file"
	di ""
}
******************************************************************************************


mata: mata clear
mata: etm("`file'",`ir',`fr',`ic',`fc',`ii',`ij')
return matrix x = x


if "`verbose'" == "verbose" {
	di ""
	di "Returned matrix: x"

}

************************************* verbose ********************************************
if "`verbose'" == "verbose" {
	di ""
	di "------------------------ end exceltomata.ado ----------------------------"
	di ""

}
******************************************************************************************

end




mata:

function etm(string scalar file,real scalar ir,real scalar fr,real scalar ic,real scalar fc, real scalar ii, real scalar ij)
{
real scalar i, j
real matrix Z
class xl scalar b

b = xl()
b.load_book(file)

Z = J(fr-ir+1,fc-ic+1,0)

for (i=ir; i<=fr; i++) {
	for (j=ic; j<=fc; j++) {
		Z[i-ii,j-ij] = b.get_number(i,j);	
	}
}
st_matrix("x",Z)
}

end
