global directory "\\netid.washington.edu\csde\other\desktop\cfhenn\Desktop\merit_aid_project\data"
*global directory "/Users/conor/Documents/PUBPOL529/data"
use "$directory/regression_input.dta", clear
keep if age > 23 & age < 31

//generate variables indicating the amount of time to and from the beginning of treatment
generate within_year_of_treatment = abs(year_begin - year) < 2 //ommitted category
generate over_tenyrs_until_trmt  = ((year_begin - year) > 10)*trmt_states_all
generate over_fivyrs_until_trmt  = ((year_begin - year) > 5 & !over_tenyrs_until_trmt)*trmt_states_all
generate undr_fivyrs_until_trmt  = ((year_begin - year) > 1 & !over_tenyrs_until_trmt & !over_fivyrs_until_trmt)*trmt_states_all

generate over_tenyrs_since_trmt  = ((year - year_begin) > 10)*trmt_states_all
generate over_fivyrs_since_trmt  = ((year - year_begin) > 5 & !over_tenyrs_since_trmt)*trmt_states_all
generate undr_fivyrs_since_trmt  = ((year - year_begin) > 1 & !over_tenyrs_since_trmt & !over_fivyrs_since_trmt)*trmt_states_all

recode *until_trmt *since_trmt (.=0) if year_begin == 0

generate trmt_weak = trmt_states_weak*treatment_time

//regress outcome on the variables that indicate time to/from treatment with the controls used in other regressions
regress edscor90 *until_trmt *since_trmt trmt_states_weak i.statefip i.year black latino native asian oth_rc female [pweight=perwt], cluster(statefip) 
regsave using "$directory/event_study_50_states.dta", pval replace
use "$directory/event_study_50_states.dta", clear

//cannot plot results against string variable list (that I know of), so I made this variable to stand in for the list of times to/from treatment
drop if _n>6
generate x_var = .
replace x_var = -10 if _n == 1
replace x_var = -5  if _n == 2
replace x_var = -1  if _n == 3
replace x_var = 1 	 if _n == 4
replace x_var = 5   if _n == 5
replace x_var = 10  if _n == 6

//plot results over time
serrbar coef stderr x_var, xtitle(At Least # Years Since Program  Begin) ytitle(Regression Coefficent) title(Event Study)


