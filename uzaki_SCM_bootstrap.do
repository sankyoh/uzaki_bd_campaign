* uzaki_SCM_IPPE
* Robustness check by bootstrapped resampling

/**** ***** ***** ***** ***** ***** *****

STEP 1. DataFrame for results store

***** ***** ***** ***** ***** ***** ****/

set seed 12345

local bs =1000
local pop=3876 // average kanto : population age 15 to 64
capture frame create results
frame change results
	clear
	set obs `bs'
	gen diff   = .
	gen rmspe  = .
	forvalues m=0/12 {
		gen n`m' = .
	}
frame change default

/**** ***** ***** ***** ***** ***** *****

STEP 2. Dataset for SCM analysis

***** ***** ***** ***** ***** ***** ****/
* Read dataset
// Orignal data from ...
// Number of blood donors by prefecture : http://www.jrc.or.jp/activity/blood/data/
// Population age 15 to 64 by prefecture : https://www.stat.go.jp/data/nihon/zuhyou/n200200600.xlsx
import excel using "Dataset_SCMuzaki.xls", sheet("Stata") firstrow clear
drop if 8<=id & id<=14 // Remove individual data for Kanto have been removed.
label data "wide-data for Uzaki-chan SCM"
save "Dataset_SCMuzaki_wide.dta", replace 
	
* Make dataset only Kanto region
keep if id==48
save "Kanto_only.dta", replace

forvalues x=1/`bs' {
	qui:use "Dataset_SCMuzaki_wide.dta", clear
	
	* Make dataset only control pool for resampling
	qui:drop if intv==1
	qui:sample 30, count
	
	* Combine Kanto region and resampling data
	qui:append using "Kanto_only.dta"
	
	sort id
	qui:drop id
	qui:gen id = _n
	
	* Reshape wide -> long
	qui:reshape long n ,i(id) j(month)

	* Labeling
	label define month 0 "2019-02" 1 "2019-03" 2 "2019-04" 3 "2019-05" 4 "2019-06" 5 "2019-07" ///
		6 "2019-08" 7 "2019-09" 8 "2019-10" 9 "2019-11" 10 "2019-12" 11 "2020-01" ///
		12 "2020-02"
	label value month month

	* Preparation for SCM
	qui:tsset id month

/**** ***** ***** ***** ***** ***** *****

STEP 3. Execute SCM analysis

***** ***** ***** ***** ***** ***** ****/
	qui:synth n pop15to64 n(0) n(1) n(2) n(3) n(4) n(5) n(6) n(7) n(8) n(9) n(10) n(11), ///
		trunit(31) trperiod(12)
		
**********
	frame change results
		qui:replace rmspe  =  e(RMSPE)[1,1] in `x'
		qui:replace diff   =  e(Y_treated)[13,1] - e(Y_synthetic)[13,1] in `x'
		forvalues m=0/12 {
			qui:replace n`m' = e(Y_synthetic)[`m'+1,1] in `x'
		}
	frame change default
**********
	di "Loop `x' completed."
}
/**** ***** ***** ***** ***** ***** *****

STEP 4. Calculate percentile of ATT

***** ***** ***** ***** ***** ***** ****/

frame change results
gen diff_p = diff/`pop'
gen ratio = diff/rmspe
save "bs_results.dta", replace

centile diff rmspe ratio n*, centile(2.5 50 97.5)
