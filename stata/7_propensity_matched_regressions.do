global directory "\\netid.washington.edu\csde\other\desktop\cfhenn\Desktop\merit_aid_project\data"

use "$directory/regression_input.dta", clear
drop if cmn_sprt != 1 //drop  states that are not part of the common support group
keep if age > 23 & age < 31

local outcome_variables skilled_job works_in_homestate edscor90

local controls_1 black latino native asian oth_rc female age
local controls_2 

	
generate treated_strong = trmt_states_strong*treatment_time
generate treated_weak = trmt_states_weak*treatment_time

//conduct diff in diff regressions for each outcome variable, with and without demographic controls
forvalues i = 1(1)2{
	preserve
	tempname propmatched_results_`i'
	postfile `propmatched_results_`i'' str20 outcome treatment_coeff stnd_err weaktreat_coeff wt_stnd_err degrees_of_freedom using "$directory/propmatched_results_`i'.dta", replace
	foreach ov of local outcome_variables {
		xi: regress `ov' treated_strong treated_weak i.statefip i.year `controls_`i'' [pweight=perwt], cluster(statefip)
		post `propmatched_results_`i'' ("`ov'") (`=_b[treated_strong]') (`=_se[treated_strong]') (`=_b[treated_weak]') (`=_se[treated_weak]') (`e(df_r)')
	}
	postclose `propmatched_results_`i''

	//create p values for saved regression coefficients
	use "$directory/propmatched_results_`i'.dta", clear
	generate t = treatment_coeff/stnd_err
	generate p = 2*ttail(degrees_of_freedom, abs(t))
	generate wt = weaktreat_coeff/wt_stnd_err
	generate wp = 2*ttail(degrees_of_freedom, abs(wt))
	drop t wt degrees_of_freedom
	save "$directory/propmatched_results_`i'.dta", replace
	restore
}

