# uzaki_bd_campaign
Analysis of the impact of the manga titled "Uzaki-chan Wants to Hang Out!" blood donation campaign on the number of blood donors in Japan, Feb 2020.

## Dataset.
Dataset_SCMuzaki.xls
There are two sheets in this file; the "Stata" sheet contains the data. The Stata-do and Jupyter Notebook files read this sheet for analysis. the "Codebook_Stata" sheet shows the meaning of each variable. This sheet is not used for analysis.

Original data from...
Number of blood donors by prefecture : http://www.jrc.or.jp/activity/blood/data/
Population age 15 to 64 by prefecture: https://www.stat.go.jp/data/nihon/zuhyou/n200200600.xlsx


## Stata-do files.
There are three Stata-do files. The codes are written in Stata 16.
### uzaki_SCM.do
The code to analyze the data using Synthetic Control Method (SCM).
### uzaki_SCM_IPPE.do
The code to calculate In-Place Placebo Effect (IPPE).
### uzaki_SCM_bootstrap.do
The code to do 1,000 bootstrap resamplings and calculate 1,000 ATTs.  And calculates the 2.5, 50, and 97.5 percentile of the calculated 1,000 ATTs.

## Jupyter Notebook files
There are two Jupyter Notebook files. The code is written in Python 3.6.
### uzaki_SCM_wreg.ipynb
The code to execute Synthetic Control Method (SCM) by calculating the weights using regression weight.
### uzaki_SCM_wreg_resampling.ipynb
The code to do 1,000 bootstrap resampling and calculate 1,000 ATTs by SCM using regression weight. And calculate the 2.5, 50 and 97.5 percentile of the 1000 ATTs.
