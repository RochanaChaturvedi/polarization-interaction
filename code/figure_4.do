global path = ".."

clear all

import delimited "$path\data\gcs_avg_tweet_len_user-day.csv", clear 

local bin 40
gen int bowbin = bowgcs*`bin'
replace bowbin = `bin' - 1 if bowgcs==1
gen int gcsbin = (gcs-.432532)/(.5791375-.432532)*`bin'
replace gcsbin = `bin' - 1 if gcs==.5791375

egen meangcslen = mean(tweet_length), by(gcsbin muslim)
egen meanbowgcslen = mean(tweet_length), by(bowbin muslim)

egen meangcs = mean(gcs), by(gcsbin muslim)
egen meanbowgcs = mean(bowgcs), by(bowbin muslim)

bysort gcsbin muslim: gen snogcs = _n
bysort bowbin muslim: gen snobowgcs = _n

twoway (connected  meangcslen meangcs if snogcs==1 & muslim==1, sort lpattern(dash)) (connected meangcslen meangcs if snogcs==1 & muslim==0, sort lpattern(dash)), ylabel(0(5)45) yscale(range(0 46)) legend(order(1 "Muslim" 2 "non-Muslim") ring(1) pos(6) row(1)) xtitle("Contextualized-GCS", size(*.8) ) ytitle("Tweet Length", size(*.8) )

graph export "$path\output\tweet_length_gcs.png", as(png) name("Graph") replace

twoway (connected meanbowgcslen meanbowgcs if snobowgcs==1 & muslim==1 & meanbowgcs!=., sort lpattern(dash)) (connected meanbowgcslen meanbowgcs if snobowgcs==1 & muslim==0 & meanbowgcs!=., sort lpattern(dash)), ylabel(0(5)45) yscale(range(0 46)) legend(order(1 "Muslim" 2 "non-Muslim") ring(1) pos(6) row(1)) xtitle("BOW-GCS", size(*.8) ) ytitle("Tweet Length", size(*.8) )

graph export "$path\output\tweet_length_bowgcs.png", as(png) name("Graph") replace