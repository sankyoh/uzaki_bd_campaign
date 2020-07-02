* uzaki_SCM_IPPE
* Robustness check by In Place Placebo Effect (IPPE)

* Preparation
version 16
cls
capture mkdir resultstore

/**** ***** ***** ***** ***** ***** *****

STEP 1. Preparation for IPPE estimate

***** ***** ***** ***** ***** ***** ****/

* Read dataset
// Orignal data from ...
// Number of blood donors by prefecture : http://www.jrc.or.jp/activity/blood/data/
// Population age 15 to 64 by prefecture : https://www.stat.go.jp/data/nihon/zuhyou/n200200600.xlsx
import excel using "Dataset_SCMuzaki.xls", sheet("Stata") firstrow clear
drop if 8<=id & id<=14 // Remove individual data for Kanto have been removed.
label data "wide-data for Uzaki-chan SCM"
save "Dataset_SCMuzaki_wide.dta", replace 

* Preparation for In-Place Placebo Effect
drop if intv==1 // Remove Kanto data
sort id
gen id2=_n
qui:sum id2
local maxofid = `r(max)'
order id2
drop  id
list id2 pref

* Reshape wide -> long
reshape long n, i(id2) j(month) 

* Labeling
label define month 0 "2019-02" 1 "2019-03" 2 "2019-04" 3 "2019-05" 4 "2019-06" 5 "2019-07" ///
	6 "2019-08" 7 "2019-09" 8 "2019-10" 9 "2019-11" 10 "2019-12" 11 "2020-01" ///
	12 "2020-02"
label value month month

* Preparation for Synthetic Control Methos (SCM)
tsset id2 month

/**** ***** ***** ***** ***** ***** *****

STEP 2. DataFrame for results store

***** ***** ***** ***** ***** ***** ****/

capture frame create results
frame change results
	clear
	set obs `maxofid'
	gen id     = .
	gen ippe   = .
	gen ippe_p = .
	gen rmspe  = .
	save "IPPE_result.dta",replace
frame change default

/**** ***** ***** ***** ***** ***** *****

STEP 3. Execute SCM analysis

***** ***** ***** ***** ***** ***** ****/

* SCM for placebo area ,that is id2=1 to 36(=`maxofid'))
capture log close
log using "in_place_placebo_effect", replace
forvalues x=1/`maxofid' {
	di "Prefecture id2=`x'"
	qui:sum pop15to64 if id2==`x'
	local pop=`r(mean)'
	synth n pop15to64 n(0) n(1) n(2) n(3) n(4) n(5) n(6) n(7) n(8) n(9) n(10) n(11), ///
		trunit(`x') trperiod(12) keep(./resultstore/result_SCM_ippe`x') replace
	di "RMSPE =", e(RMSPE)[1,1]
	di "ATT =", e(Y_treated)[13,1] - e(Y_synthetic)[13,1]
	frame change results
		qui:replace id     = `x' in `x'
		qui:replace ippe   = e(Y_treated)[13,1] - e(Y_synthetic)[13,1] in `x'
		qui:replace ippe_p = (e(Y_treated)[13,1] - e(Y_synthetic)[13,1])/`pop' in `x'
		qui:replace rmspe  = e(RMSPE)[1,1] in `x'
	frame change default
	di _newline(2)
}
log close

/**** ***** ***** ***** ***** ***** *****

STEP 4. Ratio of ippe/rmspe

***** ***** ***** ***** ***** ***** ****/
frame change results
save "IPPE_result.dta",replace

sort id
capture log close

log using "p-value_by_ippe", replace
list


replace id    = 37        in 37
replace ippe  = 296.17343 in 37
replace rmspe = 120.15764 in 37
gen ratio = abs(ippe)/rmspe
sort ratio

list *

log close
	
