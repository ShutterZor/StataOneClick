sysuse auto.dta, clear
*- 设定显著性水平
global significance 0.01

*- 设定变量
*- 设置被解释变量
global dependentVariable 	price
*- 设置解释变量
global independentVariable 	weight
*- 设置控制变量
global controlVariables 	headroom trunk length displacement


*- 以下不用修改
gen degreeOfFreedom = .
gen tValue = .
gen bOfIndX = .
gen seOfIndX = .
gen tOfIndX = .
gen rSq = .
generate controlVariableSet = ""

tuples $controlVariables
forvalues i = 1/`ntuples' {
	regress $dependentVariable $independentVariable `tuple`i''
	replace bOfIndX = _b[$independentVariable]
	replace seOfIndX = _se[$independentVariable]
	replace tOfIndX = bOfIndX / seOfIndX
	replace degreeOfFreedom = e(df_r)	
	replace tValue = invttail(degreeOfFreedom, $significance)
    replace rSq = e(r2) in `i'
	replace controlVariableSet = "`tuple`i''" in `i'
}

preserve
	keep if tOfIndX > tValue
	generate controlVariableNumbers = wordcount(controlVariableSet) if controlVariableSet != ""
	sort controlVariableNumbers rSq
	list controlVariableSet tOfIndX tValue rSq in 1/`ntuples'
restore
