global directory "\\netid.washington.edu\csde\other\desktop\cfhenn\Desktop\merit_aid_project\data"
*global directory "/Users/conor/Documents/PUBPOL529/data"

//effect heterogeneity by years since treatment began

use "$directory/regression_input.dta", clear
keep if age > 23 & age < 31

generate strong_policy_variable = trmt_states_strong*treatment_time
generate weak_policy_variable   = trmt_states_weak*treatment_time

generate modifier_variable_4  = (year - year_begin) > 15
generate modifier_variable_3  = (year - year_begin) > 10 & !modifier_variable_4
generate modifier_variable_2  = (year - year_begin) > 5  & !modifier_variable_4 & !modifier_variable_3
generate modifier_variable_1  = (year - year_begin) >= 0 & !modifier_variable_4 & !modifier_variable_3 & !modifier_variable_2
recode   modifier_variable* (.=0) 

generate strong_pol_mod_1 = strong_policy_variable * modifier_variable_1
generate strong_pol_mod_2 = strong_policy_variable * modifier_variable_2
generate strong_pol_mod_3 = strong_policy_variable * modifier_variable_3
generate strong_pol_mod_4 = strong_policy_variable * modifier_variable_4


generate weak_pol_mod_1   = weak_policy_variable   * modifier_variable_1
generate weak_pol_mod_2   = weak_policy_variable   * modifier_variable_2
generate weak_pol_mod_3   = weak_policy_variable   * modifier_variable_3
generate weak_pol_mod_4   = weak_policy_variable   * modifier_variable_4

//50 state regressions
regress edscor90 strong_policy_variable weak_policy_variable modifier* strong_pol_mod* weak_pol_mod* i.statefip i.year  [pweight=perwt], cluster(statefip) 
regsave using "$directory/efect_htgty_reg_50.dta", pval replace


//pmatched regression
drop if cmn_sprt != 1
regress edscor90 strong_policy_variable weak_policy_variable modifier* strong_pol_mod* weak_pol_mod* i.statefip i.year  [pweight=perwt], cluster(statefip) 
regsave using "$directory/efect_htgty_reg_pmatched.dta", pval replace

