global path = ".."

import delimited "$path\data\username_subsample_muslimscore.csv", clear 

prtab muslim muslim_score, threshold fscore xlabel(-3(.2)3) nograph
roctab muslim muslim_score, detail

matrix define C = r(detail)
svmat2 double C
gen cutpoint = r(cutpoints)

ren C2 sensitivity
ren C3 specificity
ren C4 correct

tostring C1, replace
replace C1 = C1 +":"

gen y = subinstr( cutpoint, C1,"S",.)
split y, parse("S")
drop y1 y3-y91
replace y2 = subinstr(y2, "( >= ","",.)
split y2, parse(" )")
drop y22-y2798

replace y21 = subinstr(y21,"( >","",.)

drop C1 C5 C6 cutpoint y y2
ren y21 cutpoint

gen youden = sensitivity + specificity - 100
gen gmean = (sensitivity*specificity)^.5

forvalues i = 1/20 {
gen muslim_pred = muslim_score>0.05
drop muslim_pred	
}

label variable youden "Youden Index"
label variable gmean "Geometric Mean"
label variable sensitivity "Sensitivity"
label variable specificity "Specificity"

destring cutpoint,replace

graph twoway (line sensitivity cut) (line specificity cut) (line gmean cut) (line youden cut), xlabel(-3(.5)3) xline(0.3, lwidth(*2)) xtitle("SVM Confidence Score Threshold", size(*.9)) xmlabel(0.3, noticks labsize(*1.6) labcolor(red)) ytitle("Score (%)", size(*.9)) legend(pos(6) ring(1) row(1))

graph export "$path\output\prediction_threshold.png", as(png) name("Graph") replace
