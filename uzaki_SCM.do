* Preparation
cls
capture mkdir resultstore

* Read dataset
// Orignal data from ...
// Number of blood donors by prefecture : http://www.jrc.or.jp/activity/blood/data/
// Population age 15 to 64 by prefecture : https://www.stat.go.jp/data/nihon/zuhyou/n200200600.xlsx
import excel using "Dataset_SCMuzaki.xls", sheet("Stata") firstrow clear
drop if 8<=id & id<=14 // Remove individual data for Kanto have been removed.
label data "wide-data for Uzaki-chan SCM"
save "Dataset_SCMuzaki_wide.dta", replace 

* Reshape wide -> long
reshape long n ,i(id) j(month)

* Labeling
label define month 0 "2019-02" 1 "2019-03" 2 "2019-04" 3 "2019-05" 4 "2019-06" 5 "2019-07" ///
	6 "2019-08" 7 "2019-09" 8 "2019-10" 9 "2019-11" 10 "2019-12" 11 "2020-01" ///
	12 "2020-02"
label value month month

* Preparation for Synthetic Control Methos (SCM)
tsset id month

* calculation of Average Treatment effect on Treated (ATT) by SCM
synth n pop15to64 n(0) n(1) n(2) n(3) n(4) n(5) n(6) n(7) n(8) n(9) n(10) n(11), ///
	trunit(48) trperiod(12) fig keep(./resultstore/result_SCM) replace
di "RMSPE =", e(RMSPE)[1,1]
di "ATT =", e(Y_treated)[13,1] - e(Y_synthetic)[13,1]
di "ratio = " (e(Y_treated)[13,1] - e(Y_synthetic)[13,1])/(e(RMSPE)[1,1])

/* results 
RMSPE= 120.15764
ATT= 296.17343
*/
