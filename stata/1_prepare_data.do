********************************************************************************
* This program merges person-level data from the American Community Survey and
* the census with data on state politics, industry productivity, and merit -
* based financial aid policies
********************************************************************************
*global directory "/Users/conor/Documents/PUBPOL529/data"
global directory "\\netid.washington.edu\csde\other\desktop\cfhenn\Desktop\merit_aid_project\data"

use "$directory/usa_0020.dta", clear
decode statefip, generate(statename)
generate three_dig_indnaics = substr(indnaics, 1, 3)
drop if year < 1990
save "$directory/regression_input.dta", replace

*merge ACS/Census data with data on the party of the governor of each state in 1990 (used for propensity score matching)
*Data available at: https://www.openicpsr.org/openicpsr/project/102000/version/V2/view;jsessionid=8E1D68CADF9A30F98D313AD0F4553E70?path=/openicpsr/102000/fcr:versions/V2/united_states_governors_1775_2020.csv&type=file
import delimited "$directory/united_states_governors_1775_2020.csv", clear
drop if year != 1990
generate dgov1990 = party == "Democrat"
rename state statename
collapse (max) dgov1990, by(statename)
recode dgov1990 (.=0)
merge 1:m statename using "$directory/regression_input.dta", keep (2 3) nogen
replace edscor90 = . if edscor90 == 999.9
drop if statefip > 56
save "$directory/regression_input.dta", replace

*merge in data on which states adopted policies, and the extend of the polices
*data available in Sjoquist and Winters (2015)
import delimited "$directory/policy_data.csv", clear
drop *placeholder
rename avg_spending_per_student_2010 avg_spend_per_stud
rename share_of_students_funded_2010 share_funded
merge 1:m statefip using "$directory/regression_input.dta", nogen
recode avg_spend_per_stud share_funded (.=0)

*generate outcome variables
generate skilled_job 		= edscor90 > 50
generate works_in_homestate = bpl == pwstate2 & bpl != . & pwstate2 != . & pwstate2 != 0
generate treatment_time 	= (year_begin - 17 <  birthyr)

*generate treatment variables
generate trmt_states_strong = avg_spend_per_stud > 300
generate trmt_states_all 	= avg_spend_per_stud > 0
generate trmt_states_weak 	= trmt_states_all == 1 & trmt_states_strong == 0

*generate control variables
generate white	= race == 1 & hispan == 0
generate latino = hispan > 0
generate black  = race == 2
generate native	= race == 3
generate asian 	= race == 4 | race == 5 | race == 6
generate oth_rc = race > 6
generate female = sex == 2

save "$directory/regression_input.dta", replace
