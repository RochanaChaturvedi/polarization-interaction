global path = ".."

clear all

import delimited "$path\data\7_lasso_7_merged\stx_long.csv", clear 

replace event = "a) Janata Curfew" if event =="juntaCurfew"
replace event = "b) Tablighi" if event =="tabliqi"
replace event = "c) Migrant Deaths" if event =="migrantraildeath"
replace event = "d) Coronil Launch" if event =="Coronil"
replace event = "e) Exam Satyagraha" if event =="exam"
replace event = "f) GDP Contraction" if event =="gdpcontracts"
replace event = "g) Bihar Manifesto" if event =="BiharManifesto"

encode event, gen(event_num)
encode learner, gen(learner_num)

label variable te_topic_0_diff "COVID Response"
label variable te_topic_1_diff "Politics-Religion"
label variable te_topic_2_diff "China & Global"
label variable te_topic_3_diff "Socio-Economic"

label variable te_valence_intensity_diff "Valence"
label variable te_anger_intensity_diff "Anger"
label variable te_fear_intensity_diff "Fear"
label variable te_sadness_intensity_diff "Sadness"
label variable te_joy_intensity_diff "Joy"

label variable gcs "GCS"
label variable topic_0 "Covid Response"
label variable topic_1 "Politics-Religion"
label variable topic_2 "China & Global"
label variable topic_3 "Socio-Economic"
label variable valence_intensity "Valence"
label variable fear_intensity "Fear"
label variable sadness_intensity "Sadness"
label variable joy_intensity "Joy"
label variable anger_intensity "Anger"
label variable user_followers_count "Followers"
label variable user_friends_count "Friends"
label variable retweet_count "Retweets"
label variable reply "Reply Fraction"
label variable tweet_frequency "Tweets"
label variable user_created_at "Account Days"

**********
*Coefplot*
**********
forvalues i=1/7 {
reg te_gcs_diff muslim_score gcs topic_0 topic_1 topic_2 topic_3 valence_intensity fear_intensity sadness_intensity joy_intensity anger_intensity user_friends_count user_followers_count retweet_count reply tweet_frequency user_created_at if learner_num==2 & event_num==`i', vce(hc3)
estimates store event`i'
}

coefplot event1 event2 event3 event4 event5 event6 event7, noci drop(_cons muslim_score) bycoef legend(order(1 "Janata Curfew" 2 "Tablighi" 3 "Migrant Deaths" 4 "Coronil Launch" 5 "Exam Satyagraha" 6 "GDP Contraction" 7 "Bihar Manifesto") row(1)) omitted ylabel("")

graph export "$path\output\te_coefplot.png", as(png) name("Graph") replace

*****************
*Plotting Graphs*
*****************
graph twoway (kdensity te_gcs_diff if muslim==0 & learner=="Tcate", recast(area) color(blue%50) lcolor(black)) (kdensity te_gcs_diff if muslim==1 & learner=="Tcate", recast(area) color(red%30) lcolor(black)), graphregion(color(white)) ytitle("Density", size(*.8)) yscale(titlegap(*5)) ylabel(0(1)3, glcolor(gs15) glpattern(shortdash) labsize(*.8)) xlabel(-1(.2)1, labsize(*.8)) xtitle("Treatment Effect", size(*.8)) xscale(titlegap(*5)) legend(ring(0) pos(2) row(1) order(2 "Muslim" 1 "non-Muslim")) by(event, note("") holes(7) ixaxes iyaxes iytick ixtick ixlabel iylabel)

graph export "$path\output\events_muslim_non_muslim_threshold.png", as(png) name("Graph") replace

foreach var of varlist te_valence_intensity_diff te_anger_intensity_diff te_fear_intensity_diff te_sadness_intensity_diff te_joy_intensity_diff te_topic_0_diff te_topic_1_diff te_topic_2_diff te_topic_3_diff {
graph twoway (kdensity `var' if muslim==0 & learner=="Tcate", recast(area) color(blue%50) lcolor(black)) (kdensity `var' if muslim==1 & learner=="Tcate", recast(area) color(red%30) lcolor(black)), graphregion(color(white)) ytitle("Density", size(*.8)) yscale(titlegap(*5)) ylabel(0(2)6, glcolor(gs15) glpattern(shortdash) labsize(*.8)) xlabel(-.6(.2).6, labsize(*.8)) xtitle("Treatment Effect", size(*.8)) xscale(titlegap(*5)) legend(ring(0) pos(2) row(1) order(2 "Muslim" 1 "non-Muslim")) by(event, note("") holes(7) ixaxes iyaxes iytick ixtick ixlabel iylabel)

graph export "$path\output\events_muslim_non_muslim`var'.png", as(png) name("Graph") replace
}

**********************************************
*Testing if means are significantly different*
**********************************************
cls
forvalues i=1/7 {
tab event_num if event_num==`i'
reg te_gcs_diff muslim if learner_num==2 & event_num==`i', vce(bootstrap)
lincom _cons + muslim
}

forvalues i=1/7 {
tab event_num if event_num==`i'
reg te_gcs_diff if learner_num==2 & event_num==`i', vce(bootstrap)
}

******************************
*Oaxaca-Blinder decomposition*
******************************
preserve
clear
save "$path\output\event_coef.dta", emptyok replace
restore

log using "$path\output\log_decomposition.smcl", replace

forvalues i = 1/7 {
matrix drop _all

oaxaca te_gcs_diff te_valence_intensity_diff te_anger_intensity_diff te_fear_intensity_diff te_sadness_intensity_diff te_joy_intensity_diff te_topic_0_diff te_topic_1_diff te_topic_2_diff te_topic_3_diff if event_num==`i' & learner_num==2, by(muslim) swap detail pooled vce(bootstrap)

matrix tb=r(table)
matrix betas=nullmat(betas)\[`i',tb["b",.]]
matrix ll=nullmat(ll)\[tb["ll",.]]
matrix ul=nullmat(ul)\[tb["ul",.]]

lbsvmat betas, matname name(b)
lbsvmat ll, matname name(ll)
lbsvmat ul, matname name(ul)
ren *, low

preserve
keep b_c1- ul_unexplained__cons
gen event = `i'
drop if b_c1==.
append using "$path\output\event_coef.dta"
save "$path\output\event_coef.dta", replace
restore

drop b_c1- ul_unexplained__cons

}

log close

use "$path\output\event_coef.dta", clear

label define eventname 1 "Janata`=char(13)'`=char(10)'Curfew" 2 "Tablighi" 3 "Migrant`=char(13)'`=char(10)'Deaths" 4 "Coronil`=char(13)'`=char(10)'Launch" 5 "Exam`=char(13)'`=char(10)'Satyagraha" 6 "GDP`=char(13)'`=char(10)'Contraction" 7 "Bihar`=char(13)'`=char(10)'Manifesto"
label values event eventname

*Overall Effect
local w = 0.3
gen eventu = event + `w'
gen eventl = event - `w'


twoway (bar b_overall_explained event, barw(`w') xlabel(1(1)7,valuelabel noticks nogrid labsize(*1.2))) (bar b_overall_difference eventl, barw(`w')) (bar b_overall_unexplained eventu, barw(`w')) (rcap ll_overall_difference ul_overall_difference eventl, lcolor(gs8)) (rcap ll_overall_explained ul_overall_explained event, lcolor(gs8)) (rcap ll_overall_unexplained ul_overall_unexplained eventu, lcolor(gs8)), legend(size(*1.2) order(2 "Difference" 1 "Explained" 3 "Unexplained") pos(6) ring(1) row(1)) xline(1.5 2.5 3.5 4.5 5.5 6.5, lpattern(dot)) ylabel(,labsize(*1.2))  xsc(outergap(5))

drop eventu eventl

graph export "$path\output\aggregate.png", as(png) name("Graph") replace

*Composition effect
local w = 0.1
gen eventu = event + `w'
gen eventl = event - `w'
gen eventu2 = event + 2*`w'
gen eventl2 = event - 2*`w'
gen eventu3 = event + 3*`w'
gen eventl3 = event - 3*`w'
gen eventu4 = event + 4*`w'
gen eventl4 = event - 4*`w'

label drop eventname
label define eventname 1 "Janata Curfew" 2 "Tablighi" 3 "Migrant Deaths" 4 "Coronil Launch" 5 "Exam Satyagraha" 6 "GDP Contraction" 7 "Bihar Manifesto"
label values event eventname

twoway (bar b_11 event, barw(`w') xlabel(1(1)7,valuelabel noticks nogrid labsize(*.9))) (bar b_7 eventl4, barw(`w')) (bar b_8 eventl3, barw(`w')) (bar b_9 eventl2, barw(`w')) (bar b_10 eventl, barw(`w')) (bar b_explained_te_topic_0_diff eventu, barw(`w')) (bar b_explained_te_topic_1_diff eventu2, barw(`w')) (bar b_explained_te_topic_2_diff eventu3, barw(`w')) (bar b_explained_te_topic_3_diff eventu4, barw(`w')) ///
(rcap ll_6 ul_6 eventl4, lcolor(gs8)) (rcap ll_7 ul_7 eventl3, lcolor(gs8)) (rcap ll_8 ul_8 eventl2, lcolor(gs8)) (rcap ll_9 ul_9 eventl, lcolor(gs8)) (rcap ll_10 ul_10 event, lcolor(gs8)) (rcap ll_explained_te_topic_0_diff ul_explained_te_topic_0_diff eventu, lcolor(gs8)) (rcap ll_explained_te_topic_1_diff ul_explained_te_topic_1_diff eventu2, lcolor(gs8)) (rcap ll_explained_te_topic_2_diff ul_explained_te_topic_2_diff eventu3, lcolor(gs8)) (rcap ll_explained_te_topic_3_diff ul_explained_te_topic_3_diff eventu4, lcolor(gs8)) ///
, legend(order(2 "Valence" 3 "Anger" 4 "Fear" 5 "Sadness" 1 "Joy" 6 "COVID Response" 7 "Politics-Religion" 8 "China & Global" 9 "Socio-Economic") pos(6) ring(1) row(2)) xline(1.5 2.5 3.5 4.5 5.5 6.5, lpattern(dot))

drop eventu* eventl*

graph export "$path\output\composition.png", as(png) name("Graph") replace