cd "C:\Users\melyg\Desktop\Malawi"

*** This do-file calculates rank correlations and AUC for updating method 1 using predictions made with XGBOOST mnodels

*************************************************************************
***Append out of sample predictions and 10,15, 20% training samples.
***For models using all HH-all districts (lasso and xgb)
foreach x in 10 15 20 {
	foreach y in full fullxg  {
		use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full_ubr_`x'_out`y'.dta", clear
		append using "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full_ubr_`x'_train`y'.dta"
		destring  predcons_census_full predwelf_census_full, replace
		replace predwelf_census_full=predcons_census_full if predwelf_census_full==. //replacing the missing in the training sample as the actual values
		egen district=concat(V2 V3)
		drop V2 V3
		spearman  predcons_census_full predwelf_census_full
		local rhof_`x'_`y'=r(rho)
		local pf_`x'_`y'=r(p)
		local Nf_`x'_`y'=r(N)
		g test=1
		
		reg predcons_census_full predwelf_census_full
		ereturn list
		local r_`x'_`y'=e(r2)
		
		/*
		putexcel set "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'", replace

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
		
		}*/
		
	}

}

***R-squared
di `r_10_fullxg'

foreach x in 10 15 20 {
	foreach y in full fullxg  {
		import excel "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'.xlsx", sheet("Sheet1") clear firstrow
		g FPR_`x'`y'=A/F
        g TPR_`x'`y'=B/E
		g FPR_`x'`y'2=C/F
        g TPR_`x'`y'2=D/E		
		keep FPR* TPR*
		export excel using "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'v2.xlsx", replace firstrow(varlabels)
	}
}

***For models using UBR districts-all HH (lasso and xgb)
foreach x in 10 15 20 {
	foreach y in ubr ubrxg  {
		use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full_ubr_`x'_out`y'.dta", clear
		append using "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full_ubr_`x'_train`y'.dta"
		destring  predcons_census_ubr predwelf_census_ubr, replace
		replace predwelf_census_ubr=predcons_census_ubr if predwelf_census_ubr==. //replacing the missing in the training sample as the actual values
		egen district=concat(V2 V3)
		drop V2 V3
		spearman  predcons_census_ubr predwelf_census_ubr
		local rhou_`x'_`y'=r(rho)
		local pu_`x'_`y'=r(p)
		local Nu_`x'_`y'=r(N)
		g test=1

		putexcel set "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'", replace
	
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

foreach x in 10 15 20 {
	foreach y in ubr ubrxg  {
		import excel "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'.xlsx", sheet("Sheet1") clear
		g FPR_`x'`y'=A/F
        g TPR_`x'`y'=B/E
		g FPR_`x'`y'2=C/F
        g TPR_`x'`y'2=D/E	
		keep FPR* TPR*
		export excel using "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'v2.xlsx", replace firstrow(varlabels)
	}
}
****************************************
*** For models using all districts -poorest 50% of HH-
*** LASSO and XGBOOST
foreach x in 10 15 20 {
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_outfullxg.dta", clear
rename predcons_xgb_full predcons_census_full 
rename predwelf_xgb_full predwelf_census_full
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_outfullxgn.dta", replace
}

foreach x in 10 15 20 {
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_outubrxg.dta", clear
rename predcons_xgb_ubr predcons_census_ubr 
rename predwelf_xgb_ubr predwelf_census_ubr
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_outubrxgn.dta", replace
}

foreach x in 10 15 20 {
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_trainfullxg.dta", clear
rename predcons_xgb_full predcons_census_full 
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_trainfullxgn.dta", replace
}

foreach x in 10 15 20 {
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_trainubrxg.dta", clear
rename predcons_xgb_ubr predcons_census_ubr 
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_trainubrxgn.dta", replace
}

foreach x in 10 15 20 {
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_outfull.dta", clear
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_outfulln.dta", replace
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_outubr.dta", clear
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_outubrn.dta", replace
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_trainfull.dta", clear
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_trainfulln.dta", replace
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_trainubr.dta", clear
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_trainubrn.dta", replace
}
			

			
foreach x in 10 15 20 {
		foreach y in full fullxg  {
			use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_out`y'n.dta", clear
			append using "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_train`y'n.dta"
			destring  predcons_census_full predwelf_census_full, replace
			replace predwelf_census_full=predcons_census_full if predwelf_census_full==. //replacing the missing in the training sample as the actual values
			egen district=concat(V2 V3)
			drop V2 V3
			
			spearman  predcons_census_full predwelf_census_full
			local rhof50_`x'_`y'=r(rho)
			local pf50_`x'_`y'=r(p)
			local Nf50_`x'_`y'=r(N)
			g test=1

			putexcel set "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'50", replace

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

foreach x in 10 15 20 {
		foreach y in full fullxg  {
		import excel "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'50.xlsx", sheet("Sheet1") clear
		g FPR_`x'`y'50=A/F
        g TPR_`x'`y'50=B/E
		g FPR_`x'`y'502=C/F
        g TPR_`x'`y'502=D/E
		keep FPR* TPR*
		export excel using "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'50v2.xlsx", replace firstrow(varlabels)
	}
}

*** For models using UBR districts -poorest 50% of HH

foreach x in 10 15 20 {
		foreach y in ubr ubrxg  {
			use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_out`y'n.dta", clear
			append using "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_train`y'n.dta"
			destring  predcons_census_ubr predwelf_census_ubr, replace
			replace predwelf_census_ubr=predcons_census_ubr if predwelf_census_ubr==. //replacing the missing in the training sample as the actual values
			egen district=concat(V2 V3)
			drop V2 V3
			
			spearman  predcons_census_ubr predwelf_census_ubr
			local rhou50_`x'_`y'=r(rho)
			local pu50_`x'_`y'=r(p)
			local Nu50_`x'_`y'=r(N)
			g test=1

			putexcel set "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'50", replace

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

foreach x in 10 15 20 {
		foreach y in ubr ubrxg  {
		import excel "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'50.xlsx", sheet("Sheet1") clear
		g FPR_`x'`y'50=A/F
        g TPR_`x'`y'50=B/E
		g FPR_`x'`y'502=C/F
        g TPR_`x'`y'502=D/E	
		keep FPR* TPR*
		export excel using "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'50v2.xlsx", replace firstrow(varlabels)
	}
}


*** Rank correlations when using benchmark welfare predicted using LASSO models
putexcel set "Census\Updated results\out_of_sample_updt1_xgb\Correlations_predicted_actual_lasso_xgboost", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel B2="Predicted consumption based on all districts in IHS"
putexcel C2="Predicted consumption based on UBR districts in IHS"
putexcel D2="Predicted consumption based on Poorest 50% HH in all districts in IHS"
putexcel E2="Predicted consumption based on Poorest 50% HH in UBR districts in IHS"
putexcel B3=`rhof_10_full'
putexcel B4=`pf_10_full'
putexcel B5=`Nf_10_full'
putexcel C3=`rhou_10_ubr'
putexcel C4=`pu_10_ubr'
putexcel C5=`Nu_10_ubr'

putexcel B6=`rhof_15_full'
putexcel B7=`pf_15_full'
putexcel B8=`Nf_15_full'
putexcel C6=`rhou_15_ubr'
putexcel C7=`pu_15_ubr'
putexcel C8=`Nu_15_ubr'

putexcel B9=`rhof_20_full'
putexcel B10=`pf_20_full'
putexcel B11=`Nf_20_full'
putexcel C9=`rhou_20_ubr'
putexcel C10=`pu_20_ubr'
putexcel C11=`Nu_20_ubr'

putexcel D3=`rhof50_10_full'
putexcel D4=`pf50_10_full'
putexcel D5=`Nf50_10_full'
putexcel E3=`rhou50_10_ubr'
putexcel E4=`pu50_10_ubr'
putexcel E5=`Nu50_10_ubr'

putexcel D6=`rhof50_15_full'
putexcel D7=`pf50_15_full'
putexcel D8=`Nf50_15_full'
putexcel E6=`rhou50_15_ubr'
putexcel E7=`pu50_15_ubr'
putexcel E8=`Nu50_15_ubr'

putexcel D9=`rhof50_20_full'
putexcel D10=`pf50_20_full'
putexcel D11=`Nf50_20_full'
putexcel E9=`rhou50_20_ubr'
putexcel E10=`pu50_20_ubr'
putexcel E11=`Nu50_20_ubr'

*** Rank correlations when using benchmark welfare predicted using XGBOOST models

putexcel set "Census\Updated results\out_of_sample_updt1_xgb\Correlations_predicted_actual_xgboost_xgboost", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel B2="Predicted consumption based on all districts in IHS"
putexcel C2="Predicted consumption based on UBR districts in IHS"
putexcel D2="Predicted consumption based on Poorest 50% HH in all districts in IHS"
putexcel E2="Predicted consumption based on Poorest 50% HH in UBR districts in IHS"
putexcel B3=`rhof_10_fullxg'
putexcel B4=`pf_10_fullxg'
putexcel B5=`Nf_10_fullxg'
putexcel C3=`rhou_10_ubrxg'
putexcel C4=`pu_10_ubrxg'
putexcel C5=`Nu_10_ubrxg'

putexcel B6=`rhof_15_fullxg'
putexcel B7=`pf_15_fullxg'
putexcel B8=`Nf_15_fullxg'
putexcel C6=`rhou_15_ubrxg'
putexcel C7=`pu_15_ubrxg'
putexcel C8=`Nu_15_ubrxg'

putexcel B9=`rhof_20_fullxg'
putexcel B10=`pf_20_fullxg'
putexcel B11=`Nf_20_fullxg'
putexcel C9=`rhou_20_ubrxg'
putexcel C10=`pu_20_ubrxg'
putexcel C11=`Nu_20_ubrxg'

putexcel D3=`rhof50_10_fullxg'
putexcel D4=`pf50_10_fullxg'
putexcel D5=`Nf50_10_fullxg'
putexcel E3=`rhou50_10_ubrxg'
putexcel E4=`pu50_10_ubrxg'
putexcel E5=`Nu50_10_ubrxg'

putexcel D6=`rhof50_15_fullxg'
putexcel D7=`pf50_15_fullxg'
putexcel D8=`Nf50_15_fullxg'
putexcel E6=`rhou50_15_ubrxg'
putexcel E7=`pu50_15_ubrxg'
putexcel E8=`Nu50_15_ubrxg'

putexcel D9=`rhof50_20_fullxg'
putexcel D10=`pf50_20_fullxg'
putexcel D11=`Nf50_20_fullxg'
putexcel E9=`rhou50_20_ubrxg'
putexcel E10=`pu50_20_ubrxg'
putexcel E11=`Nu50_20_ubrxg'


***************************************************************************************
*** AUC graphs and AUC
*** True measure LASSO, prediction XGB
/*
foreach i in 10 15 20 {
import excel "C:\Users\melyg\Desktop\Malawi\Census\Updated results\out_of_sample_updt1_xgb\FTR_TPR_lasso_xgb_`i'.xlsx", sheet("Sheet1") firstrow clear

twoway (scatter TPR_full FPR_full, msize(tiny) graphregion(fcolor(white))) ///
       (scatter TPR_ubr FPR_ubr, msize(tiny)) ///
	   (scatter TPR_full50 FPR_full50, msize(vsmall) msymbol(diamond_hollow) ) ///
	   (scatter TPR_ubr50 FPR_ubr50, msize(vsmall) msymbol(diamond_hollow) ) ///
	   (lpoly TPR_full FPR_full) ///
       (lpoly TPR_ubr FPR_ubr) ///
	   (lpoly TPR_full50 FPR_full50) ///
	   (lpoly TPR_ubr50 FPR_ubr50), ///
	    ytitle(True Positive Rate, size(8pt)) xtitle(False Positive Rate, size(8pt)) ///
		xlabel(, labsize(vsmall)) ylabel(, labsize(vsmall)) ///
		title("True:LASSO, Sample `i'%", size(8pt)) ///
		legend(order(1 "Full" 2 "UBR" 3 "Full50" 4 "UBR50") size(vsmall) cols(4))  saving(auc1_`i', replace)

set obs `=_N+1'

foreach x in full ubr full50 ubr50  {
	replace TPR_`x'=1 if TPR_`x'==.
	replace FPR_`x'=1 if FPR_`x'==.
}		
		
***Area under the curve
foreach x in full ubr full50 ubr50 {
	integ TPR_`x' FPR_`x', gen(total_auc`x'`i') trapezoid
	local auc1_`x'`i'=r(integral) 
}
*/
	foreach y in full ubr full50 ubr50  {
		foreach x in 10 15 20 {

		import excel "C:\Users\melyg\Desktop\Malawi\Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'v2.xlsx", sheet("Sheet1") firstrow clear
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

*** True measure XGB, prediction XGB
/*
import excel "C:\Users\melyg\Desktop\Malawi\Census\Updated results\out_of_sample_updt1_xgb\FTR_TPR_xgb_xgb_`i'.xlsx", sheet("Sheet1") firstrow clear

twoway (scatter TPR_full FPR_full, msize(tiny) graphregion(fcolor(white))) ///
       (scatter TPR_ubr FPR_ubr, msize(tiny)) ///
	   (scatter TPR_full50 FPR_full50, msize(vsmall) msymbol(diamond_hollow) ) ///
	   (scatter TPR_ubr50 FPR_ubr50, msize(vsmall) msymbol(diamond_hollow) ) ///
	   (lpoly TPR_full FPR_full) ///
       (lpoly TPR_ubr FPR_ubr) ///
	   (lpoly TPR_full50 FPR_full50) ///
	   (lpoly TPR_ubr50 FPR_ubr50), ///
	    ytitle(True Positive Rate, size(8pt)) xtitle(False Positive Rate, size(8pt)) ///
		xlabel(, labsize(vsmall)) ylabel(, labsize(vsmall)) ///
		title("True:XGB, Sample `i'%", size(8pt)) ///
		legend(order(1 "Full" 2 "UBR" 3 "Full50" 4 "UBR50") size(vsmall) cols(4))  saving(auc2_`i', replace)

set obs `=_N+1'

foreach x in full ubr full50 ubr50  {
	replace TPR_`x'=1 if TPR_`x'==.
	replace FPR_`x'=1 if FPR_`x'==.
}

***Area under the curve
foreach x in full ubr full50 ubr50 {
	integ  TPR_`x' FPR_`x', gen(total_auc`x'`i') trapezoid
	local auc2_`x'`i'=r(integral) 
}

}
*/

foreach x in 10 15 20 {
	foreach y in fullxg ubrxg  fullxg50  ubrxg50 {
		import excel "C:\Users\melyg\Desktop\Malawi\Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'v2.xlsx", sheet("Sheet1") firstrow clear
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



putexcel set "Census\Updated results\out_of_sample_updt1_xgb\AUC_predictions_xgb", replace

putexcel B1="Full"
putexcel D1="UBR"
putexcel F1="Full50"
putexcel H1="UBR50"


putexcel A2="True measure estimated with LASSO"
putexcel A5="True measure estimated with XGB"

putexcel B2=`auc1_10full'
putexcel D2=`auc1_10ubr'
putexcel F2=`auc1_10full50'
putexcel H2=`auc1_10ubr50'

putexcel B3=`auc1_15full'
putexcel D3=`auc1_15ubr'
putexcel F3=`auc1_15full50'
putexcel H3=`auc1_15ubr50'

putexcel B4=`auc1_20full'
putexcel D4=`auc1_20ubr'
putexcel F4=`auc1_20full50'
putexcel H4=`auc1_20ubr50'

putexcel B5=`auc1_10fullxg'
putexcel D5=`auc1_10ubrxg'
putexcel F5=`auc1_10fullxg50'
putexcel H5=`auc1_10ubrxg50'

putexcel B6=`auc1_15fullxg'
putexcel D6=`auc1_15ubrxg'
putexcel F6=`auc1_15fullxg50'
putexcel H6=`auc1_15ubrxg50'

putexcel B7=`auc1_20fullxg'
putexcel D7=`auc1_20ubrxg'
putexcel F7=`auc1_20fullxg50'
putexcel H7=`auc1_20ubrxg50'


putexcel C2=`auc2_10full'
putexcel E2=`auc2_10ubr'
putexcel G2=`auc2_10full50'
putexcel I2=`auc2_10ubr50'

putexcel C3=`auc2_15full'
putexcel E3=`auc2_15ubr'
putexcel G3=`auc2_15full50'
putexcel I3=`auc2_15ubr50'

putexcel C4=`auc2_20full'
putexcel E4=`auc2_20ubr'
putexcel G4=`auc2_20full50'
putexcel I4=`auc2_20ubr50'

putexcel C5=`auc2_10fullxg'
putexcel E5=`auc2_10ubrxg'
putexcel G5=`auc2_10fullxg50'
putexcel I5=`auc2_10ubrxg50'

putexcel C6=`auc2_15fullxg'
putexcel E6=`auc2_15ubrxg'
putexcel G6=`auc2_15fullxg50'
putexcel I6=`auc2_15ubrxg50'

putexcel C7=`auc2_20fullxg'
putexcel E7=`auc2_20ubrxg'
putexcel G7=`auc2_20fullxg50'
putexcel I7=`auc2_20ubrxg50'

*/

**********************************************************************************************
**********************************************************************************************
***Only using out of sample predictions
***Append out of sample and 10,15, 20% training samples.

***For FULL (lasso and xgb)
foreach x in 10 15 20 {
	foreach y in full fullxg  {
		use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full_ubr_`x'_out`y'.dta", clear
		*append using "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full_ubr_`x'_train`y'.dta"
		destring  predcons_census_full predwelf_census_full, replace
		*replace predwelf_census_full=predcons_census_full if predwelf_census_full==. //replacing the missing in the training sample as the actual values
		*egen district=concat(V2 V3)
		*drop V2 V3
		rename V3 district
		spearman  predcons_census_full predwelf_census_full
		local rhof_`x'_`y'=r(rho)
		local pf_`x'_`y'=r(p)
		local Nf_`x'_`y'=r(N)
		g test=1

		putexcel set "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'", replace

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

foreach x in 10 15 20 {
	foreach y in full fullxg  {
		import excel "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'.xlsx", sheet("Sheet1") clear
		g FPR_`x'`y'=A/F
        g TPR_`x'`y'=B/E
		g FPR_`x'`y'2=C/F
        g TPR_`x'`y'2=D/E
		keep FPR* TPR*
		export excel using "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'v2.xlsx",  replace firstrow(varlabels)
	}
}

***For UBR (lasso and xgb)
foreach x in 10 15 20 {
	foreach y in ubr ubrxg  {
		use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full_ubr_`x'_out`y'.dta", clear
		*append using "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full_ubr_`x'_train`y'.dta"
		destring  predcons_census_ubr predwelf_census_ubr, replace
		*replace predwelf_census_ubr=predcons_census_ubr if predwelf_census_ubr==. //replacing the missing in the training sample as the actual values
		*egen district=concat(V2 V3)
		*drop V2 V3
		rename V3 district
		spearman  predcons_census_ubr predwelf_census_ubr
		local rhou_`x'_`y'=r(rho)
		local pu_`x'_`y'=r(p)
		local Nu_`x'_`y'=r(N)
		g test=1

		putexcel set "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'", replace
	
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

foreach x in 10 15 20 {
	foreach y in ubr ubrxg  {
		import excel "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'.xlsx", sheet("Sheet1") clear
		g FPR_`x'`y'=A/F
        g TPR_`x'`y'=B/E
		g FPR_`x'`y'2=C/F
        g TPR_`x'`y'2=D/E	
		keep TPR* FPR*
		export excel using "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'v2.xlsx", replace firstrow(varlabels)
	}
}


****************************************
***For FULL50 lasso XGBOOST
foreach x in 10 15 20 {
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_outfullxg.dta", clear
rename predcons_xgb_full predcons_census_full 
rename predwelf_xgb_full predwelf_census_full
save "Census\Updated results\out_of_sample_updt1_xgb\only_pred\pred_xgboos_full50_ubr50_`x'_outfullxgn.dta", replace
}

foreach x in 10 15 20 {
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_outubrxg.dta", clear
rename predcons_xgb_ubr predcons_census_ubr 
rename predwelf_xgb_ubr predwelf_census_ubr
save "Census\Updated results\out_of_sample_updt1_xgb\only_pred\pred_xgboos_full50_ubr50_`x'_outubrxgn.dta", replace
}



foreach x in 10 15 20 {
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_outfull.dta", clear
save "Census\Updated results\out_of_sample_updt1_xgb\only_pred\pred_xgboos_full50_ubr50_`x'_outfulln.dta", replace
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_outubr.dta", clear
save "Census\Updated results\out_of_sample_updt1_xgb\only_pred\pred_xgboos_full50_ubr50_`x'_outubrn.dta", replace

}
			
		
foreach x in 10 15 20 {
		foreach y in full fullxg  {
			use "Census\Updated results\out_of_sample_updt1_xgb\only_pred\pred_xgboos_full50_ubr50_`x'_out`y'n.dta", clear
			*append using "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_train`y'n.dta"
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

			putexcel set "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'50", replace

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

foreach x in 10 15 20 {
		foreach y in full fullxg  {
		import excel "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'50.xlsx", sheet("Sheet1") clear
		g FPR_`x'`y'50=A/F
        g TPR_`x'`y'50=B/E
		g FPR_`x'`y'502=C/F
        g TPR_`x'`y'502=D/E
		keep TPR* FPR*
		export excel using "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'50v2.xlsx", replace firstrow(varlabels)
	}
}


***For UBR50 LASSO and XGBOOST
foreach x in 10 15 20 {
		foreach y in ubr ubrxg  {
			use "Census\Updated results\out_of_sample_updt1_xgb\only_pred\pred_xgboos_full50_ubr50_`x'_out`y'n.dta", clear
			*append using "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_train`y'n.dta"
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

			putexcel set "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'50", replace

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

foreach x in 10 15 20 {
		foreach y in ubr ubrxg  {
		import excel "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'50.xlsx", sheet("Sheet1") clear
		g FPR_`x'`y'50=A/F
        g TPR_`x'`y'50=B/E
		g FPR_`x'`y'502=C/F
        g TPR_`x'`y'502=D/E	
		keep TPR* FPR*
		export excel using "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'50v2.xlsx", replace firstrow(varlabels)
	}
}

putexcel set "Census\Updated results\out_of_sample_updt1_xgb\only_pred\Correlations_predicted_actual_lasso_xgboost", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel B2="All districts-all HH"
putexcel C2="UBR districts-all HH"
putexcel D2="All districts-poorest 50% HH"
putexcel E2="UBR districts-poorest 50% HH"
putexcel B3=`rhof_10_full'
putexcel B4=`pf_10_full'
putexcel B5=`Nf_10_full'
putexcel C3=`rhou_10_ubr'
putexcel C4=`pu_10_ubr'
putexcel C5=`Nu_10_ubr'

putexcel B6=`rhof_15_full'
putexcel B7=`pf_15_full'
putexcel B8=`Nf_15_full'
putexcel C6=`rhou_15_ubr'
putexcel C7=`pu_15_ubr'
putexcel C8=`Nu_15_ubr'

putexcel B9=`rhof_20_full'
putexcel B10=`pf_20_full'
putexcel B11=`Nf_20_full'
putexcel C9=`rhou_20_ubr'
putexcel C10=`pu_20_ubr'
putexcel C11=`Nu_20_ubr'

putexcel D3=`rhof50_10_full'
putexcel D4=`pf50_10_full'
putexcel D5=`Nf50_10_full'
putexcel E3=`rhou50_10_ubr'
putexcel E4=`pu50_10_ubr'
putexcel E5=`Nu50_10_ubr'

putexcel D6=`rhof50_15_full'
putexcel D7=`pf50_15_full'
putexcel D8=`Nf50_15_full'
putexcel E6=`rhou50_15_ubr'
putexcel E7=`pu50_15_ubr'
putexcel E8=`Nu50_15_ubr'

putexcel D9=`rhof50_20_full'
putexcel D10=`pf50_20_full'
putexcel D11=`Nf50_20_full'
putexcel E9=`rhou50_20_ubr'
putexcel E10=`pu50_20_ubr'
putexcel E11=`Nu50_20_ubr'


putexcel set "Census\Updated results\out_of_sample_updt1_xgb\only_pred\Correlations_predicted_actual_xgboost_xgboost", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel B2="All districts-all HH"
putexcel C2="UBR districts-all HH"
putexcel D2="All districts-poorest 50% HH"
putexcel E2="UBR districts-poorest 50% HH"
putexcel B3=`rhof_10_fullxg'
putexcel B4=`pf_10_fullxg'
putexcel B5=`Nf_10_fullxg'
putexcel C3=`rhou_10_ubrxg'
putexcel C4=`pu_10_ubrxg'
putexcel C5=`Nu_10_ubrxg'

putexcel B6=`rhof_15_fullxg'
putexcel B7=`pf_15_fullxg'
putexcel B8=`Nf_15_fullxg'
putexcel C6=`rhou_15_ubrxg'
putexcel C7=`pu_15_ubrxg'
putexcel C8=`Nu_15_ubrxg'

putexcel B9=`rhof_20_fullxg'
putexcel B10=`pf_20_fullxg'
putexcel B11=`Nf_20_fullxg'
putexcel C9=`rhou_20_ubrxg'
putexcel C10=`pu_20_ubrxg'
putexcel C11=`Nu_20_ubrxg'

putexcel D3=`rhof50_10_fullxg'
putexcel D4=`pf50_10_fullxg'
putexcel D5=`Nf50_10_fullxg'
putexcel E3=`rhou50_10_ubrxg'
putexcel E4=`pu50_10_ubrxg'
putexcel E5=`Nu50_10_ubrxg'

putexcel D6=`rhof50_15_fullxg'
putexcel D7=`pf50_15_fullxg'
putexcel D8=`Nf50_15_fullxg'
putexcel E6=`rhou50_15_ubrxg'
putexcel E7=`pu50_15_ubrxg'
putexcel E8=`Nu50_15_ubrxg'

putexcel D9=`rhof50_20_fullxg'
putexcel D10=`pf50_20_fullxg'
putexcel D11=`Nf50_20_fullxg'
putexcel E9=`rhou50_20_ubrxg'
putexcel E10=`pu50_20_ubrxg'
putexcel E11=`Nu50_20_ubrxg'


***************************************************************************************
*** True measure LASSO, prediction XGB
/*
foreach i in 10 15 20 {
import excel "C:\Users\melyg\Desktop\Malawi\Census\Updated results\out_of_sample_updt1_xgb\only_pred\FTR_TPR_lasso_xgb_`i'.xlsx", sheet("Sheet1") firstrow clear

twoway (scatter TPR_full FPR_full, msize(tiny) graphregion(fcolor(white))) ///
       (scatter TPR_ubr FPR_ubr, msize(tiny)) ///
	   (scatter TPR_full50 FPR_full50, msize(vsmall) msymbol(diamond_hollow) ) ///
	   (scatter TPR_ubr50 FPR_ubr50, msize(vsmall) msymbol(diamond_hollow) ) ///
	   (lpoly TPR_full FPR_full) ///
       (lpoly TPR_ubr FPR_ubr) ///
	   (lpoly TPR_full50 FPR_full50) ///
	   (lpoly TPR_ubr50 FPR_ubr50), ///
	    ytitle(True Positive Rate, size(8pt)) xtitle(False Positive Rate, size(8pt)) ///
		xlabel(, labsize(vsmall)) ylabel(, labsize(vsmall)) ///
		title("True:LASSO, Sample `i'%", size(8pt)) ///
		legend(order(1 "Full" 2 "UBR" 3 "Full50" 4 "UBR50") size(vsmall) cols(4))  saving(auc1_`i', replace)

		
***Area under the curve
foreach x in full ubr full50 ubr50 {
	integ TPR_`x' FPR_`x', gen(total_auc`x'`i')
	local auc1_`x'`i'=r(integral) 
}
*/

	foreach y in full ubr full50 ubr50  {
		foreach x in 10 15 20 {

		import excel "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'v2.xlsx", sheet("Sheet1") firstrow clear
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

*** True measure XGB, prediction XGB
/*
import excel "C:\Users\melyg\Desktop\Malawi\Census\Updated results\out_of_sample_updt1_xgb\only_pred\FTR_TPR_xgb_xgb_`i'.xlsx", sheet("Sheet1") firstrow clear

twoway (scatter TPR_full FPR_full, msize(tiny) graphregion(fcolor(white))) ///
       (scatter TPR_ubr FPR_ubr, msize(tiny)) ///
	   (scatter TPR_full50 FPR_full50, msize(vsmall) msymbol(diamond_hollow) ) ///
	   (scatter TPR_ubr50 FPR_ubr50, msize(vsmall) msymbol(diamond_hollow) ) ///
	   (lpoly TPR_full FPR_full) ///
       (lpoly TPR_ubr FPR_ubr) ///
	   (lpoly TPR_full50 FPR_full50) ///
	   (lpoly TPR_ubr50 FPR_ubr50), ///
	    ytitle(True Positive Rate, size(8pt)) xtitle(False Positive Rate, size(8pt)) ///
		xlabel(, labsize(vsmall)) ylabel(, labsize(vsmall)) ///
		title("True:XGB, Sample `i'%", size(8pt)) ///
		legend(order(1 "Full" 2 "UBR" 3 "Full50" 4 "UBR50") size(vsmall) cols(4))  saving(auc2_`i', replace)
		
***Area under the curve
foreach x in full ubr full50 ubr50 {
	integ  TPR_`x' FPR_`x', gen(total_auc`x'`i')
	local auc2_`x'`i'=r(integral) 
}

}

graph combine auc1_10.gph auc1_15.gph auc1_20.gph auc2_10.gph auc2_15.gph auc2_20.gph, ///
title("False positive rates vs. True positive rates using XGBOOST" , size(8pt)) 
graph export "Census\Updated results\out_of_sample_updt1_xgb\only_pred\auc_pred_xgb.pdf", replace
*/

foreach x in 10 15 20 {
	foreach y in fullxg ubrxg  fullxg50  ubrxg50 {
		import excel "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'v2.xlsx", sheet("Sheet1") firstrow clear
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

putexcel set "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_predictions_xgb", replace

putexcel B1="Full"
putexcel D1="UBR"
putexcel F1="Full50"
putexcel H1="UBR50"


putexcel A2="True measure estimated with LASSO"
putexcel A5="True measure estimated with XGB"

putexcel B2=`auc1_10full'
putexcel D2=`auc1_10ubr'
putexcel F2=`auc1_10full50'
putexcel H2=`auc1_10ubr50'

putexcel B3=`auc1_15full'
putexcel D3=`auc1_15ubr'
putexcel F3=`auc1_15full50'
putexcel H3=`auc1_15ubr50'

putexcel B4=`auc1_20full'
putexcel D4=`auc1_20ubr'
putexcel F4=`auc1_20full50'
putexcel H4=`auc1_20ubr50'

putexcel B5=`auc1_10fullxg'
putexcel D5=`auc1_10ubrxg'
putexcel F5=`auc1_10fullxg50'
putexcel H5=`auc1_10ubrxg50'

putexcel B6=`auc1_15fullxg'
putexcel D6=`auc1_15ubrxg'
putexcel F6=`auc1_15fullxg50'
putexcel H6=`auc1_15ubrxg50'

putexcel B7=`auc1_20fullxg'
putexcel D7=`auc1_20ubrxg'
putexcel F7=`auc1_20fullxg50'
putexcel H7=`auc1_20ubrxg50'


putexcel C2=`auc2_10full'
putexcel E2=`auc2_10ubr'
putexcel G2=`auc2_10full50'
putexcel I2=`auc2_10ubr50'

putexcel C3=`auc2_15full'
putexcel E3=`auc2_15ubr'
putexcel G3=`auc2_15full50'
putexcel I3=`auc2_15ubr50'

putexcel C4=`auc2_20full'
putexcel E4=`auc2_20ubr'
putexcel G4=`auc2_20full50'
putexcel I4=`auc2_20ubr50'

putexcel C5=`auc2_10fullxg'
putexcel E5=`auc2_10ubrxg'
putexcel G5=`auc2_10fullxg50'
putexcel I5=`auc2_10ubrxg50'

putexcel C6=`auc2_15fullxg'
putexcel E6=`auc2_15ubrxg'
putexcel G6=`auc2_15fullxg50'
putexcel I6=`auc2_15ubrxg50'

putexcel C7=`auc2_20fullxg'
putexcel E7=`auc2_20ubrxg'
putexcel G7=`auc2_20fullxg50'
putexcel I7=`auc2_20ubrxg50'

**********************************************************************************************
*************************************************************************************************
***Last additions full5050 ubr5050
***OUT+training

****************************************
*** For models using all districts -poorest 50% of HH-
*** LASSO and XGBOOST
foreach x in 10 15 20 {
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_outfullxg.dta", clear
rename predcons_xgb_full predcons_census_full 
rename predwelf_xgb_full predwelf_census_full
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_outfullxgn.dta", replace
}

foreach x in 10 15 20 {
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_outubrxg.dta", clear
rename predcons_xgb_ubr predcons_census_ubr 
rename predwelf_xgb_ubr predwelf_census_ubr
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_outubrxgn.dta", replace
}

foreach x in 10 15 20 {
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_trainfullxg.dta", clear
rename predcons_xgb_full predcons_census_full 
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_trainfullxgn.dta", replace
}

foreach x in 10 15 20 {
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_trainubrxg.dta", clear
rename predcons_xgb_ubr predcons_census_ubr 
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_trainubrxgn.dta", replace
}

foreach x in 10 15 20 {
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_outfull.dta", clear
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_outfulln.dta", replace
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_outubr.dta", clear
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_outubrn.dta", replace
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_trainfull.dta", clear
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_trainfulln.dta", replace
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_trainubr.dta", clear
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_trainubrn.dta", replace
}
			
			use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_outfullxgn.dta", clear
			append using "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_trainfullxgn.dta"
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

foreach x in 10 15 20 {
		foreach y in full fullxg  {
			use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_out`y'n.dta", clear
			append using "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_train`y'n.dta"
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
			
			putexcel set "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'5050v2", replace

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
di `r_10_fullxg'

foreach x in 10 15 20 {
		foreach y in full fullxg  {
		import excel "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'5050v2.xlsx", sheet("Sheet1") clear
		g FPR_`x'`y'=A/F
        g TPR_`x'`y'=B/E
		g FPR_`x'`y'2=C/F
        g TPR_`x'`y'2=D/E		
		keep FPR* TPR*
		export excel using "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'5050v2.xlsx", replace firstrow(variables)
	}
}

*** For models using UBR districts -poorest 50% of HH

foreach x in 10 15 20 {
		foreach y in ubr ubrxg  {
			use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_out`y'n.dta", clear
			append using "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_train`y'n.dta"
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
			/*
			putexcel set "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'5050v2", replace

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
			}*/
		}
}
***R-squared
di `r_10_ubrxg'

foreach x in 10 15 20 {
		foreach y in ubr ubrxg  {
		import excel "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'5050v2.xlsx", sheet("Sheet1") clear
		g FPR_`x'`y'=A/F
        g TPR_`x'`y'=B/E
		g FPR_`x'`y'2=C/F
        g TPR_`x'`y'2=D/E		
		
		keep FPR* TPR*
		
		export excel using "Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'5050v2.xlsx", replace firstrow(variables)
	}
}


*** Rank correlations when using benchmark welfare predicted using LASSO models
putexcel set "Census\Updated results\out_of_sample_updt1_xgb\Correlations_predicted_actual_lasso_xgboost5050", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel D2="Predicted consumption based on Poorest 50% HH in all districts in IHS"
putexcel E2="Predicted consumption based on Poorest 50% HH in UBR districts in IHS"

putexcel D3=`rhof50_10_full'
putexcel D4=`pf50_10_full'
putexcel D5=`Nf50_10_full'
putexcel E3=`rhou50_10_ubr'
putexcel E4=`pu50_10_ubr'
putexcel E5=`Nu50_10_ubr'

putexcel D6=`rhof50_15_full'
putexcel D7=`pf50_15_full'
putexcel D8=`Nf50_15_full'
putexcel E6=`rhou50_15_ubr'
putexcel E7=`pu50_15_ubr'
putexcel E8=`Nu50_15_ubr'

putexcel D9=`rhof50_20_full'
putexcel D10=`pf50_20_full'
putexcel D11=`Nf50_20_full'
putexcel E9=`rhou50_20_ubr'
putexcel E10=`pu50_20_ubr'
putexcel E11=`Nu50_20_ubr'

*** Rank correlations when using benchmark welfare predicted using XGBOOST models

putexcel set "Census\Updated results\out_of_sample_updt1_xgb\Correlations_predicted_actual_xgboost_xgboost5050", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"


putexcel D2="Predicted consumption based on Poorest 50% HH in all districts in IHS"
putexcel E2="Predicted consumption based on Poorest 50% HH in UBR districts in IHS"
putexcel D3=`rhof50_10_fullxg'
putexcel D4=`pf50_10_fullxg'
putexcel D5=`Nf50_10_fullxg'
putexcel E3=`rhou50_10_ubrxg'
putexcel E4=`pu50_10_ubrxg'
putexcel E5=`Nu50_10_ubrxg'

putexcel D6=`rhof50_15_fullxg'
putexcel D7=`pf50_15_fullxg'
putexcel D8=`Nf50_15_fullxg'
putexcel E6=`rhou50_15_ubrxg'
putexcel E7=`pu50_15_ubrxg'
putexcel E8=`Nu50_15_ubrxg'

putexcel D9=`rhof50_20_fullxg'
putexcel D10=`pf50_20_fullxg'
putexcel D11=`Nf50_20_fullxg'
putexcel E9=`rhou50_20_ubrxg'
putexcel E10=`pu50_20_ubrxg'
putexcel E11=`Nu50_20_ubrxg'


***************************************************************************************
*** AUC graphs and AUC
*** True measure LASSO, prediction XGB
foreach x in 10 15 20 {
	foreach y in full fullxg ubr ubrxg  {
		import excel "C:\Users\melyg\Desktop\Malawi\Census\Updated results\out_of_sample_updt1_xgb\AUC_`x'_`y'5050v2.xlsx", sheet("Sheet1") firstrow clear
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

putexcel set "Census\Updated results\out_of_sample_updt1_xgb\AUC_predictions_xgb5050v2", replace

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



putexcel C2=`auc2_10full'
putexcel E2=`auc2_10ubr'

putexcel C3=`auc2_15full'
putexcel E3=`auc2_15ubr'

putexcel C4=`auc2_20full'
putexcel E4=`auc2_20ubr'

putexcel C5=`auc2_10fullxg'
putexcel E5=`auc2_10ubrxg'

putexcel C6=`auc2_15fullxg'
putexcel E6=`auc2_15ubrxg'

putexcel C7=`auc2_20fullxg'
putexcel E7=`auc2_20ubrxg'


****************************************
****************************************
***Out of sample
***For FULL50 lasso XGBOOST
foreach x in 10 15 20 {
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_outfullxg.dta", clear
rename predcons_xgb_full predcons_census_full 
rename predwelf_xgb_full predwelf_census_full
save "Census\Updated results\out_of_sample_updt1_xgb\only_pred\pred_xgboos_full5050_ubr5050_`x'_outfullxgn.dta", replace
}

foreach x in 10 15 20 {
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_outubrxg.dta", clear
rename predcons_xgb_ubr predcons_census_ubr 
rename predwelf_xgb_ubr predwelf_census_ubr
save "Census\Updated results\out_of_sample_updt1_xgb\only_pred\pred_xgboos_full5050_ubr5050_`x'_outubrxgn.dta", replace
}



foreach x in 10 15 20 {
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_outfull.dta", clear
save "Census\Updated results\out_of_sample_updt1_xgb\only_pred\pred_xgboos_full5050_ubr5050_`x'_outfulln.dta", replace
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_`x'_outubr.dta", clear
save "Census\Updated results\out_of_sample_updt1_xgb\only_pred\pred_xgboos_full5050_ubr5050_`x'_outubrn.dta", replace

}
			
		
foreach x in 10 15 20 {
		foreach y in full fullxg  {
			use "Census\Updated results\out_of_sample_updt1_xgb\only_pred\pred_xgboos_full5050_ubr5050_`x'_out`y'n.dta", clear
			*append using "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_train`y'n.dta"
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

			putexcel set "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'5050", replace

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

foreach x in 10 15 20 {
		foreach y in full fullxg  {
		import excel "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'5050.xlsx", sheet("Sheet1") clear
		g FPR_`x'`y'=A/F
        g TPR_`x'`y'=B/E
		g FPR_`x'`y'2=C/F
        g TPR_`x'`y'2=D/E		
		export excel using "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'5050.xlsx", replace firstrow(variables)
	}
}


***For UBR50 LASSO and XGBOOST
foreach x in 10 15 20 {
		foreach y in ubr ubrxg  {
			use "Census\Updated results\out_of_sample_updt1_xgb\only_pred\pred_xgboos_full5050_ubr5050_`x'_out`y'n.dta", clear
			*append using "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full50_ubr50_`x'_train`y'n.dta"
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

			putexcel set "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'5050", replace

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

foreach x in 10 15 20 {
		foreach y in ubr ubrxg  {
		import excel "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'5050.xlsx", sheet("Sheet1") clear
		g FPR_`x'`y'=A/F
        g TPR_`x'`y'=B/E
		g FPR_`x'`y'2=C/F
        g TPR_`x'`y'2=D/E		
		export excel using "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'5050.xlsx", replace firstrow(variables)
	}
}

putexcel set "Census\Updated results\out_of_sample_updt1_xgb\only_pred\Correlations_predicted_actual_lasso_xgboost5050", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"


putexcel D2="All districts-poorest 50% HH"
putexcel E2="UBR districts-poorest 50% HH"

putexcel D3=`rhof50_10_full'
putexcel D4=`pf50_10_full'
putexcel D5=`Nf50_10_full'
putexcel E3=`rhou50_10_ubr'
putexcel E4=`pu50_10_ubr'
putexcel E5=`Nu50_10_ubr'

putexcel D6=`rhof50_15_full'
putexcel D7=`pf50_15_full'
putexcel D8=`Nf50_15_full'
putexcel E6=`rhou50_15_ubr'
putexcel E7=`pu50_15_ubr'
putexcel E8=`Nu50_15_ubr'

putexcel D9=`rhof50_20_full'
putexcel D10=`pf50_20_full'
putexcel D11=`Nf50_20_full'
putexcel E9=`rhou50_20_ubr'
putexcel E10=`pu50_20_ubr'
putexcel E11=`Nu50_20_ubr'


putexcel set "Census\Updated results\out_of_sample_updt1_xgb\only_pred\Correlations_predicted_actual_xgboost_xgboost5050", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel D2="All districts-poorest 50% HH"
putexcel E2="UBR districts-poorest 50% HH"

putexcel D3=`rhof50_10_fullxg'
putexcel D4=`pf50_10_fullxg'
putexcel D5=`Nf50_10_fullxg'
putexcel E3=`rhou50_10_ubrxg'
putexcel E4=`pu50_10_ubrxg'
putexcel E5=`Nu50_10_ubrxg'

putexcel D6=`rhof50_15_fullxg'
putexcel D7=`pf50_15_fullxg'
putexcel D8=`Nf50_15_fullxg'
putexcel E6=`rhou50_15_ubrxg'
putexcel E7=`pu50_15_ubrxg'
putexcel E8=`Nu50_15_ubrxg'

putexcel D9=`rhof50_20_fullxg'
putexcel D10=`pf50_20_fullxg'
putexcel D11=`Nf50_20_fullxg'
putexcel E9=`rhou50_20_ubrxg'
putexcel E10=`pu50_20_ubrxg'
putexcel E11=`Nu50_20_ubrxg'

***************************************************************************************
*** AUC graphs and AUC
*** True measure LASSO, prediction XGB
foreach x in 10 15 20 {
	foreach y in full fullxg ubr ubrxg  {
		import excel "C:\Users\melyg\Desktop\Malawi\Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_`x'_`y'5050.xlsx", sheet("Sheet1") firstrow clear
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

putexcel set "Census\Updated results\out_of_sample_updt1_xgb\only_pred\AUC_predictions_xgb5050", replace

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



putexcel C2=`auc2_10full'
putexcel E2=`auc2_10ubr'

putexcel C3=`auc2_15full'
putexcel E3=`auc2_15ubr'

putexcel C4=`auc2_20full'
putexcel E4=`auc2_20ubr'

putexcel C5=`auc2_10fullxg'
putexcel E5=`auc2_10ubrxg'

putexcel C6=`auc2_15fullxg'
putexcel E6=`auc2_15ubrxg'

putexcel C7=`auc2_20fullxg'
putexcel E7=`auc2_20ubrxg'

