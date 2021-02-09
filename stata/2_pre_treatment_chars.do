*global directory "/Users/conor/Documents/PUBPOL529/data"
global directory "\\netid.washington.edu\csde\other\desktop\cfhenn\Desktop\merit_aid_project\data"


use "$directory/regression_input.dta", clear 
//compare states on pre-treatment characteristics
drop if year != 1990
save "$directory/pre_treatment.dta", replace

//generate explanatory variables


//pct born in state becoming workers in state
generate state_pct_ntv_wkr_retain1990 = pwstate2 == bpl
collapse (mean) state_pct_ntv_wkr_retain1990 [pweight=perwt], by (bpl)
rename bpl statefip
merge 1:m statefip using "$directory/pre_treatment.dta", nogen
drop if statefip > 56
save "$directory/pre_treatment.dta", replace

//job education level
generate state_pct_skilled_jobs1990 = edscor90 > 50
collapse(mean) state_pct_skilled_jobs1990 [pweight=perwt], by(statefip)
merge 1:m statefip using "$directory/pre_treatment.dta", nogen
save "$directory/pre_treatment.dta", replace

//avg edscor90 
generate state_mean_edscor90_1990 = edscor90
collapse(mean) state_mean_edscor90 [pweight=perwt], by(statefip)
merge 1:m statefip using "$directory/pre_treatment.dta", nogen
save "$directory/pre_treatment.dta", replace

//pct any college
generate state_pct_anycollege1990 = educd > 70
collapse(mean) state_pct_anycollege1990 [pweight=perwt], by(statefip)
merge 1:m statefip using "$directory/pre_treatment.dta", nogen
save "$directory/pre_treatment.dta", replace

//median income
collapse(median) incearn [pweight=perwt], by(statefip)
rename incearn state_median_income1990
merge 1:m statefip using "$directory/pre_treatment.dta", nogen
save "$directory/pre_treatment.dta", replace

//age
generate state_pct_working_age1990 = age >= 25 & age <= 65
collapse(mean) state_pct_working_age1990 [pweight=perwt], by(statefip)
merge 1:m statefip using "$directory/pre_treatment.dta", nogen
save "$directory/pre_treatment.dta", replace

//unemployment
generate state_pct_unemployed1990 = empstat ==2
collapse(mean) state_pct_unemployed1990 [pweight=perwt], by(statefip)
merge 1:m statefip using "$directory/pre_treatment.dta", nogen
save "$directory/pre_treatment.dta", replace

//labor force participation
generate state_pct_in_labforce1990 = labforce == 2
collapse(mean) state_pct_in_labforce1990 [pweight=perwt], by(statefip)
merge 1:m statefip using "$directory/pre_treatment.dta", nogen
save "$directory/pre_treatment.dta", replace

//pct immigrants
generate state_pct_immigrants1990 = citizen > 0 & pwstate2 > 0
collapse(mean) state_pct_immigrants1990 [pweight=perwt], by(statefip)
merge 1:m statefip using "$directory/pre_treatment.dta", nogen
save "$directory/pre_treatment.dta", replace 


collapse (mean) *1990, by (statefip)
merge 1:m statefip using "$directory/regression_input.dta", nogen
save "$directory/regression_input.dta", replace

