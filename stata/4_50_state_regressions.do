global directory "\\netid.washington.edu\csde\other\desktop\cfhenn\Desktop\merit_aid_project\data"

use "$directory/regression_input.dta", clear
keep if age > 23 & age < 31
generate treat_weak = 0 //this variable only needed for the regression that used strong/weak treatment dummy variables
replace avg_spend_per_stud = ln(avg_spend_per_stud) //use log of spending

local outcome_variables skilled_job works_in_homestate edscor90
local treatment_vars share_funded avg_spend_per_stud trmt_states_strong
local controls_1 black latino native asian oth_rc female
local controls_2 

//regress each of the outcome variables on a time*treatment variable (use three different forms of treatment variable), state and time fixed effects - use additional controls once for each outcome/treatment combo
forvalues i = 1(1)2{
	foreach tv of local treatment_vars{
		preserve
		replace treat_weak = trmt_states_weak*treatment_time if "`tv'" == "trmt_states_strong" 	
		generate treatment_var = `tv'*treatment_time // turn people in treatment states in pre-treatment period into untreated
	
		tempname `tv'_results_`i'
		postfile ``tv'_results_`i'' str20 outcome treatment_coeff stnd_err weaktreat_coeff wt_stnd_err degrees_of_freedom using "$directory/`tv'_results_`i'.dta", replace
		foreach ov of local outcome_variables {
			xi: regress `ov' treatment_var treat_weak i.statefip i.year `controls_`i'' [pweight=perwt], cluster(statefip) 
			post ``tv'_results_`i'' ("`ov'") (`=_b[treatment_var]') (`=_se[treatment_var]') (`=_b[treat_weak]') (`=_se[treat_weak]') (`e(df_r)')
		}
		postclose ``tv'_results_`i''

		//generate p-values for saved file
		use "$directory/`tv'_results_`i'.dta", clear
		gen t = treatment_coeff/stnd_err
		gen p = 2*ttail(degrees_of_freedom, abs(t))
		gen wt = weaktreat_coeff/wt_stnd_err
		gen wp = 2*ttail(degrees_of_freedom, abs(wt))
		drop t wt degrees_of_freedom
		save "$directory/`tv'_results_`i'.dta", replace
	
		restore
	}
}	
	
