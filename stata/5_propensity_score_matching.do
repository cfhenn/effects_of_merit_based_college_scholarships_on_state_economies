*global directory "/Users/conor/Documents/PUBPOL529/data"
global directory "\\netid.washington.edu\csde\other\desktop\cfhenn\Desktop\merit_aid_project\data"

use "$directory/pre_treatment.dta", clear
probit trmt_states_all *1990, cluster(statefip) //estimate probability of treatment as a function of state-level factors
predict prob_treat  							//create predicted treatment odds variable
keep statefip state_pct_ntv_wkr_retain1990 prob_treat trmt*
duplicates drop
sort prob_treat
save "$directory/states_w_prop_scores.dta", replace

keep if .5 < prob_treat & prob_treat < 95		//keep those in common support region
gen cmn_sprt = 1								//mark them as common support and merge back into larger file
keep statefip cmn_sprt 
duplicates drop
merge 1:m statefip using "$directory/pre_treatment.dta", nogen
save "$directory/pre_treatment.dta", replace

keep statefip cmn_sprt
duplicates drop
merge 1:m statefip using "$directory/regression_input.dta", keep (3) nogen
save "$directory/regression_input.dta", replace
