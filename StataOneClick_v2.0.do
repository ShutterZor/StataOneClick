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
gen controlVariableSet = ""

tuples $controlVariables
forvalues i = 1/`ntuples' {
	regress $dependentVariable $independentVariable `tuple`i''
	replace bOfIndX = _b[$independentVariable] in `i'
	replace seOfIndX = _se[$independentVariable] in `i'
	replace tOfIndX = bOfIndX / seOfIndX in `i'
	replace degreeOfFreedom = e(df_r) in `i'	
	replace tValue = invttail(degreeOfFreedom, $significance) in `i'
    replace rSq = e(r2) in `i'
	replace controlVariableSet = "`tuple`i''" in `i'
}

preserve
	replace tOfIndX = abs(tOfIndX)
	replace tValue = abs(tValue)
	keep if tOfIndX > tValue
	sort controlVariableNumbers rSq
	keep if rSq != .
	list controlVariableSet tOfIndX tValue rSq
restore
