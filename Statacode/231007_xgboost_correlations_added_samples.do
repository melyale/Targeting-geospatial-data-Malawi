cd "C:\Users\melyg\Desktop\Malawi"

**********************************************************************************************
*************************************************************************************************
***Last additions full5050 ubr5050
***OUT+training

****************************************
*** For models using all districts -poorest 50% of HH-
*** LASSO and XGBOOST
foreach x in 05 25 30 {
use "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_outfullxg.dta", clear
rename predcons_xgb_full predcons_census_full 
rename predwelf_xgb_full predwelf_census_full
save "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_outfullxgn.dta", replace
}

foreach x in 05 25 30 {
use "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_outubrxg.dta", clear
rename predcons_xgb_ubr predcons_census_ubr 
rename predwelf_xgb_ubr predwelf_census_ubr
save "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_outubrxgn.dta", replace
}

foreach x in 05 25 30 {
use "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_trainfullxg.dta", clear
rename predcons_xgb_full predcons_census_full 
save "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_trainfullxgn.dta", replace
}

foreach x in 05 25 30 {
use "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_trainubrxg.dta", clear
rename predcons_xgb_ubr predcons_census_ubr 
save "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_trainubrxgn.dta", replace
}

foreach x in 05 25 30 {
use "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_outfull.dta", clear
save "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_outfulln.dta", replace
use "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_outubr.dta", clear
save "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_outubrn.dta", replace
use "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_trainfull.dta", clear
save "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_trainfulln.dta", replace
use "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_trainubr.dta", clear
save "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_trainubrn.dta", replace
}
			/*
			use "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_05_outfullxgn.dta", clear
			append using "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_05_trainfullxgn.dta"
			destring  predcons_census_full predwelf_census_full, replace
			replace predwelf_census_full=predcons_census_full if predwelf_census_full==. //replacing the missing in the training sample as the actual values
			egen district=concat(V2 V3)
			*g pov_line=137428
			g pcc_level=exp(predcons_census_full)
			g pcc_levelpred=exp(predwelf_census_full)
			g cons_ppp=pcc_level/78.7/365
			g predcons_ppp=pcc_levelpred/78.7/365
			egen p10 = pctile(predcons_census_full), p(25)
			egen p10pred = pctile(predwelf_census_full), p(25)

			set scheme plotplainblind
			g true_poor=(predcons_census_full<p10)
			g pred_poor=(predwelf_census_full<p10pred)
			local p10=p10
			local p10pred=p10pred
			
graph twoway (scatter predwelf_census_full predcons_census_full if true_poor==1 & pred_poor==1 ,xline(`p10') yline(`p10pred') msize(tiny) mcolor(dknavy) xtitle(Benchmark welfare,size(vsmall)) ytitle(Predicted welfare with partial registry,size(vsmall)) legend(off) xlabel(,labsize(vsmall)) ylabel(,labsize(vsmall))) (scatter predwelf_census_full predcons_census_full if true_poor==0 & pred_poor==0, msize(tiny) mcolor(eltblue)) (scatter predwelf_census_full predcons_census_full if true_poor==1 & pred_poor==0, msize(tiny) mcolor(gs5)) (scatter predwelf_census_full predcons_census_full if true_poor==0 & pred_poor==1, msize(tiny) mcolor(khaki)) ///
(lfitci predwelf_census_full predcons_census_full)	
graph save partreg_scatter, replace
*/
foreach x in 05 25 30 {
		foreach y in full fullxg  {
			use "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_out`y'n.dta", clear
			append using "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_train`y'n.dta"
			destring  predcons_census_full predwelf_census_full, replace
			replace predwelf_census_full=predcons_census_full if predwelf_census_full==. //replacing the missing in the training sample as the actual values
			egen district=concat(V2 V3)
			drop V2 V3
			
			spearman  predcons_census_full predwelf_census_full
			local rhof50_`x'_`y'=r(rho)
			local pf50_`x'_`y'=r(p)
			local Nf50_`x'_`y'=r(N)
			g test=1
			
			reg predcons_census_full predwelf_census_full
			ereturn list
			local r_`x'_`y'=e(r2)
			
			putexcel set "Census\Updated results\sample_sizes\AUC_`x'_`y'5050", replace

			forvalues i=1(1)99 {
			egen rtrue_full`x'`y'_`i' = pctile(predcons_census_full), /*by(district)*/ p(`i') 
			egen rpred_full`x'`y'_`i' = pctile(predwelf_census_full), /*by(district)*/ p(`i') 

			g ranktrue_full`x'`y'_`i'=(predcons_census_full<rtrue_full`x'`y'_`i')
			g rankpred_full`x'`y'_`i'=(predwelf_census_full<rtrue_full`x'`y'_`i')
			g rankpred2_full`x'`y'_`i'=(predwelf_census_full<rpred_full`x'`y'_`i')

			sum test if rankpred_full`x'`y'_`i'==1 & ranktrue_full`x'`y'_`i'==0 //false positive rate
			return list
			local FPf1`x'`y'`i'=r(N)
			sum test if rankpred2_full`x'`y'_`i'==1 & ranktrue_full`x'`y'_`i'==0 //false positive rate
			return list
			local FP2f1`x'`y'`i'=r(N)
			sum test if rankpred_full`x'`y'_`i'==1 & ranktrue_full`x'`y'_`i'==1 //true postive rate
			return list
			local TPf1`x'`y'`i'=r(N)
			sum test if rankpred2_full`x'`y'_`i'==1 & ranktrue_full`x'`y'_`i'==1 //true postive rate 2
			return list
			local TP2f1`x'`y'`i'=r(N)
			sum test if ranktrue_full`x'`y'_`i'==1 //total poor
			return list
			local Pf1`x'`y'`i'=r(N)
			sum test if ranktrue_full`x'`y'_`i'==0 //total non-poor
			return list
			local NPf1`x'`y'`i'=r(N)
			
			putexcel A`i'=`FPf1`x'`y'`i''
			putexcel B`i'=`TPf1`x'`y'`i''			
			putexcel C`i'=`FP2f1`x'`y'`i''
			putexcel D`i'=`TP2f1`x'`y'`i''		
			putexcel E`i'=`Pf1`x'`y'`i''
			putexcel F`i'=`NPf1`x'`y'`i''
			}
		}
}

**R-squared
di `r_05_fullxg'
di `r_25_fullxg'
di `r_30_fullxg'

foreach x in 05 25 30 {
		foreach y in full fullxg  {
		import excel "Census\Updated results\sample_sizes\AUC_`x'_`y'5050.xlsx", sheet("Sheet1") clear
		g FPR_`x'`y'=A/F
        g TPR_`x'`y'=B/E
		g FPR_`x'`y'2=C/F
        g TPR_`x'`y'2=D/E		
		keep FPR* TPR*
		export excel using "Census\Updated results\sample_sizes\AUC_`x'_`y'5050v2.xlsx", replace firstrow(variables)
	}
}

*** For models using UBR districts -poorest 50% of HH

foreach x in 05 25 30 {
		foreach y in ubr ubrxg  {
			use "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_out`y'n.dta", clear
			append using "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_train`y'n.dta"
			destring  predcons_census_ubr predwelf_census_ubr, replace
			replace predwelf_census_ubr=predcons_census_ubr if predwelf_census_ubr==. //replacing the missing in the training sample as the actual values
			egen district=concat(V2 V3)
			drop V2 V3
			
			spearman  predcons_census_ubr predwelf_census_ubr
			local rhou50_`x'_`y'=r(rho)
			local pu50_`x'_`y'=r(p)
			local Nu50_`x'_`y'=r(N)
			g test=1
			
			reg predcons_census_ubr predwelf_census_ubr
			ereturn list
			local r_`x'_`y'=e(r2)
			
			putexcel set "Census\Updated results\sample_sizes\AUC_`x'_`y'5050", replace

			forvalues i=1(1)99 {
			egen rtrue_ubr`x'`y'_`i' = pctile(predcons_census_ubr), /*by(district)*/ p(`i') 
			egen rpred_ubr`x'`y'_`i' = pctile(predwelf_census_ubr), /*by(district)*/ p(`i') 
			
			g ranktrue_ubr`x'`y'_`i'=(predcons_census_ubr<rtrue_ubr`x'`y'_`i')
			g rankpred_ubr`x'`y'_`i'=(predwelf_census_ubr<rtrue_ubr`x'`y'_`i')
			g rankpred2_ubr`x'`y'_`i'=(predwelf_census_ubr<rpred_ubr`x'`y'_`i')

			sum test if rankpred_ubr`x'`y'_`i'==1 & ranktrue_ubr`x'`y'_`i'==0 //false positive rate
			return list
			local FPf2`x'`y'`i'=r(N)
			sum test if rankpred_ubr`x'`y'_`i'==1 & ranktrue_ubr`x'`y'_`i'==1 //true postive rate
			return list
			local TPf2`x'`y'`i'=r(N)
			sum test if rankpred2_ubr`x'`y'_`i'==1 & ranktrue_ubr`x'`y'_`i'==0 //false positive rate
			return list
			local FP2f2`x'`y'`i'=r(N)
			sum test if rankpred2_ubr`x'`y'_`i'==1 & ranktrue_ubr`x'`y'_`i'==1 //true postive rate
			return list
			local TP2f2`x'`y'`i'=r(N)			
			sum test if ranktrue_ubr`x'`y'_`i'==1 //total poor
			return list
			local Pf2`x'`y'`i'=r(N)
			sum test if ranktrue_ubr`x'`y'_`i'==0 //total non-poor
			return list
			local NPf2`x'`y'`i'=r(N)
			
			putexcel A`i'=`FPf2`x'`y'`i''
			putexcel B`i'=`TPf2`x'`y'`i''
			putexcel C`i'=`FP2f2`x'`y'`i''
			putexcel D`i'=`TP2f2`x'`y'`i''			
			putexcel E`i'=`Pf2`x'`y'`i''
			putexcel F`i'=`NPf2`x'`y'`i''
			}
		}
}

***R-squared
di `r_05_ubrxg'

foreach x in 05 25 30 {
		foreach y in ubr ubrxg  {
		import excel "Census\Updated results\sample_sizes\AUC_`x'_`y'5050.xlsx", sheet("Sheet1") clear
		g FPR_`x'`y'=A/F
        g TPR_`x'`y'=B/E
		g FPR_`x'`y'2=C/F
        g TPR_`x'`y'2=D/E		
		
		keep FPR* TPR*
		
		export excel using "Census\Updated results\sample_sizes\AUC_`x'_`y'5050v2.xlsx", replace firstrow(variables)
	}
}


*** Rank correlations when using benchmark welfare predicted using LASSO models
putexcel set "Census\Updated results\sample_sizes\Correlations_predicted_actual_lasso_xgboost5050", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel D2="Predicted consumption based on Poorest 50% HH in all districts in IHS"
putexcel E2="Predicted consumption based on Poorest 50% HH in UBR districts in IHS"

putexcel D3=`rhof50_05_full'
putexcel D4=`pf50_05_full'
putexcel D5=`Nf50_05_full'
putexcel E3=`rhou50_05_ubr'
putexcel E4=`pu50_05_ubr'
putexcel E5=`Nu50_05_ubr'

putexcel D6=`rhof50_25_full'
putexcel D7=`pf50_25_full'
putexcel D8=`Nf50_25_full'
putexcel E6=`rhou50_25_ubr'
putexcel E7=`pu50_25_ubr'
putexcel E8=`Nu50_25_ubr'

putexcel D9=`rhof50_30_full'
putexcel D10=`pf50_30_full'
putexcel D11=`Nf50_30_full'
putexcel E9=`rhou50_30_ubr'
putexcel E10=`pu50_30_ubr'
putexcel E11=`Nu50_30_ubr'

*** Rank correlations when using benchmark welfare predicted using XGBOOST models

putexcel set "Census\Updated results\sample_sizes\Correlations_predicted_actual_xgboost_xgboost5050", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"


putexcel D2="Predicted consumption based on Poorest 50% HH in all districts in IHS"
putexcel E2="Predicted consumption based on Poorest 50% HH in UBR districts in IHS"
putexcel D3=`rhof50_05_fullxg'
putexcel D4=`pf50_05_fullxg'
putexcel D5=`Nf50_05_fullxg'
putexcel E3=`rhou50_05_ubrxg'
putexcel E4=`pu50_05_ubrxg'
putexcel E5=`Nu50_05_ubrxg'

putexcel D6=`rhof50_25_fullxg'
putexcel D7=`pf50_25_fullxg'
putexcel D8=`Nf50_25_fullxg'
putexcel E6=`rhou50_25_ubrxg'
putexcel E7=`pu50_25_ubrxg'
putexcel E8=`Nu50_25_ubrxg'

putexcel D9=`rhof50_30_fullxg'
putexcel D10=`pf50_30_fullxg'
putexcel D11=`Nf50_30_fullxg'
putexcel E9=`rhou50_30_ubrxg'
putexcel E10=`pu50_30_ubrxg'
putexcel E11=`Nu50_30_ubrxg'


***************************************************************************************
*** AUC graphs and AUC
*** True measure LASSO, prediction XGB
foreach x in 05 25 30 {
	foreach y in full fullxg ubr ubrxg  {
		import excel "C:\Users\melyg\Desktop\Malawi\Census\Updated results\sample_sizes\AUC_`x'_`y'5050v2.xlsx", sheet("Sheet1") firstrow clear
		set obs `=_N+1'
		replace TPR_`x'`y'=1 if TPR_`x'`y'==.
		replace FPR_`x'`y'=1 if FPR_`x'`y'==.
		replace TPR_`x'`y'2=1 if TPR_`x'`y'2==.
		replace FPR_`x'`y'2=1 if FPR_`x'`y'2==.
		
***Area under the curve
	integ TPR_`x'`y' FPR_`x'`y', gen(total_auc_`x'`y')
	local auc1_`x'`y'=r(integral) 

		
***Area under the curve
	integ  TPR_`x'`y'2 FPR_`x'`y'2, gen(total_auc`x'`y'2)
	local auc2_`x'`y'=r(integral) 
}

}

putexcel set "Census\Updated results\sample_sizes\AUC_predictions_xgb5050v2", replace

putexcel B1="Full50"
putexcel D1="UBR50"

putexcel A2="True measure estimated with LASSO"
putexcel A5="True measure estimated with XGB"

putexcel B2=`auc1_05full'
putexcel D2=`auc1_05ubr'

putexcel B3=`auc1_25full'
putexcel D3=`auc1_25ubr'

putexcel B4=`auc1_30full'
putexcel D4=`auc1_30ubr'

putexcel B5=`auc1_05fullxg'
putexcel D5=`auc1_05ubrxg'

putexcel B6=`auc1_25fullxg'
putexcel D6=`auc1_25ubrxg'

putexcel B7=`auc1_30fullxg'
putexcel D7=`auc1_30ubrxg'



putexcel C2=`auc2_05full'
putexcel E2=`auc2_05ubr'

putexcel C3=`auc2_25full'
putexcel E3=`auc2_25ubr'

putexcel C4=`auc2_30full'
putexcel E4=`auc2_30ubr'

putexcel C5=`auc2_05fullxg'
putexcel E5=`auc2_05ubrxg'

putexcel C6=`auc2_25fullxg'
putexcel E6=`auc2_25ubrxg'

putexcel C7=`auc2_30fullxg'
putexcel E7=`auc2_30ubrxg'


****************************************
****************************************
***Out of sample
***For FULL50 lasso XGBOOST
foreach x in 05 25 30 {
use "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_outfullxg.dta", clear
rename predcons_xgb_full predcons_census_full 
rename predwelf_xgb_full predwelf_census_full
save "Census\Updated results\sample_sizes\only_pred\pred_xgboos_full5050_ubr5050_`x'_outfullxgn.dta", replace
}

foreach x in 05 25 30 {
use "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_outubrxg.dta", clear
rename predcons_xgb_ubr predcons_census_ubr 
rename predwelf_xgb_ubr predwelf_census_ubr
save "Census\Updated results\sample_sizes\only_pred\pred_xgboos_full5050_ubr5050_`x'_outubrxgn.dta", replace
}



foreach x in 05 25 30 {
use "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_outfull.dta", clear
save "Census\Updated results\sample_sizes\only_pred\pred_xgboos_full5050_ubr5050_`x'_outfulln.dta", replace
use "Census\Updated results\sample_sizes\pred_xgboos_full5050_ubr5050_`x'_outubr.dta", clear
save "Census\Updated results\sample_sizes\only_pred\pred_xgboos_full5050_ubr5050_`x'_outubrn.dta", replace

}
			
		
foreach x in 05 25 30 {
		foreach y in full fullxg  {
			use "Census\Updated results\sample_sizes\only_pred\pred_xgboos_full5050_ubr5050_`x'_out`y'n.dta", clear
			*append using "Census\Updated results\sample_sizes\pred_xgboos_full50_ubr50_`x'_train`y'n.dta"
			destring  predcons_census_full predwelf_census_full, replace
			*replace predwelf_census_full=predcons_census_full if predwelf_census_full==. //replacing the missing in the training sample as the actual values
			*egen district=concat(V2 V3)
			*drop V2 V3
			rename V3 district
			spearman  predcons_census_full predwelf_census_full
			local rhof50_`x'_`y'=r(rho)
			local pf50_`x'_`y'=r(p)
			local Nf50_`x'_`y'=r(N)
			g test=1

			putexcel set "Census\Updated results\sample_sizes\only_pred\AUC_`x'_`y'5050", replace

			forvalues i=1(1)99 {
			egen rtrue_full`x'`y'_`i' = pctile(predcons_census_full), /*by(district)*/ p(`i') 
			egen rpred_full`x'`y'_`i' = pctile(predwelf_census_full), /*by(district)*/ p(`i') 

			g ranktrue_full`x'`y'_`i'=(predcons_census_full<rtrue_full`x'`y'_`i')
			g rankpred_full`x'`y'_`i'=(predwelf_census_full<rtrue_full`x'`y'_`i')
			g rankpred2_full`x'`y'_`i'=(predwelf_census_full<rpred_full`x'`y'_`i')

		sum test if rankpred_full`x'`y'_`i'==1 & ranktrue_full`x'`y'_`i'==0 //false positive rate
		return list
		local FPf1`x'`y'`i'=r(N)
		sum test if rankpred_full`x'`y'_`i'==1 & ranktrue_full`x'`y'_`i'==1 //true postive rate
		return list
		local TPf1`x'`y'`i'=r(N)
		sum test if rankpred2_full`x'`y'_`i'==1 & ranktrue_full`x'`y'_`i'==0 //false positive rate
		return list
		local FP2f1`x'`y'`i'=r(N)
		sum test if rankpred2_full`x'`y'_`i'==1 & ranktrue_full`x'`y'_`i'==1 //true postive rate
		return list
		local TP2f1`x'`y'`i'=r(N)		
		sum test if ranktrue_full`x'`y'_`i'==1 //total poor
		return list
		local Pf1`x'`y'`i'=r(N)
		sum test if ranktrue_full`x'`y'_`i'==0 //total non-poor
		return list
		local NPf1`x'`y'`i'=r(N)
			
			putexcel A`i'=`FPf1`x'`y'`i''
			putexcel B`i'=`TPf1`x'`y'`i''
			putexcel C`i'=`FP2f1`x'`y'`i''
			putexcel D`i'=`TP2f1`x'`y'`i''
			putexcel E`i'=`Pf1`x'`y'`i''
			putexcel F`i'=`NPf1`x'`y'`i''
			}
		}
}

foreach x in 05 25 30 {
		foreach y in full fullxg  {
		import excel "Census\Updated results\sample_sizes\only_pred\AUC_`x'_`y'5050.xlsx", sheet("Sheet1") clear
		g FPR_`x'`y'=A/F
        g TPR_`x'`y'=B/E
		g FPR_`x'`y'2=C/F
        g TPR_`x'`y'2=D/E		
		export excel using "Census\Updated results\sample_sizes\only_pred\AUC_`x'_`y'5050.xlsx", replace firstrow(variables)
	}
}


***For UBR50 LASSO and XGBOOST
foreach x in 05 25 30 {
		foreach y in ubr ubrxg  {
			use "Census\Updated results\sample_sizes\only_pred\pred_xgboos_full5050_ubr5050_`x'_out`y'n.dta", clear
			*append using "Census\Updated results\sample_sizes\pred_xgboos_full50_ubr50_`x'_train`y'n.dta"
			destring  predcons_census_ubr predwelf_census_ubr, replace
			*replace predwelf_census_ubr=predcons_census_ubr if predwelf_census_ubr==. //replacing the missing in the training sample as the actual values
			*egen district=concat(V2 V3)
			*drop V2 V3
			rename V3 district
			spearman  predcons_census_ubr predwelf_census_ubr
			local rhou50_`x'_`y'=r(rho)
			local pu50_`x'_`y'=r(p)
			local Nu50_`x'_`y'=r(N)
			g test=1

			putexcel set "Census\Updated results\sample_sizes\only_pred\AUC_`x'_`y'5050", replace

			forvalues i=1(1)99 {
			egen rtrue_ubr`x'`y'_`i' = pctile(predcons_census_ubr), /*by(district)*/ p(`i') 
			egen rpred_ubr`x'`y'_`i' = pctile(predwelf_census_ubr), /*by(district)*/ p(`i') 
			
			g ranktrue_ubr`x'`y'_`i'=(predcons_census_ubr<rtrue_ubr`x'`y'_`i')
			g rankpred_ubr`x'`y'_`i'=(predwelf_census_ubr<rtrue_ubr`x'`y'_`i')
			g rankpred2_ubr`x'`y'_`i'=(predwelf_census_ubr<rpred_ubr`x'`y'_`i')

			sum test if rankpred_ubr`x'`y'_`i'==1 & ranktrue_ubr`x'`y'_`i'==0 //false positive rate
			return list
			local FPf2`x'`y'`i'=r(N)
			sum test if rankpred_ubr`x'`y'_`i'==1 & ranktrue_ubr`x'`y'_`i'==1 //true postive rate
			return list
			local TPf2`x'`y'`i'=r(N)
			sum test if rankpred2_ubr`x'`y'_`i'==1 & ranktrue_ubr`x'`y'_`i'==0 //false positive rate
			return list
			local FP2f2`x'`y'`i'=r(N)
			sum test if rankpred2_ubr`x'`y'_`i'==1 & ranktrue_ubr`x'`y'_`i'==1 //true postive rate
			return list
			local TP2f2`x'`y'`i'=r(N)			
			sum test if ranktrue_ubr`x'`y'_`i'==1 //total poor
			return list
			local Pf2`x'`y'`i'=r(N)
			sum test if ranktrue_ubr`x'`y'_`i'==0 //total non-poor
			return list
			local NPf2`x'`y'`i'=r(N)
			
			putexcel A`i'=`FPf2`x'`y'`i''
			putexcel B`i'=`TPf2`x'`y'`i''
			putexcel C`i'=`FP2f2`x'`y'`i''
			putexcel D`i'=`TP2f2`x'`y'`i''			
			putexcel E`i'=`Pf2`x'`y'`i''
			putexcel F`i'=`NPf2`x'`y'`i''
			}
		}
}

foreach x in 05 25 30 {
		foreach y in ubr ubrxg  {
		import excel "Census\Updated results\sample_sizes\only_pred\AUC_`x'_`y'5050.xlsx", sheet("Sheet1") clear
		g FPR_`x'`y'=A/F
        g TPR_`x'`y'=B/E
		g FPR_`x'`y'2=C/F
        g TPR_`x'`y'2=D/E		
		export excel using "Census\Updated results\sample_sizes\only_pred\AUC_`x'_`y'5050.xlsx", replace firstrow(variables)
	}
}

putexcel set "Census\Updated results\sample_sizes\only_pred\Correlations_predicted_actual_lasso_xgboost5050", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"


putexcel D2="All districts-poorest 50% HH"
putexcel E2="UBR districts-poorest 50% HH"

putexcel D3=`rhof50_05_full'
putexcel D4=`pf50_05_full'
putexcel D5=`Nf50_05_full'
putexcel E3=`rhou50_05_ubr'
putexcel E4=`pu50_05_ubr'
putexcel E5=`Nu50_05_ubr'

putexcel D6=`rhof50_25_full'
putexcel D7=`pf50_25_full'
putexcel D8=`Nf50_25_full'
putexcel E6=`rhou50_25_ubr'
putexcel E7=`pu50_25_ubr'
putexcel E8=`Nu50_25_ubr'

putexcel D9=`rhof50_30_full'
putexcel D10=`pf50_30_full'
putexcel D11=`Nf50_30_full'
putexcel E9=`rhou50_30_ubr'
putexcel E10=`pu50_30_ubr'
putexcel E11=`Nu50_30_ubr'


putexcel set "Census\Updated results\sample_sizes\only_pred\Correlations_predicted_actual_xgboost_xgboost5050", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel D2="All districts-poorest 50% HH"
putexcel E2="UBR districts-poorest 50% HH"

putexcel D3=`rhof50_05_fullxg'
putexcel D4=`pf50_05_fullxg'
putexcel D5=`Nf50_05_fullxg'
putexcel E3=`rhou50_05_ubrxg'
putexcel E4=`pu50_05_ubrxg'
putexcel E5=`Nu50_05_ubrxg'

putexcel D6=`rhof50_25_fullxg'
putexcel D7=`pf50_25_fullxg'
putexcel D8=`Nf50_25_fullxg'
putexcel E6=`rhou50_25_ubrxg'
putexcel E7=`pu50_25_ubrxg'
putexcel E8=`Nu50_25_ubrxg'

putexcel D9=`rhof50_30_fullxg'
putexcel D10=`pf50_30_fullxg'
putexcel D11=`Nf50_30_fullxg'
putexcel E9=`rhou50_30_ubrxg'
putexcel E10=`pu50_30_ubrxg'
putexcel E11=`Nu50_30_ubrxg'

***************************************************************************************
*** AUC graphs and AUC
*** True measure LASSO, prediction XGB
foreach x in 05 25 30 {
	foreach y in full fullxg ubr ubrxg  {
		import excel "C:\Users\melyg\Desktop\Malawi\Census\Updated results\sample_sizes\only_pred\AUC_`x'_`y'5050.xlsx", sheet("Sheet1") firstrow clear
		set obs `=_N+1'
		replace TPR_`x'`y'=1 if TPR_`x'`y'==.
		replace FPR_`x'`y'=1 if FPR_`x'`y'==.
		replace TPR_`x'`y'2=1 if TPR_`x'`y'2==.
		replace FPR_`x'`y'2=1 if FPR_`x'`y'2==.
***Area under the curve
	integ TPR_`x'`y' FPR_`x'`y', gen(total_auc_`x'`y')
	local auc1_`x'`y'=r(integral) 

		
***Area under the curve
	integ  TPR_`x'`y'2 FPR_`x'`y'2, gen(total_auc`x'`y'2)
	local auc2_`x'`y'=r(integral) 
}

}

putexcel set "Census\Updated results\sample_sizes\only_pred\AUC_predictions_xgb5050", replace

putexcel B1="Full50"
putexcel D1="UBR50"

putexcel A2="True measure estimated with LASSO"
putexcel A5="True measure estimated with XGB"

putexcel B2=`auc1_05full'
putexcel D2=`auc1_05ubr'

putexcel B3=`auc1_25full'
putexcel D3=`auc1_25ubr'

putexcel B4=`auc1_30full'
putexcel D4=`auc1_30ubr'

putexcel B5=`auc1_05fullxg'
putexcel D5=`auc1_05ubrxg'

putexcel B6=`auc1_25fullxg'
putexcel D6=`auc1_25ubrxg'

putexcel B7=`auc1_30fullxg'
putexcel D7=`auc1_30ubrxg'



putexcel C2=`auc2_05full'
putexcel E2=`auc2_05ubr'

putexcel C3=`auc2_25full'
putexcel E3=`auc2_25ubr'

putexcel C4=`auc2_30full'
putexcel E4=`auc2_30ubr'

putexcel C5=`auc2_05fullxg'
putexcel E5=`auc2_05ubrxg'

putexcel C6=`auc2_25fullxg'
putexcel E6=`auc2_25ubrxg'

putexcel C7=`auc2_30fullxg'
putexcel E7=`auc2_30ubrxg'

