
{smcl}
{.-}
help for {cmd:tcmd} {right:()}
{.-}

{title:Title}

tcmd - Provides a characterization of a panel data set in an html file

{title:Syntax}

{p 8 15}
{cmd:tcmd} {it:panelvar} {it:timevar} [{help if}], [{it:options}]

{p}

{title:Description}

{p}
This command analyzes a panel data set and generarate html files which provide information on the time-series features of a panel data set. One or more html files are produced: 
one for the panel's general statistics and one for each variable's analysis.


{title:Options}

General Options

{p 0 4} {opt nobasic} does not report general statistics for the panel

{p 0 4} {opt keepmd} keeps stmd files

{p 0 4} {opt tccheck(tccheck_options)} runs a time consistency analysis for one or more variables that the user specifies. Specifically, it analyses the over-time evolution of the variable(s), possibly conditional upon certain aggregation level.
	One or more graphs will be produced for each predifined time pattern illustrated below. 
    Type 1 pattern captures the periods where significant increase/decrease (i.e., relative changes above the threshold set by the user) are observed. 
	This pattern is highlighted in the graph(s). Areas where there is an increase will
	be eltblue and solid. Areas with negative changes will be eltgreen and dash.
    Type 2 pattern captures the periods where significant increase/decrease is followed by significant decrease/increase which is not necessarily always consecutive. 
	The significance of the relative changes are defined based on the threshold set by the user.
	The same colors and patterns are used for type 2, but now dependent upon the first relative change.

{p 0 4} {opt verbose} shows the progress of the program


tccheck_options

{p 4 8}{opt vars(var1,var2,...)} specify variables for which the analysis will be performed. Input "_all" in order to perform the analysis for all the variables except panelvar and timevar.

{p 4 8}{opt rlvc} to display relative changes instead of absolute changes in graphs with mean and median values of the collapsed variable. These graphs are not the same as the
ones reported in the pattern analysis.

{p 4 8}{opt unit(#)} change scale of variables for some statistics and graphs. # is the power of 10. The default value is 0 and the max value is 9.

{p 4 8}{opt step(#)} set delta for x axis ticks. The default value is 1.

{p 4 8}{opt by(var)} only applies to categorical variable. If specified, the analysed variable will be collapsed by timevar as well as the categorical variable. Otherwise, it will be only collapsed
by timevar.

{p 4 8}{opt langle(#)} set xlabel angle. The default value is 0.

{p 4 8}{opt yangle(#)} set ylabel angle. The default value is 0.

{p 4 8}{opt den(#)} set denominator for relative changes. By default (# = 1), the denominator will be var[_n-1]. If # = 2, the denominator used to compute relative changes will be {help abs}(var[_n]+var[_n-1])/2.

{p 4 8}{opt flow(stat)} specify the stats that can be used in {help collapse}. The default value is mean.

{p 4 8}{opt thr(#)} set threshold value in percentage for relative changes. 

{p 4 8}{opt save()} set path for graphs to be saved. Graphs for pattern 1 and 2 will be saved in the folders tccheck1 and tccheck2, respectively. If cwd is specified, 
the graphs will be saved in the current working directory. If not, the graphs won't be saved.

{p 4 8}{opt rows(#)} set the configuration for # rows in a combined graph (see {help graph combine}). The default value is 3.

{p 4 8}{opt ptrn(#)} set the pattern to be checked. # = 1 for the type 1 and # = 2 for the type 2 pattern (see {opt tccheck}). If not specified, both patterns are presented.

{p 4 8}{opt fillin} balances the panel if there is break in the panel data (see {help fillin}). Missing values will be set as zero if this option is specified.

{title:Examples}

Example 1:

{p 8 16}{inp:. use nlswork, clear}{p_end}
{p 8 16}{inp:. tcmd idcode year}{p_end}

Example 2:

{p 8 16}{inp:. use nlswork, clear}{p_end}
{p 8 16}{inp:. tcmd idcode year, nobasic tccheck(vars(grade) by(race) langle(90) thr(10) save(cwd)) }{p_end}



{title:Remarks}

Please notice that this software is provided "as is", without warranty of any kind, whether
express, implied, or statutory, including, but not limited to, any warranty of merchantability
or fitness for a particular purpose or any warranty that the contents of the item will be error-free.
In no respect shall the author incur any liability for any damages, including, but limited to, 
direct, indirect, special, or consequential damages arising out of, resulting from, or any way 
connected to the use of the item, whether or not based upon warranty, contract, tort, or otherwise. 

{title:Dependencies}

{cmd:panelstat} (version 3.46 27nov2018) by Paulo Guimaraes
{cmd:markstat} (version 2.2.0 7may2018) by Germán Rodríguez
{cmd:matrixtools} package by Niels Henrik Bruun
{cmd:gtools} package by Mauricio Bravo
{cmd:plotmatrix} by Adrian Mander

{title:Author}

{p}
Gustavo Iglésias, BPlim, Banco de Portugal, Portugal.

{p}
Email: {browse "mailto:gustavo.p.iglesias@gmail.com":gustavo.p.iglesias@gmail.com}

I appreciate your feedback. Comments are welcome!
