********************************************************************************
* Conor Hennessy
* PUBPOL 529
* Effects of Statewide Merit-Based Financial Aid Programs on Job Characteristics
********************************************************************************
global stata_code "\\netid.washington.edu\csde\other\desktop\cfhenn\Desktop\merit_aid_project\stata"

log using "$stata_code\logfile", replace
do "$stata_code/1_prepare_data.do"
do "$stata_code/2_pre_treatment_chars.do"
do "$stata_code/3_initial_heckman_hotz.do"
do "$stata_code/4_50_state_regressions.do"
do "$stata_code/5_propensity_score_matching.do"
do "$stata_code/6_propensity_matched_heckman_hotz.do" 
do "$stata_code/7_propensity_matched_regressions.do"
do "$stata_code/8_effect_heterogeneity_regression.do"
do "$stata_code/9_event_study.do"

log close
