cd "C:\Users\melyg\Desktop\Malawi"



***Append out of sample and 10,15, 20% training samples.
foreach x in 10 15 20 {
use "Census\Updated results\full_sample_pred\pred_xgboos_full_ubr_`x'_outs.dta", clear
destring  predcons_census_full predwelf_census_full predcons_census_ubr predwelf_census_ubr, replace
rename V5 district
*drop V5 V3
save "Census\Updated results\full_sample_pred\pred_xgboos_full_ubr_`x'_n.dta", replace
}


foreach x in 10 15 20 {
use "Census\Updated results\full_sample_pred\pred_xgboos_full_ubr_`x'_n.dta", clear

spearman  predcons_census_full predwelf_census_full
local rhof_`x'=r(rho)
local pf_`x'=r(p)
local Nf_`x'=r(N)

spearman  predcons_census_ubr predwelf_census_ubr
local rhou_`x'=r(rho)
local pu_`x'=r(p)
local Nu_`x'=r(N)
g test=1

putexcel set "Census\Updated results\full_sample_pred\AUC_`x'_fullubr.xlsx", replace

forvalues i=1(1)99 {
egen rtrue_full`x'`i' = pctile(predcons_census_full), /*by(district)*/ p(`i') 
g ranktrue_full`x'_`i'=(predcons_census_full<rtrue_full`x'`i')
egen rtrue_ubr`x'`i' = pctile(predcons_census_ubr), /*by(district)*/ p(`i') 
g ranktrue_ubr`x'_`i'=(predcons_census_ubr<rtrue_ubr`x'`i')

egen rpred_full`x'`i' = pctile(predwelf_census_full), /*by(district)*/ p(`i') 
egen rpred_ubr`x'`i' = pctile(predwelf_census_ubr), /*by(district)*/ p(`i') 

g rankpred_full`x'_`i'=(predwelf_census_full<rtrue_full`x'`i')
g rankpred_ubr`x'_`i'=(predwelf_census_ubr<rtrue_ubr`x'`i')

g rankpred2_full`x'_`i'=(predwelf_census_full<rpred_full`x'`i')
g rankpred2_ubr`x'_`i'=(predwelf_census_ubr<rpred_ubr`x'`i')


sum test if rankpred_full`x'_`i'==1 & ranktrue_full`x'_`i'==0 //false positive rate
return list
local FPf1`x'`i'=r(N)
sum test if rankpred_full`x'_`i'==1 & ranktrue_full`x'_`i'==1 //true postive rate
return list
local TPf1`x'`i'=r(N)
sum test if rankpred2_full`x'_`i'==1 & ranktrue_full`x'_`i'==0 //false positive rate
return list
local FP2f1`x'`i'=r(N)
sum test if rankpred2_full`x'_`i'==1 & ranktrue_full`x'_`i'==1 //true postive rate
return list
local TP2f1`x'`i'=r(N)
sum test if ranktrue_full`x'_`i'==1 //total poor
return list
local Pf1`x'`i'=r(N)
sum test if ranktrue_full`x'_`i'==0 //total non-poor
return list
local NPf1`x'`i'=r(N)

sum test if rankpred_ubr`x'_`i'==1 & ranktrue_ubr`x'_`i'==0 //false positive rate
return list
local FPf2`x'`i'=r(N)
sum test if rankpred_ubr`x'_`i'==1 & ranktrue_ubr`x'_`i'==1 //true postive rate
return list
local TPf2`x'`i'=r(N)
sum test if rankpred2_ubr`x'_`i'==1 & ranktrue_ubr`x'_`i'==0 //false positive rate
return list
local FP2f2`x'`i'=r(N)
sum test if rankpred2_ubr`x'_`i'==1 & ranktrue_ubr`x'_`i'==1 //true postive rate
return list
local TP2f2`x'`i'=r(N)
sum test if ranktrue_ubr`x'_`i'==1 //total poor
return list
local Pf2`x'`i'=r(N)
sum test if ranktrue_ubr`x'_`i'==0 //total non-poor
return list
local NPf2`x'`i'=r(N)
		
putexcel A`i'=`FPf1`x'`i''
putexcel B`i'=`TPf1`x'`i''
putexcel C`i'=`FP2f1`x'`i''
putexcel D`i'=`TP2f1`x'`i''
putexcel E`i'=`Pf1`x'`i''
putexcel F`i'=`NPf1`x'`i''

putexcel G`i'=`FPf2`x'`i''
putexcel H`i'=`TPf2`x'`i''
putexcel I`i'=`FP2f2`x'`i''
putexcel J`i'=`TP2f2`x'`i''
putexcel K`i'=`Pf2`x'`i''
putexcel L`i'=`NPf2`x'`i''
}
}

foreach x in 10 15 20 {
		import excel "Census\Updated results\full_sample_pred\AUC_`x'_fullubr.xlsx", sheet("Sheet1") clear
		g FPR_`x'full=A/F
        g TPR_`x'full=B/E
		g FPR_`x'full2=C/F
        g TPR_`x'full2=D/E
		
		g FPR_`x'ubr=G/L
        g TPR_`x'ubr=H/K
		g FPR_`x'ubr2=I/L
        g TPR_`x'ubr2=J/K				
		export excel using "Census\Updated results\full_sample_pred\AUC_`x'_fullubr.xlsx", replace
	}


*****************************************

foreach x in 10 15 20 {
use "Census\Updated results\full_sample_pred\pred_xgboos_fullxg_ubrxg_`x'_outs.dta", clear
destring  predcons_census_full predwelf_census_full predcons_census_ubr predwelf_census_ubr, replace
rename V5 district
save "Census\Updated results\full_sample_pred\pred_xgboos_fullxg_ubrxg_`x'_n.dta", replace
}

foreach x in 10 15 20 {
use "Census\Updated results\full_sample_pred\pred_xgboos_fullxg_ubrxg_`x'_n.dta", clear
rename predcons_census_full predcons_xgb_full 
rename predcons_census_ubr predcons_xgb_ubr 
rename predwelf_census_full predwelf_xgb_full 
rename predwelf_census_ubr predwelf_xgb_ubr 

spearman  predcons_xgb_full predwelf_xgb_full
local rhofxg_`x'=r(rho)
local pfxg_`x'=r(p)
local Nfxg_`x'=r(N)

spearman  predcons_xgb_ubr predwelf_xgb_ubr
local rhouxg_`x'=r(rho)
local puxg_`x'=r(p)
local Nuxg_`x'=r(N)
g test=1

putexcel set "Census\Updated results\full_sample_pred\AUC_`x'_fullxgubrxg.xlsx", replace

forvalues i=1(1)99 {
egen rtrue_full`x'`i' = pctile(predcons_xgb_full), /*by(district)*/ p(`i') 
egen rtrue_ubr`x'`i' = pctile(predcons_xgb_ubr), /*by(district)*/ p(`i') 
g ranktrue_full`x'_`i'=(predcons_xgb_full<rtrue_full`x'`i')
g ranktrue_ubr`x'_`i'=(predcons_xgb_ubr<rtrue_ubr`x'`i')

egen rpred_full`x'`i' = pctile(predwelf_xgb_full), /*by(district)*/ p(`i') 
egen rpred_ubr`x'`i'=pctile(predwelf_xgb_ubr), /*by(district)*/ p(`i') 

g rankpred_full`x'_`i'=(predwelf_xgb_full<rtrue_full`x'`i')
g rankpred_ubr`x'_`i'=(predwelf_xgb_ubr<rtrue_ubr`x'`i')
g rankpred2_full`x'_`i'=(predwelf_xgb_full<rpred_full`x'`i')
g rankpred2_ubr`x'_`i'=(predwelf_xgb_ubr<rpred_ubr`x'`i')

sum test if rankpred_full`x'_`i'==1 & ranktrue_full`x'_`i'==0 //false positive rate
return list
local FPf1`x'`i'=r(N)
sum test if rankpred_full`x'_`i'==1 & ranktrue_full`x'_`i'==1 //true postive rate
return list
local TPf1`x'`i'=r(N)
sum test if rankpred2_full`x'_`i'==1 & ranktrue_full`x'_`i'==0 //false positive rate
return list
local FP2f1`x'`i'=r(N)
sum test if rankpred2_full`x'_`i'==1 & ranktrue_full`x'_`i'==1 //true postive rate
return list
local TP2f1`x'`i'=r(N)
sum test if ranktrue_full`x'_`i'==1 //total poor
return list
local Pf1`x'`i'=r(N)
sum test if ranktrue_full`x'_`i'==0 //total non-poor
return list
local NPf1`x'`i'=r(N)

sum test if rankpred_ubr`x'_`i'==1 & ranktrue_ubr`x'_`i'==0 //false positive rate
return list
local FPf2`x'`i'=r(N)
sum test if rankpred_ubr`x'_`i'==1 & ranktrue_ubr`x'_`i'==1 //true postive rate
return list
local TPf2`x'`i'=r(N)
sum test if rankpred2_ubr`x'_`i'==1 & ranktrue_ubr`x'_`i'==0 //false positive rate
return list
local FP2f2`x'`i'=r(N)
sum test if rankpred2_ubr`x'_`i'==1 & ranktrue_ubr`x'_`i'==1 //true postive rate
return list
local TP2f2`x'`i'=r(N)
sum test if ranktrue_ubr`x'_`i'==1 //total poor
return list
local Pf2`x'`i'=r(N)
sum test if ranktrue_ubr`x'_`i'==0 //total non-poor
return list
local NPf2`x'`i'=r(N)
		
putexcel A`i'=`FPf1`x'`i''
putexcel B`i'=`TPf1`x'`i''
putexcel C`i'=`FP2f1`x'`i''
putexcel D`i'=`TP2f1`x'`i''
putexcel E`i'=`Pf1`x'`i''
putexcel F`i'=`NPf1`x'`i''

putexcel G`i'=`FPf2`x'`i''
putexcel H`i'=`TPf2`x'`i''
putexcel I`i'=`FP2f2`x'`i''
putexcel J`i'=`TP2f2`x'`i''
putexcel K`i'=`Pf2`x'`i''
putexcel L`i'=`NPf2`x'`i''

}
}

foreach x in 10 15 20 {
		import excel "Census\Updated results\full_sample_pred\AUC_`x'_fullxgubrxg.xlsx", sheet("Sheet1") clear
		g FPR_`x'full=A/F
        g TPR_`x'full=B/E
		g FPR_`x'full2=C/F
        g TPR_`x'full2=D/E
		
		g FPR_`x'ubr=G/L
        g TPR_`x'ubr=H/K
		g FPR_`x'ubr2=I/L
        g TPR_`x'ubr2=J/K				
		export excel using "Census\Updated results\full_sample_pred\AUC_`x'_fullxgubrxg.xlsx", replace
	}



********************************************************************************

foreach x in 10 15 20 {
use "Census\Updated results\full_sample_pred\pred_xgboos_full50_ubr50_`x'_outs.dta", clear
destring  predcons_census_full predwelf_census_full predcons_census_ubr predwelf_census_ubr predcons_xgb_full predcons_xgb_ubr predwelf_xgb_full predwelf_xgb_ubr, replace
rename V9 district
save "Census\Updated results\full_sample_pred\pred_xgboos_full50_ubr50_`x'_n.dta", replace
}

foreach x in 10 15 20 {
use "Census\Updated results\full_sample_pred\pred_xgboos_full50_ubr50_`x'_n.dta", clear
spearman  predcons_census_full predwelf_census_full
local rhof50_`x'=r(rho)
local pf50_`x'=r(p)
local Nf50_`x'=r(N)

spearman  predcons_census_ubr predwelf_census_ubr
local rhou50_`x'=r(rho)
local pu50_`x'=r(p)
local Nu50_`x'=r(N)

spearman  predcons_xgb_full predwelf_xgb_full
local rhofxg50_`x'=r(rho)
local pfxg50_`x'=r(p)
local Nfxg50_`x'=r(N)

spearman  predcons_xgb_ubr predwelf_xgb_ubr
local rhouxg50_`x'=r(rho)
local puxg50_`x'=r(p)
local Nuxg50_`x'=r(N)
g test=1


putexcel set "Census\Updated results\full_sample_pred\AUC_`x'_full50ubr50.xlsx", replace

forvalues i=1(1)99 {

egen rtrue_full`x'`i' = pctile(predcons_census_full), /*by(district)*/ p(`i') 
g ranktrue_full`x'_`i'=(predcons_census_full<rtrue_full`x'`i')
egen rtrue_ubr`x'`i' = pctile(predcons_census_ubr), /*by(district)*/ p(`i') 
g ranktrue_ubr`x'_`i'=(predcons_census_ubr<rtrue_ubr`x'`i')

egen rtrue_fullxg`x'`i' = pctile(predcons_xgb_full), /*by(district)*/ p(`i') 
g ranktrue_fullxg`x'_`i'=(predcons_xgb_full<rtrue_fullxg`x'`i')
egen rtrue_ubrxg`x'`i' = pctile(predcons_xgb_ubr), /*by(district)*/ p(`i') 
g ranktrue_ubrxg`x'_`i'=(predcons_xgb_ubr<rtrue_ubrxg`x'`i')

egen rpred_full`x'`i' = pctile(predwelf_census_full), /*by(district)*/ p(`i') 
egen rpred_ubr`x'`i' = pctile(predwelf_census_ubr), /*by(district)*/ p(`i') 
egen rpred_fullxg`x'`i' = pctile(predwelf_xgb_full), /*by(district)*/ p(`i') 
egen rpred_ubrxg`x'`i' = pctile(predwelf_xgb_ubr), /*by(district)*/ p(`i') 

g rankpred_full`x'_`i'=(predwelf_census_full<rtrue_full`x'`i')
g rankpred_ubr`x'_`i'=(predwelf_census_ubr<rtrue_ubr`x'`i')
g rankpred_fullxg`x'_`i'=(predwelf_xgb_full<rtrue_fullxg`x'`i')
g rankpred_ubrxg`x'_`i'=(predwelf_xgb_ubr<rtrue_ubrxg`x'`i')

g rankpred2_full`x'_`i'=(predwelf_census_full<rpred_full`x'`i')
g rankpred2_ubr`x'_`i'=(predwelf_census_ubr<rpred_ubr`x'`i')
g rankpred2_fullxg`x'_`i'=(predwelf_xgb_full<rpred_fullxg`x'`i')
g rankpred2_ubrxg`x'_`i'=(predwelf_xgb_ubr<rpred_ubrxg`x'`i')

sum test if rankpred_full`x'_`i'==1 & ranktrue_full`x'_`i'==0 //false positive rate
return list
local FPf1`x'`i'=r(N)
sum test if rankpred_full`x'_`i'==1 & ranktrue_full`x'_`i'==1 //true postive rate
return list
local TPf1`x'`i'=r(N)
sum test if ranktrue_full`x'_`i'==1 //total poor
return list
local Pf1`x'`i'=r(N)
sum test if ranktrue_full`x'_`i'==0 //total non-poor
return list
local NPf1`x'`i'=r(N)
sum test if rankpred2_full`x'_`i'==1 & ranktrue_full`x'_`i'==0 //false positive rate
return list
local FP2f1`x'`i'=r(N)
sum test if rankpred2_full`x'_`i'==1 & ranktrue_full`x'_`i'==1 //true postive rate
return list
local TP2f1`x'`i'=r(N)

sum test if rankpred_ubr`x'_`i'==1 & ranktrue_ubr`x'_`i'==0 //false positive rate
return list
local FPf2`x'`i'=r(N)
sum test if rankpred_ubr`x'_`i'==1 & ranktrue_ubr`x'_`i'==1 //true postive rate
return list
local TPf2`x'`i'=r(N)
sum test if ranktrue_ubr`x'_`i'==1 //total poor
return list
local Pf2`x'`i'=r(N)
sum test if ranktrue_ubr`x'_`i'==0 //total non-poor
return list
local NPf2`x'`i'=r(N)
sum test if rankpred2_ubr`x'_`i'==1 & ranktrue_ubr`x'_`i'==0 //false positive rate
return list
local FP2f2`x'`i'=r(N)
sum test if rankpred2_ubr`x'_`i'==1 & ranktrue_ubr`x'_`i'==1 //true postive rate
return list
local TP2f2`x'`i'=r(N)

sum test if rankpred_fullxg`x'_`i'==1 & ranktrue_fullxg`x'_`i'==0 //false positive rate
return list
local FPf1xg`x'`i'=r(N)
sum test if rankpred_fullxg`x'_`i'==1 & ranktrue_fullxg`x'_`i'==1 //true postive rate
return list
local TPf1xg`x'`i'=r(N)
sum test if ranktrue_fullxg`x'_`i'==1 //total poor
return list
local Pf1xg`x'`i'=r(N)
sum test if ranktrue_fullxg`x'_`i'==0 //total non-poor
return list
local NPf1xg`x'`i'=r(N)
sum test if rankpred2_fullxg`x'_`i'==1 & ranktrue_fullxg`x'_`i'==0 //false positive rate
return list
local FP2f1xg`x'`i'=r(N)
sum test if rankpred2_fullxg`x'_`i'==1 & ranktrue_fullxg`x'_`i'==1 //true postive rate
return list
local TP2f1xg`x'`i'=r(N)


sum test if rankpred_ubrxg`x'_`i'==1 & ranktrue_ubrxg`x'_`i'==0 //false positive rate
return list
local FPf2xg`x'`i'=r(N)
sum test if rankpred_ubrxg`x'_`i'==1 & ranktrue_ubrxg`x'_`i'==1 //true postive rate
return list
local TPf2xg`x'`i'=r(N)
sum test if ranktrue_ubrxg`x'_`i'==1 //total poor
return list
local Pf2xg`x'`i'=r(N)
sum test if ranktrue_ubrxg`x'_`i'==0 //total non-poor
return list
local NPf2xg`x'`i'=r(N)
sum test if rankpred2_ubrxg`x'_`i'==1 & ranktrue_ubrxg`x'_`i'==0 //false positive rate
return list
local FP2f2xg`x'`i'=r(N)
sum test if rankpred2_ubrxg`x'_`i'==1 & ranktrue_ubrxg`x'_`i'==1 //true postive rate
return list
local TP2f2xg`x'`i'=r(N)
		
putexcel A`i'=`FPf1`x'`i''
putexcel B`i'=`TPf1`x'`i''
putexcel C`i'=`FP2f1`x'`i''
putexcel D`i'=`TP2f1`x'`i''
putexcel E`i'=`Pf1`x'`i''
putexcel F`i'=`NPf1`x'`i''

putexcel H`i'=`FPf2`x'`i''
putexcel I`i'=`TPf2`x'`i''
putexcel J`i'=`FP2f2`x'`i''
putexcel K`i'=`TP2f2`x'`i''
putexcel L`i'=`Pf2`x'`i''
putexcel M`i'=`NPf2`x'`i''

putexcel O`i'=`FPf1xg`x'`i''
putexcel P`i'=`TPf1xg`x'`i''
putexcel Q`i'=`FP2f1xg`x'`i''
putexcel R`i'=`TP2f1xg`x'`i''
putexcel S`i'=`Pf1xg`x'`i''
putexcel T`i'=`NPf1xg`x'`i''

putexcel V`i'=`FPf2xg`x'`i''
putexcel W`i'=`TPf2xg`x'`i''
putexcel X`i'=`FP2f2xg`x'`i''
putexcel Y`i'=`TP2f2xg`x'`i''
putexcel Z`i'=`Pf2xg`x'`i''
putexcel AA`i'=`NPf2xg`x'`i''

}
}

foreach x in 10 15 20 {
		import excel "Census\Updated results\full_sample_pred\AUC_`x'_full50ubr50.xlsx", sheet("Sheet1") clear
		g FPR_`x'full=A/F
        g TPR_`x'full=B/E
		g FPR_`x'full2=C/F
        g TPR_`x'full2=D/E
		
		g FPR_`x'ubr=H/M
        g TPR_`x'ubr=I/L
		g FPR_`x'ubr2=J/M
        g TPR_`x'ubr2=K/L
		
		g FPR_`x'fullxg=O/T
        g TPR_`x'fullxg=P/S
		g FPR_`x'fullxg2=Q/T
        g TPR_`x'fullxg2=R/S
		
		g FPR_`x'ubrxg=V/AA
        g TPR_`x'ubrxg=W/Z
		g FPR_`x'ubrxg2=X/AA
        g TPR_`x'ubrxg2=Y/Z
		
		export excel using "Census\Updated results\full_sample_pred\AUC_`x'_full50ubr50.xlsx", replace
	}


putexcel set "Census\Updated results\full_sample_pred\Correlations_predicted_actual_lasso_xgboost", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel B2="Predicted consumption based on all districts in IHS"
putexcel C2="Predicted consumption based on UBR districts in IHS"
putexcel D2="Predicted consumption based on Poorest 50% HH in all districts in IHS"
putexcel E2="Predicted consumption based on Poorest 50% HH in UBR districts in IHS"
putexcel B3=`rhof_10'
putexcel B4=`pf_10'
putexcel B5=`Nf_10'
putexcel C3=`rhou_10'
putexcel C4=`pu_10'
putexcel C5=`Nu_10'

putexcel B6=`rhof_15'
putexcel B7=`pf_15'
putexcel B8=`Nf_15'
putexcel C6=`rhou_15'
putexcel C7=`pu_15'
putexcel C8=`Nu_15'

putexcel B9=`rhof_20'
putexcel B10=`pf_20'
putexcel B11=`Nf_20'
putexcel C9=`rhou_20'
putexcel C10=`pu_20'
putexcel C11=`Nu_20'

putexcel D3=`rhof50_10'
putexcel D4=`pf50_10'
putexcel D5=`Nf50_10'
putexcel E3=`rhou50_10'
putexcel E4=`pu50_10'
putexcel E5=`Nu50_10'

putexcel D6=`rhof50_15'
putexcel D7=`pf50_15'
putexcel D8=`Nf50_15'
putexcel E6=`rhou50_15'
putexcel E7=`pu50_15'
putexcel E8=`Nu50_15'

putexcel D9=`rhof50_20'
putexcel D10=`pf50_20'
putexcel D11=`Nf50_20'
putexcel E9=`rhou50_20'
putexcel E10=`pu50_20'
putexcel E11=`Nu50_20'


putexcel set "Census\Updated results\full_sample_pred\Correlations_predicted_actual_xgboost_xgboost", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel B2="Predicted consumption based on all districts in IHS"
putexcel C2="Predicted consumption based on UBR districts in IHS"
putexcel D2="Predicted consumption based on Poorest 50% HH in all districts in IHS"
putexcel E2="Predicted consumption based on Poorest 50% HH in UBR districts in IHS"
putexcel B3=`rhofxg_10'
putexcel B4=`pfxg_10'
putexcel B5=`Nfxg_10'
putexcel C3=`rhouxg_10'
putexcel C4=`puxg_10'
putexcel C5=`Nuxg_10'

putexcel B6=`rhofxg_15'
putexcel B7=`pfxg_15'
putexcel B8=`Nfxg_15'
putexcel C6=`rhouxg_15'
putexcel C7=`puxg_15'
putexcel C8=`Nuxg_15'

putexcel B9=`rhofxg_20'
putexcel B10=`pfxg_20'
putexcel B11=`Nfxg_20'
putexcel C9=`rhouxg_20'
putexcel C10=`puxg_20'
putexcel C11=`Nuxg_20'

putexcel D3=`rhofxg50_10'
putexcel D4=`pfxg50_10'
putexcel D5=`Nfxg50_10'
putexcel E3=`rhouxg50_10'
putexcel E4=`puxg50_10'
putexcel E5=`Nuxg50_10'

putexcel D6=`rhofxg50_15'
putexcel D7=`pfxg50_15'
putexcel D8=`Nfxg50_15'
putexcel E6=`rhouxg50_15'
putexcel E7=`puxg50_15'
putexcel E8=`Nuxg50_15'

putexcel D9=`rhofxg50_20'
putexcel D10=`pfxg50_20'
putexcel D11=`Nfxg50_20'
putexcel E9=`rhouxg50_20'
putexcel E10=`puxg50_20'
putexcel E11=`Nuxg50_20'

***************************************************************************************
*** True measure LASSO, prediction XGB
foreach i in 10 15 20 {
import excel "C:\Users\melyg\Desktop\Malawi\Census\Updated results\full_sample_pred\FTR_TPR_lasso_xgb_`i'.xlsx", sheet("Sheet1") firstrow clear
		
***Area under the curve
foreach x in full ubr full50 ubr50 {
	integ TPR_`x' FPR_`x', gen(total_auc`x'`i')
	local auc1_`x'`i'=r(integral) 
}

*** True measure XGB, prediction XGB
import excel "C:\Users\melyg\Desktop\Malawi\Census\Updated results\full_sample_pred\FTR_TPR_xgb_xgb_`i'.xlsx", sheet("Sheet1") firstrow clear
	
***Area under the curve
foreach x in full ubr full50 ubr50 {
	integ  TPR_`x' FPR_`x', gen(total_auc`x'`i')
	local auc2_`x'`i'=r(integral) 
}

}

graph combine auc1_10.gph auc1_15.gph auc1_20.gph auc2_10.gph auc2_15.gph auc2_20.gph, ///
title("False positive rates vs. True positive rates using XGBOOST" , size(8pt)) 
graph export "Census\Updated results\full_sample_pred\auc_pred_xgb.pdf", replace

putexcel set "Census\Updated results\full_sample_pred\AUC_predictions_xgb", replace

putexcel B1="Full"
putexcel C1="UBR"
putexcel D1="Full50"
putexcel E1="UBR50"

putexcel A2="True measure estimated with LASSO"
putexcel A5="True measure estimated with XGB"

putexcel B2=`auc1_full10'
putexcel C2=`auc1_ubr10'
putexcel D2=`auc1_full5010'
putexcel E2=`auc1_ubr5010'

putexcel B3=`auc1_full15'
putexcel C3=`auc1_ubr15'
putexcel D3=`auc1_full5015'
putexcel E3=`auc1_ubr5015'

putexcel B4=`auc1_full20'
putexcel C4=`auc1_ubr20'
putexcel D4=`auc1_full5020'
putexcel E4=`auc1_ubr5020'

putexcel B5=`auc2_full10'
putexcel C5=`auc2_ubr10'
putexcel D5=`auc2_full5010'
putexcel E5=`auc2_ubr5010'

putexcel B6=`auc2_full15'
putexcel C6=`auc2_ubr15'
putexcel D6=`auc2_full5015'
putexcel E6=`auc2_ubr5015'

putexcel B7=`auc2_full20'
putexcel C7=`auc2_ubr20'
putexcel D7=`auc2_full5020'
putexcel E7=`auc2_ubr5020'

************************************************************************************
************************************************************************************
***FOR 50VILL50 AND 50UBRVILL50
********************************************************************************

foreach x in 10 15 20 {
use "Census\Updated results\full_sample_pred\pred_xgboos_full5050_ubr5050_`x'_outs.dta", clear
destring  predcons_census_full predwelf_census_full predcons_census_ubr predwelf_census_ubr predcons_xgb_full predcons_xgb_ubr predwelf_xgb_full predwelf_xgb_ubr, replace
rename V9 district
save "Census\Updated results\full_sample_pred\pred_xgboos_full5050_ubr5050_`x'_n.dta", replace
}

foreach x in 10 15 20 {
use "Census\Updated results\full_sample_pred\pred_xgboos_full5050_ubr5050_`x'_n.dta", clear
spearman  predcons_census_full predwelf_census_full
local rhof50_`x'=r(rho)
local pf50_`x'=r(p)
local Nf50_`x'=r(N)

spearman  predcons_census_ubr predwelf_census_ubr
local rhou50_`x'=r(rho)
local pu50_`x'=r(p)
local Nu50_`x'=r(N)

spearman  predcons_xgb_full predwelf_xgb_full
local rhofxg50_`x'=r(rho)
local pfxg50_`x'=r(p)
local Nfxg50_`x'=r(N)

spearman  predcons_xgb_ubr predwelf_xgb_ubr
local rhouxg50_`x'=r(rho)
local puxg50_`x'=r(p)
local Nuxg50_`x'=r(N)
g test=1


putexcel set "Census\Updated results\full_sample_pred\AUC_`x'_full5050ubr5050.xlsx", replace

forvalues i=1(1)99 {

egen rtrue_full`x'`i' = pctile(predcons_census_full), /*by(district)*/ p(`i') 
g ranktrue_full`x'_`i'=(predcons_census_full<rtrue_full`x'`i')
egen rtrue_ubr`x'`i' = pctile(predcons_census_ubr), /*by(district)*/ p(`i') 
g ranktrue_ubr`x'_`i'=(predcons_census_ubr<rtrue_ubr`x'`i')

egen rtrue_fullxg`x'`i' = pctile(predcons_xgb_full), /*by(district)*/ p(`i') 
g ranktrue_fullxg`x'_`i'=(predcons_xgb_full<rtrue_fullxg`x'`i')
egen rtrue_ubrxg`x'`i' = pctile(predcons_xgb_ubr), /*by(district)*/ p(`i') 
g ranktrue_ubrxg`x'_`i'=(predcons_xgb_ubr<rtrue_ubrxg`x'`i')

egen rpred_full`x'`i' = pctile(predwelf_census_full), /*by(district)*/ p(`i') 
egen rpred_ubr`x'`i' = pctile(predwelf_census_ubr), /*by(district)*/ p(`i') 
egen rpred_fullxg`x'`i' = pctile(predwelf_xgb_full), /*by(district)*/ p(`i') 
egen rpred_ubrxg`x'`i' = pctile(predwelf_xgb_ubr), /*by(district)*/ p(`i') 

g rankpred_full`x'_`i'=(predwelf_census_full<rtrue_full`x'`i')
g rankpred_ubr`x'_`i'=(predwelf_census_ubr<rtrue_ubr`x'`i')
g rankpred_fullxg`x'_`i'=(predwelf_xgb_full<rtrue_fullxg`x'`i')
g rankpred_ubrxg`x'_`i'=(predwelf_xgb_ubr<rtrue_ubrxg`x'`i')

g rankpred2_full`x'_`i'=(predwelf_census_full<rpred_full`x'`i')
g rankpred2_ubr`x'_`i'=(predwelf_census_ubr<rpred_ubr`x'`i')
g rankpred2_fullxg`x'_`i'=(predwelf_xgb_full<rpred_fullxg`x'`i')
g rankpred2_ubrxg`x'_`i'=(predwelf_xgb_ubr<rpred_ubrxg`x'`i')

sum test if rankpred_full`x'_`i'==1 & ranktrue_full`x'_`i'==0 //false positive rate
return list
local FPf1`x'`i'=r(N)
sum test if rankpred_full`x'_`i'==1 & ranktrue_full`x'_`i'==1 //true postive rate
return list
local TPf1`x'`i'=r(N)
sum test if ranktrue_full`x'_`i'==1 //total poor
return list
local Pf1`x'`i'=r(N)
sum test if ranktrue_full`x'_`i'==0 //total non-poor
return list
local NPf1`x'`i'=r(N)
sum test if rankpred2_full`x'_`i'==1 & ranktrue_full`x'_`i'==0 //false positive rate
return list
local FP2f1`x'`i'=r(N)
sum test if rankpred2_full`x'_`i'==1 & ranktrue_full`x'_`i'==1 //true postive rate
return list
local TP2f1`x'`i'=r(N)

sum test if rankpred_ubr`x'_`i'==1 & ranktrue_ubr`x'_`i'==0 //false positive rate
return list
local FPf2`x'`i'=r(N)
sum test if rankpred_ubr`x'_`i'==1 & ranktrue_ubr`x'_`i'==1 //true postive rate
return list
local TPf2`x'`i'=r(N)
sum test if ranktrue_ubr`x'_`i'==1 //total poor
return list
local Pf2`x'`i'=r(N)
sum test if ranktrue_ubr`x'_`i'==0 //total non-poor
return list
local NPf2`x'`i'=r(N)
sum test if rankpred2_ubr`x'_`i'==1 & ranktrue_ubr`x'_`i'==0 //false positive rate
return list
local FP2f2`x'`i'=r(N)
sum test if rankpred2_ubr`x'_`i'==1 & ranktrue_ubr`x'_`i'==1 //true postive rate
return list
local TP2f2`x'`i'=r(N)

sum test if rankpred_fullxg`x'_`i'==1 & ranktrue_fullxg`x'_`i'==0 //false positive rate
return list
local FPf1xg`x'`i'=r(N)
sum test if rankpred_fullxg`x'_`i'==1 & ranktrue_fullxg`x'_`i'==1 //true postive rate
return list
local TPf1xg`x'`i'=r(N)
sum test if ranktrue_fullxg`x'_`i'==1 //total poor
return list
local Pf1xg`x'`i'=r(N)
sum test if ranktrue_fullxg`x'_`i'==0 //total non-poor
return list
local NPf1xg`x'`i'=r(N)
sum test if rankpred2_fullxg`x'_`i'==1 & ranktrue_fullxg`x'_`i'==0 //false positive rate
return list
local FP2f1xg`x'`i'=r(N)
sum test if rankpred2_fullxg`x'_`i'==1 & ranktrue_fullxg`x'_`i'==1 //true postive rate
return list
local TP2f1xg`x'`i'=r(N)


sum test if rankpred_ubrxg`x'_`i'==1 & ranktrue_ubrxg`x'_`i'==0 //false positive rate
return list
local FPf2xg`x'`i'=r(N)
sum test if rankpred_ubrxg`x'_`i'==1 & ranktrue_ubrxg`x'_`i'==1 //true postive rate
return list
local TPf2xg`x'`i'=r(N)
sum test if ranktrue_ubrxg`x'_`i'==1 //total poor
return list
local Pf2xg`x'`i'=r(N)
sum test if ranktrue_ubrxg`x'_`i'==0 //total non-poor
return list
local NPf2xg`x'`i'=r(N)
sum test if rankpred2_ubrxg`x'_`i'==1 & ranktrue_ubrxg`x'_`i'==0 //false positive rate
return list
local FP2f2xg`x'`i'=r(N)
sum test if rankpred2_ubrxg`x'_`i'==1 & ranktrue_ubrxg`x'_`i'==1 //true postive rate
return list
local TP2f2xg`x'`i'=r(N)
		
putexcel A`i'=`FPf1`x'`i''
putexcel B`i'=`TPf1`x'`i''
putexcel C`i'=`FP2f1`x'`i''
putexcel D`i'=`TP2f1`x'`i''
putexcel E`i'=`Pf1`x'`i''
putexcel F`i'=`NPf1`x'`i''

putexcel H`i'=`FPf2`x'`i''
putexcel I`i'=`TPf2`x'`i''
putexcel J`i'=`FP2f2`x'`i''
putexcel K`i'=`TP2f2`x'`i''
putexcel L`i'=`Pf2`x'`i''
putexcel M`i'=`NPf2`x'`i''

putexcel O`i'=`FPf1xg`x'`i''
putexcel P`i'=`TPf1xg`x'`i''
putexcel Q`i'=`FP2f1xg`x'`i''
putexcel R`i'=`TP2f1xg`x'`i''
putexcel S`i'=`Pf1xg`x'`i''
putexcel T`i'=`NPf1xg`x'`i''

putexcel V`i'=`FPf2xg`x'`i''
putexcel W`i'=`TPf2xg`x'`i''
putexcel X`i'=`FP2f2xg`x'`i''
putexcel Y`i'=`TP2f2xg`x'`i''
putexcel Z`i'=`Pf2xg`x'`i''
putexcel AA`i'=`NPf2xg`x'`i''

}
}

foreach x in 10 15 20 {
		import excel "Census\Updated results\full_sample_pred\AUC_`x'_full5050ubr5050.xlsx", sheet("Sheet1") clear
		g FPR_`x'full=A/F
        g TPR_`x'full=B/E
		g FPR_`x'full2=C/F
        g TPR_`x'full2=D/E
		
		g FPR_`x'ubr=H/M
        g TPR_`x'ubr=I/L
		g FPR_`x'ubr2=J/M
        g TPR_`x'ubr2=K/L
		
		g FPR_`x'fullxg=O/T
        g TPR_`x'fullxg=P/S
		g FPR_`x'fullxg2=Q/T
        g TPR_`x'fullxg2=R/S
		
		g FPR_`x'ubrxg=V/AA
        g TPR_`x'ubrxg=W/Z
		g FPR_`x'ubrxg2=X/AA
        g TPR_`x'ubrxg2=Y/Z
		
		keep FPR* TPR*
		
		export excel using "Census\Updated results\full_sample_pred\AUC_`x'_full5050ubr5050V2.xlsx", replace firstrow(variables)
	}


putexcel set "Census\Updated results\full_sample_pred\Correlations_predicted_actual_lasso_xgboost5050", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel D2="Predicted consumption based on Poorest 50% HH in all districts in IHS"
putexcel E2="Predicted consumption based on Poorest 50% HH in UBR districts in IHS"

putexcel D3=`rhof50_10'
putexcel D4=`pf50_10'
putexcel D5=`Nf50_10'
putexcel E3=`rhou50_10'
putexcel E4=`pu50_10'
putexcel E5=`Nu50_10'

putexcel D6=`rhof50_15'
putexcel D7=`pf50_15'
putexcel D8=`Nf50_15'
putexcel E6=`rhou50_15'
putexcel E7=`pu50_15'
putexcel E8=`Nu50_15'

putexcel D9=`rhof50_20'
putexcel D10=`pf50_20'
putexcel D11=`Nf50_20'
putexcel E9=`rhou50_20'
putexcel E10=`pu50_20'
putexcel E11=`Nu50_20'


putexcel set "Census\Updated results\full_sample_pred\Correlations_predicted_actual_xgboost_xgboost5050", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel C2="Predicted consumption based on UBR districts in IHS"
putexcel D2="Predicted consumption based on Poorest 50% HH in all districts in IHS"
putexcel E2="Predicted consumption based on Poorest 50% HH in UBR districts in IHS"


putexcel D3=`rhofxg50_10'
putexcel D4=`pfxg50_10'
putexcel D5=`Nfxg50_10'
putexcel E3=`rhouxg50_10'
putexcel E4=`puxg50_10'
putexcel E5=`Nuxg50_10'

putexcel D6=`rhofxg50_15'
putexcel D7=`pfxg50_15'
putexcel D8=`Nfxg50_15'
putexcel E6=`rhouxg50_15'
putexcel E7=`puxg50_15'
putexcel E8=`Nuxg50_15'

putexcel D9=`rhofxg50_20'
putexcel D10=`pfxg50_20'
putexcel D11=`Nfxg50_20'
putexcel E9=`rhouxg50_20'
putexcel E10=`puxg50_20'
putexcel E11=`Nuxg50_20'

***************************************************************************************
*** True measure LASSO, prediction XGB
foreach i in 10 15 20 {
import excel "C:\Users\melyg\Desktop\Malawi\Census\Updated results\full_sample_pred\AUC_`i'_full5050ubr5050V2.xlsx", sheet("Sheet1") firstrow clear


		
***Area under the curve
foreach x in full ubr fullxg ubrxg  {
	integ TPR_`i'`x' FPR_`i'`x', gen(total_auc`i'`x')
	local auc1_`i'`x'=r(integral) 
}

foreach x in full ubr fullxg ubrxg  {
	integ TPR_`i'`x'2 FPR_`i'`x'2, gen(total_auc`i'`x'2)
	local auc1_`i'`x'2=r(integral) 
}


}


putexcel set "Census\Updated results\full_sample_pred\AUC_predictions_xgb5050", replace


putexcel B1="Full50"
putexcel D1="UBR50"

putexcel A2="True measure estimated with LASSO"
putexcel A5="True measure estimated with XGB"


putexcel B2=`auc1_10full'
putexcel D2=`auc1_10ubr'

putexcel B3=`auc1_15full'
putexcel D3=`auc1_15ubr'

putexcel B4=`auc1_20full'
putexcel D4=`auc1_20ubr'

putexcel B5=`auc1_10fullxg'
putexcel D5=`auc1_10ubrxg'

putexcel B6=`auc1_15fullxg'
putexcel D6=`auc1_15ubrxg'

putexcel B7=`auc1_20fullxg'
putexcel D7=`auc1_20ubrxg'



putexcel C2=`auc1_10full2'
putexcel E2=`auc1_10ubr2'

putexcel C3=`auc1_15full2'
putexcel E3=`auc1_15ubr2'

putexcel C4=`auc1_20full2'
putexcel E4=`auc1_20ubr2'

putexcel C5=`auc1_10fullxg2'
putexcel E5=`auc1_10ubrxg2'

putexcel C6=`auc1_15fullxg2'
putexcel E6=`auc1_15ubrxg2'

putexcel C7=`auc1_20fullxg2'
putexcel E7=`auc1_20ubrxg2'
