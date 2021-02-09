*global directory "/Users/conor/Documents/PUBPOL529/data"
global directory "\\netid.washington.edu\csde\other\desktop\cfhenn\Desktop\merit_aid_project\data"

***description

use "$directory/pre_treatment.dta", clear
drop if cmn_sprt == .
drop if year != 1990

local pt_characteristics state_mean_edscor90_1990 state_pct_anycollege1990 state_pct_immigrants1990 state_pct_in_labforce1990 state_pct_ntv_wkr_retain1990 state_pct_skilled_jobs1990 state_pct_unemployed1990 state_pct_working_age1990 state_median_income1990 dgov1990

//test each pre-treatment characteristic for differences between treated and untreated states, in the common support region ONLY
foreach v of local pt_characteristics{
	regress trmt_states_all `v', cluster(statefip)
	regsave `v' using "$directory/prmatched_heckman_hotz_`v'.dta", pval replace
}

//merge all regression results into one file
use "$directory/prmatched_heckman_hotz_state_mean_edscor90_1990.dta", clear
foreach v of local pt_characteristics{
	append using "$directory/prmatched_heckman_hotz_`v'.dta"
	rm "$directory/prmatched_heckman_hotz_`v'.dta"
}
drop if _n == 1
save "$directory/prmatched_heckman_hotz.dta", replace
