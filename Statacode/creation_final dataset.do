cd "C:\Users\melyg\Desktop\Malawi"
/*
***********************************************************************
***Updating method 4 using LASSO
***********************************************************************
use "Survey/Updated results/IHS_proc.dta", clear
***Setting globals
global indepvar11="urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean moss_mean shrub_mean bare_mean ltype_12 ltype_13 ltype_14 nightlyr ch_10_18 ch_09_00 ch_99_90 ch_89_85" 
global indepvar12="count density cv_area cv_length mean_barea mean_blength tot_barea tot_blength sh_urban dist_roads_mean pdensity_mean_lag pdensity_mean BSG_mean_lag BSG_mean mean_rwi" 
global indepvar21="urban_mean_lag crops_mean_lag zscore_prec_lag zscore_ndwi_lag precyr_lag ndwiyr_lag waterperm_mean_lag waterseas_mean_lag zscore_ndvi_lag ndviyr_lag soilyr_lag grass_mean_lag moss_mean_lag shrub_mean_lag bare_mean_lag ltype_12_lag ltype_13_lag ltype_14_lag nightlyr_lag ch_10_18 ch_09_00 ch_99_90 ch_89_85"
global indepvar13="q_asset_1 q_asset_2 q_asset_3 q_asset_4 q_asset_5 q_asset_6 electricity2"

global sample="UBR" //all or UBR
local sample="$sample"
 
***Checking with lasso
splitsample , generate(sample) split(.50 .50) rseed(12345)
label define slabel 1 "Training" 2 "Validation", modify
label values sample slabel

splitsample if UBR==1 , generate(sample_UBR) split(.50 .50) rseed(12345)
label define slabel2 1 "Training" 2 "Validation", modify
label values sample_UBR slabel2


***Final models
lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1, nolog rseed(12345) cluster(district)
estimates store cv_raw

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) cluster(district)
estimates store cv_rawubr_at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1 & poorest50raw==1, nolog rseed(12345) cluster(district)
estimates store cv_raw50_at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 & poorest50raw==1, nolog rseed(12345) cluster(district)
estimates store cv_rawubr50at


*** Predicting welfare using IHS models
use "Census\Census_satellite_data.dta", clear 
merge 1:1 id_tagvnvill using "Census\Census_satellite_datav2.dta", keepusing(numhh)

estimates restore cv_raw // all districts
predict predcons_satell_ihs_full, xb postselection

estimates restore cv_rawubr_at //best with UBR districts
predict predcons_satell_ihs_ubr, xb postselection

estimates restore cv_raw50_at //all distrcits with 50% poorest HH
predict predcons_satell_ihs_full50, xb postselection

estimates restore cv_rawubr50at //best with UBR districts with 50% poorest HH
predict predcons_satell_ihs_ubr50, xb postselection


*******************************************
*** Updating method 1
*******************************************

global indepvar10="poorsh_vill poorersh_vill poorestsh_vill richbetter_vill" 
global indepvar20="pmtmean_vill"
global indepvar30="pmtraw_vill" 
global indepvar11="urban_mean_lag crops_mean_lag zscore_prec_lag zscore_ndwi_lag precyr_lag ndwiyr_lag waterperm_mean_lag waterseas_mean_lag zscore_ndvi_lag ndviyr_lag soilyr_lag grass_mean_lag shrub_mean_lag bare_mean_lag ltype_12_lag ltype_13_lag ltype_14_lag nightlyr_lag ch_10 ch_09_00 ch_99_90 ch_89_85" 
global indepvar12="count density cv_area cv_length mean_barea mean_blength tot_barea tot_blength sh_urban dist_roads_mean pdensity_mean pdensity_mean_lag BSG_mean mean_rwi" 
global indepvar21="urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean shrub_mean bare_mean ltype_12 ltype_13 ltype_14 nightlyr ch_10 ch_09_00 ch_99_90 ch_89_85"
global indepvar13="q_asset_1 q_asset_2 q_asset_3 q_asset_4 q_asset_5 q_asset_6 electricity2" 


/*The best models are the ones with predicted variable susing the full sample so 3 (best) then 1. Models with UBR districts not good*/
splitsample , generate(sample1) split(.1 .9) rseed(12345)
label define slabel 1 "Training" 2 "Validation", modify
label values sample1 slabel

splitsample , generate(sample2) split(.15 .85) rseed(12345)
label define slabel 1 "Training" 2 "Validation", modify
label values sample2 slabel

splitsample , generate(sample3) split(.2 .8) rseed(12345)
label define slabel 1 "Training" 2 "Validation", modify
label values sample3 slabel

*****************************************
*** Predictions using LASSO models

*** Benchmark welfare predicted with LASSO

*** For sample 1: 10%
lasso linear predcons_census_fullvill $indepvar21  $indepvar12 $indepvar13 i.district if sample1==1, nolog rseed(12345) cluster(ID)
lassogof   if sample1 ==2, postselection
predict predwelfare_full1, xb postselection
predict predwelfare_full1v2 if sample1==2, xb postselection
g predwelfare_full1v3=predwelfare_full1v2
replace predwelfare_full1v3=predcons_census_fullvill if predwelfare_full1v3==. & sample1==1

lasso linear predcons_census_ubrvill $indepvar21  $indepvar12 /*$indepvar13*/ i.district if sample1==1, nolog rseed(12345) cluster(ID)
lassogof   if sample1 ==2, postselection
predict predwelfare_ubr1, xb postselection
predict predwelfare_ubr1v2 if sample1==2, xb postselection
g predwelfare_ubr1v3=predwelfare_ubr1v2
replace predwelfare_ubr1v3=predcons_census_ubrvill if predwelfare_ubr1v3==. & sample1==1

lasso linear predcons_census_fullvill50 $indepvar21  $indepvar12 /*$indepvar13*/ i.district if sample1==1, nolog rseed(12345) cluster(ID)
lassogof   if sample1 ==2, postselection
predict predwelfare_50full1, xb postselection
predict predwelfare_50full1v2 if sample1==2, xb postselection
g predwelfare_50full1v3=predwelfare_50full1v2
replace predwelfare_50full1v3=predcons_census_fullvill50 if predwelfare_50full1v3==. & sample1==1

lasso linear predcons_census_ubrvill50 $indepvar21  $indepvar12 /*$indepvar13*/ i.district if sample1==1, nolog rseed(12345)  cluster(ID)
lassogof   if sample1 ==2, postselection
predict predwelfare_50ubr1, xb postselection
predict predwelfare_50ubr1v2 if sample1==2, xb postselection
g predwelfare_50ubr1v3=predwelfare_50ubr1v2
replace predwelfare_50ubr1v3=predcons_census_ubrvill50 if predwelfare_50ubr1v3==. & sample1==1

lasso linear predcons_census_50vill50 $indepvar21  $indepvar12 /*$indepvar13*/ i.district if sample1==1, nolog rseed(12345) cluster(ID)
lassogof   if sample1 ==2, postselection
predict predwelfare_50full501, xb postselection
predict predwelfare_50full501v2 if sample1==2, xb postselection
g predwelfare_50full501v3=predwelfare_50full501v2
replace predwelfare_50full501v3=predcons_census_50vill50 if predwelfare_50full501v3==. & sample1==1

lasso linear predcons_census_50ubrvill50 $indepvar21  $indepvar12 /*$indepvar13*/ i.district if sample1==1, nolog rseed(12345) cluster(ID)
lassogof   if sample1 ==2, postselection
predict predwelfare_50ubr501, xb postselection
predict predwelfare_50ubr501v2 if sample1==2, xb postselection
g predwelfare_50ubr501v3=predwelfare_50ubr501v2
replace predwelfare_50ubr501v3=predcons_census_50ubrvill50 if predwelfare_50ubr501v3==. & sample1==1


***For second sample: 15%
lasso linear predcons_census_fullvill $indepvar21  $indepvar12  i.district if sample2==1, nolog rseed(12345)  cluster(ID)
predict predwelfare_full2, xb postselection
predict predwelfare_full2v2 if sample2==2, xb postselection
g predwelfare_full2v3=predwelfare_full2v2
replace predwelfare_full2v3=predcons_census_fullvill if predwelfare_full2v3==. & sample2==1

lasso linear predcons_census_ubrvill $indepvar21  $indepvar12  i.district if sample2==1, nolog rseed(12345)  cluster(ID)
predict predwelfare_ubr2, xb postselection
predict predwelfare_ubr2v2 if sample2==2, xb postselection
g predwelfare_ubr2v3=predwelfare_ubr2v2
replace predwelfare_ubr2v3=predcons_census_ubrvill if predwelfare_ubr2v3==. & sample2==1

lasso linear predcons_census_fullvill50 $indepvar21  $indepvar12  i.district if sample2==1, nolog rseed(12345)  cluster(ID)
predict predwelfare_50full2, xb postselection
predict predwelfare_50full2v2 if sample2==2, xb postselection
g predwelfare_50full2v3=predwelfare_50full2v2
replace predwelfare_50full2v3=predcons_census_fullvill50 if predwelfare_50full2v3==. & sample2==1

lasso linear predcons_census_ubrvill50 $indepvar21  $indepvar12  i.district if sample2==1, nolog rseed(12345)  cluster(ID)
predict predwelfare_50ubr2, xb postselection
predict predwelfare_50ubr2v2 if sample2==2, xb postselection
g predwelfare_50ubr2v3=predwelfare_50ubr2v2
replace predwelfare_50ubr2v3=predcons_census_ubrvill50 if predwelfare_50ubr2v3==. & sample2==1

lasso linear predcons_census_50vill50 $indepvar21  $indepvar12 /*$indepvar13*/ i.district if sample2==1, nolog rseed(12345) cluster(ID)
predict predwelfare_50full502, xb postselection
predict predwelfare_50full502v2 if sample2==2, xb postselection
g predwelfare_50full502v3=predwelfare_50full502v2
replace predwelfare_50full502v3=predcons_census_50vill50 if predwelfare_50full502v3==. & sample2==1

lasso linear predcons_census_50ubrvill50 $indepvar21  $indepvar12 /*$indepvar13*/ i.district if sample2==1, nolog rseed(12345) cluster(ID)
predict predwelfare_50ubr502, xb postselection
predict predwelfare_50ubr502v2 if sample2==2, xb postselection
g predwelfare_50ubr502v3=predwelfare_50ubr502v2
replace predwelfare_50ubr502v3=predcons_census_50ubrvill50 if predwelfare_50ubr502v3==. & sample2==1


*** For third sample: 20%
lasso linear predcons_census_fullvill $indepvar21  $indepvar12  i.district if sample3==1, nolog rseed(12345)  cluster(ID)
predict predwelfare_full3, xb postselection
predict predwelfare_full3v2 if sample3==2, xb postselection
g predwelfare_full3v3=predwelfare_full3v2
replace predwelfare_full3v3=predcons_census_fullvill if predwelfare_full3v3==. & sample3==1

lasso linear predcons_census_ubrvill $indepvar21  $indepvar12  i.district if sample3==1, nolog rseed(12345)  cluster(ID)
predict predwelfare_ubr3, xb postselection
predict predwelfare_ubr3v2 if sample3==2, xb postselection
g predwelfare_ubr3v3=predwelfare_ubr3v2
replace predwelfare_ubr3v3=predcons_census_ubrvill if predwelfare_ubr3v3==. & sample3==1

lasso linear predcons_census_fullvill50 $indepvar21  $indepvar12  i.district if sample3==1, nolog rseed(12345)  cluster(ID)
predict predwelfare_50full3, xb postselection
predict predwelfare_50full3v2 if sample3==2, xb postselection
g predwelfare_50full3v3=predwelfare_50full3v2
replace predwelfare_50full3v3=predcons_census_fullvill50 if predwelfare_50full3v3==. & sample3==1

lasso linear predcons_census_ubrvill50 $indepvar21  $indepvar12  i.district if sample3==1, nolog rseed(12345)  cluster(ID)
predict predwelfare_50ubr3, xb postselection
predict predwelfare_50ubr3v2 if sample3==2, xb postselection
g predwelfare_50ubr3v3=predwelfare_50ubr3v2
replace predwelfare_50ubr3v3=predcons_census_ubrvill50 if predwelfare_50ubr3v3==. & sample3==1

lasso linear predcons_census_50vill50 $indepvar21  $indepvar12 /*$indepvar13*/ i.district if sample3==1, nolog rseed(12345) cluster(ID)
predict predwelfare_50full503, xb postselection
predict predwelfare_50full503v2 if sample3==2, xb postselection
g predwelfare_50full503v3=predwelfare_50full503v2
replace predwelfare_50full503v3=predcons_census_50vill50 if predwelfare_50full503v3==. & sample3==1

lasso linear predcons_census_50ubrvill50 $indepvar21  $indepvar12 /*$indepvar13*/ i.district if sample3==1, nolog rseed(12345) cluster(ID)
predict predwelfare_50ubr503, xb postselection
predict predwelfare_50ubr503v2 if sample3==2, xb postselection
g predwelfare_50ubr503v3=predwelfare_50ubr503v2
replace predwelfare_50ubr503v3=predcons_census_50ubrvill50 if predwelfare_50ubr503v3==. & sample3==1

*** Renaming predicted variables
forvalues i=1(1)3 {
	foreach x in full ubr 50full 50ubr  {
		rename predwelfare_`x'`i' predwelf_lasso_`x'`i'
		rename predwelfare_`x'`i'v2 predwelf_lasso_`x'`i'v2
		rename predwelfare_`x'`i'v3 predwelf_lasso_`x'`i'v3
	}
}

forvalues i=1(1)3 {
	foreach x in 50full50 50ubr50  {
		rename predwelfare_`x'`i' predwelf_lasso_`x'`i'
		rename predwelfare_`x'`i'v2 predwelf_lasso_`x'`i'v2
		rename predwelfare_`x'`i'v3 predwelf_lasso_`x'`i'v3
	}
}


*******************************
*** Benchmark welfare predicted with XGBOOST

*** For first sample:10%
lasso linear predcons_xgb_fullvill $indepvar21  $indepvar12  i.district if sample1==1, nolog rseed(12345) cluster(ID)
lassogof   if sample1 ==2, postselection
predict predwelfare_full1, xb postselection
predict predwelfare_full1v2 if sample1==2, xb postselection
g predwelfare_full1v3=predwelfare_full1v2
replace predwelfare_full1v3=predcons_xgb_fullvill if predwelfare_full1v3==. & sample1==1

lasso linear predcons_xgb_ubrvill $indepvar21  $indepvar12  i.district if sample1==1, nolog rseed(12345) cluster(ID)
lassogof   if sample1 ==2, postselection
predict predwelfare_ubr1, xb postselection
predict predwelfare_ubr1v2 if sample1==2, xb postselection
g predwelfare_ubr1v3=predwelfare_ubr1v2
replace predwelfare_ubr1v3=predcons_xgb_ubrvill if predwelfare_ubr1v3==. & sample1==1

lasso linear predcons_xgb_fullvill50 $indepvar21  $indepvar12  i.district if sample1==1, nolog rseed(12345) cluster(ID)
lassogof   if sample1 ==2, postselection
predict predwelfare_50full1, xb postselection
predict predwelfare_50full1v2 if sample1==2, xb postselection
g predwelfare_50full1v3=predwelfare_50full1v2
replace predwelfare_50full1v3=predcons_xgb_fullvill50 if predwelfare_50full1v3==. & sample1==1

lasso linear predcons_xgb_ubrvill50 $indepvar21  $indepvar12  i.district if sample1==1, nolog rseed(12345)  cluster(ID)
lassogof   if sample1 ==2, postselection
predict predwelfare_50ubr1, xb postselection
predict predwelfare_50ubr1v2 if sample1==2, xb postselection
g predwelfare_50ubr1v3=predwelfare_50ubr1v2
replace predwelfare_50ubr1v3=predcons_xgb_ubrvill50 if predwelfare_50ubr1v3==. & sample1==1

lasso linear predcons_xgb_50vill50 $indepvar21  $indepvar12  i.district if sample1==1, nolog rseed(12345) cluster(ID)
lassogof   if sample1 ==2, postselection
predict predwelfare_50full501, xb postselection
predict predwelfare_50full501v2 if sample1==2, xb postselection
g predwelfare_50full501v3=predwelfare_50full501v2
replace predwelfare_50full501v3=predcons_xgb_50vill50 if predwelfare_50full501v3==. & sample1==1

lasso linear predcons_xgb_50ubrvill50 $indepvar21  $indepvar12  i.district if sample1==1, nolog rseed(12345)  cluster(ID)
lassogof   if sample1 ==2, postselection
predict predwelfare_50ubr501, xb postselection
predict predwelfare_50ubr501v2 if sample1==2, xb postselection
g predwelfare_50ubr501v3=predwelfare_50ubr501v2
replace predwelfare_50ubr501v3=predcons_xgb_50ubrvill50 if predwelfare_50ubr501v3==. & sample1==1

*** For second sample:15%
lasso linear predcons_xgb_fullvill $indepvar21  $indepvar12  i.district if sample2==1, nolog rseed(12345)  cluster(ID)
lassogof   if sample2 ==2, postselection
predict predwelfare_full2, xb postselection
predict predwelfare_full2v2 if sample2==2, xb postselection
g predwelfare_full2v3=predwelfare_full2v2
replace predwelfare_full2v3=predcons_xgb_fullvill if predwelfare_full2v3==. & sample2==1

lasso linear predcons_xgb_ubrvill $indepvar21  $indepvar12  i.district if sample2==1, nolog rseed(12345)  cluster(ID)
lassogof   if sample2 ==2, postselection
predict predwelfare_ubr2, xb postselection
predict predwelfare_ubr2v2 if sample2==2, xb postselection
g predwelfare_ubr2v3=predwelfare_ubr2v2
replace predwelfare_ubr2v3=predcons_xgb_ubrvill if predwelfare_ubr2v3==. & sample2==1

lasso linear predcons_xgb_fullvill50 $indepvar21  $indepvar12  i.district if sample2==1, nolog rseed(12345)  cluster(ID)
lassogof   if sample2 ==2, postselection
predict predwelfare_50full2, xb postselection
predict predwelfare_50full2v2 if sample2==2, xb postselection
g predwelfare_50full2v3=predwelfare_50full2v2
replace predwelfare_50full2v3=predcons_xgb_fullvill50 if predwelfare_50full2v3==. & sample2==1

lasso linear predcons_xgb_ubrvill50 $indepvar21  $indepvar12  i.district if sample2==1, nolog rseed(12345)  cluster(ID)
lassogof   if sample2 ==2, postselection
predict predwelfare_50ubr2, xb postselection
predict predwelfare_50ubr2v2 if sample2==2, xb postselection
g predwelfare_50ubr2v3=predwelfare_50ubr2v2
replace predwelfare_50ubr2v3=predcons_xgb_ubrvill50 if predwelfare_50ubr2v3==. & sample2==1

lasso linear predcons_xgb_50vill50 $indepvar21  $indepvar12  i.district if sample2==1, nolog rseed(12345)  cluster(ID)
lassogof   if sample2 ==2, postselection
predict predwelfare_50full502, xb postselection
predict predwelfare_50full502v2 if sample3==2, xb postselection
g predwelfare_50full502v3=predwelfare_50full502v2
replace predwelfare_50full502v3=predcons_xgb_50vill50 if predwelfare_50full502v3==. & sample2==1

lasso linear predcons_xgb_50ubrvill50 $indepvar21  $indepvar12  i.district if sample2==1, nolog rseed(12345)  cluster(ID)
lassogof   if sample2 ==2, postselection
predict predwelfare_50ubr502, xb postselection
predict predwelfare_50ubr502v2 if sample2==2, xb postselection
g predwelfare_50ubr502v3=predwelfare_50ubr502v2
replace predwelfare_50ubr502v3=predcons_xgb_50ubrvill50 if predwelfare_50ubr502v3==. & sample2==1

*** For third sample: 20%
lasso linear predcons_xgb_fullvill $indepvar21  $indepvar12  i.district if sample3==1, nolog rseed(12345)  cluster(ID)
lassogof   if sample2 ==2, postselection
predict predwelfare_full3, xb postselection
predict predwelfare_full3v2 if sample3==2, xb postselection
g predwelfare_full3v3=predwelfare_full3v2
replace predwelfare_full3v3=predcons_xgb_fullvill if predwelfare_full3v3==. & sample3==1

lasso linear predcons_xgb_ubrvill $indepvar21  $indepvar12  i.district if sample3==1, nolog rseed(12345)  cluster(ID)
lassogof   if sample2 ==2, postselection
predict predwelfare_ubr3, xb postselection
predict predwelfare_ubr3v2 if sample3==2, xb postselection
g predwelfare_ubr3v3=predwelfare_ubr3v2
replace predwelfare_ubr3v3=predcons_xgb_ubrvill if predwelfare_ubr3v3==. & sample3==1

lasso linear predcons_xgb_fullvill50 $indepvar21  $indepvar12  i.district if sample3==1, nolog rseed(12345)  cluster(ID)
lassogof   if sample2 ==2, postselection
predict predwelfare_50full3, xb postselection
predict predwelfare_50full3v2 if sample3==2, xb postselection
g predwelfare_50full3v3=predwelfare_50full3v2
replace predwelfare_50full3v3=predcons_xgb_fullvill50 if predwelfare_50full3v3==. & sample3==1

lasso linear predcons_xgb_ubrvill50 $indepvar21  $indepvar12  i.district if sample3==1, nolog rseed(12345)  cluster(ID)
lassogof   if sample2 ==2, postselection
predict predwelfare_50ubr3, xb postselection
predict predwelfare_50ubr3v2 if sample3==2, xb postselection
g predwelfare_50ubr3v3=predwelfare_50ubr3v2
replace predwelfare_50ubr3v3=predcons_xgb_ubrvill50 if predwelfare_50ubr3v3==. & sample3==1

lasso linear predcons_xgb_50vill50 $indepvar21  $indepvar12  i.district if sample3==1, nolog rseed(12345)  cluster(ID)
lassogof   if sample2 ==2, postselection
predict predwelfare_50full503, xb postselection
predict predwelfare_50full503v2 if sample3==2, xb postselection
g predwelfare_50full503v3=predwelfare_50full503v2
replace predwelfare_50full503v3=predcons_xgb_50vill50 if predwelfare_50full503v3==. & sample3==1

lasso linear predcons_xgb_50ubrvill50 $indepvar21  $indepvar12  i.district if sample3==1, nolog rseed(12345)  cluster(ID)
lassogof   if sample2 ==2, postselection
predict predwelfare_50ubr503, xb postselection
predict predwelfare_50ubr503v2 if sample3==2, xb postselection
g predwelfare_50ubr503v3=predwelfare_50ubr503v2
replace predwelfare_50ubr503v3=predcons_xgb_50ubrvill50 if predwelfare_50ubr503v3==. & sample3==1

*** Renaming predicted variables
forvalues i=1(1)3 {
	foreach x in full ubr 50full 50ubr  {
		rename predwelfare_`x'`i' predwelf_xgb_`x'`i'
		rename predwelfare_`x'`i'v2 predwelf_xgb_`x'`i'v2
		rename predwelfare_`x'`i'v3 predwelf_xgb_`x'`i'v3
	}
}

forvalues i=1(1)3 {
	foreach x in 50full50 50ubr50  {
		rename predwelfare_`x'`i' predwelf_xgb_`x'`i'
		rename predwelfare_`x'`i'v2 predwelf_xgb_`x'`i'v2
		rename predwelfare_`x'`i'v3 predwelf_xgb_`x'`i'v3
	}
}


*** Labeling variables
label var predcons_census_fullvill "Benchmark welfare_alldist_lasso"
label var predcons_census_ubrvill "Benchmark welfare_ubrdist_lasso"
label var predcons_census_fullvill50 "Benchmark welfare alldist50_lasso"
label var predcons_census_ubrvill50 "Benchmark welfare ubrdist50_lasso"
label var predcons_census_fullvill50 "Benchmark welfare alldist50_lasso"
label var predcons_census_ubrvill50 "Benchmark welfare ubrdist50_lasso"
label var predcons_census_50vill50 "Benchmark welfare 50alldist50_lasso"
label var predcons_census_50ubrvill50 "Benchmark welfare 50ubrdist50_lasso"


label var predcons_xgb_fullvill "Benchmark welfare_alldist_xgb"
label var predcons_xgb_ubrvill "Benchmark welfare_ubrdist_xgb"
label var predcons_xgb_fullvill50 "Benchmark welfare alldist50_xgb"
label var predcons_xgb_ubrvill50 "Benchmark welfare ubrdist50_xgb"
label var predcons_xgb_50vill50 "Benchmark welfare 50alldist50_xgb"
label var predcons_xgb_50ubrvill50 "Benchmark welfare 50ubrdist50_xgb"


foreach x in full ubr 50full 50ubr  {
	label var predwelf_xgb_`x'1 "Predicted welfare_census10_`x'_xgb"
	label var predwelf_lasso_`x'1 "Predicted welfare_census10_`x'_lasso"
}
foreach x in full ubr 50full 50ubr  {
	label var predwelf_xgb_`x'2 "Predicted welfare_census15_`x'_xgb"
	label var predwelf_lasso_`x'2 "Predicted welfare_census15_`x'_lasso"
}
foreach x in full ubr 50full 50ubr  {
	label var predwelf_xgb_`x'3 "Predicted welfare_census20_`x'_xgb"
	label var predwelf_lasso_`x'3 "Predicted welfare_census20_`x'_lasso"
}

foreach x in  50full50 50ubr50 {
	label var predwelf_xgb_`x'1 "Predicted welfare_census10_`x'_xgb"
	label var predwelf_lasso_`x'1 "Predicted welfare_census10_`x'_lasso"
}
foreach x in 50full50 50ubr50 {
	label var predwelf_xgb_`x'2 "Predicted welfare_census15_`x'_xgb"
	label var predwelf_lasso_`x'2 "Predicted welfare_census15_`x'_lasso"
}
foreach x in 50full50 50ubr50 {
	label var predwelf_xgb_`x'3 "Predicted welfare_census20_`x'_xgb"
	label var predwelf_lasso_`x'3 "Predicted welfare_census20_`x'_lasso"
}

label var predcons_satell_ihs_full "Predicted welfare_ihs_alldist"
label var predcons_satell_ihs_ubr "Predicted welfare_ihs_ubrdist"
label var predcons_satell_ihs_full50 "Predicted welfare_ihs_alldist50"
label var predcons_satell_ihs_ubr50 "Predicted welfare_ihs_ubrdist50"
label var id_tagvnvill "village id"
label var pmtscore_mean_villraw "Average PMT scores (raw)"
label var pmtscore_mean_vill "Average PMT scores (trimmed)"


keep  district id_tagvnvill ID predcons_census_fullvill predcons_census_ubrvill  predcons_census_fullvill50 predcons_census_50vill50 predcons_census_50ubrvill50 predcons_xgb_50vill50 predcons_xgb_50ubrvill50 predcons_census_ubrvill50 predcons_xgb_fullvill predcons_xgb_ubrvill  predcons_xgb_fullvill50 predcons_xgb_ubrvill50 ///
pmtscore_mean_vill pmtscore_mean_villraw mean_rwi median_rwi predwelf_lasso_* predwelf_xgb_* ///
predcons_satell_ihs_full predcons_satell_ihs_ubr predcons_satell_ihs_full50 predcons_satell_ihs_ubr50 ///
sample1 sample2 sample3 numhh

save "Census\Updated results\data_updt1lasso_updt2_updt3lasso_updt4.dta", replace
*/
***********************************************************************************
*** Rank correlations and AUC

use "Census\Updated results\data_updt1lasso_updt2_updt3lasso_updt4.dta", clear
/*
set scheme plotplain
graph twoway (scatter pmtscore_mean_vill predcons_xgb_50vill50, msymbol(square) msize(tiny) mcolor(black) pstyle(p3 p4 p5)) ///
			(lfitci pmtscore_mean_vill predcons_xgb_50vill50, clstyle(p1line)) ///
			, ytitle("PMT scores (trimmed)",size(small)) xtitle("Benchmark welfare",size(small)) legend(off)
graph save pmt_trimmed, replace

graph twoway (scatter pmtscore_mean_villraw predcons_xgb_50vill50, msymbol(square) msize(tiny) mcolor(black) pstyle(p3 p4 p5)) ///
			(lfitci pmtscore_mean_villraw predcons_xgb_50vill50, clstyle(p1line)) ///
			, ytitle("PMT scores (raw)",size(small)) xtitle("Benchmark welfare",size(small)) legend(off)
graph save pmt_raw, replace
graph combine 	pmt_trimmed.gph pmt_raw.gph
graph export pmt_correlation.pdf

set scheme plotplain
graph twoway (scatter mean_rwi predcons_xgb_50vill50, msymbol(square) msize(tiny) mcolor(black) pstyle(p3 p4 p5)) ///
			(lfitci mean_rwi predcons_xgb_50vill50, clstyle(p1line)) ///
			, ytitle("RWI",size(small)) xtitle("Benchmark welfare",size(small)) legend(off)
graph save pmt_trimmed, replace

set scheme plotplain
graph twoway (scatter predwelf_xgb_50full501 predcons_xgb_50vill50, msymbol(square) msize(tiny) mcolor(black) pstyle(p3 p4 p5)) ///
			(lfitci predwelf_xgb_50full501 predcons_xgb_50vill50, clstyle(p1line)) ///
			, ytitle("Predicted welfare with partial registry (10%)",size(small)) xtitle("Benchmark welfare",size(small)) legend(off)
graph save pmt_trimmed, replace
*/
****Scatter plots
g pcc_level=exp(predcons_xgb_50vill50)
g cons_ppp=pcc_level/78.7/365	

egen p10 = pctile(predcons_xgb_50vill50), p(25)
egen p10pmt = pctile(pmtscore_mean_vill), p(25)
egen p10rwi = pctile(mean_rwi), p(25)

g true_poor=(predcons_xgb_50vill50<p10)
g pmt_poor=(pmtscore_mean_vill<p10pmt)
g rwi_poor=(mean_rwi<p10rwi)

local p10=p10
local p10pmt=p10pmt
set scheme plotplainblind
graph twoway  (scatter pmtscore_mean_vill predcons_xgb_50vill50 if true_poor==1 & pmt_poor==1 ,xline(`p10') yline(`p10pmt') msize(tiny) mcolor(dknavy) xtitle(Benchmark welfare,size(vsmall)) ytitle(PMT scores,size(vsmall)) legend(off) xlabel(,labsize(vsmall)) ylabel(,labsize(vsmall))) (scatter pmtscore_mean_vill predcons_xgb_50vill50 if true_poor==0 & pmt_poor==0, msize(tiny) mcolor(eltblue)) (scatter pmtscore_mean_vill predcons_xgb_50vill50 if true_poor==1 & pmt_poor==0, msize(tiny) mcolor(gs5)) (scatter pmtscore_mean_vill predcons_xgb_50vill50 if true_poor==0 & pmt_poor==1, msize(tiny) mcolor(khaki)) ///
(lfitci pmtscore_mean_vill predcons_xgb_50vill50)	
graph save pmt_scatter, replace

local p10rwi=p10rwi
set scheme plotplainblind
graph twoway (scatter mean_rwi predcons_xgb_50vill50 if true_poor==1 & rwi_poor==1 ,xline(`p10') yline(`p10rwi') msize(tiny) mcolor(dknavy) xtitle(Benchmark welfare,size(vsmall)) ytitle(RWI,size(vsmall)) legend(off) xlabel(,labsize(vsmall)) ylabel(,labsize(vsmall))) (scatter mean_rwi predcons_xgb_50vill50 if true_poor==0 & rwi_poor==0, msize(tiny) mcolor(eltblue)) (scatter mean_rwi predcons_xgb_50vill50 if true_poor==1 & rwi_poor==0, msize(tiny) mcolor(gs5)) (scatter mean_rwi predcons_xgb_50vill50 if true_poor==0 & rwi_poor==1, msize(tiny) mcolor(khaki)) ///
(lfitci mean_rwi predcons_xgb_50vill50)	
graph save rwi_scatter, replace

preserve
use "Census\Updated results\predcensus_xgb_IHS_full50new.dta",clear
set scheme plotplain
g pcc_level=exp(predcons_xgb_50vill50)
g cons_ppp=pcc_level/78.7/365		

g pcc_levelpred=exp(predwelf_ihsxgb_full50)
g predcons_ppp=pcc_levelpred/78.7/365	

egen p10 = pctile(predcons_xgb_50vill50), p(25)
egen p10ihs = pctile(predwelf_ihsxgb_full50), p(25)

local p10=p10
local p10ihs=p10ihs

g true_poor=(predcons_xgb_50vill50<p10)
g pred_poor=(predwelf_ihsxgb_full50<p10ihs)

graph twoway (scatter predwelf_ihsxgb_full50 predcons_xgb_50vill50 if true_poor==1 & pred_poor==1 ,xline(`p10') yline(`p10ihs') msize(tiny) mcolor(dknavy) xtitle(Benchmark welfare,size(vsmall)) ytitle(Predicted welfare with IHS,size(vsmall)) legend(label(1 "Correct prediction of poor") size(vsmall) cols(3)) xlabel(,labsize(vsmall)) ylabel(,labsize(vsmall))) (scatter  predwelf_ihsxgb_full50 predcons_xgb_50vill50 if true_poor==0 & pred_poor==0, msize(tiny) mcolor(eltblue) legend(label(2 "Correct prediction of non-poor") size(vsmall))) (scatter  predwelf_ihsxgb_full50 predcons_xgb_50vill50 if true_poor==1 & pred_poor==0, msize(tiny) mcolor(gs5) legend(label(3 "Exclusion error") size(vsmall))) (scatter  predwelf_ihsxgb_full50 predcons_xgb_50vill50 if true_poor==0 & pred_poor==1, msize(tiny) mcolor(khaki) legend(label(4 "Inclusion error") size(vsmall)))	///
(lfitci  predwelf_ihsxgb_full50 predcons_xgb_50vill50)	
graph save ihs_scatter, replace

restore


grc1leg partreg_scatter.gph pmt_scatter.gph rwi_scatter.gph ihs_scatter.gph, legendfrom(ihs_scatter.gph) ring(6)

***************************************
*** Updating method 1
***************************************

************************************
*** Benchmark: estimated with LASSO

* enable for out of sample and out of sample+training
global ren_var="predwelf_lasso_full predwelf_lasso_ubr predwelf_lasso_50full predwelf_lasso_50ubr predwelf_lasso_50full50  predwelf_lasso_50ubr50 predwelf_xgb_full predwelf_xgb_ubr predwelf_xgb_50full predwelf_xgb_50ubr predwelf_xgb_50full50 predwelf_xgb_50ubr50"

foreach var in $ren_var {
	forvalues i=1(1)3 {
	rename `var'`i' `var'`i'drop
	rename `var'`i'v3 `var'`i'
	}
}
*/

***R-squared
reg predcons_census_50vill50 predwelf_lasso_50full501 

**********************
*** Sample 10%
*** Rank correlations
spearman predcons_census_fullvill predwelf_lasso_full1 
	local frho1=r(rho)
	local fp1=r(p)
	local fN1=r(N)
spearman predcons_census_ubrvill predwelf_lasso_ubr1
	local urho1=r(rho)
	local up1=r(p)
	local uN1=r(N)
spearman predcons_census_fullvill50 predwelf_lasso_50full1 
	local f50rho1=r(rho)
	local f50p1=r(p)
	local f50N1=r(N)
spearman predcons_census_ubrvill50 predwelf_lasso_50ubr1
	local u50rho1=r(rho)
	local u50p1=r(p)
	local u50N1=r(N)
spearman predcons_census_50vill50 predwelf_lasso_50full501 
	local f5050rho1=r(rho)
	local f5050p1=r(p)
	local f5050N1=r(N)
spearman predcons_census_50ubrvill50 predwelf_lasso_50ubr501
	local u5050rho1=r(rho)
	local u5050p1=r(p)
	local u5050N1=r(N)
	
spearman predcons_census_fullvill predwelf_xgb_full1 
	local 2frho1=r(rho)
	local 2fp1=r(p)
	local 2fN1=r(N)
spearman predcons_census_ubrvill predwelf_xgb_ubr1
	local 2urho1=r(rho)
	local 2up1=r(p)
	local 2uN1=r(N)
spearman predcons_census_fullvill50 predwelf_xgb_50full1 
	local 2f50rho1=r(rho)
	local 2f50p1=r(p)
	local 2f50N1=r(N)
spearman predcons_census_ubrvill50 predwelf_xgb_50ubr1
	local 2u50rho1=r(rho)
	local 2u50p1=r(p)
	local 2u50N1=r(N)
spearman predcons_census_50vill50 predwelf_xgb_50full501 
	local 2f5050rho1=r(rho)
	local 2f5050p1=r(p)
	local 2f5050N1=r(N)
spearman predcons_census_50ubrvill50 predwelf_xgb_50ubr501
	local 2u5050rho1=r(rho)
	local 2u5050p1=r(p)
	local 2u5050N1=r(N)
	
	
*** Data for AUC: FPR and TPR
g test=1
putexcel set "Census\Updated results\AUC_lasso_census10", replace

forvalues i=1(1)99 {
	egen ranktrue_11`i' = pctile(predcons_census_fullvill), /*by(district)*/ p(`i') 
	g ranktrue_full_`i'=(predcons_census_fullvill<ranktrue_11`i')
	egen ranktrue_12`i' = pctile(predcons_census_ubrvill), /*by(district)*/ p(`i') 
	g ranktrue_ubr_`i'=(predcons_census_ubrvill<ranktrue_12`i')
	egen ranktrue_13`i' = pctile(predcons_census_fullvill50), /*by(district)*/ p(`i') 
	g ranktrue_full50_`i'=(predcons_census_fullvill50<ranktrue_13`i')
	egen ranktrue_14`i' = pctile(predcons_census_ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_ubr50_`i'=(predcons_census_ubrvill50<ranktrue_14`i')
	
	egen ranktrue_15`i' = pctile(predcons_census_50vill50), /*by(district)*/ p(`i') 
	g ranktrue_50full50_`i'=(predcons_census_50vill50<ranktrue_15`i')
	egen ranktrue_16`i' = pctile(predcons_census_50ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_50ubr50_`i'=(predcons_census_50ubrvill50<ranktrue_16`i')
	
	egen rankpred_11`i' = pctile(predwelf_lasso_full1), /*by(district)*/ p(`i') 
	egen rankpred_12`i' = pctile(predwelf_lasso_ubr1), /*by(district)*/ p(`i') 
	egen rankpred_13`i' = pctile(predwelf_lasso_50full1), /*by(district)*/ p(`i') 
	egen rankpred_14`i' = pctile(predwelf_lasso_50ubr1), /*by(district)*/ p(`i') 
	egen rankpred_15`i' = pctile(predwelf_lasso_50full501), /*by(district)*/ p(`i') 
	egen rankpred_16`i' = pctile(predwelf_lasso_50ubr501), /*by(district)*/ p(`i') 

	g rankpred1_full_`i'=(predwelf_lasso_full1<ranktrue_11`i')
	g rankpred1_ubr_`i'=(predwelf_lasso_ubr1<ranktrue_12`i')
	g rankpred1_full50_`i'=(predwelf_lasso_50full1<ranktrue_13`i')
	g rankpred1_ubr50_`i'=(predwelf_lasso_50ubr1<ranktrue_14`i')
	g rankpred1_50full50_`i'=(predwelf_lasso_50full501<ranktrue_15`i')
	g rankpred1_50ubr50_`i'=(predwelf_lasso_50ubr501<ranktrue_16`i')
	
	g rank2pred1_full_`i'=(predwelf_lasso_full1<rankpred_11`i')
	g rank2pred1_ubr_`i'=(predwelf_lasso_ubr1<rankpred_12`i')
	g rank2pred1_full50_`i'=(predwelf_lasso_50full1<rankpred_13`i')
	g rank2pred1_ubr50_`i'=(predwelf_lasso_50ubr1<rankpred_14`i')
	g rank2pred1_50full50_`i'=(predwelf_lasso_50full501<rankpred_15`i')
	g rank2pred1_50ubr50_`i'=(predwelf_lasso_50ubr501<rankpred_16`i')

sum test if rankpred1_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FPf1`i'=r(N)
sum test if rankpred1_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TPf1`i'=r(N)
sum test if rank2pred1_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FP2f1`i'=r(N)
sum test if rank2pred1_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TP2f1`i'=r(N)
sum test if ranktrue_full_`i'==1 //total poor
return list
local Pf1`i'=r(N)
sum test if ranktrue_full_`i'==0 //total non-poor
return list
local NPf1`i'=r(N)

sum test if rankpred1_full50_`i'==1 & ranktrue_full50_`i'==0 //false positive rate
return list
local FPf150`i'=r(N)
sum test if rankpred1_full50_`i'==1 & ranktrue_full50_`i'==1 //true postive rate
return list
local TPf150`i'=r(N)
sum test if rank2pred1_full50_`i'==1 & ranktrue_full50_`i'==0 //false positive rate
return list
local FP2f150`i'=r(N)
sum test if rank2pred1_full50_`i'==1 & ranktrue_full50_`i'==1 //true postive rate
return list
local TP2f150`i'=r(N)
sum test if ranktrue_full50_`i'==1 //total poor
return list
local Pf150`i'=r(N)
sum test if ranktrue_full50_`i'==0 //total non-poor
return list
local NPf150`i'=r(N)

sum test if rankpred1_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FPu1`i'=r(N)
sum test if rankpred1_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TPu1`i'=r(N)
sum test if rank2pred1_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FP2u1`i'=r(N)
sum test if rank2pred1_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TP2u1`i'=r(N)
sum test if ranktrue_ubr_`i'==1 //total poor
return list
local Pu1`i'=r(N)
sum test if ranktrue_ubr_`i'==0 //total non-poor
return list
local NPu1`i'=r(N)

sum test if rankpred1_ubr50_`i'==1 & ranktrue_ubr50_`i'==0 //false positive rate
return list
local FPu150`i'=r(N)
sum test if rankpred1_ubr50_`i'==1 & ranktrue_ubr50_`i'==1 //true postive rate
return list
local TPu150`i'=r(N)
sum test if rank2pred1_ubr50_`i'==1 & ranktrue_ubr50_`i'==0 //false positive rate
return list
local FP2u150`i'=r(N)
sum test if rank2pred1_ubr50_`i'==1 & ranktrue_ubr50_`i'==1 //true postive rate
return list
local TP2u150`i'=r(N)
sum test if ranktrue_ubr50_`i'==1 //total poor
return list
local Pu150`i'=r(N)
sum test if ranktrue_ubr50_`i'==0 //total non-poor
return list
local NPu150`i'=r(N)

sum test if rankpred1_50full50_`i'==1 & ranktrue_50full50_`i'==0 //false positive rate
return list
local FPf15050`i'=r(N)
sum test if rankpred1_50full50_`i'==1 & ranktrue_50full50_`i'==1 //true postive rate
return list
local TPf15050`i'=r(N)
sum test if rank2pred1_50full50_`i'==1 & ranktrue_50full50_`i'==0 //false positive rate
return list
local FP2f15050`i'=r(N)
sum test if rank2pred1_50full50_`i'==1 & ranktrue_50full50_`i'==1 //true postive rate
return list
local TP2f15050`i'=r(N)
sum test if ranktrue_50full50_`i'==1 //total poor
return list
local Pf15050`i'=r(N)
sum test if ranktrue_50full50_`i'==0 //total non-poor
return list
local NPf15050`i'=r(N)

sum test if rankpred1_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==0 //false positive rate
return list
local FPu15050`i'=r(N)
sum test if rankpred1_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==1 //true postive rate
return list
local TPu15050`i'=r(N)
sum test if rank2pred1_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==0 //false positive rate
return list
local FP2u15050`i'=r(N)
sum test if rank2pred1_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==1 //true postive rate
return list
local TP2u15050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==1 //total poor
return list
local Pu15050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==0 //total non-poor
return list
local NPu15050`i'=r(N)
	
putexcel A`i'=`FPf1`i''
putexcel B`i'=`TPf1`i''
putexcel C`i'=`FP2f1`i''
putexcel D`i'=`TP2f1`i''
putexcel E`i'=`Pf1`i''
putexcel F`i'=`NPf1`i''

putexcel H`i'=`FPu1`i''
putexcel I`i'=`TPu1`i''
putexcel J`i'=`FP2u1`i''
putexcel K`i'=`TP2u1`i''
putexcel L`i'=`Pu1`i''
putexcel M`i'=`NPu1`i''

putexcel O`i'=`FPf150`i''
putexcel P`i'=`TPf150`i''
putexcel Q`i'=`FP2f150`i''
putexcel R`i'=`TP2f150`i''
putexcel S`i'=`Pf150`i''
putexcel T`i'=`NPf150`i''

putexcel V`i'=`FPu150`i''
putexcel W`i'=`TPu150`i''
putexcel X`i'=`FP2u150`i''
putexcel Y`i'=`TP2u150`i''
putexcel Z`i'=`Pu150`i''
putexcel AA`i'=`NPu150`i''	

putexcel AC`i'=`FPf15050`i''
putexcel AD`i'=`TPf15050`i''
putexcel AE`i'=`FP2f15050`i''
putexcel AF`i'=`TP2f15050`i''
putexcel AG`i'=`Pf15050`i''
putexcel AH`i'=`NPf15050`i''

putexcel AJ`i'=`FPu15050`i''
putexcel AK`i'=`TPu15050`i''
putexcel AL`i'=`FP2u15050`i''
putexcel AM`i'=`TP2u15050`i''
putexcel AN`i'=`Pu15050`i''
putexcel AO`i'=`NPu15050`i''	

}
drop rankpred_1* rankpred1_* rank2pred1_* ranktrue_*

*** AUC calculations
preserve
import excel "Census\Updated results\AUC_lasso_census10.xlsx", sheet("Sheet1") clear

g FPR_full=A/F
g TPR_full=B/E
g FPR_full2=C/F
g TPR_full2=D/E

g FPR_ubr=H/M
g TPR_ubr=I/L
g FPR_ubr2=J/M
g TPR_ubr2=K/L

g FPR_full50=O/T
g TPR_full50=P/S
g FPR_full502=Q/T
g TPR_full502=R/S

g FPR_ubr50=V/AA
g TPR_ubr50=W/Z
g FPR_ubr502=X/AA
g TPR_ubr502=Y/Z

g FPR_50full50=AC/AH
g TPR_50full50=AD/AG
g FPR_50full502=AE/AH
g TPR_50full502=AF/AG

g FPR_50ubr50=AJ/AO
g TPR_50ubr50=AK/AN
g FPR_50ubr502=AL/AO
g TPR_50ubr502=AM/AN

keep FPR* TPR* 

set obs `=_N+1'

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
	replace TPR_`x'=1 if TPR_`x'==.
	replace FPR_`x'=1 if FPR_`x'==.
	replace TPR_`x'2=1 if TPR_`x'2==.
	replace FPR_`x'2=1 if FPR_`x'2==.
}

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x' FPR_`x', gen(total_auc`x') trapezoid
local auclasso10_1`x'=r(integral) 
}

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x'2 FPR_`x'2, gen(total_auc`x'2) trapezoid
local auclasso10_2`x'=r(integral) 
}

restore
*/
**********************
*** Sample 15%
*** Rank correlations
spearman predcons_census_fullvill predwelf_lasso_full2 
	local frho2=r(rho)
	local fp2=r(p)
	local fN2=r(N)
spearman predcons_census_ubrvill predwelf_lasso_ubr2
	local urho2=r(rho)
	local up2=r(p)
	local uN2=r(N)
spearman predcons_census_fullvill50 predwelf_lasso_50full2 
	local f50rho2=r(rho)
	local f50p2=r(p)
	local f50N2=r(N)
spearman predcons_census_ubrvill50 predwelf_lasso_50ubr2
	local u50rho2=r(rho)
	local u50p2=r(p)
	local u50N2=r(N)
spearman predcons_census_50vill50 predwelf_lasso_50full502 
	local f5050rho2=r(rho)
	local f5050p2=r(p)
	local f5050N2=r(N)
spearman predcons_census_50ubrvill50 predwelf_lasso_50ubr502
	local u5050rho2=r(rho)
	local u5050p2=r(p)
	local u5050N2=r(N)
	
spearman predcons_census_fullvill predwelf_xgb_full2 
	local 2frho2=r(rho)
	local 2fp2=r(p)
	local 2fN2=r(N)
spearman predcons_census_ubrvill predwelf_xgb_ubr2
	local 2urho2=r(rho)
	local 2up2=r(p)
	local 2uN2=r(N)
spearman predcons_census_fullvill50 predwelf_xgb_50full2 
	local 2f50rho2=r(rho)
	local 2f50p2=r(p)
	local 2f50N2=r(N)
spearman predcons_census_ubrvill50 predwelf_xgb_50ubr2
	local 2u50rho2=r(rho)
	local 2u50p2=r(p)
	local 2u50N2=r(N)
spearman predcons_census_50vill50 predwelf_xgb_50full502 
	local 2f5050rho2=r(rho)
	local 2f5050p2=r(p)
	local 2f5050N2=r(N)
spearman predcons_census_50ubrvill50 predwelf_xgb_50ubr502
	local 2u5050rho2=r(rho)
	local 2u5050p2=r(p)
	local 2u5050N2=r(N)
		
*** Data for AUC: FPR and TPR

putexcel set "Census\Updated results\AUC_lasso_census15", replace

forvalues i=1(1)99 {
	egen ranktrue_21`i' = pctile(predcons_census_fullvill), /*by(district)*/ p(`i') 
	g ranktrue_full_`i'=(predcons_census_fullvill<ranktrue_21`i')
	egen ranktrue_22`i' = pctile(predcons_census_ubrvill), /*by(district)*/ p(`i') 
	g ranktrue_ubr_`i'=(predcons_census_ubrvill<ranktrue_22`i')
	egen ranktrue_23`i' = pctile(predcons_census_fullvill50), /*by(district)*/ p(`i') 
	g ranktrue_full50_`i'=(predcons_census_fullvill50<ranktrue_23`i')
	egen ranktrue_24`i' = pctile(predcons_census_ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_ubr50_`i'=(predcons_census_ubrvill50<ranktrue_24`i')
	egen ranktrue_25`i' = pctile(predcons_census_50vill50), /*by(district)*/ p(`i') 
	g ranktrue_50full50_`i'=(predcons_census_50vill50<ranktrue_25`i')
	egen ranktrue_26`i' = pctile(predcons_census_50ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_50ubr50_`i'=(predcons_census_50ubrvill50<ranktrue_26`i')
	
	egen rankpred_21`i' = pctile(predwelf_lasso_full2), /*by(district)*/ p(`i') 
	egen rankpred_22`i' = pctile(predwelf_lasso_ubr2), /*by(district)*/ p(`i') 
	egen rankpred_23`i' = pctile(predwelf_lasso_50full2), /*by(district)*/ p(`i') 
	egen rankpred_24`i' = pctile(predwelf_lasso_50ubr2), /*by(district)*/ p(`i') 
	egen rankpred_25`i' = pctile(predwelf_lasso_50full502), /*by(district)*/ p(`i') 
	egen rankpred_26`i' = pctile(predwelf_lasso_50ubr502), /*by(district)*/ p(`i') 

	g rankpred2_full_`i'=(predwelf_lasso_full2<ranktrue_21`i')
	g rankpred2_ubr_`i'=(predwelf_lasso_ubr2<ranktrue_22`i')
	g rankpred2_full50_`i'=(predwelf_lasso_50full2<ranktrue_23`i')
	g rankpred2_ubr50_`i'=(predwelf_lasso_50ubr2<ranktrue_24`i')
	g rankpred2_50full50_`i'=(predwelf_lasso_50full502<ranktrue_25`i')
	g rankpred2_50ubr50_`i'=(predwelf_lasso_50ubr502<ranktrue_26`i')

	g rank2pred2_full_`i'=(predwelf_lasso_full2<rankpred_21`i')
	g rank2pred2_ubr_`i'=(predwelf_lasso_ubr2<rankpred_22`i')
	g rank2pred2_full50_`i'=(predwelf_lasso_50full2<rankpred_23`i')
	g rank2pred2_ubr50_`i'=(predwelf_lasso_50ubr2<rankpred_24`i')
	g rank2pred2_50full50_`i'=(predwelf_lasso_50full502<rankpred_25`i')
	g rank2pred2_50ubr50_`i'=(predwelf_lasso_50ubr502<rankpred_26`i')

sum test if rankpred2_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FPf1`i'=r(N)
sum test if rankpred2_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TPf1`i'=r(N)
sum test if rank2pred2_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FP2f1`i'=r(N)
sum test if rank2pred2_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TP2f1`i'=r(N)
sum test if ranktrue_full_`i'==1 //total poor
return list
local Pf1`i'=r(N)
sum test if ranktrue_full_`i'==0 //total non-poor
return list
local NPf1`i'=r(N)

sum test if rankpred2_full50_`i'==1 & ranktrue_full50_`i'==0 //false positive rate
return list
local FPf150`i'=r(N)
sum test if rankpred2_full50_`i'==1 & ranktrue_full50_`i'==1 //true postive rate
return list
local TPf150`i'=r(N)
sum test if rank2pred2_full50_`i'==1 & ranktrue_full50_`i'==0 //false positive rate
return list
local FP2f150`i'=r(N)
sum test if rank2pred2_full50_`i'==1 & ranktrue_full50_`i'==1 //true postive rate
return list
local TP2f150`i'=r(N)
sum test if ranktrue_full50_`i'==1 //total poor
return list
local Pf150`i'=r(N)
sum test if ranktrue_full50_`i'==0 //total non-poor
return list
local NPf150`i'=r(N)

sum test if rankpred2_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FPu1`i'=r(N)
sum test if rankpred2_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TPu1`i'=r(N)
sum test if rank2pred2_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FP2u1`i'=r(N)
sum test if rank2pred2_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TP2u1`i'=r(N)
sum test if ranktrue_ubr_`i'==1 //total poor
return list
local Pu1`i'=r(N)
sum test if ranktrue_ubr_`i'==0 //total non-poor
return list
local NPu1`i'=r(N)

sum test if rankpred2_ubr50_`i'==1 & ranktrue_ubr50_`i'==0 //false positive rate
return list
local FPu150`i'=r(N)
sum test if rankpred2_ubr50_`i'==1 & ranktrue_ubr50_`i'==1 //true postive rate
return list
local TPu150`i'=r(N)
sum test if rank2pred2_ubr50_`i'==1 & ranktrue_ubr50_`i'==0 //false positive rate
return list
local FP2u150`i'=r(N)
sum test if rank2pred2_ubr50_`i'==1 & ranktrue_ubr50_`i'==1 //true postive rate
return list
local TP2u150`i'=r(N)
sum test if ranktrue_ubr50_`i'==1 //total poor
return list
local Pu150`i'=r(N)
sum test if ranktrue_ubr50_`i'==0 //total non-poor
return list
local NPu150`i'=r(N)

sum test if rankpred2_50full50_`i'==1 & ranktrue_50full50_`i'==0 //false positive rate
return list
local FPf15050`i'=r(N)
sum test if rankpred2_50full50_`i'==1 & ranktrue_50full50_`i'==1 //true postive rate
return list
local TPf15050`i'=r(N)
sum test if rank2pred2_50full50_`i'==1 & ranktrue_50full50_`i'==0 //false positive rate
return list
local FP2f15050`i'=r(N)
sum test if rank2pred2_50full50_`i'==1 & ranktrue_50full50_`i'==1 //true postive rate
return list
local TP2f15050`i'=r(N)
sum test if ranktrue_50full50_`i'==1 //total poor
return list
local Pf15050`i'=r(N)
sum test if ranktrue_50full50_`i'==0 //total non-poor
return list
local NPf15050`i'=r(N)

sum test if rankpred2_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==0 //false positive rate
return list
local FPu15050`i'=r(N)
sum test if rankpred2_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==1 //true postive rate
return list
local TPu15050`i'=r(N)
sum test if rank2pred2_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==0 //false positive rate
return list
local FP2u15050`i'=r(N)
sum test if rank2pred2_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==1 //true postive rate
return list
local TP2u15050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==1 //total poor
return list
local Pu15050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==0 //total non-poor
return list
local NPu15050`i'=r(N)
	
putexcel A`i'=`FPf1`i''
putexcel B`i'=`TPf1`i''
putexcel C`i'=`FP2f1`i''
putexcel D`i'=`TP2f1`i''
putexcel E`i'=`Pf1`i''
putexcel F`i'=`NPf1`i''

putexcel H`i'=`FPu1`i''
putexcel I`i'=`TPu1`i''
putexcel J`i'=`FP2u1`i''
putexcel K`i'=`TP2u1`i''
putexcel L`i'=`Pu1`i''
putexcel M`i'=`NPu1`i''

putexcel O`i'=`FPf150`i''
putexcel P`i'=`TPf150`i''
putexcel Q`i'=`FP2f150`i''
putexcel R`i'=`TP2f150`i''
putexcel S`i'=`Pf150`i''
putexcel T`i'=`NPf150`i''

putexcel V`i'=`FPu150`i''
putexcel W`i'=`TPu150`i''
putexcel X`i'=`FP2u150`i''
putexcel Y`i'=`TP2u150`i''
putexcel Z`i'=`Pu150`i''
putexcel AA`i'=`NPu150`i''	

putexcel AC`i'=`FPf15050`i''
putexcel AD`i'=`TPf15050`i''
putexcel AE`i'=`FP2f15050`i''
putexcel AF`i'=`TP2f15050`i''
putexcel AG`i'=`Pf15050`i''
putexcel AH`i'=`NPf15050`i''

putexcel AJ`i'=`FPu15050`i''
putexcel AK`i'=`TPu15050`i''
putexcel AL`i'=`FP2u15050`i''
putexcel AM`i'=`TP2u15050`i''
putexcel AN`i'=`Pu15050`i''
putexcel AO`i'=`NPu15050`i''	

}
drop rankpred_2* rankpred2_* rank2pred2_* ranktrue_*

*** AUC calculations
preserve
import excel "Census\Updated results\AUC_lasso_census15.xlsx", sheet("Sheet1") clear

g FPR_full=A/F
g TPR_full=B/E
g FPR_full2=C/F
g TPR_full2=D/E

g FPR_ubr=H/M
g TPR_ubr=I/L
g FPR_ubr2=J/M
g TPR_ubr2=K/L

g FPR_full50=O/T
g TPR_full50=P/S
g FPR_full502=Q/T
g TPR_full502=R/S

g FPR_ubr50=V/AA
g TPR_ubr50=W/Z
g FPR_ubr502=X/AA
g TPR_ubr502=Y/Z

g FPR_50full50=AC/AH
g TPR_50full50=AD/AG
g FPR_50full502=AE/AH
g TPR_50full502=AF/AG

g FPR_50ubr50=AJ/AO
g TPR_50ubr50=AK/AN
g FPR_50ubr502=AL/AO
g TPR_50ubr502=AM/AN


keep FPR* TPR* 

set obs `=_N+1'

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
	replace TPR_`x'=1 if TPR_`x'==.
	replace FPR_`x'=1 if FPR_`x'==.
	replace TPR_`x'2=1 if TPR_`x'2==.
	replace FPR_`x'2=1 if FPR_`x'2==.
}

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x' FPR_`x', gen(total_auc`x') trapezoid
local auclasso15_1`x'=r(integral) 
}

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x'2 FPR_`x'2, gen(total_auc`x'2) trapezoid
local auclasso15_2`x'=r(integral) 
}

restore
*/

**********************
*** Sample 20%
*** Rank correlations
spearman predcons_census_fullvill predwelf_lasso_full3 
	local frho3=r(rho)
	local fp3=r(p)
	local fN3=r(N)
spearman predcons_census_ubrvill predwelf_lasso_ubr3
	local urho3=r(rho)
	local up3=r(p)
	local uN3=r(N)
spearman predcons_census_fullvill50 predwelf_lasso_50full3 
	local f50rho3=r(rho)
	local f50p3=r(p)
	local f50N3=r(N)
spearman predcons_census_ubrvill50 predwelf_lasso_50ubr3
	local u50rho3=r(rho)
	local u50p3=r(p)
	local u50N3=r(N)
spearman predcons_census_50vill50 predwelf_lasso_50full503 
	local f5050rho3=r(rho)
	local f5050p3=r(p)
	local f5050N3=r(N)
spearman predcons_census_50ubrvill50 predwelf_lasso_50ubr503
	local u5050rho3=r(rho)
	local u5050p3=r(p)
	local u5050N3=r(N)
	
	spearman predcons_census_fullvill predwelf_xgb_full3 
	local 2frho3=r(rho)
	local 2fp3=r(p)
	local 2fN3=r(N)
spearman predcons_census_ubrvill predwelf_xgb_ubr3
	local 2urho3=r(rho)
	local 2up3=r(p)
	local 2uN3=r(N)
spearman predcons_census_fullvill50 predwelf_xgb_50full3 
	local 2f50rho3=r(rho)
	local 2f50p3=r(p)
	local 2f50N3=r(N)
spearman predcons_census_ubrvill50 predwelf_xgb_50ubr3
	local 2u50rho3=r(rho)
	local 2u50p3=r(p)
	local 2u50N3=r(N)
spearman predcons_census_50vill50 predwelf_xgb_50full503 
	local 2f5050rho3=r(rho)
	local 2f5050p3=r(p)
	local 2f5050N3=r(N)
spearman predcons_census_50ubrvill50 predwelf_xgb_50ubr503
	local 2u5050rho3=r(rho)
	local 2u5050p3=r(p)
	local 2u5050N3=r(N)	

	
*** Data for AUC: FPR and TPR
putexcel set "Census\Updated results\AUC_lasso_census20", replace

forvalues i=1(1)99 {
	egen ranktrue_31`i' = pctile(predcons_census_fullvill), /*by(district)*/ p(`i') 
	g ranktrue_full_`i'=(predcons_census_fullvill<ranktrue_31`i')
	egen ranktrue_32`i' = pctile(predcons_census_ubrvill), /*by(district)*/ p(`i') 
	g ranktrue_ubr_`i'=(predcons_census_ubrvill<ranktrue_32`i')
	egen ranktrue_33`i' = pctile(predcons_census_fullvill50), /*by(district)*/ p(`i') 
	g ranktrue_full50_`i'=(predcons_census_fullvill50<ranktrue_33`i')
	egen ranktrue_34`i' = pctile(predcons_census_ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_ubr50_`i'=(predcons_census_ubrvill50<ranktrue_34`i')
	egen ranktrue_35`i' = pctile(predcons_census_50vill50), /*by(district)*/ p(`i') 
	g ranktrue_50full50_`i'=(predcons_census_50vill50<ranktrue_35`i')
	egen ranktrue_36`i' = pctile(predcons_census_50ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_50ubr50_`i'=(predcons_census_50ubrvill50<ranktrue_36`i')

	egen rankpred_31`i' = pctile(predwelf_lasso_full3), /*by(district)*/ p(`i') 
	egen rankpred_32`i' = pctile(predwelf_lasso_ubr3), /*by(district)*/ p(`i') 
	egen rankpred_33`i' = pctile(predwelf_lasso_50full3), /*by(district)*/ p(`i') 
	egen rankpred_34`i' = pctile(predwelf_lasso_50ubr3), /*by(district)*/ p(`i') 
	egen rankpred_35`i' = pctile(predwelf_lasso_50full503), /*by(district)*/ p(`i') 
	egen rankpred_36`i' = pctile(predwelf_lasso_50ubr503), /*by(district)*/ p(`i') 

	g rankpred3_full_`i'=(predwelf_lasso_full3<ranktrue_31`i')
	g rankpred3_ubr_`i'=(predwelf_lasso_ubr3<ranktrue_32`i')
	g rankpred3_full50_`i'=(predwelf_lasso_50full3<ranktrue_33`i')
	g rankpred3_ubr50_`i'=(predwelf_lasso_50ubr3<ranktrue_34`i')
	g rankpred3_50full50_`i'=(predwelf_lasso_50full503<ranktrue_35`i')
	g rankpred3_50ubr50_`i'=(predwelf_lasso_50ubr503<ranktrue_36`i')

	g rank2pred3_full_`i'=(predwelf_lasso_full3<rankpred_31`i')
	g rank2pred3_ubr_`i'=(predwelf_lasso_ubr3<rankpred_32`i')
	g rank2pred3_full50_`i'=(predwelf_lasso_50full3<rankpred_33`i')
	g rank2pred3_ubr50_`i'=(predwelf_lasso_50ubr3<rankpred_34`i')
	g rank2pred3_50full50_`i'=(predwelf_lasso_50full503<rankpred_35`i')
	g rank2pred3_50ubr50_`i'=(predwelf_lasso_50ubr503<rankpred_36`i')

sum test if rankpred3_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FPf1`i'=r(N)
sum test if rankpred3_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TPf1`i'=r(N)
sum test if rank2pred3_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FP2f1`i'=r(N)
sum test if rank2pred3_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TP2f1`i'=r(N)
sum test if ranktrue_full_`i'==1 //total poor
return list
local Pf1`i'=r(N)
sum test if ranktrue_full_`i'==0 //total non-poor
return list
local NPf1`i'=r(N)

sum test if rankpred3_full50_`i'==1 & ranktrue_full50_`i'==0 //false positive rate
return list
local FPf150`i'=r(N)
sum test if rankpred3_full50_`i'==1 & ranktrue_full50_`i'==1 //true postive rate
return list
local TPf150`i'=r(N)
sum test if rank2pred3_full50_`i'==1 & ranktrue_full50_`i'==0 //false positive rate
return list
local FP2f150`i'=r(N)
sum test if rank2pred3_full50_`i'==1 & ranktrue_full50_`i'==1 //true postive rate
return list
local TP2f150`i'=r(N)
sum test if ranktrue_full50_`i'==1 //total poor
return list
local Pf150`i'=r(N)
sum test if ranktrue_full50_`i'==0 //total non-poor
return list
local NPf150`i'=r(N)

sum test if rankpred3_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FPu1`i'=r(N)
sum test if rankpred3_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TPu1`i'=r(N)
sum test if rank2pred3_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FP2u1`i'=r(N)
sum test if rank2pred3_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TP2u1`i'=r(N)
sum test if ranktrue_ubr_`i'==1 //total poor
return list
local Pu1`i'=r(N)
sum test if ranktrue_ubr_`i'==0 //total non-poor
return list
local NPu1`i'=r(N)

sum test if rankpred3_ubr50_`i'==1 & ranktrue_ubr50_`i'==0 //false positive rate
return list
local FPu150`i'=r(N)
sum test if rankpred3_ubr50_`i'==1 & ranktrue_ubr50_`i'==1 //true postive rate
return list
local TPu150`i'=r(N)
sum test if rank2pred3_ubr50_`i'==1 & ranktrue_ubr50_`i'==0 //false positive rate
return list
local FP2u150`i'=r(N)
sum test if rank2pred3_ubr50_`i'==1 & ranktrue_ubr50_`i'==1 //true postive rate
return list
local TP2u150`i'=r(N)
sum test if ranktrue_ubr50_`i'==1 //total poor
return list
local Pu150`i'=r(N)
sum test if ranktrue_ubr50_`i'==0 //total non-poor
return list
local NPu150`i'=r(N)

sum test if rankpred3_50full50_`i'==1 & ranktrue_50full50_`i'==0 //false positive rate
return list
local FPf15050`i'=r(N)
sum test if rankpred3_50full50_`i'==1 & ranktrue_50full50_`i'==1 //true postive rate
return list
local TPf15050`i'=r(N)
sum test if rank2pred3_50full50_`i'==1 & ranktrue_50full50_`i'==0 //false positive rate
return list
local FP2f15050`i'=r(N)
sum test if rank2pred3_50full50_`i'==1 & ranktrue_50full50_`i'==1 //true postive rate
return list
local TP2f15050`i'=r(N)
sum test if ranktrue_50full50_`i'==1 //total poor
return list
local Pf15050`i'=r(N)
sum test if ranktrue_50full50_`i'==0 //total non-poor
return list
local NPf15050`i'=r(N)

sum test if rankpred3_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==0 //false positive rate
return list
local FPu15050`i'=r(N)
sum test if rankpred3_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==1 //true postive rate
return list
local TPu15050`i'=r(N)
sum test if rank2pred3_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==0 //false positive rate
return list
local FP2u15050`i'=r(N)
sum test if rank2pred3_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==1 //true postive rate
return list
local TP2u15050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==1 //total poor
return list
local Pu15050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==0 //total non-poor
return list
local NPu15050`i'=r(N)
	
putexcel A`i'=`FPf1`i''
putexcel B`i'=`TPf1`i''
putexcel C`i'=`FP2f1`i''
putexcel D`i'=`TP2f1`i''
putexcel E`i'=`Pf1`i''
putexcel F`i'=`NPf1`i''

putexcel H`i'=`FPu1`i''
putexcel I`i'=`TPu1`i''
putexcel J`i'=`FP2u1`i''
putexcel K`i'=`TP2u1`i''
putexcel L`i'=`Pu1`i''
putexcel M`i'=`NPu1`i''

putexcel O`i'=`FPf150`i''
putexcel P`i'=`TPf150`i''
putexcel Q`i'=`FP2f150`i''
putexcel R`i'=`TP2f150`i''
putexcel S`i'=`Pf150`i''
putexcel T`i'=`NPf150`i''

putexcel V`i'=`FPu150`i''
putexcel W`i'=`TPu150`i''
putexcel X`i'=`FP2u150`i''
putexcel Y`i'=`TP2u150`i''
putexcel Z`i'=`Pu150`i''
putexcel AA`i'=`NPu150`i''	

putexcel AC`i'=`FPf15050`i''
putexcel AD`i'=`TPf15050`i''
putexcel AE`i'=`FP2f15050`i''
putexcel AF`i'=`TP2f15050`i''
putexcel AG`i'=`Pf15050`i''
putexcel AH`i'=`NPf15050`i''

putexcel AJ`i'=`FPu15050`i''
putexcel AK`i'=`TPu15050`i''
putexcel AL`i'=`FP2u15050`i''
putexcel AM`i'=`TP2u15050`i''
putexcel AN`i'=`Pu15050`i''
putexcel AO`i'=`NPu15050`i''

}
drop rankpred_3* rankpred3_* rank2pred3_* ranktrue_*

*** AUC calculations
preserve
import excel "Census\Updated results\AUC_lasso_census20.xlsx", sheet("Sheet1") clear

g FPR_full=A/F
g TPR_full=B/E
g FPR_full2=C/F
g TPR_full2=D/E

g FPR_ubr=H/M
g TPR_ubr=I/L
g FPR_ubr2=J/M
g TPR_ubr2=K/L

g FPR_full50=O/T
g TPR_full50=P/S
g FPR_full502=Q/T
g TPR_full502=R/S

g FPR_ubr50=V/AA
g TPR_ubr50=W/Z
g FPR_ubr502=X/AA
g TPR_ubr502=Y/Z

g FPR_50full50=AC/AH
g TPR_50full50=AD/AG
g FPR_50full502=AE/AH
g TPR_50full502=AF/AG

g FPR_50ubr50=AJ/AO
g TPR_50ubr50=AK/AN
g FPR_50ubr502=AL/AO
g TPR_50ubr502=AM/AN

keep FPR* TPR* 

set obs `=_N+1'

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
	replace TPR_`x'=1 if TPR_`x'==.
	replace FPR_`x'=1 if FPR_`x'==.
	replace TPR_`x'2=1 if TPR_`x'2==.
	replace FPR_`x'2=1 if FPR_`x'2==.
}

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x' FPR_`x', gen(total_auc`x') trapezoid
local auclasso20_1`x'=r(integral) 
}

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x'2 FPR_`x'2, gen(total_auc`x'2) trapezoid
local auclasso20_2`x'=r(integral) 
}

restore

*** Creating AUC Excel file
putexcel set "Census\Updated results\AUC_lasso_updating1", replace

putexcel A1="AUC"

putexcel A3="Sample 1: 10%-90%"
putexcel A4="Sample 2: 15%-85%"
putexcel A5="Sample 2: 20%-80%"

putexcel B1="Predicted consumption based on all districts-all HH in IHS & all HH in census"
putexcel D1="Predicted consumption based on UBR districts-all HH in IHS & all UBR HH in census"
putexcel F1="Predicted consumption based on all districts-all HH in IHS & poorest 50% HH in census"
putexcel H1="Predicted consumption based on UBR districts-all HH in IHS & poorest 50% UBR HH in census"
putexcel J1="Predicted consumption based on Poorest 50% HH in all districts in IHS & poorest 50% HH in census"
putexcel L1="Predicted consumption based on Poorest 50% HH in UBR districts in IHS & poorest 50% UBR HH in census"

putexcel B2="One threshold"
putexcel C2="Two thresholds"
putexcel D2="One threshold"
putexcel E2="Two thresholds"
putexcel F2="One threshold"
putexcel G2="Two thresholds"
putexcel H2="One threshold"
putexcel I2="Two thresholds"
putexcel J2="One threshold"
putexcel K2="Two thresholds"
putexcel L2="One threshold"
putexcel M2="Two thresholds"

putexcel B3=`auclasso10_1full'
putexcel C3=`auclasso10_2full'
putexcel D3=`auclasso10_1ubr'
putexcel E3=`auclasso10_2ubr'
putexcel F3=`auclasso10_1full50'
putexcel G3=`auclasso10_2full50'
putexcel H3=`auclasso10_1ubr50'
putexcel I3=`auclasso10_2ubr50'
putexcel J3=`auclasso10_150full50'
putexcel K3=`auclasso10_250full50'
putexcel L3=`auclasso10_150ubr50'
putexcel M3=`auclasso10_250ubr50'

putexcel B4=`auclasso15_1full'
putexcel C4=`auclasso15_2full'
putexcel D4=`auclasso15_1ubr'
putexcel E4=`auclasso15_2ubr'
putexcel F4=`auclasso15_1full50'
putexcel G4=`auclasso15_2full50'
putexcel H4=`auclasso15_1ubr50'
putexcel I4=`auclasso15_2ubr50'
putexcel J4=`auclasso15_150full50'
putexcel K4=`auclasso15_250full50'
putexcel L4=`auclasso15_150ubr50'
putexcel M4=`auclasso15_250ubr50'

putexcel B5=`auclasso20_1full'
putexcel C5=`auclasso20_2full'
putexcel D5=`auclasso20_1ubr'
putexcel E5=`auclasso20_2ubr'
putexcel F5=`auclasso20_1full50'
putexcel G5=`auclasso20_2full50'
putexcel H5=`auclasso20_1ubr50'
putexcel I5=`auclasso20_2ubr50'
putexcel J5=`auclasso20_150full50'
putexcel K5=`auclasso20_250full50'
putexcel L5=`auclasso20_150ubr50'
putexcel M5=`auclasso20_250ubr50'
*/
*** Creating rank correlations Excel file
/* "LASSO_rankcorr_lasso_lasso_updat1": 
'LASSO' models to predict welfare, 
'rancorr' rank correlations between 
'lasso' benchmark welfare estimated with lasso, 
'lasso' predicted welfare using LASSO models that use as dependent variable the benchmark welfare predicted with lasso models.
*/
putexcel set "Census\Updated results\LASSO_rankcorr_lasso_lasso_updat1", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel B1="Predicted consumption based on all districts-all HH in IHS & all HH in census"
putexcel C1="Predicted consumption based on UBR districts-all HH in IHS & all UBR HH in census"
putexcel D1="Predicted consumption based on all districts-all HH in IHS & poorest 50% HH in census"
putexcel E1="Predicted consumption based on UBR districts-all HH in IHS & poorest 50% UBR HH in census"
putexcel F1="Predicted consumption based on Poorest 50% HH in all districts in IHS & poorest 50% HH in census"
putexcel G1="Predicted consumption based on Poorest 50% HH in UBR districts in IHS & poorest 50% UBR HH in census"

putexcel B3=`frho1'
putexcel B4=`fp1'
putexcel B5=`fN1'
putexcel C3=`urho1'
putexcel C4=`up1'
putexcel C5=`uN1'
putexcel D3=`f50rho1'
putexcel D4=`f50p1'
putexcel D5=`f50N1'
putexcel E3=`u50rho1'
putexcel E4=`u50p1'
putexcel E5=`u50N1'
putexcel F3=`f5050rho1'
putexcel F4=`f5050p1'
putexcel F5=`f5050N1'
putexcel G3=`u5050rho1'
putexcel G4=`u5050p1'
putexcel G5=`u5050N1'

putexcel B6=`frho2'
putexcel B7=`fp2'
putexcel B8=`fN2'
putexcel C6=`urho2'
putexcel C7=`up2'
putexcel C8=`uN2'
putexcel D6=`f50rho2'
putexcel D7=`f50p2'
putexcel D8=`f50N2'
putexcel E6=`u50rho2'
putexcel E7=`u50p2'
putexcel E8=`u50N2'
putexcel F6=`f5050rho2'
putexcel F7=`f5050p2'
putexcel F8=`f5050N2'
putexcel G6=`u5050rho2'
putexcel G7=`u5050p2'
putexcel G8=`u5050N2'

putexcel B9=`frho3'
putexcel B10=`fp3'
putexcel B11=`fN3'
putexcel C9=`urho3'
putexcel C10=`up3'
putexcel C11=`uN3'
putexcel D9=`f50rho3'
putexcel D10=`f50p3'
putexcel D11=`f50N3'
putexcel E9=`u50rho3'
putexcel E10=`u50p3'
putexcel E11=`u50N3'
putexcel F9=`f5050rho3'
putexcel F10=`f5050p3'
putexcel F11=`f5050N3'
putexcel G9=`u5050rho3'
putexcel G10=`u5050p3'
putexcel G11=`u5050N3'

/* "LASSO_rankcorr_lasso_lasso_updat1": 
'LASSO' models to predict welfare, 
'rancorr' rank correlations between 
'lasso' benchmark welfare estimated with lasso, 
'xgb' predicted welfare using LASSO models that use as dependent variable the benchmark welfare predicted with xgb models.
*/

putexcel set "Census\Updated results\LASSO_rankcorr_lasso_xgb_updat1", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel B1="Predicted consumption based on all districts-all HH in IHS & all HH in census"
putexcel C1="Predicted consumption based on UBR districts-all HH in IHS & all UBR HH in census"
putexcel D1="Predicted consumption based on all districts-all HH in IHS & poorest 50% HH in census"
putexcel E1="Predicted consumption based on UBR districts-all HH in IHS & poorest 50% UBR HH in census"
putexcel F1="Predicted consumption based on Poorest 50% HH in all districts in IHS & poorest 50% HH in census"
putexcel G1="Predicted consumption based on Poorest 50% HH in UBR districts in IHS & poorest 50% UBR HH in census"
putexcel B3=`2frho1'
putexcel B4=`2fp1'
putexcel B5=`2fN1'
putexcel C3=`2urho1'
putexcel C4=`2up1'
putexcel C5=`2uN1'
putexcel D3=`2f50rho1'
putexcel D4=`2f50p1'
putexcel D5=`2f50N1'
putexcel E3=`2u50rho1'
putexcel E4=`2u50p1'
putexcel E5=`2u50N1'
putexcel F3=`2f5050rho1'
putexcel F4=`2f5050p1'
putexcel F5=`2f5050N1'
putexcel G3=`2u5050rho1'
putexcel G4=`2u5050p1'
putexcel G5=`2u5050N1'

putexcel B6=`2frho2'
putexcel B7=`2fp2'
putexcel B8=`2fN2'
putexcel C6=`2urho2'
putexcel C7=`2up2'
putexcel C8=`2uN2'
putexcel D6=`2f50rho2'
putexcel D7=`2f50p2'
putexcel D8=`2f50N2'
putexcel E6=`2u50rho2'
putexcel E7=`2u50p2'
putexcel E8=`2u50N2'
putexcel F6=`2f5050rho2'
putexcel F7=`2f5050p2'
putexcel F8=`2f5050N2'
putexcel G6=`2u5050rho2'
putexcel G7=`2u5050p2'
putexcel G8=`2u5050N2'

putexcel B9=`2frho3'
putexcel B10=`2fp3'
putexcel B11=`2fN3'
putexcel C9=`2urho3'
putexcel C10=`2up3'
putexcel C11=`2uN3'
putexcel D9=`2f50rho3'
putexcel D10=`2f50p3'
putexcel D11=`2f50N3'
putexcel E9=`2u50rho3'
putexcel E10=`2u50p3'
putexcel E11=`2u50N3'
putexcel F9=`2f5050rho3'
putexcel F10=`2f5050p3'
putexcel F11=`2f5050N3'
putexcel G9=`2u5050rho3'
putexcel G10=`2u5050p3'
putexcel G11=`2u5050N3'

***********************************************
*** Benchmark: estimated with XGBOOST

***R-squared
reg predcons_xgb_50vill50 predwelf_xgb_50full501 


*** Rank correlations
spearman predcons_xgb_fullvill predwelf_xgb_full1 
	local frho1=r(rho)
	local fp1=r(p)
	local fN1=r(N)
spearman predcons_xgb_ubrvill predwelf_xgb_ubr1
	local urho1=r(rho)
	local up1=r(p)
	local uN1=r(N)
spearman predcons_xgb_fullvill50 predwelf_xgb_50full1 
	local f50rho1=r(rho)
	local f50p1=r(p)
	local f50N1=r(N)
spearman predcons_xgb_ubrvill50 predwelf_xgb_50ubr1
	local u50rho1=r(rho)
	local u50p1=r(p)
	local u50N1=r(N)
spearman predcons_xgb_50vill50 predwelf_xgb_50full501 
	local f5050rho1=r(rho)
	local f5050p1=r(p)
	local f5050N1=r(N)
spearman predcons_xgb_50ubrvill50 predwelf_xgb_50ubr501
	local u5050rho1=r(rho)
	local u5050p1=r(p)
	local u5050N1=r(N)
	
spearman predcons_xgb_fullvill predwelf_lasso_full1 
	local 2frho1=r(rho)
	local 2fp1=r(p)
	local 2fN1=r(N)
spearman predcons_xgb_ubrvill predwelf_lasso_ubr1
	local 2urho1=r(rho)
	local 2up1=r(p)
	local 2uN1=r(N)
spearman predcons_xgb_fullvill50 predwelf_lasso_50full1 
	local 2f50rho1=r(rho)
	local 2f50p1=r(p)
	local 2f50N1=r(N)
spearman predcons_xgb_ubrvill50 predwelf_lasso_50ubr1
	local 2u50rho1=r(rho)
	local 2u50p1=r(p)
	local 2u50N1=r(N)
spearman predcons_xgb_50vill50 predwelf_lasso_50full501 
	local 2f5050rho1=r(rho)
	local 2f5050p1=r(p)
	local 2f5050N1=r(N)
spearman predcons_xgb_50ubrvill50 predwelf_lasso_50ubr501
	local 2u5050rho1=r(rho)
	local 2u5050p1=r(p)
	local 2u5050N1=r(N)
	
***Data for AUC: FPR and TPR
putexcel set "Census\Updated results\AUC_xgb_census10", replace

forvalues i=1(1)99 {
	egen ranktrue_11`i' = pctile(predcons_xgb_fullvill), /*by(district)*/ p(`i') 
	g ranktrue_full_`i'=(predcons_xgb_fullvill<ranktrue_11`i')
	egen ranktrue_12`i' = pctile(predcons_xgb_ubrvill), /*by(district)*/ p(`i') 
	g ranktrue_ubr_`i'=(predcons_xgb_ubrvill<ranktrue_12`i')
	egen ranktrue_13`i' = pctile(predcons_xgb_fullvill50), /*by(district)*/ p(`i') 
	g ranktrue_full50_`i'=(predcons_xgb_fullvill50<ranktrue_13`i')
	egen ranktrue_14`i' = pctile(predcons_xgb_ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_ubr50_`i'=(predcons_xgb_ubrvill50<ranktrue_14`i')
	egen ranktrue_15`i' = pctile(predcons_xgb_50vill50), /*by(district)*/ p(`i') 
	g ranktrue_50full50_`i'=(predcons_xgb_50vill50<ranktrue_15`i')
	egen ranktrue_16`i' = pctile(predcons_xgb_50ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_50ubr50_`i'=(predcons_xgb_50ubrvill50<ranktrue_16`i')
	
	egen rankpred_11`i' = pctile(predwelf_xgb_full1), /*by(district)*/ p(`i') 
	egen rankpred_12`i' = pctile(predwelf_xgb_ubr1), /*by(district)*/ p(`i') 
	egen rankpred_13`i' = pctile(predwelf_xgb_50full1), /*by(district)*/ p(`i') 
	egen rankpred_14`i' = pctile(predwelf_xgb_50ubr1), /*by(district)*/ p(`i') 
	egen rankpred_15`i' = pctile(predwelf_xgb_50full501), /*by(district)*/ p(`i') 
	egen rankpred_16`i' = pctile(predwelf_xgb_50ubr501), /*by(district)*/ p(`i') 

	g rankpred1_full_`i'=(predwelf_xgb_full1<ranktrue_11`i')
	g rankpred1_ubr_`i'=(predwelf_xgb_ubr1<ranktrue_12`i')
	g rankpred1_full50_`i'=(predwelf_xgb_50full1<ranktrue_13`i')
	g rankpred1_ubr50_`i'=(predwelf_xgb_50ubr1<ranktrue_14`i')
	g rankpred1_50full50_`i'=(predwelf_xgb_50full501<ranktrue_15`i')
	g rankpred1_50ubr50_`i'=(predwelf_xgb_50ubr501<ranktrue_16`i')

	g rank2pred1_full_`i'=(predwelf_xgb_full1<rankpred_11`i')
	g rank2pred1_ubr_`i'=(predwelf_xgb_ubr1<rankpred_12`i')
	g rank2pred1_full50_`i'=(predwelf_xgb_50full1<rankpred_13`i')
	g rank2pred1_ubr50_`i'=(predwelf_xgb_50ubr1<rankpred_14`i')
	g rank2pred1_50full50_`i'=(predwelf_xgb_50full501<rankpred_15`i')
	g rank2pred1_50ubr50_`i'=(predwelf_xgb_50ubr501<rankpred_16`i')

sum test if rankpred1_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FPf1`i'=r(N)
sum test if rankpred1_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TPf1`i'=r(N)
sum test if rank2pred1_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FP2f1`i'=r(N)
sum test if rank2pred1_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TP2f1`i'=r(N)
sum test if ranktrue_full_`i'==1 //total poor
return list
local Pf1`i'=r(N)
sum test if ranktrue_full_`i'==0 //total non-poor
return list
local NPf1`i'=r(N)

sum test if rankpred1_full50_`i'==1 & ranktrue_full50_`i'==0 //false positive rate
return list
local FPf150`i'=r(N)
sum test if rankpred1_full50_`i'==1 & ranktrue_full50_`i'==1 //true postive rate
return list
local TPf150`i'=r(N)
sum test if rank2pred1_full50_`i'==1 & ranktrue_full50_`i'==0 //false positive rate
return list
local FP2f150`i'=r(N)
sum test if rank2pred1_full50_`i'==1 & ranktrue_full50_`i'==1 //true postive rate
return list
local TP2f150`i'=r(N)
sum test if ranktrue_full50_`i'==1 //total poor
return list
local Pf150`i'=r(N)
sum test if ranktrue_full50_`i'==0 //total non-poor
return list
local NPf150`i'=r(N)

sum test if rankpred1_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FPu1`i'=r(N)
sum test if rankpred1_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TPu1`i'=r(N)
sum test if rank2pred1_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FP2u1`i'=r(N)
sum test if rank2pred1_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TP2u1`i'=r(N)
sum test if ranktrue_ubr_`i'==1 //total poor
return list
local Pu1`i'=r(N)
sum test if ranktrue_ubr_`i'==0 //total non-poor
return list
local NPu1`i'=r(N)

sum test if rankpred1_ubr50_`i'==1 & ranktrue_ubr50_`i'==0 //false positive rate
return list
local FPu150`i'=r(N)
sum test if rankpred1_ubr50_`i'==1 & ranktrue_ubr50_`i'==1 //true postive rate
return list
local TPu150`i'=r(N)
sum test if rank2pred1_ubr50_`i'==1 & ranktrue_ubr50_`i'==0 //false positive rate
return list
local FP2u150`i'=r(N)
sum test if rank2pred1_ubr50_`i'==1 & ranktrue_ubr50_`i'==1 //true postive rate
return list
local TP2u150`i'=r(N)
sum test if ranktrue_ubr50_`i'==1 //total poor
return list
local Pu150`i'=r(N)
sum test if ranktrue_ubr50_`i'==0 //total non-poor
return list
local NPu150`i'=r(N)

sum test if rankpred1_50full50_`i'==1 & ranktrue_50full50_`i'==0 //false positive rate
return list
local FPf15050`i'=r(N)
sum test if rankpred1_50full50_`i'==1 & ranktrue_50full50_`i'==1 //true postive rate
return list
local TPf15050`i'=r(N)
sum test if rank2pred1_50full50_`i'==1 & ranktrue_50full50_`i'==0 //false positive rate
return list
local FP2f15050`i'=r(N)
sum test if rank2pred1_50full50_`i'==1 & ranktrue_50full50_`i'==1 //true postive rate
return list
local TP2f15050`i'=r(N)
sum test if ranktrue_50full50_`i'==1 //total poor
return list
local Pf15050`i'=r(N)
sum test if ranktrue_50full50_`i'==0 //total non-poor
return list
local NPf15050`i'=r(N)

sum test if rankpred1_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==0 //false positive rate
return list
local FPu15050`i'=r(N)
sum test if rankpred1_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==1 //true postive rate
return list
local TPu15050`i'=r(N)
sum test if rank2pred1_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==0 //false positive rate
return list
local FP2u15050`i'=r(N)
sum test if rank2pred1_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==1 //true postive rate
return list
local TP2u15050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==1 //total poor
return list
local Pu15050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==0 //total non-poor
return list
local NPu15050`i'=r(N)
	
putexcel A`i'=`FPf1`i''
putexcel B`i'=`TPf1`i''
putexcel C`i'=`FP2f1`i''
putexcel D`i'=`TP2f1`i''
putexcel E`i'=`Pf1`i''
putexcel F`i'=`NPf1`i''

putexcel H`i'=`FPu1`i''
putexcel I`i'=`TPu1`i''
putexcel J`i'=`FP2u1`i''
putexcel K`i'=`TP2u1`i''
putexcel L`i'=`Pu1`i''
putexcel M`i'=`NPu1`i''

putexcel O`i'=`FPf150`i''
putexcel P`i'=`TPf150`i''
putexcel Q`i'=`FP2f150`i''
putexcel R`i'=`TP2f150`i''
putexcel S`i'=`Pf150`i''
putexcel T`i'=`NPf150`i''

putexcel V`i'=`FPu150`i''
putexcel W`i'=`TPu150`i''
putexcel X`i'=`FP2u150`i''
putexcel Y`i'=`TP2u150`i''
putexcel Z`i'=`Pu150`i''
putexcel AA`i'=`NPu150`i''	

putexcel AC`i'=`FPf15050`i''
putexcel AD`i'=`TPf15050`i''
putexcel AE`i'=`FP2f15050`i''
putexcel AF`i'=`TP2f15050`i''
putexcel AG`i'=`Pf15050`i''
putexcel AH`i'=`NPf15050`i''

putexcel AJ`i'=`FPu15050`i''
putexcel AK`i'=`TPu15050`i''
putexcel AL`i'=`FP2u15050`i''
putexcel AM`i'=`TP2u15050`i''
putexcel AN`i'=`Pu15050`i''
putexcel AO`i'=`NPu15050`i''	

	}

drop rankpred_1* rankpred1_* rank2pred1_*  ranktrue_*

*** AUC calculations
preserve
import excel "Census\Updated results\AUC_xgb_census10.xlsx", sheet("Sheet1") clear

g FPR_full=A/F
g TPR_full=B/E
g FPR_full2=C/F
g TPR_full2=D/E

g FPR_ubr=H/M
g TPR_ubr=I/L
g FPR_ubr2=J/M
g TPR_ubr2=K/L

g FPR_full50=O/T
g TPR_full50=P/S
g FPR_full502=Q/T
g TPR_full502=R/S

g FPR_ubr50=V/AA
g TPR_ubr50=W/Z
g FPR_ubr502=X/AA
g TPR_ubr502=Y/Z

g FPR_50full50=AC/AH
g TPR_50full50=AD/AG
g FPR_50full502=AE/AH
g TPR_50full502=AF/AG

g FPR_50ubr50=AJ/AO
g TPR_50ubr50=AK/AN
g FPR_50ubr502=AL/AO
g TPR_50ubr502=AM/AN

keep FPR* TPR* 

set obs `=_N+1'

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
	replace TPR_`x'=1 if TPR_`x'==.
	replace FPR_`x'=1 if FPR_`x'==.
	replace TPR_`x'2=1 if TPR_`x'2==.
	replace FPR_`x'2=1 if FPR_`x'2==.
}

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x' FPR_`x' , trapezoid
local aucxgb10_1`x'=r(integral) 
}

foreach x in full ubr full50 ubr50 50full50 50ubr50 {

integ TPR_`x'2 FPR_`x'2, trapezoid
local aucxgb10_2`x'=r(integral) 
}
restore

**********************
*** Sample 15%
*** Rank correlations
spearman predcons_xgb_fullvill predwelf_xgb_full2 
	local frho2=r(rho)
	local fp2=r(p)
	local fN2=r(N)
spearman predcons_xgb_ubrvill predwelf_xgb_ubr2
	local urho2=r(rho)
	local up2=r(p)
	local uN2=r(N)
spearman predcons_xgb_fullvill50 predwelf_xgb_50full2 
	local f50rho2=r(rho)
	local f50p2=r(p)
	local f50N2=r(N)
spearman predcons_xgb_ubrvill50 predwelf_xgb_50ubr2
	local u50rho2=r(rho)
	local u50p2=r(p)
	local u50N2=r(N)
spearman predcons_xgb_50vill50 predwelf_xgb_50full502 
	local f5050rho2=r(rho)
	local f5050p2=r(p)
	local f5050N2=r(N)
spearman predcons_xgb_50ubrvill50 predwelf_xgb_50ubr502
	local u5050rho2=r(rho)
	local u5050p2=r(p)
	local u5050N2=r(N)
	
spearman predcons_xgb_fullvill predwelf_lasso_full2 
	local 2frho2=r(rho)
	local 2fp2=r(p)
	local 2fN2=r(N)
spearman predcons_xgb_ubrvill predwelf_lasso_ubr2
	local 2urho2=r(rho)
	local 2up2=r(p)
	local 2uN2=r(N)
spearman predcons_xgb_fullvill50 predwelf_lasso_50full2 
	local 2f50rho2=r(rho)
	local 2f50p2=r(p)
	local 2f50N2=r(N)
spearman predcons_xgb_ubrvill50 predwelf_lasso_50ubr2
	local 2u50rho2=r(rho)
	local 2u50p2=r(p)
	local 2u50N2=r(N)
spearman predcons_xgb_50vill50 predwelf_lasso_50full502 
	local 2f5050rho2=r(rho)
	local 2f5050p2=r(p)
	local 2f5050N2=r(N)
spearman predcons_xgb_50ubrvill50 predwelf_lasso_50ubr502
	local 2u5050rho2=r(rho)
	local 2u5050p2=r(p)
	local 2u5050N2=r(N)
	
*** Data for AUC: FPR and TPR
putexcel set "Census\Updated results\AUC_xgb_census15", replace

forvalues i=1(1)99 {
	egen ranktrue_21`i' = pctile(predcons_xgb_fullvill), /*by(district)*/ p(`i') 
	g ranktrue_full_`i'=(predcons_xgb_fullvill<ranktrue_21`i')
	egen ranktrue_22`i' = pctile(predcons_xgb_ubrvill), /*by(district)*/ p(`i') 
	g ranktrue_ubr_`i'=(predcons_xgb_ubrvill<ranktrue_22`i')
	egen ranktrue_23`i' = pctile(predcons_xgb_fullvill50), /*by(district)*/ p(`i') 
	g ranktrue_full50_`i'=(predcons_xgb_fullvill50<ranktrue_23`i')
	egen ranktrue_24`i' = pctile(predcons_xgb_ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_ubr50_`i'=(predcons_xgb_ubrvill50<ranktrue_24`i')
	egen ranktrue_25`i' = pctile(predcons_xgb_50vill50), /*by(district)*/ p(`i') 
	g ranktrue_50full50_`i'=(predcons_xgb_50vill50<ranktrue_25`i')
	egen ranktrue_26`i' = pctile(predcons_xgb_50ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_50ubr50_`i'=(predcons_xgb_50ubrvill50<ranktrue_26`i')
	
	egen rankpred_21`i' = pctile(predwelf_xgb_full2), /*by(district)*/ p(`i') 
	egen rankpred_22`i' = pctile(predwelf_xgb_ubr2), /*by(district)*/ p(`i') 
	egen rankpred_23`i' = pctile(predwelf_xgb_50full2), /*by(district)*/ p(`i') 
	egen rankpred_24`i' = pctile(predwelf_xgb_50ubr2), /*by(district)*/ p(`i') 
	egen rankpred_25`i' = pctile(predwelf_xgb_50full502), /*by(district)*/ p(`i') 
	egen rankpred_26`i' = pctile(predwelf_xgb_50ubr502), /*by(district)*/ p(`i') 

	g rankpred2_full_`i'=(predwelf_xgb_full2<ranktrue_21`i')
	g rankpred2_ubr_`i'=(predwelf_xgb_ubr2<ranktrue_22`i')
	g rankpred2_full50_`i'=(predwelf_xgb_50full2<ranktrue_23`i')
	g rankpred2_ubr50_`i'=(predwelf_xgb_50ubr2<ranktrue_24`i')
	g rankpred2_50full50_`i'=(predwelf_xgb_50full502<ranktrue_25`i')
	g rankpred2_50ubr50_`i'=(predwelf_xgb_50ubr502<ranktrue_26`i')

	g rank2pred2_full_`i'=(predwelf_xgb_full2<rankpred_21`i')
	g rank2pred2_ubr_`i'=(predwelf_xgb_ubr2<rankpred_22`i')
	g rank2pred2_full50_`i'=(predwelf_xgb_50full2<rankpred_23`i')
	g rank2pred2_ubr50_`i'=(predwelf_xgb_50ubr2<rankpred_24`i')
	g rank2pred2_50full50_`i'=(predwelf_xgb_50full502<rankpred_25`i')
	g rank2pred2_50ubr50_`i'=(predwelf_xgb_50ubr502<rankpred_26`i')

sum test if rankpred2_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FPf1`i'=r(N)
sum test if rankpred2_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TPf1`i'=r(N)
sum test if rank2pred2_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FP2f1`i'=r(N)
sum test if rank2pred2_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TP2f1`i'=r(N)
sum test if ranktrue_full_`i'==1 //total poor
return list
local Pf1`i'=r(N)
sum test if ranktrue_full_`i'==0 //total non-poor
return list
local NPf1`i'=r(N)

sum test if rankpred2_full50_`i'==1 & ranktrue_full50_`i'==0 //false positive rate
return list
local FPf150`i'=r(N)
sum test if rankpred2_full50_`i'==1 & ranktrue_full50_`i'==1 //true postive rate
return list
local TPf150`i'=r(N)
sum test if rank2pred2_full50_`i'==1 & ranktrue_full50_`i'==0 //false positive rate
return list
local FP2f150`i'=r(N)
sum test if rank2pred2_full50_`i'==1 & ranktrue_full50_`i'==1 //true postive rate
return list
local TP2f150`i'=r(N)
sum test if ranktrue_full50_`i'==1 //total poor
return list
local Pf150`i'=r(N)
sum test if ranktrue_full50_`i'==0 //total non-poor
return list
local NPf150`i'=r(N)

sum test if rankpred2_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FPu1`i'=r(N)
sum test if rankpred2_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TPu1`i'=r(N)
sum test if rank2pred2_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FP2u1`i'=r(N)
sum test if rank2pred2_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TP2u1`i'=r(N)
sum test if ranktrue_ubr_`i'==1 //total poor
return list
local Pu1`i'=r(N)
sum test if ranktrue_ubr_`i'==0 //total non-poor
return list
local NPu1`i'=r(N)

sum test if rankpred2_ubr50_`i'==1 & ranktrue_ubr50_`i'==0 //false positive rate
return list
local FPu150`i'=r(N)
sum test if rankpred2_ubr50_`i'==1 & ranktrue_ubr50_`i'==1 //true postive rate
return list
local TPu150`i'=r(N)
sum test if rank2pred2_ubr50_`i'==1 & ranktrue_ubr50_`i'==0 //false positive rate
return list
local FP2u150`i'=r(N)
sum test if rank2pred2_ubr50_`i'==1 & ranktrue_ubr50_`i'==1 //true postive rate
return list
local TP2u150`i'=r(N)
sum test if ranktrue_ubr50_`i'==1 //total poor
return list
local Pu150`i'=r(N)
sum test if ranktrue_ubr50_`i'==0 //total non-poor
return list
local NPu150`i'=r(N)

sum test if rankpred2_50full50_`i'==1 & ranktrue_50full50_`i'==0 //false positive rate
return list
local FPf15050`i'=r(N)
sum test if rankpred2_50full50_`i'==1 & ranktrue_50full50_`i'==1 //true postive rate
return list
local TPf15050`i'=r(N)
sum test if rank2pred2_50full50_`i'==1 & ranktrue_50full50_`i'==0 //false positive rate
return list
local FP2f15050`i'=r(N)
sum test if rank2pred2_50full50_`i'==1 & ranktrue_50full50_`i'==1 //true postive rate
return list
local TP2f15050`i'=r(N)
sum test if ranktrue_50full50_`i'==1 //total poor
return list
local Pf15050`i'=r(N)
sum test if ranktrue_50full50_`i'==0 //total non-poor
return list
local NPf15050`i'=r(N)

sum test if rankpred2_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==0 //false positive rate
return list
local FPu15050`i'=r(N)
sum test if rankpred2_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==1 //true postive rate
return list
local TPu15050`i'=r(N)
sum test if rank2pred2_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==0 //false positive rate
return list
local FP2u15050`i'=r(N)
sum test if rank2pred2_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==1 //true postive rate
return list
local TP2u15050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==1 //total poor
return list
local Pu15050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==0 //total non-poor
return list
local NPu15050`i'=r(N)
	
putexcel A`i'=`FPf1`i''
putexcel B`i'=`TPf1`i''
putexcel C`i'=`FP2f1`i''
putexcel D`i'=`TP2f1`i''
putexcel E`i'=`Pf1`i''
putexcel F`i'=`NPf1`i''

putexcel H`i'=`FPu1`i''
putexcel I`i'=`TPu1`i''
putexcel J`i'=`FP2u1`i''
putexcel K`i'=`TP2u1`i''
putexcel L`i'=`Pu1`i''
putexcel M`i'=`NPu1`i''

putexcel O`i'=`FPf150`i''
putexcel P`i'=`TPf150`i''
putexcel Q`i'=`FP2f150`i''
putexcel R`i'=`TP2f150`i''
putexcel S`i'=`Pf150`i''
putexcel T`i'=`NPf150`i''

putexcel V`i'=`FPu150`i''
putexcel W`i'=`TPu150`i''
putexcel X`i'=`FP2u150`i''
putexcel Y`i'=`TP2u150`i''
putexcel Z`i'=`Pu150`i''
putexcel AA`i'=`NPu150`i''	

putexcel AC`i'=`FPf15050`i''
putexcel AD`i'=`TPf15050`i''
putexcel AE`i'=`FP2f15050`i''
putexcel AF`i'=`TP2f15050`i''
putexcel AG`i'=`Pf15050`i''
putexcel AH`i'=`NPf15050`i''

putexcel AJ`i'=`FPu15050`i''
putexcel AK`i'=`TPu15050`i''
putexcel AL`i'=`FP2u15050`i''
putexcel AM`i'=`TP2u15050`i''
putexcel AN`i'=`Pu15050`i''
putexcel AO`i'=`NPu15050`i''

	

}
drop rankpred_2* rankpred2_* rank2pred2_* ranktrue_*

*** AUC calculations
preserve
import excel "Census\Updated results\AUC_xgb_census15.xlsx", sheet("Sheet1") clear

g FPR_full=A/F
g TPR_full=B/E
g FPR_full2=C/F
g TPR_full2=D/E

g FPR_ubr=H/M
g TPR_ubr=I/L
g FPR_ubr2=J/M
g TPR_ubr2=K/L

g FPR_full50=O/T
g TPR_full50=P/S
g FPR_full502=Q/T
g TPR_full502=R/S

g FPR_ubr50=V/AA
g TPR_ubr50=W/Z
g FPR_ubr502=X/AA
g TPR_ubr502=Y/Z

g FPR_50full50=AC/AH
g TPR_50full50=AD/AG
g FPR_50full502=AE/AH
g TPR_50full502=AF/AG

g FPR_50ubr50=AJ/AO
g TPR_50ubr50=AK/AN
g FPR_50ubr502=AL/AO
g TPR_50ubr502=AM/AN

keep FPR* TPR* 

set obs `=_N+1'

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
	replace TPR_`x'=0.99 if TPR_`x'==.
	replace FPR_`x'=0.99 if FPR_`x'==.
	replace TPR_`x'2=0.99 if TPR_`x'2==.
	replace FPR_`x'2=0.99 if FPR_`x'2==.
}

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x' FPR_`x', gen(total_auc`x') trapezoid
local aucxgb15_1`x'=r(integral) 
}

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x'2 FPR_`x'2, gen(total_auc`x'2) trapezoid
local aucxgb15_2`x'=r(integral) 
}

restore


**********************
*** Sample 20%
*** Rank correlations
spearman predcons_xgb_fullvill predwelf_xgb_full3 
	local frho3=r(rho)
	local fp3=r(p)
	local fN3=r(N)
spearman predcons_xgb_ubrvill predwelf_xgb_ubr3
	local urho3=r(rho)
	local up3=r(p)
	local uN3=r(N)
spearman predcons_xgb_fullvill50 predwelf_xgb_50full3 
	local f50rho3=r(rho)
	local f50p3=r(p)
	local f50N3=r(N)
spearman predcons_xgb_ubrvill50 predwelf_xgb_50ubr3
	local u50rho3=r(rho)
	local u50p3=r(p)
	local u50N3=r(N)
spearman predcons_xgb_50vill50 predwelf_xgb_50full503 
	local f5050rho3=r(rho)
	local f5050p3=r(p)
	local f5050N3=r(N)
spearman predcons_xgb_50ubrvill50 predwelf_xgb_50ubr503
	local u5050rho3=r(rho)
	local u5050p3=r(p)
	local u5050N3=r(N)
	
spearman predcons_xgb_fullvill predwelf_lasso_full3 
	local 2frho3=r(rho)
	local 2fp3=r(p)
	local 2fN3=r(N)
spearman predcons_xgb_ubrvill predwelf_lasso_ubr3
	local 2urho3=r(rho)
	local 2up3=r(p)
	local 2uN3=r(N)
spearman predcons_xgb_fullvill50 predwelf_lasso_50full3 
	local 2f50rho3=r(rho)
	local 2f50p3=r(p)
	local 2f50N3=r(N)
spearman predcons_xgb_ubrvill50 predwelf_lasso_50ubr3
	local 2u50rho3=r(rho)
	local 2u50p3=r(p)
	local 2u50N3=r(N)
spearman predcons_xgb_50vill50 predwelf_lasso_50full503 
	local 2f5050rho3=r(rho)
	local 2f5050p3=r(p)
	local 2f5050N3=r(N)
spearman predcons_xgb_50ubrvill50 predwelf_lasso_50ubr503
	local 2u5050rho3=r(rho)
	local 2u5050p3=r(p)
	local 2u5050N3=r(N)
		
*** Data for AUC: FPR and TPR
putexcel set "Census\Updated results\AUC_xgb_census20", replace

forvalues i=1(1)99 {
	egen ranktrue_31`i' = pctile(predcons_xgb_fullvill), /*by(district)*/ p(`i') 
	g ranktrue_full_`i'=(predcons_xgb_fullvill<ranktrue_31`i')
	egen ranktrue_32`i' = pctile(predcons_xgb_ubrvill), /*by(district)*/ p(`i') 
	g ranktrue_ubr_`i'=(predcons_xgb_ubrvill<ranktrue_32`i')
	egen ranktrue_33`i' = pctile(predcons_xgb_fullvill50), /*by(district)*/ p(`i') 
	g ranktrue_full50_`i'=(predcons_xgb_fullvill50<ranktrue_33`i')
	egen ranktrue_34`i' = pctile(predcons_xgb_ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_ubr50_`i'=(predcons_xgb_ubrvill50<ranktrue_34`i')
	egen ranktrue_35`i' = pctile(predcons_xgb_50vill50), /*by(district)*/ p(`i') 
	g ranktrue_50full50_`i'=(predcons_xgb_50vill50<ranktrue_35`i')
	egen ranktrue_36`i' = pctile(predcons_xgb_50ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_50ubr50_`i'=(predcons_xgb_50ubrvill50<ranktrue_36`i')

	egen rankpred_31`i' = pctile(predwelf_xgb_full3), /*by(district)*/ p(`i') 
	egen rankpred_32`i' = pctile(predwelf_xgb_ubr3), /*by(district)*/ p(`i') 
	egen rankpred_33`i' = pctile(predwelf_xgb_50full3), /*by(district)*/ p(`i') 
	egen rankpred_34`i' = pctile(predwelf_xgb_50ubr3), /*by(district)*/ p(`i') 
	egen rankpred_35`i' = pctile(predwelf_xgb_50full503), /*by(district)*/ p(`i') 
	egen rankpred_36`i' = pctile(predwelf_xgb_50ubr503), /*by(district)*/ p(`i') 

	g rankpred3_full_`i'=(predwelf_xgb_full3<ranktrue_31`i')
	g rankpred3_ubr_`i'=(predwelf_xgb_ubr3<ranktrue_32`i')
	g rankpred3_full50_`i'=(predwelf_xgb_50full3<ranktrue_33`i')
	g rankpred3_ubr50_`i'=(predwelf_xgb_50ubr3<ranktrue_34`i')
	g rankpred3_50full50_`i'=(predwelf_xgb_50full503<ranktrue_35`i')
	g rankpred3_50ubr50_`i'=(predwelf_xgb_50ubr503<ranktrue_36`i')
	
	g rank2pred3_full_`i'=(predwelf_xgb_full3<rankpred_31`i')
	g rank2pred3_ubr_`i'=(predwelf_xgb_ubr3<rankpred_32`i')
	g rank2pred3_full50_`i'=(predwelf_xgb_50full3<rankpred_33`i')
	g rank2pred3_ubr50_`i'=(predwelf_xgb_50ubr3<rankpred_34`i')
	g rank2pred3_50full50_`i'=(predwelf_xgb_50full503<rankpred_35`i')
	g rank2pred3_50ubr50_`i'=(predwelf_xgb_50ubr503<rankpred_36`i')
	
sum test if rankpred3_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FPf1`i'=r(N)
sum test if rankpred3_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TPf1`i'=r(N)
sum test if rank2pred3_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FP2f1`i'=r(N)
sum test if rank2pred3_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TP2f1`i'=r(N)
sum test if ranktrue_full_`i'==1 //total poor
return list
local Pf1`i'=r(N)
sum test if ranktrue_full_`i'==0 //total non-poor
return list
local NPf1`i'=r(N)

sum test if rankpred3_full50_`i'==1 & ranktrue_full50_`i'==0 //false positive rate
return list
local FPf150`i'=r(N)
sum test if rankpred3_full50_`i'==1 & ranktrue_full50_`i'==1 //true postive rate
return list
local TPf150`i'=r(N)
sum test if rank2pred3_full50_`i'==1 & ranktrue_full50_`i'==0 //false positive rate
return list
local FP2f150`i'=r(N)
sum test if rank2pred3_full50_`i'==1 & ranktrue_full50_`i'==1 //true postive rate
return list
local TP2f150`i'=r(N)
sum test if ranktrue_full50_`i'==1 //total poor
return list
local Pf150`i'=r(N)
sum test if ranktrue_full50_`i'==0 //total non-poor
return list
local NPf150`i'=r(N)

sum test if rankpred3_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FPu1`i'=r(N)
sum test if rankpred3_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TPu1`i'=r(N)
sum test if rank2pred3_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FP2u1`i'=r(N)
sum test if rank2pred3_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TP2u1`i'=r(N)
sum test if ranktrue_ubr_`i'==1 //total poor
return list
local Pu1`i'=r(N)
sum test if ranktrue_ubr_`i'==0 //total non-poor
return list
local NPu1`i'=r(N)

sum test if rankpred3_ubr50_`i'==1 & ranktrue_ubr50_`i'==0 //false positive rate
return list
local FPu150`i'=r(N)
sum test if rankpred3_ubr50_`i'==1 & ranktrue_ubr50_`i'==1 //true postive rate
return list
local TPu150`i'=r(N)
sum test if rank2pred3_ubr50_`i'==1 & ranktrue_ubr50_`i'==0 //false positive rate
return list
local FP2u150`i'=r(N)
sum test if rank2pred3_ubr50_`i'==1 & ranktrue_ubr50_`i'==1 //true postive rate
return list
local TP2u150`i'=r(N)
sum test if ranktrue_ubr50_`i'==1 //total poor
return list
local Pu150`i'=r(N)
sum test if ranktrue_ubr50_`i'==0 //total non-poor
return list
local NPu150`i'=r(N)

sum test if rankpred3_50full50_`i'==1 & ranktrue_50full50_`i'==0 //false positive rate
return list
local FPf15050`i'=r(N)
sum test if rankpred3_50full50_`i'==1 & ranktrue_50full50_`i'==1 //true postive rate
return list
local TPf15050`i'=r(N)
sum test if rank2pred3_50full50_`i'==1 & ranktrue_50full50_`i'==0 //false positive rate
return list
local FP2f15050`i'=r(N)
sum test if rank2pred3_50full50_`i'==1 & ranktrue_50full50_`i'==1 //true postive rate
return list
local TP2f15050`i'=r(N)
sum test if ranktrue_50full50_`i'==1 //total poor
return list
local Pf15050`i'=r(N)
sum test if ranktrue_50full50_`i'==0 //total non-poor
return list
local NPf15050`i'=r(N)

sum test if rankpred3_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==0 //false positive rate
return list
local FPu15050`i'=r(N)
sum test if rankpred3_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==1 //true postive rate
return list
local TPu15050`i'=r(N)
sum test if rank2pred3_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==0 //false positive rate
return list
local FP2u15050`i'=r(N)
sum test if rank2pred3_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==1 //true postive rate
return list
local TP2u15050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==1 //total poor
return list
local Pu15050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==0 //total non-poor
return list
local NPu15050`i'=r(N)
	
putexcel A`i'=`FPf1`i''
putexcel B`i'=`TPf1`i''
putexcel C`i'=`FP2f1`i''
putexcel D`i'=`TP2f1`i''
putexcel E`i'=`Pf1`i''
putexcel F`i'=`NPf1`i''

putexcel H`i'=`FPu1`i''
putexcel I`i'=`TPu1`i''
putexcel J`i'=`FP2u1`i''
putexcel K`i'=`TP2u1`i''
putexcel L`i'=`Pu1`i''
putexcel M`i'=`NPu1`i''

putexcel O`i'=`FPf150`i''
putexcel P`i'=`TPf150`i''
putexcel Q`i'=`FP2f150`i''
putexcel R`i'=`TP2f150`i''
putexcel S`i'=`Pf150`i''
putexcel T`i'=`NPf150`i''

putexcel V`i'=`FPu150`i''
putexcel W`i'=`TPu150`i''
putexcel X`i'=`FP2u150`i''
putexcel Y`i'=`TP2u150`i''
putexcel Z`i'=`Pu150`i''
putexcel AA`i'=`NPu150`i''	

putexcel AC`i'=`FPf15050`i''
putexcel AD`i'=`TPf15050`i''
putexcel AE`i'=`FP2f15050`i''
putexcel AF`i'=`TP2f15050`i''
putexcel AG`i'=`Pf15050`i''
putexcel AH`i'=`NPf15050`i''

putexcel AJ`i'=`FPu15050`i''
putexcel AK`i'=`TPu15050`i''
putexcel AL`i'=`FP2u15050`i''
putexcel AM`i'=`TP2u15050`i''
putexcel AN`i'=`Pu15050`i''
putexcel AO`i'=`NPu15050`i''


}
drop rankpred_3* rankpred3_* rank2pred3_* ranktrue_*

*** AUC calculations
preserve
import excel "Census\Updated results\AUC_xgb_census20.xlsx", sheet("Sheet1") clear

g FPR_full=A/F
g TPR_full=B/E
g FPR_full2=C/F
g TPR_full2=D/E

g FPR_ubr=H/M
g TPR_ubr=I/L
g FPR_ubr2=J/M
g TPR_ubr2=K/L

g FPR_full50=O/T
g TPR_full50=P/S
g FPR_full502=Q/T
g TPR_full502=R/S

g FPR_ubr50=V/AA
g TPR_ubr50=W/Z
g FPR_ubr502=X/AA
g TPR_ubr502=Y/Z

g FPR_50full50=AC/AH
g TPR_50full50=AD/AG
g FPR_50full502=AE/AH
g TPR_50full502=AF/AG

g FPR_50ubr50=AJ/AO
g TPR_50ubr50=AK/AN
g FPR_50ubr502=AL/AO
g TPR_50ubr502=AM/AN

keep FPR* TPR* 

set obs `=_N+1'

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
	replace TPR_`x'=1 if TPR_`x'==.
	replace FPR_`x'=1 if FPR_`x'==.
	replace TPR_`x'2=1 if TPR_`x'2==.
	replace FPR_`x'2=1 if FPR_`x'2==.
}

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x' FPR_`x', gen(total_auc`x') trapezoid
local aucxgb20_1`x'=r(integral) 
}

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x'2 FPR_`x'2, gen(total_auc`x'2) trapezoid
local aucxgb20_2`x'=r(integral) 
}

restore

*** Creating AUC Excel file
putexcel set "Census\Updated results\AUC_xgb_updating1", replace

putexcel A1="AUC"

putexcel A3="Sample 1: 10%-90%"
putexcel A4="Sample 2: 15%-85%"
putexcel A5="Sample 2: 20%-80%"

putexcel B1="Predicted consumption based on all districts-all HH in IHS & all HH in census"
putexcel D1="Predicted consumption based on UBR districts-all HH in IHS & all UBR HH in census"
putexcel F1="Predicted consumption based on all districts-all HH in IHS & poorest 50% HH in census"
putexcel H1="Predicted consumption based on UBR districts-all HH in IHS & poorest 50% UBR HH in census"
putexcel J1="Predicted consumption based on Poorest 50% HH in all districts in IHS & poorest 50% HH in census"
putexcel L1="Predicted consumption based on Poorest 50% HH in UBR districts in IHS & poorest 50% UBR HH in census"

putexcel B2="One threshold"
putexcel C2="Two thresholds"
putexcel D2="One threshold"
putexcel E2="Two thresholds"
putexcel F2="One threshold"
putexcel G2="Two thresholds"
putexcel H2="One threshold"
putexcel I2="Two thresholds"
putexcel J2="One threshold"
putexcel K2="Two thresholds"
putexcel L2="One threshold"
putexcel M2="Two thresholds"

putexcel B3=`aucxgb10_1full'
putexcel C3=`aucxgb10_2full'
putexcel D3=`aucxgb10_1ubr'
putexcel E3=`aucxgb10_2ubr'
putexcel F3=`aucxgb10_1full50'
putexcel G3=`aucxgb10_2full50'
putexcel H3=`aucxgb10_1ubr50'
putexcel I3=`aucxgb10_2ubr50'
putexcel J3=`aucxgb10_150full50'
putexcel K3=`aucxgb10_250full50'
putexcel L3=`aucxgb10_150ubr50'
putexcel M3=`aucxgb10_250ubr50'

putexcel B4=`aucxgb15_1full'
putexcel C4=`aucxgb15_2full'
putexcel D4=`aucxgb15_1ubr'
putexcel E4=`aucxgb15_2ubr'
putexcel F4=`aucxgb15_1full50'
putexcel G4=`aucxgb15_2full50'
putexcel H4=`aucxgb15_1ubr50'
putexcel I4=`aucxgb15_2ubr50'
putexcel J4=`aucxgb15_150full50'
putexcel K4=`aucxgb15_250full50'
putexcel L4=`aucxgb15_150ubr50'
putexcel M4=`aucxgb15_250ubr50'

putexcel B5=`aucxgb20_1full'
putexcel C5=`aucxgb20_2full'
putexcel D5=`aucxgb20_1ubr'
putexcel E5=`aucxgb20_2ubr'
putexcel F5=`aucxgb20_1full50'
putexcel G5=`aucxgb20_2full50'
putexcel H5=`aucxgb20_1ubr50'
putexcel I5=`aucxgb20_2ubr50'
putexcel J5=`aucxgb20_150full50'
putexcel K5=`aucxgb20_250full50'
putexcel L5=`aucxgb20_150ubr50'
putexcel M5=`aucxgb20_250ubr50'


/* "LASSO_rankcorr_lasso_lasso_updat1": 
'LASSO' models to predict welfare, 
'rancorr' rank correlations between 
'xgb' benchmark welfare estimated with xgb, 
'xgb' predicted welfare using LASSO models that use as dependent variable the benchmark welfare predicted with xgb models.
*/
*** Creating rank correlations Excel file
putexcel set "Census\Updated results\LASSO_rankcorr_xgb_xgb_updat1", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel B1="Predicted consumption based on all districts-all HH in IHS & all HH in census"
putexcel C1="Predicted consumption based on UBR districts-all HH in IHS & all UBR HH in census"
putexcel D1="Predicted consumption based on all districts-all HH in IHS & poorest 50% HH in census"
putexcel E1="Predicted consumption based on UBR districts-all HH in IHS & poorest 50% UBR HH in census"
putexcel F1="Predicted consumption based on Poorest 50% HH in all districts in IHS & poorest 50% HH in census"
putexcel G1="Predicted consumption based on Poorest 50% HH in UBR districts in IHS & poorest 50% UBR HH in census"

putexcel B3=`frho1'
putexcel B4=`fp1'
putexcel B5=`fN1'
putexcel C3=`urho1'
putexcel C4=`up1'
putexcel C5=`uN1'
putexcel D3=`f50rho1'
putexcel D4=`f50p1'
putexcel D5=`f50N1'
putexcel E3=`u50rho1'
putexcel E4=`u50p1'
putexcel E5=`u50N1'
putexcel F3=`f5050rho1'
putexcel F4=`f5050p1'
putexcel F5=`f5050N1'
putexcel G3=`u5050rho1'
putexcel G4=`u5050p1'
putexcel G5=`u5050N1'

putexcel B6=`frho2'
putexcel B7=`fp2'
putexcel B8=`fN2'
putexcel C6=`urho2'
putexcel C7=`up2'
putexcel C8=`uN2'
putexcel D6=`f50rho2'
putexcel D7=`f50p2'
putexcel D8=`f50N2'
putexcel E6=`u50rho2'
putexcel E7=`u50p2'
putexcel E8=`u50N2'
putexcel F6=`f5050rho2'
putexcel F7=`f5050p2'
putexcel F8=`f5050N2'
putexcel G6=`u5050rho2'
putexcel G7=`u5050p2'
putexcel G8=`u5050N2'

putexcel B9=`frho3'
putexcel B10=`fp3'
putexcel B11=`fN3'
putexcel C9=`urho3'
putexcel C10=`up3'
putexcel C11=`uN3'
putexcel D9=`f50rho3'
putexcel D10=`f50p3'
putexcel D11=`f50N3'
putexcel E9=`u50rho3'
putexcel E10=`u50p3'
putexcel E11=`u50N3'
putexcel F9=`f5050rho3'
putexcel F10=`f5050p3'
putexcel F11=`f5050N3'
putexcel G9=`u5050rho3'
putexcel G10=`u5050p3'
putexcel G11=`u5050N3'


/* "LASSO_rankcorr_lasso_lasso_updat1": 
'LASSO' models to predict welfare, 
'rancorr' rank correlations between 
'xgb' benchmark welfare estimated with xgb, 
'lasso' predicted welfare using LASSO models that use as dependent variable the benchmark welfare predicted with xgb models.
*/
putexcel set "Census\Updated results\LASSO_rankcorr_xgb_lasso_updat1", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel B1="Predicted consumption based on all districts-all HH in IHS & all HH in census"
putexcel C1="Predicted consumption based on UBR districts-all HH in IHS & all UBR HH in census"
putexcel D1="Predicted consumption based on all districts-all HH in IHS & poorest 50% HH in census"
putexcel E1="Predicted consumption based on UBR districts-all HH in IHS & poorest 50% UBR HH in census"
putexcel F1="Predicted consumption based on Poorest 50% HH in all districts in IHS & poorest 50% HH in census"
putexcel G1="Predicted consumption based on Poorest 50% HH in UBR districts in IHS & poorest 50% UBR HH in census"
putexcel B3=`2frho1'
putexcel B4=`2fp1'
putexcel B5=`2fN1'
putexcel C3=`2urho1'
putexcel C4=`2up1'
putexcel C5=`2uN1'
putexcel D3=`2f50rho1'
putexcel D4=`2f50p1'
putexcel D5=`2f50N1'
putexcel E3=`2u50rho1'
putexcel E4=`2u50p1'
putexcel E5=`2u50N1'
putexcel F3=`2f5050rho1'
putexcel F4=`2f5050p1'
putexcel F5=`2f5050N1'
putexcel G3=`2u5050rho1'
putexcel G4=`2u5050p1'
putexcel G5=`2u5050N1'

putexcel B6=`2frho2'
putexcel B7=`2fp2'
putexcel B8=`2fN2'
putexcel C6=`2urho2'
putexcel C7=`2up2'
putexcel C8=`2uN2'
putexcel D6=`2f50rho2'
putexcel D7=`2f50p2'
putexcel D8=`2f50N2'
putexcel E6=`2u50rho2'
putexcel E7=`2u50p2'
putexcel E8=`2u50N2'
putexcel F6=`2f5050rho2'
putexcel F7=`2f5050p2'
putexcel F8=`2f5050N2'
putexcel G6=`2u5050rho2'
putexcel G7=`2u5050p2'
putexcel G8=`2u5050N2'

putexcel B9=`2frho3'
putexcel B10=`2fp3'
putexcel B11=`2fN3'
putexcel C9=`2urho3'
putexcel C10=`2up3'
putexcel C11=`2uN3'
putexcel D9=`2f50rho3'
putexcel D10=`2f50p3'
putexcel D11=`2f50N3'
putexcel E9=`2u50rho3'
putexcel E10=`2u50p3'
putexcel E11=`2u50N3'
putexcel F9=`2f5050rho3'
putexcel F10=`2f5050p3'
putexcel F11=`2f5050N3'
putexcel G9=`2u5050rho3'
putexcel G10=`2u5050p3'
putexcel G11=`2u5050N3'


*******************************************************
*** Updating method 2
*******************************************************
use "Census\Updated results\data_updt1lasso_updt2_updt3lasso_updt4.dta", clear
g test=1
*** Using benchkmark welfare predicted with lasso
***Rank correlations
putexcel set "Census\Updated results\rank_correlations_lasso_pmt", replace


***R-squared
***Trimmed PMT and raw predicted consumption
foreach x in fullvill ubrvill fullvill50 ubrvill50  50vill50 50ubrvill50  {
	reg  predcons_xgb_`x' pmtscore_mean_vill
	ereturn list
	local r_`x'= e(r2)
}

di `r_50vill50'  
di `r_50ubrvill50' 
di `r_fullvill'

***Trimmed PMT and raw predicted consumption
foreach x in fullvill ubrvill fullvill50 ubrvill50  50vill50 50ubrvill50  {
	spearman  predcons_census_`x' pmtscore_mean_vill
	local rho`x'=r(rho)
	local p`x'=r(p)
	local N`x'=r(N)
}
***Raw PMT and raw predicted consumption
foreach x in fullvill ubrvill fullvill50 ubrvill50 50vill50 50ubrvill50 {
	spearman  predcons_census_`x' pmtscore_mean_villraw
	local rawrho`x'=r(rho)
	local rawp`x'=r(p)
	local rawN`x'=r(N)
}


putexcel A2="Using Trimmed PMT scores and predicted consumption in Census"
putexcel B1="All HH-All districts-all HH in IHS"
putexcel B2=`rhofullvill'
putexcel B3=`pfullvill'
putexcel C1="All HH-UBR districts-all HH in IHS"
putexcel C2=`rhoubrvill'
putexcel C3=`pubrvill'
putexcel D1="All HH-All districts-Poorest 50% HH in IHS"
putexcel D2=`rhofullvill50'
putexcel D3=`pfullvill50'
putexcel E1="All HH-UBR districts-Poorest 50% HH in IHS"
putexcel E2=`rhoubrvill50'
putexcel E3=`pubrvill50'
putexcel F1="50% poorest HH -All districts-Poorest 50% HH in IHS"
putexcel F2=`rho50vill50'
putexcel F3=`p50vill50'
putexcel G1="50% poorest HH -UBR districts-Poorest 50% HH in IHS"
putexcel G2=`rho50ubrvill50'
putexcel G3=`p50ubrvill50'

putexcel A4="Using raw PMT scores and predicted consumption in Census"
putexcel B4=`rawrhofullvill'
putexcel B5=`rawpfullvill'
putexcel C4=`rawrhoubrvill'
putexcel C5=`rawpubrvill'
putexcel D4=`rawrhofullvill50'
putexcel D5=`rawpfullvill50'
putexcel E4=`rawrhoubrvill50'
putexcel E5=`rawpubrvill50'
putexcel F4=`rawrho50vill50'
putexcel F5=`rawp50vill50'
putexcel G4=`rawrho50ubrvill50'
putexcel G5=`rawp50ubrvill50'

*** Using benchkmark welfare predicted with xgboost
***Rank correlations
putexcel set "Census\Updated results\rank_correlations_xgb_pmt", replace

***Rank correlations
***Trimmed PMT and raw predicted consumption
foreach x in fullvill ubrvill fullvill50 ubrvill50 50vill50 50ubrvill50 {
	spearman  predcons_xgb_`x' pmtscore_mean_vill
	local rho`x'xg=r(rho)
	local p`x'xg=r(p)
	local N`x'xg=r(N)
}
***Raw PMT and raw predicted consumption
foreach x in fullvill ubrvill fullvill50 ubrvill50 50vill50 50ubrvill50 {
	spearman  predcons_xgb_`x' pmtscore_mean_villraw
	local rawrho`x'xg=r(rho)
	local rawp`x'xg=r(p)
	local rawN`x'xg=r(N)
}

putexcel A2="Using Trimmed PMT scores and predicted consumption in Census"
putexcel B1="All HH-All districts-all HH in IHS"
putexcel B2=`rhofullvillxg'
putexcel B3=`pfullvillxg'
putexcel C1="All HH-UBR districts-all HH in IHS"
putexcel C2=`rhoubrvillxg'
putexcel C3=`pubrvillxg'
putexcel D1="All HH-All districts-Poorest 50% HH in IHS"
putexcel D2=`rhofullvill50xg'
putexcel D3=`pfullvill50xg'
putexcel E1="All HH-UBR districts-Poorest 50% HH in IHS"
putexcel E2=`rhoubrvill50xg'
putexcel E3=`pubrvill50xg'
putexcel F1="50% poorest HH -All districts-Poorest 50% HH in IHS"
putexcel F2=`rho50vill50xg'
putexcel F3=`p50vill50xg'
putexcel G1="50% poorest HH -UBR districts-Poorest 50% HH in IHS"
putexcel G2=`rho50ubrvill50xg'
putexcel G3=`p50ubrvill50xg'

putexcel A4="Using raw PMT scores and predicted consumption in Census"
putexcel B4=`rawrhofullvillxg'
putexcel B5=`rawpfullvillxg'
putexcel C4=`rawrhoubrvillxg'
putexcel C5=`rawpubrvillxg'
putexcel D4=`rawrhofullvill50xg'
putexcel D5=`rawpfullvill50xg'
putexcel E4=`rawrhoubrvill50xg'
putexcel E5=`rawpubrvill50xg'
putexcel F4=`rawrho50vill50xg'
putexcel F5=`rawp50vill50xg'
putexcel G4=`rawrho50ubrvill50xg'
putexcel G5=`rawp50ubrvill50xg'

***AUC: false positve rates and true positive rates for each percentile

***Using lasso prediction for benchmark welfare
putexcel set "Census\Updated results\AUC_lasso_updating2", replace

forvalues i=1(1)99 {
	egen ranktrue_1`i' = pctile(predcons_census_fullvill), /*by(district)*/ p(`i') 
	g ranktrue_full_`i'=(predcons_census_fullvill<ranktrue_1`i')
	egen ranktrue_2`i' = pctile(predcons_census_ubrvill), /*by(district)*/ p(`i') 
	g ranktrue_ubr_`i'=(predcons_census_ubrvill<ranktrue_2`i')
	egen ranktrue_3`i' = pctile(predcons_census_fullvill50), /*by(district)*/ p(`i') 
	g ranktrue_full50_`i'=(predcons_census_fullvill50<ranktrue_3`i')
	egen ranktrue_4`i' = pctile(predcons_census_ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_ubr50_`i'=(predcons_census_ubrvill50<ranktrue_4`i')
	egen ranktrue_5`i' = pctile(predcons_census_50vill50), /*by(district)*/ p(`i') 
	g ranktrue_50full50_`i'=(predcons_census_50vill50<ranktrue_5`i')
	egen ranktrue_6`i' = pctile(predcons_census_50ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_50ubr50_`i'=(predcons_census_50ubrvill50<ranktrue_6`i')
	
	egen rankpmt`i' = pctile(pmtscore_mean_vill), /*by(district)*/ p(`i') 
	g rank_pmt`i'=(pmtscore_mean_vill<rankpmt`i')

drop rankpmt* ranktrue_4* ranktrue_3* ranktrue_2* ranktrue_1*

sum test if rank_pmt`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FPf`i'=r(N)
sum test if rank_pmt`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TPf`i'=r(N)
sum test if ranktrue_full_`i'==1 //total poor
return list
local Pf`i'=r(N)
sum test if ranktrue_full_`i'==0 //total non-poor
return list
local NPf`i'=r(N)

sum test if rank_pmt`i'==1 & ranktrue_full50_`i'==0 //false positive rate
return list
local FPf50`i'=r(N)
sum test if rank_pmt`i'==1 & ranktrue_full50_`i'==1 //true postive rate
return list
local TPf50`i'=r(N)
sum test if ranktrue_full50_`i'==1 //total poor
return list
local Pf50`i'=r(N)
sum test if ranktrue_full50_`i'==0 //total non-poor
return list
local NPf50`i'=r(N)

sum test if rank_pmt`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FPu`i'=r(N)
sum test if rank_pmt`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TPu`i'=r(N)
sum test if ranktrue_ubr_`i'==1 //total poor
return list
local Pu`i'=r(N)
sum test if ranktrue_ubr_`i'==0 //total non-poor
return list
local NPu`i'=r(N)

sum test if rank_pmt`i'==1 & ranktrue_ubr50_`i'==0 //false positive rate
return list
local FPu50`i'=r(N)
sum test if rank_pmt`i'==1 & ranktrue_ubr50_`i'==1 //true postive rate
return list
local TPu50`i'=r(N)
sum test if ranktrue_ubr50_`i'==1 //total poor
return list
local Pu50`i'=r(N)
sum test if ranktrue_ubr50_`i'==0 //total non-poor
return list
local NPu50`i'=r(N)

sum test if rank_pmt`i'==1 & ranktrue_50full50_`i'==0 //false positive rate
return list
local FPf5050`i'=r(N)
sum test if rank_pmt`i'==1 & ranktrue_50full50_`i'==1 //true postive rate
return list
local TPf5050`i'=r(N)
sum test if ranktrue_50full50_`i'==1 //total poor
return list
local Pf5050`i'=r(N)
sum test if ranktrue_50full50_`i'==0 //total non-poor
return list
local NPf5050`i'=r(N)

sum test if rank_pmt`i'==1 & ranktrue_50ubr50_`i'==0 //false positive rate
return list
local FPu5050`i'=r(N)
sum test if rank_pmt`i'==1 & ranktrue_50ubr50_`i'==1 //true postive rate
return list
local TPu5050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==1 //total poor
return list
local Pu5050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==0 //total non-poor
return list
local NPu5050`i'=r(N)

putexcel A`i'=`FPf`i''
putexcel B`i'=`TPf`i''
putexcel C`i'=`Pf`i''
putexcel D`i'=`NPf`i''

putexcel E`i'=`FPu`i''
putexcel F`i'=`TPu`i''
putexcel G`i'=`Pu`i''
putexcel H`i'=`NPu`i''

putexcel I`i'=`FPf50`i''
putexcel J`i'=`TPf50`i''
putexcel K`i'=`Pf50`i''
putexcel L`i'=`NPf50`i''

putexcel M`i'=`FPu50`i''
putexcel N`i'=`TPu50`i''
putexcel O`i'=`Pu50`i''
putexcel P`i'=`NPu50`i''

putexcel Q`i'=`FPf5050`i''
putexcel R`i'=`TPf5050`i''
putexcel S`i'=`Pf5050`i''
putexcel T`i'=`NPf5050`i''

putexcel U`i'=`FPu5050`i''
putexcel V`i'=`TPu5050`i''
putexcel W`i'=`Pu5050`i''
putexcel X`i'=`NPu5050`i''

}
drop ranktrue_* rank_pmt*

*** AUC calculations
preserve
import excel "Census\Updated results\AUC_lasso_updating2.xlsx", sheet("Sheet1") clear

g FPR_full=A/D
g TPR_full=B/C

g FPR_ubr=E/H
g TPR_ubr=F/G

g FPR_full50=I/L
g TPR_full50=J/K

g FPR_ubr50=M/P
g TPR_ubr50=N/O

g FPR_50full50=Q/T
g TPR_50full50=R/S

g FPR_50ubr50=U/X
g TPR_50ubr50=V/W

export excel using "Census\Updated results\AUC_lasso_updating2.xlsx", replace

keep FPR* TPR* 

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x' FPR_`x', gen(total_auc`x')
local auclassopmt_`x'=r(integral) 
}

restore


*** Using  XGBOOST prediction for benchmark welfare

***AUC: false positve rates and true positive rates for each percentile
putexcel set "Census\Updated results\AUC_xgb_updating2", replace

forvalues i=1(1)99 {
	egen ranktrue_1xg`i' = pctile(predcons_xgb_fullvill), /*by(district)*/ p(`i') 
	g ranktrue_fullxg`i'=(predcons_xgb_fullvill<ranktrue_1xg`i')
	egen ranktrue_2xg`i' = pctile(predcons_xgb_ubrvill), /*by(district)*/ p(`i') 
	g ranktrue_ubrxg`i'=(predcons_xgb_ubrvill<ranktrue_2xg`i')
	egen ranktrue_3xg`i' = pctile(predcons_xgb_fullvill50), /*by(district)*/ p(`i') 
	g ranktrue_full50xg`i'=(predcons_xgb_fullvill50<ranktrue_3xg`i')
	egen ranktrue_4xg`i' = pctile(predcons_xgb_ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_ubr50xg`i'=(predcons_xgb_ubrvill50<ranktrue_4xg`i')
	egen ranktrue_5xg`i' = pctile(predcons_xgb_50vill50), /*by(district)*/ p(`i') 
	g ranktrue_50full50xg`i'=(predcons_xgb_50vill50<ranktrue_5xg`i')
	egen ranktrue_6xg`i' = pctile(predcons_xgb_50ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_50ubr50xg`i'=(predcons_xgb_50ubrvill50<ranktrue_6xg`i')
	
	egen rankpmt`i' = pctile(pmtscore_mean_vill), /*by(district)*/ p(`i') 
	g rank_pmt`i'=(pmtscore_mean_vill<rankpmt`i')

drop rankpmt* ranktrue_4xg* ranktrue_3xg* ranktrue_2xg* ranktrue_1xg*


sum test if rank_pmt`i'==1 & ranktrue_fullxg`i'==0 //false positive rate
return list
local FPf`i'=r(N)
sum test if rank_pmt`i'==1 & ranktrue_fullxg`i'==1 //true postive rate
return list
local TPf`i'=r(N)
sum test if ranktrue_fullxg`i'==1 //total poor
return list
local Pf`i'=r(N)
sum test if ranktrue_fullxg`i'==0 //total poor
return list
local NPf`i'=r(N)

sum test if rank_pmt`i'==1 & ranktrue_full50xg`i'==0 //false positive rate
return list
local FPf50`i'=r(N)
sum test if rank_pmt`i'==1 & ranktrue_full50xg`i'==1 //true postive rate
return list
local TPf50`i'=r(N)
sum test if ranktrue_full50xg`i'==1 //total poor
return list
local Pf50`i'=r(N)
sum test if ranktrue_full50xg`i'==0 //total poor
return list
local NPf50`i'=r(N)

sum test if rank_pmt`i'==1 & ranktrue_ubrxg`i'==0 //false positive rate
return list
local FPu`i'=r(N)
sum test if rank_pmt`i'==1 & ranktrue_ubrxg`i'==1 //true postive rate
return list
local TPu`i'=r(N)
sum test if ranktrue_ubrxg`i'==1 //total poor
return list
local Pu`i'=r(N)
sum test if ranktrue_ubrxg`i'==0 //total poor
return list
local NPu`i'=r(N)

sum test if rank_pmt`i'==1 & ranktrue_ubr50xg`i'==0 //false positive rate
return list
local FPu50`i'=r(N)
sum test if rank_pmt`i'==1 & ranktrue_ubr50xg`i'==1 //true postive rate
return list
local TPu50`i'=r(N)
sum test if ranktrue_ubr50xg`i'==1 //total poor
return list
local Pu50`i'=r(N)
sum test if ranktrue_ubr50xg`i'==0 //total poor
return list
local NPu50`i'=r(N)

sum test if rank_pmt`i'==1 & ranktrue_50full50xg`i'==0 //false positive rate
return list
local FPf5050`i'=r(N)
sum test if rank_pmt`i'==1 & ranktrue_50full50xg`i'==1 //true postive rate
return list
local TPf5050`i'=r(N)
sum test if ranktrue_50full50xg`i'==1 //total poor
return list
local Pf5050`i'=r(N)
sum test if ranktrue_50full50xg`i'==0 //total poor
return list
local NPf5050`i'=r(N)

sum test if rank_pmt`i'==1 & ranktrue_50ubr50xg`i'==0 //false positive rate
return list
local FPu5050`i'=r(N)
sum test if rank_pmt`i'==1 & ranktrue_50ubr50xg`i'==1 //true postive rate
return list
local TPu5050`i'=r(N)
sum test if ranktrue_50ubr50xg`i'==1 //total poor
return list
local Pu5050`i'=r(N)
sum test if ranktrue_50ubr50xg`i'==0 //total poor
return list
local NPu5050`i'=r(N)

putexcel A`i'=`FPf`i''
putexcel B`i'=`TPf`i''
putexcel C`i'=`Pf`i''
putexcel D`i'=`NPf`i''

putexcel E`i'=`FPu`i''
putexcel F`i'=`TPu`i''
putexcel G`i'=`Pu`i''
putexcel H`i'=`NPu`i''

putexcel I`i'=`FPf50`i''
putexcel J`i'=`TPf50`i''
putexcel K`i'=`Pf50`i''
putexcel L`i'=`NPf50`i''

putexcel M`i'=`FPu50`i''
putexcel N`i'=`TPu50`i''
putexcel O`i'=`Pu50`i''
putexcel P`i'=`NPu50`i''

putexcel Q`i'=`FPf5050`i''
putexcel R`i'=`TPf5050`i''
putexcel S`i'=`Pf5050`i''
putexcel T`i'=`NPf5050`i''

putexcel U`i'=`FPu5050`i''
putexcel V`i'=`TPu5050`i''
putexcel W`i'=`Pu5050`i''
putexcel X`i'=`NPu5050`i''

}
drop ranktrue_* rank_pmt*

*** AUC calculations
preserve
import excel "Census\Updated results\AUC_xgb_updating2.xlsx", sheet("Sheet1") clear

g FPR_full=A/D
g TPR_full=B/C

g FPR_ubr=E/H
g TPR_ubr=F/G

g FPR_full50=I/L
g TPR_full50=J/K

g FPR_ubr50=M/P
g TPR_ubr50=N/O

g FPR_50full50=Q/T
g TPR_50full50=R/S

g FPR_50ubr50=U/X
g TPR_50ubr50=V/W

export excel using "Census\Updated results\AUC_xgb_updating2.xlsx", replace

keep FPR* TPR* 

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x' FPR_`x', gen(total_auc`x')
local aucxgbpmt_`x'=r(integral) 
}

restore

putexcel set "Census\Updated results\AUC_updating2", replace

putexcel A1="AUC"
putexcel A2="Benchmark welfare predicted with LASSO"
putexcel A3="Benchmark welfare predicted with XGBOOST"

putexcel B1="All districts-all HH in IHS & all HH in census"
putexcel C1="UBR districts-all HH in IHS & all UBR HH in census"
putexcel D1="All districts-all HH in IHS & poorest 50% HH in census"
putexcel E1="UBR districts-all HH in IHS & poorest 50% UBR HH in census"
putexcel F1="Poorest 50% HH in all districts in IHS & poorest 50% HH in census"
putexcel G1="Poorest 50% HH in UBR districts in IHS & poorest 50% UBR HH in census"

putexcel B2=`auclassopmt_full'
putexcel C2=`auclassopmt_ubr'
putexcel D2=`auclassopmt_full50'
putexcel E2=`auclassopmt_ubr50'
putexcel F2=`auclassopmt_50full50'
putexcel G2=`auclassopmt_50ubr50'

putexcel B3=`aucxgbpmt_full'
putexcel C3=`aucxgbpmt_ubr'
putexcel D3=`aucxgbpmt_full50'
putexcel E3=`aucxgbpmt_ubr50'
putexcel F3=`aucxgbpmt_50full50'
putexcel G3=`aucxgbpmt_50ubr50'

*************************************************************
*** Updating method 3: IHS
*************************************************************
use "Census\Updated results\data_updt1lasso_updt2_updt3lasso_updt4.dta", clear
g test=1
***Rank correlations

*** Using  LASSO prediction for benchmark welfare
spearman predcons_census_fullvill predcons_satell_ihs_full
	local rhofull=r(rho)
	local pfull=r(p)
	local Nfull=r(N)
spearman predcons_census_ubrvill predcons_satell_ihs_ubr
	local rhoubr=r(rho)
	local pubr=r(p)
	local Nubr=r(N)
spearman predcons_census_fullvill50 predcons_satell_ihs_full50
	local rhofull50=r(rho)
	local pfull50=r(p)
	local Nfull50=r(N)
spearman predcons_census_ubrvill50 predcons_satell_ihs_ubr50
	local rhoubr50=r(rho)
	local pubr50=r(p)
	local Nubr50=r(N)
spearman predcons_census_50vill50 predcons_satell_ihs_full50
	local rhofull5050=r(rho)
	local pfull5050=r(p)
	local Nfull5050=r(N)
spearman predcons_census_50ubrvill50 predcons_satell_ihs_ubr50
	local rhoubr5050=r(rho)
	local pubr5050=r(p)
	local Nubr5050=r(N)
	
*** Using  XGBOOST prediction for benchmark welfare

spearman predcons_xgb_fullvill predcons_satell_ihs_full
	local rhofullxg=r(rho)
	local pfullxg=r(p)
	local Nfullxg=r(N)
spearman predcons_xgb_ubrvill predcons_satell_ihs_ubr
	local rhoubrxg=r(rho)
	local pubrxg=r(p)
	local Nubrxg=r(N)
spearman predcons_xgb_fullvill50 predcons_satell_ihs_full50
	local rhofullxg50=r(rho)
	local pfullxg50=r(p)
	local Nfullxg50=r(N)
spearman predcons_xgb_ubrvill50 predcons_satell_ihs_ubr50
	local rhoubrxg50=r(rho)
	local pubrxg50=r(p)
	local Nubrxg50=r(N)
spearman predcons_xgb_50vill50 predcons_satell_ihs_full50
	local rhofullxg5050=r(rho)
	local pfullxg5050=r(p)
	local Nfullxg5050=r(N)
spearman predcons_xgb_50ubrvill50 predcons_satell_ihs_ubr50
	local rhoubrxg5050=r(rho)
	local pubrxg5050=r(p)
	local Nubrxg5050=r(N)

***Excel file 
putexcel set "Census\Updated results\rank_correlations_IHS", replace

putexcel A3="Benchmark welfare estimated using LASSO"
putexcel A6="Benchmark welfare estimated using XGBOOST"

putexcel B2="All districts-all HH in IHS & all HH in census"
putexcel C2="UBR districts-all HH in IHS & all UBR HH in census"
putexcel D2="All districts-all HH in IHS & poorest 50% HH in census"
putexcel E2="UBR districts-all HH in IHS & poorest 50% UBR HH in census"
putexcel F2="Poorest 50% HH in all districts in IHS & poorest 50% HH in census"
putexcel G2="Poorest 50% HH in UBR districts in IHS & poorest 50% UBR HH in census"

putexcel B3=`rhofull'
putexcel B4=`pfull'
putexcel B5=`Nfull'
putexcel C3=`rhoubr'
putexcel C4=`pubr'
putexcel C5=`Nubr'
putexcel D3=`rhofull50'
putexcel D4=`pfull50'
putexcel D5=`Nfull50'
putexcel E3=`rhoubr50'
putexcel E4=`pubr50'
putexcel E5=`Nubr50'
putexcel F3=`rhofull5050'
putexcel F4=`pfull5050'
putexcel F5=`Nfull5050'
putexcel G3=`rhoubr5050'
putexcel G4=`pubr5050'
putexcel G5=`Nubr5050'

putexcel B6=`rhofullxg'
putexcel B7=`pfullxg'
putexcel B8=`Nfullxg'
putexcel C6=`rhoubrxg'
putexcel C7=`pubrxg'
putexcel C8=`Nubrxg'
putexcel D6=`rhofullxg50'
putexcel D7=`pfullxg50'
putexcel D8=`Nfullxg50'
putexcel E6=`rhoubrxg50'
putexcel E7=`pubrxg50'
putexcel E8=`Nubrxg50'
putexcel F6=`rhofullxg5050'
putexcel F7=`pfullxg5050'
putexcel F8=`Nfullxg5050'
putexcel G6=`rhoubrxg5050'
putexcel G7=`pubrxg5050'
putexcel G8=`Nubrxg5050'

***AUC
*g test=1
putexcel set "Census\Updated results\AUC_lasso_updating3", replace

***True consumption using xgb
forvalues i=1(1)99 {
	egen ranktrue_11`i' = pctile(predcons_census_fullvill),  p(`i') 
	g ranktrue_full_`i'=(predcons_census_fullvill<ranktrue_11`i')
	egen ranktrue_12`i' = pctile(predcons_census_ubrvill),  p(`i') 
	g ranktrue_ubr_`i'=(predcons_census_ubrvill<ranktrue_12`i')
	egen ranktrue_13`i' = pctile(predcons_census_fullvill50), p(`i') 
	g ranktrue_full50_`i'=(predcons_census_fullvill50<ranktrue_13`i')
	egen ranktrue_14`i' = pctile(predcons_census_ubrvill50),  p(`i') 
	g ranktrue_ubr50_`i'=(predcons_census_ubrvill50<ranktrue_14`i')
	egen ranktrue_15`i' = pctile(predcons_census_50vill50), p(`i') 
	g ranktrue_50full50_`i'=(predcons_census_50vill50<ranktrue_15`i')
	egen ranktrue_16`i' = pctile(predcons_census_50ubrvill50),  p(`i') 
	g ranktrue_50ubr50_`i'=(predcons_census_50ubrvill50<ranktrue_16`i')
	
	egen rankpred_11`i' = pctile(predcons_satell_ihs_full),  p(`i') 
	egen rankpred_12`i' = pctile(predcons_satell_ihs_ubr),  p(`i') 
	egen rankpred_13`i' = pctile(predcons_satell_ihs_full50),  p(`i') 
	egen rankpred_14`i' = pctile(predcons_satell_ihs_ubr50),  p(`i') 

	g rankpred_full_`i'=(predcons_satell_ihs_full<ranktrue_11`i')
	g rankpred_ubr_`i'=(predcons_satell_ihs_ubr<ranktrue_12`i')
	g rankpred_full50_`i'=(predcons_satell_ihs_full50<ranktrue_13`i')
	g rankpred_ubr50_`i'=(predcons_satell_ihs_ubr50<ranktrue_14`i')
	g rankpred_50full50_`i'=(predcons_satell_ihs_full50<ranktrue_15`i')
	g rankpred_50ubr50_`i'=(predcons_satell_ihs_ubr50<ranktrue_16`i')

	g rankpred2_full_`i'=(predcons_satell_ihs_full<rankpred_11`i')
	g rankpred2_ubr_`i'=(predcons_satell_ihs_ubr<rankpred_12`i')
	g rankpred2_full50_`i'=(predcons_satell_ihs_full50<rankpred_13`i')
	g rankpred2_ubr50_`i'=(predcons_satell_ihs_ubr50<rankpred_14`i')
	
sum test if rankpred_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FPf1`i'=r(N)
sum test if rankpred_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TPf1`i'=r(N)
sum test if rankpred2_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FP2f1`i'=r(N)
sum test if rankpred2_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TP2f1`i'=r(N)
sum test if ranktrue_full_`i'==1 //total poor
return list
local Pf1`i'=r(N)
sum test if ranktrue_full_`i'==0 //total non-poor
return list
local NPf1`i'=r(N)

sum test if rankpred_full50_`i'==1 & ranktrue_full50_`i'==0 //false positive rate
return list
local FPf150`i'=r(N)
sum test if rankpred_full50_`i'==1 & ranktrue_full50_`i'==1 //true postive rate
return list
local TPf150`i'=r(N)
sum test if rankpred2_full50_`i'==1 & ranktrue_full50_`i'==0 //false positive rate
return list
local FP2f150`i'=r(N)
sum test if rankpred2_full50_`i'==1 & ranktrue_full50_`i'==1 //true postive rate
return list
local TP2f150`i'=r(N)
sum test if ranktrue_full50_`i'==1 //total poor
return list
local Pf150`i'=r(N)
sum test if ranktrue_full50_`i'==0 //total non-poor
return list
local NPf150`i'=r(N)

sum test if rankpred_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FPu1`i'=r(N)
sum test if rankpred_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TPu1`i'=r(N)
sum test if rankpred2_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FP2u1`i'=r(N)
sum test if rankpred2_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TP2u1`i'=r(N)
sum test if ranktrue_ubr_`i'==1 //total poor
return list
local Pu1`i'=r(N)
sum test if ranktrue_ubr_`i'==0 //total non-poor
return list
local NPu1`i'=r(N)

sum test if rankpred_ubr50_`i'==1 & ranktrue_ubr50_`i'==0 //false positive rate
return list
local FPu150`i'=r(N)
sum test if rankpred_ubr50_`i'==1 & ranktrue_ubr50_`i'==1 //true postive rate
return list
local TPu150`i'=r(N)
sum test if rankpred2_ubr50_`i'==1 & ranktrue_ubr50_`i'==0 //false positive rate
return list
local FP2u150`i'=r(N)
sum test if rankpred2_ubr50_`i'==1 & ranktrue_ubr50_`i'==1 //true postive rate
return list
local TP2u150`i'=r(N)
sum test if ranktrue_ubr50_`i'==1 //total poor
return list
local Pu150`i'=r(N)
sum test if ranktrue_ubr50_`i'==0 //total non-poor
return list
local NPu150`i'=r(N)

sum test if rankpred_50full50_`i'==1 & ranktrue_50full50_`i'==0 //false positive rate
return list
local FPf15050`i'=r(N)
sum test if rankpred_50full50_`i'==1 & ranktrue_50full50_`i'==1 //true postive rate
return list
local TPf15050`i'=r(N)
sum test if rankpred2_full50_`i'==1 & ranktrue_50full50_`i'==0 //false positive rate
return list
local FP2f15050`i'=r(N)
sum test if rankpred2_full50_`i'==1 & ranktrue_50full50_`i'==1 //true postive rate
return list
local TP2f15050`i'=r(N)
sum test if ranktrue_50full50_`i'==1 //total poor
return list
local Pf15050`i'=r(N)
sum test if ranktrue_50full50_`i'==0 //total non-poor
return list
local NPf15050`i'=r(N)

sum test if rankpred_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==0 //false positive rate
return list
local FPu15050`i'=r(N)
sum test if rankpred_50ubr50_`i'==1 & ranktrue_50ubr50_`i'==1 //true postive rate
return list
local TPu15050`i'=r(N)
sum test if rankpred2_ubr50_`i'==1 & ranktrue_50ubr50_`i'==0 //false positive rate
return list
local FP2u15050`i'=r(N)
sum test if rankpred2_ubr50_`i'==1 & ranktrue_50ubr50_`i'==1 //true postive rate
return list
local TP2u15050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==1 //total poor
return list
local Pu15050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==0 //total non-poor
return list
local NPu15050`i'=r(N)
		
putexcel A`i'=`FPf1`i''
putexcel B`i'=`TPf1`i''
putexcel C`i'=`FP2f1`i''
putexcel D`i'=`TP2f1`i''
putexcel E`i'=`Pf1`i''
putexcel F`i'=`NPf1`i''

putexcel H`i'=`FPu1`i''
putexcel I`i'=`TPu1`i''
putexcel J`i'=`FP2u1`i''
putexcel K`i'=`TP2u1`i''
putexcel L`i'=`Pu1`i''
putexcel M`i'=`NPu1`i''

putexcel O`i'=`FPf150`i''
putexcel P`i'=`TPf150`i''
putexcel Q`i'=`FP2f150`i''
putexcel R`i'=`TP2f150`i''
putexcel S`i'=`Pf150`i''
putexcel T`i'=`NPf150`i''

putexcel V`i'=`FPu150`i''
putexcel W`i'=`TPu150`i''
putexcel X`i'=`FP2u150`i''
putexcel Y`i'=`TP2u150`i''
putexcel Z`i'=`Pu150`i''
putexcel AA`i'=`NPu150`i''	

putexcel AC`i'=`FPf15050`i''
putexcel AD`i'=`TPf15050`i''
putexcel AE`i'=`FP2f15050`i''
putexcel AF`i'=`TP2f15050`i''
putexcel AG`i'=`Pf15050`i''
putexcel AH`i'=`NPf15050`i''

putexcel AJ`i'=`FPu15050`i''
putexcel AK`i'=`TPu15050`i''
putexcel AL`i'=`FP2u15050`i''
putexcel AM`i'=`TP2u15050`i''
putexcel AN`i'=`Pu15050`i''
putexcel AO`i'=`NPu15050`i''

}

drop rankpred_* rankpred2_* ranktrue*

*** AUC calculations
preserve
import excel "Census\Updated results\AUC_lasso_updating3", sheet("Sheet1") clear

g FPR_full=A/F
g TPR_full=B/E
g FPR_full2=C/F
g TPR_full2=D/E

g FPR_ubr=H/M
g TPR_ubr=I/L
g FPR_ubr2=J/M
g TPR_ubr2=K/L

g FPR_full50=O/T
g TPR_full50=P/S
g FPR_full502=Q/T
g TPR_full502=R/S

g FPR_ubr50=V/AA
g TPR_ubr50=W/Z
g FPR_ubr502=X/AA
g TPR_ubr502=Y/Z

g FPR_50full50=AC/AH
g TPR_50full50=AD/AG
g FPR_50full502=AE/AH
g TPR_50full502=AF/AG

g FPR_50ubr50=AJ/AO
g TPR_50ubr50=AK/AN
g FPR_50ubr502=AL/AO
g TPR_50ubr502=AM/AN

keep FPR* TPR* 

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x' FPR_`x', gen(total_auc`x')
local auclassoihs_1`x'=r(integral) 
}

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x'2 FPR_`x'2, gen(total_auc`x'2)
local auclassoihs_2`x'=r(integral) 
}

restore

***True consumption using xgb
putexcel set "Census\Updated results\AUC_XGB_updating3", replace


forvalues i=1(1)99 {
	egen ranktrue_21`i' = pctile(predcons_xgb_fullvill),  p(`i') 
	g ranktrue2_full_`i'=(predcons_xgb_fullvill<ranktrue_21`i')
	egen ranktrue_22`i' = pctile(predcons_xgb_ubrvill),  p(`i') 
	g ranktrue2_ubr_`i'=(predcons_xgb_ubrvill<ranktrue_22`i')
	egen ranktrue_23`i' = pctile(predcons_xgb_fullvill50), p(`i') 
	g ranktrue2_full50_`i'=(predcons_xgb_fullvill50<ranktrue_23`i')
	egen ranktrue_24`i' = pctile(predcons_xgb_ubrvill50), p(`i') 
	g ranktrue2_ubr50_`i'=(predcons_xgb_ubrvill50<ranktrue_24`i')
	egen ranktrue_25`i' = pctile(predcons_xgb_50vill50), p(`i') 
	g ranktrue2_50full50_`i'=(predcons_xgb_50vill50<ranktrue_25`i')
	egen ranktrue_26`i' = pctile(predcons_xgb_50ubrvill50), p(`i') 
	g ranktrue2_50ubr50_`i'=(predcons_xgb_50ubrvill50<ranktrue_26`i')
	
	egen rankpred_21`i' = pctile(predcons_satell_ihs_full),  p(`i') 
	egen rankpred_22`i' = pctile(predcons_satell_ihs_ubr),  p(`i') 
	egen rankpred_23`i' = pctile(predcons_satell_ihs_full50),  p(`i') 
	egen rankpred_24`i' = pctile(predcons_satell_ihs_ubr50),  p(`i') 
	
	g rankpred_full_`i'=(predcons_satell_ihs_full<ranktrue_21`i')
	g rankpred_ubr_`i'=(predcons_satell_ihs_ubr<ranktrue_22`i')
	g rankpred_full50_`i'=(predcons_satell_ihs_full50<ranktrue_23`i')
	g rankpred_ubr50_`i'=(predcons_satell_ihs_ubr50<ranktrue_24`i')
	g rankpred_50full50_`i'=(predcons_satell_ihs_full50<ranktrue_25`i')
	g rankpred_50ubr50_`i'=(predcons_satell_ihs_ubr50<ranktrue_26`i')

	g rankpred2_full_`i'=(predcons_satell_ihs_full<rankpred_21`i')
	g rankpred2_ubr_`i'=(predcons_satell_ihs_ubr<rankpred_22`i')
	g rankpred2_full50_`i'=(predcons_satell_ihs_full50<rankpred_23`i')
	g rankpred2_ubr50_`i'=(predcons_satell_ihs_ubr50<rankpred_24`i')

sum test if rankpred_full_`i'==1 & ranktrue2_full_`i'==0 //false positive rate
return list
local FPf1`i'=r(N)
sum test if rankpred_full_`i'==1 & ranktrue2_full_`i'==1 //true postive rate
return list
local TPf1`i'=r(N)
sum test if rankpred2_full_`i'==1 & ranktrue2_full_`i'==0 //false positive rate
return list
local FP2f1`i'=r(N)
sum test if rankpred2_full_`i'==1 & ranktrue2_full_`i'==1 //true postive rate
return list
local TP2f1`i'=r(N)
sum test if ranktrue2_full_`i'==1 //total poor
return list
local Pf1`i'=r(N)
sum test if ranktrue2_full_`i'==0 //total non-poor
return list
local NPf1`i'=r(N)

sum test if rankpred_full50_`i'==1 & ranktrue2_full50_`i'==0 //false positive rate
return list
local FPf150`i'=r(N)
sum test if rankpred_full50_`i'==1 & ranktrue2_full50_`i'==1 //true postive rate
return list
local TPf150`i'=r(N)
sum test if rankpred2_full50_`i'==1 & ranktrue2_full50_`i'==0 //false positive rate
return list
local FP2f150`i'=r(N)
sum test if rankpred2_full50_`i'==1 & ranktrue2_full50_`i'==1 //true postive rate
return list
local TP2f150`i'=r(N)
sum test if ranktrue2_full50_`i'==1 //total poor
return list
local Pf150`i'=r(N)
sum test if ranktrue2_full50_`i'==0 //total non-poor
return list
local NPf150`i'=r(N)

sum test if rankpred_ubr_`i'==1 & ranktrue2_ubr_`i'==0 //false positive rate
return list
local FPu1`i'=r(N)
sum test if rankpred_ubr_`i'==1 & ranktrue2_ubr_`i'==1 //true postive rate
return list
local TPu1`i'=r(N)
sum test if rankpred2_ubr_`i'==1 & ranktrue2_ubr_`i'==0 //false positive rate
return list
local FP2u1`i'=r(N)
sum test if rankpred2_ubr_`i'==1 & ranktrue2_ubr_`i'==1 //true postive rate
return list
local TP2u1`i'=r(N)
sum test if ranktrue2_ubr_`i'==1 //total poor
return list
local Pu1`i'=r(N)
sum test if ranktrue2_ubr_`i'==0 //total non-poor
return list
local NPu1`i'=r(N)

sum test if rankpred_ubr50_`i'==1 & ranktrue2_ubr50_`i'==0 //false positive rate
return list
local FPu150`i'=r(N)
sum test if rankpred_ubr50_`i'==1 & ranktrue2_ubr50_`i'==1 //true postive rate
return list
local TPu150`i'=r(N)
sum test if rankpred2_ubr50_`i'==1 & ranktrue2_ubr50_`i'==0 //false positive rate
return list
local FP2u150`i'=r(N)
sum test if rankpred2_ubr50_`i'==1 & ranktrue2_ubr50_`i'==1 //true postive rate
return list
local TP2u150`i'=r(N)
sum test if ranktrue2_ubr50_`i'==1 //total poor
return list
local Pu150`i'=r(N)
sum test if ranktrue2_ubr50_`i'==0 //total non-poor
return list
local NPu150`i'=r(N)

sum test if rankpred_50full50_`i'==1 & ranktrue2_50full50_`i'==0 //false positive rate
return list
local FPf15050`i'=r(N)
sum test if rankpred_50full50_`i'==1 & ranktrue2_50full50_`i'==1 //true postive rate
return list
local TPf15050`i'=r(N)
sum test if rankpred2_full50_`i'==1 & ranktrue2_50full50_`i'==0 //false positive rate
return list
local FP2f15050`i'=r(N)
sum test if rankpred2_full50_`i'==1 & ranktrue2_50full50_`i'==1 //true postive rate
return list
local TP2f15050`i'=r(N)
sum test if ranktrue2_50full50_`i'==1 //total poor
return list
local Pf15050`i'=r(N)
sum test if ranktrue2_50full50_`i'==0 //total non-poor
return list
local NPf15050`i'=r(N)

sum test if rankpred_50ubr50_`i'==1 & ranktrue2_50ubr50_`i'==0 //false positive rate
return list
local FPu15050`i'=r(N)
sum test if rankpred_50ubr50_`i'==1 & ranktrue2_50ubr50_`i'==1 //true postive rate
return list
local TPu15050`i'=r(N)
sum test if rankpred2_ubr50_`i'==1 & ranktrue2_50ubr50_`i'==0 //false positive rate
return list
local FP2u15050`i'=r(N)
sum test if rankpred2_ubr50_`i'==1 & ranktrue2_50ubr50_`i'==1 //true postive rate
return list
local TP2u15050`i'=r(N)
sum test if ranktrue2_50ubr50_`i'==1 //total poor
return list
local Pu15050`i'=r(N)
sum test if ranktrue2_50ubr50_`i'==0 //total non-poor
return list
local NPu15050`i'=r(N)

	
putexcel A`i'=`FPf1`i''
putexcel B`i'=`TPf1`i''
putexcel C`i'=`FP2f1`i''
putexcel D`i'=`TP2f1`i''
putexcel E`i'=`Pf1`i''
putexcel F`i'=`NPf1`i''

putexcel H`i'=`FPu1`i''
putexcel I`i'=`TPu1`i''
putexcel J`i'=`FP2u1`i''
putexcel K`i'=`TP2u1`i''
putexcel L`i'=`Pu1`i''
putexcel M`i'=`NPu1`i''

putexcel O`i'=`FPf150`i''
putexcel P`i'=`TPf150`i''
putexcel Q`i'=`FP2f150`i''
putexcel R`i'=`TP2f150`i''
putexcel S`i'=`Pf150`i''
putexcel T`i'=`NPf150`i''

putexcel V`i'=`FPu150`i''
putexcel W`i'=`TPu150`i''
putexcel X`i'=`FP2u150`i''
putexcel Y`i'=`TP2u150`i''
putexcel Z`i'=`Pu150`i''
putexcel AA`i'=`NPu150`i''	

putexcel AC`i'=`FPf15050`i''
putexcel AD`i'=`TPf15050`i''
putexcel AE`i'=`FP2f15050`i''
putexcel AF`i'=`TP2f15050`i''
putexcel AG`i'=`Pf15050`i''
putexcel AH`i'=`NPf15050`i''

putexcel AJ`i'=`FPu15050`i''
putexcel AK`i'=`TPu15050`i''
putexcel AL`i'=`FP2u15050`i''
putexcel AM`i'=`TP2u15050`i''
putexcel AN`i'=`Pu15050`i''
putexcel AO`i'=`NPu15050`i''

}
drop rankpred_* rankpred2_* ranktrue*


*** AUC calculations
preserve
import excel "Census\Updated results\AUC_XGB_updating3.xlsx", sheet("Sheet1") clear

g FPR_full=A/F
g TPR_full=B/E
g FPR_full2=C/F
g TPR_full2=D/E

g FPR_ubr=H/M
g TPR_ubr=I/L
g FPR_ubr2=J/M
g TPR_ubr2=K/L

g FPR_full50=O/T
g TPR_full50=P/S
g FPR_full502=Q/T
g TPR_full502=R/S

g FPR_ubr50=V/AA
g TPR_ubr50=W/Z
g FPR_ubr502=X/AA
g TPR_ubr502=Y/Z

g FPR_50full50=AC/AH
g TPR_50full50=AD/AG
g FPR_50full502=AE/AH
g TPR_50full502=AF/AG

g FPR_50ubr50=AJ/AO
g TPR_50ubr50=AK/AN
g FPR_50ubr502=AL/AO
g TPR_50ubr502=AM/AN

export excel using "Census\Updated results\AUC_XGB_updating3.xlsx", replace

keep FPR* TPR* 

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x' FPR_`x', gen(total_auc`x')
local aucxgbihs_1`x'=r(integral) 
}

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x'2 FPR_`x'2, gen(total_auc`x'2)
local aucxgbihs_2`x'=r(integral) 
}

restore

*** Creating AUC Excel file
putexcel set "Census\Updated results\AUC_updating3_lasso", replace

putexcel A2="AUC"

putexcel A3="Benchmark welfare predicted with LASSO"
putexcel A4="Benchmark welfare predicted with XGBOOST"

putexcel B2="All districts-all HH in IHS & all HH in census"
putexcel D2="UBR districts-all HH in IHS & all UBR HH in census"
putexcel F2="All districts-all HH in IHS & poorest 50% HH in census"
putexcel H2="UBR districts-all HH in IHS & poorest 50% UBR HH in census"
putexcel J2="Poorest 50% HH in all districts in IHS & poorest 50% HH in census"
putexcel L2="Poorest 50% HH in UBR districts in IHS & poorest 50% UBR HH in census"

putexcel B2="One threshold"
putexcel C2="Two thresholds"
putexcel D2="One threshold"
putexcel E2="Two thresholds"
putexcel F2="One threshold"
putexcel G2="Two thresholds"
putexcel H2="One threshold"
putexcel I2="Two thresholds"
putexcel J2="One threshold"
putexcel K2="Two thresholds"
putexcel L2="One threshold"
putexcel M2="Two thresholds"

putexcel B3=`auclassoihs_1full'
putexcel C3=`auclassoihs_2full'
putexcel D3=`auclassoihs_1ubr'
putexcel E3=`auclassoihs_2ubr'
putexcel F3=`auclassoihs_1full50'
putexcel G3=`auclassoihs_2full50'
putexcel H3=`auclassoihs_1ubr50'
putexcel I3=`auclassoihs_2ubr50'
putexcel J3=`auclassoihs_150full50'
putexcel K3=`auclassoihs_250full50'
putexcel L3=`auclassoihs_150ubr50'
putexcel M3=`auclassoihs_250ubr50'

putexcel B4=`aucxgbihs_1full'
putexcel C4=`aucxgbihs_2full'
putexcel D4=`aucxgbihs_1ubr'
putexcel E4=`aucxgbihs_2ubr'
putexcel F4=`aucxgbihs_1full50'
putexcel G4=`aucxgbihs_2full50'
putexcel H4=`aucxgbihs_1ubr50'
putexcel I4=`aucxgbihs_2ubr50'
putexcel J4=`aucxgbihs_150full50'
putexcel K4=`aucxgbihs_250full50'
putexcel L4=`aucxgbihs_150ubr50'
putexcel M4=`aucxgbihs_250ubr50'

*******************************************************
*** Benchmark welfare predicted using xgboost IHS update

*** Rank correlations
preserve
foreach x in full ubr  {
use "Census\Updated results\predcensus_xgb_IHS_`x'.dta",clear
spearman predwelf_ihsxgb_`x' predcons_xgb_`x'vill
	local rho`x'xg=r(rho)
	local p`x'xg=r(p)
	local N`x'xg=r(N)
spearman predwelf_ihsxgb_`x' predcons_census_`x'vill
	local rho`x'=r(rho)
	local p`x'=r(p)
	local N`x'=r(N)
***R-squared
	reg  predcons_xgb_`x'vill predwelf_ihsxgb_`x'
	ereturn list
	local r_`x'= e(r2)
}
di `r_full'
di `r_ubr'

foreach x in full ubr  {
use "Census\Updated results\predcensus_xgb_IHS_`x'50new.dta",clear
spearman predwelf_ihsxgb_`x'50 predcons_xgb_`x'vill50
	local rho`x'xg50=r(rho)
	local p`x'xg50=r(p)
	local N`x'xg50=r(N)
spearman predwelf_ihsxgb_`x'50 predcons_census_`x'vill50
	local rho`x'50=r(rho)
	local p`x'50=r(p)
	local N`x'50=r(N)
}


use "Census\Updated results\predcensus_xgb_IHS_full50new.dta",clear
spearman predwelf_ihsxgb_full50 predcons_xgb_50vill50
	local rhofullxg5050=r(rho)
	local pfullxg5050=r(p)
	local Nfullxg5050=r(N)
spearman predwelf_ihsxgb_full50 predcons_census_50vill50
	local rhofull5050=r(rho)
	local pfull5050=r(p)
	local Nfull5050=r(N)
***R-squared
reg  predcons_xgb_50vill50 predwelf_ihsxgb_full50
ereturn list
local r_50vill50= e(r2)
di `r_50vill50'

use "Census\Updated results\predcensus_xgb_IHS_ubr50new.dta",clear
spearman predwelf_ihsxgb_ubr50 predcons_xgb_50ubrvill50
	local rhoubrxg5050=r(rho) 
	local pubrxg5050=r(p)
	local Nubrxg5050=r(N)
spearman predwelf_ihsxgb_ubr50 predcons_census_50ubrvill50
	local rhoubr5050=r(rho)
	local pubr5050=r(p)
	local Nubr5050=r(N)
***R-squared
reg  predcons_xgb_50ubrvill50 predwelf_ihsxgb_ubr50
ereturn list
local r_50ubrvill50= e(r2)
di `r_50ubrvill50'
	
putexcel set "Census\Updated results\Correlations_census_precited_IHS_XGB_updt4", replace

putexcel A1="Rank correlations between True and Predicted consumption using XGBOOST"

putexcel A3="Benchmark welfare estimated using LASSO"
putexcel A6="Benchmark welfare estimated using XGBOOST"

putexcel B2="All districts-all HH in IHS & all HH in census"
putexcel C2="UBR districts-all HH in IHS & all UBR HH in census"
putexcel D2="All districts-all HH in IHS & poorest 50% HH in census"
putexcel E2="UBR districts-all HH in IHS & poorest 50% UBR HH in census"
putexcel F2="Poorest 50% HH in all districts in IHS & poorest 50% HH in census"
putexcel G2="Poorest 50% HH in UBR districts in IHS & poorest 50% UBR HH in census"

putexcel B3=`rhofull'
putexcel B4=`pfull'
putexcel B5=`Nfull'
putexcel C3=`rhoubr'
putexcel C4=`pubr'
putexcel C5=`Nubr'
putexcel D3=`rhofull50'
putexcel D4=`pfull50'
putexcel D5=`Nfull50'
putexcel E3=`rhoubr50'
putexcel E4=`pubr50'
putexcel E5=`Nubr50'
putexcel F3=`rhofull5050'
putexcel F4=`pfull5050'
putexcel F5=`Nfull5050'
putexcel G3=`rhoubr5050'
putexcel G4=`pubr5050'
putexcel G5=`Nubr5050'

putexcel B6=`rhofullxg'
putexcel B7=`pfullxg'
putexcel B8=`Nfullxg'
putexcel C6=`rhoubrxg'
putexcel C7=`pubrxg'
putexcel C8=`Nubrxg'
putexcel D6=`rhofullxg50'
putexcel D7=`pfullxg50'
putexcel D8=`Nfullxg50'
putexcel E6=`rhoubrxg50'
putexcel E7=`pubrxg50'
putexcel E8=`Nubrxg50'
putexcel F6=`rhofullxg5050'
putexcel F7=`pfullxg5050'
putexcel F8=`Nfullxg5050'
putexcel G6=`rhoubrxg5050'
putexcel G7=`pubrxg5050'
putexcel G8=`Nubrxg5050'

restore

*** AUC: FPR and TPR
preserve

***Full sample
use "Census\Updated results\predcensus_xgb_IHS_full.dta", clear
g test=1
putexcel set "Census\Updated results\AUC_updt_3full", replace

forvalues i=1(1)99 {
	
	egen ranktrue_1xg`i' = pctile(predcons_xgb_fullvill),  p(`i') 
	g ranktrue_full_xg`i'=(predcons_xgb_fullvill<ranktrue_1xg`i')

	egen ranktrue_1`i' = pctile(predcons_census_fullvill),  p(`i') 
	g ranktrue_full_`i'=(predcons_census_fullvill<ranktrue_1`i')

	egen rankpred_1`i' = pctile(predwelf_ihsxgb_full), p(`i') 
	g rankpred_full_xg`i'=(predwelf_ihsxgb_full<ranktrue_1xg`i')
	g rankpred_full_`i'=(predwelf_ihsxgb_full<ranktrue_1`i')
	g rankpred2_full_`i'=(predwelf_ihsxgb_full<rankpred_1`i')
	g rankpred2_full_xg`i'=(predwelf_ihsxgb_full<rankpred_1`i')

*drop ranktrue_1* rankpred_1*	

sum test if rankpred_full_xg`i'==1 & ranktrue_full_xg`i'==0 //false positive rate
return list
local FPf1xg`i'=r(N)
sum test if rankpred_full_xg`i'==1 & ranktrue_full_xg`i'==1 //true postive rate
return list
local TPf1xg`i'=r(N)
sum test if rankpred2_full_xg`i'==1 & ranktrue_full_xg`i'==0 //false positive rate
return list
local FP2f1xg`i'=r(N)
sum test if rankpred2_full_xg`i'==1 & ranktrue_full_xg`i'==1 //true postive rate
return list
local TP2f1xg`i'=r(N)
sum test if ranktrue_full_xg`i'==1 //total poor
return list
local Pf1xg`i'=r(N)
sum test if ranktrue_full_xg`i'==0 //total non-poor
return list
local NPf1xg`i'=r(N)

sum test if rankpred_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FPf1`i'=r(N)
sum test if rankpred_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TPf1`i'=r(N)
sum test if rankpred2_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FP2f1`i'=r(N)
sum test if rankpred2_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TP2f1`i'=r(N)
sum test if ranktrue_full_`i'==1 //total poor
return list
local Pf1`i'=r(N)
sum test if ranktrue_full_`i'==0 //total non-poor
return list
local NPf1`i'=r(N)
		
putexcel A`i'=`FPf1`i''
putexcel B`i'=`TPf1`i''
putexcel C`i'=`FP2f1`i''
putexcel D`i'=`TP2f1`i''
putexcel E`i'=`Pf1`i''
putexcel F`i'=`NPf1`i''

putexcel H`i'=`FPf1xg`i''
putexcel I`i'=`TPf1xg`i''
putexcel J`i'=`FP2f1xg`i''
putexcel K`i'=`TP2f1xg`i''
putexcel L`i'=`Pf1xg`i''
putexcel M`i'=`NPf1xg`i''	
}

import excel "Census\Updated results\AUC_updt_3full.xlsx", sheet("Sheet1") clear

g FPR_full=A/F
g TPR_full=B/E
g FPR_full2=C/F
g TPR_full2=D/E

g FPR_fullxg=H/M
g TPR_fullxg=I/L
g FPR_fullxg2=J/M
g TPR_fullxg2=K/L

export excel using "Census\Updated results\AUC_updt_3full.xlsx", replace

keep FPR* TPR* 

integ TPR_full FPR_full , gen(total_aucfull)
local aucfullihs_full=r(integral) 
integ TPR_fullxg FPR_fullxg , gen(total_aucfullxg)
local aucfullxgihs_full=r(integral) 

integ TPR_full2 FPR_full2 , gen(total_aucfull2)
local aucfullihs_full2=r(integral) 
integ TPR_fullxg2 FPR_fullxg2 , gen(total_aucfullxg2)
local aucfullxgihs_full2=r(integral) 

restore


***UBR sample
preserve
use "Census\Updated results\predcensus_xgb_IHS_ubr.dta", clear
g test=1
putexcel set "Census\Updated results\AUC_updt_3ubr", replace

forvalues i=1(1)99 {
	
	egen ranktrue_1xg`i' = pctile(predcons_xgb_ubrvill), p(`i') 
	g ranktrue_ubr_xg`i'=(predcons_xgb_ubrvill<ranktrue_1xg`i')

	egen ranktrue_1`i' = pctile(predcons_census_ubrvill), p(`i') 
	g ranktrue_ubr_`i'=(predcons_census_ubrvill<ranktrue_1`i')

	egen rankpred_1`i' = pctile(predwelf_ihsxgb_ubr), p(`i') 
	g rankpred_ubr_xg`i'=(predwelf_ihsxgb_ubr<ranktrue_1xg`i')
	g rankpred_ubr_`i'=(predwelf_ihsxgb_ubr<ranktrue_1`i')
	g rankpred2_ubr_xg`i'=(predwelf_ihsxgb_ubr< rankpred_1`i')
	g rankpred2_ubr_`i'=(predwelf_ihsxgb_ubr< rankpred_1`i')
	
*drop ranktrue_1* rankpred_2*	

sum test if rankpred_ubr_xg`i'==1 & ranktrue_ubr_xg`i'==0 //false positive rate
return list
local FPu1xg`i'=r(N)
sum test if rankpred_ubr_xg`i'==1 & ranktrue_ubr_xg`i'==1 //true postive rate
return list
local TPu1xg`i'=r(N)
sum test if rankpred2_ubr_xg`i'==1 & ranktrue_ubr_xg`i'==0 //false positive rate
return list
local FP2u1xg`i'=r(N)
sum test if rankpred2_ubr_xg`i'==1 & ranktrue_ubr_xg`i'==1 //true postive rate
return list
local TP2u1xg`i'=r(N)
sum test if ranktrue_ubr_xg`i'==1 //total poor
return list
local Pu1xg`i'=r(N)
sum test if ranktrue_ubr_xg`i'==0 //total non-poor
return list
local NPu1xg`i'=r(N)

sum test if rankpred_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FPu1`i'=r(N)
sum test if rankpred_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TPu1`i'=r(N)
sum test if rankpred2_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FP2u1`i'=r(N)
sum test if rankpred2_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TP2u1`i'=r(N)
sum test if ranktrue_ubr_`i'==1 //total poor
return list
local Pu1`i'=r(N)
sum test if ranktrue_ubr_`i'==0 //total non-poor
return list
local NPu1`i'=r(N)
		
putexcel A`i'=`FPu1`i''
putexcel B`i'=`TPu1`i''
putexcel C`i'=`FP2u1`i''
putexcel D`i'=`TP2u1`i''
putexcel E`i'=`Pu1`i''
putexcel F`i'=`NPu1`i''

putexcel H`i'=`FPu1xg`i''
putexcel I`i'=`TPu1xg`i''
putexcel J`i'=`FP2u1xg`i''
putexcel K`i'=`TP2u1xg`i''
putexcel L`i'=`Pu1xg`i''
putexcel M`i'=`NPu1xg`i''	

}

import excel "Census\Updated results\AUC_updt_3ubr", sheet("Sheet1") clear

g FPR_ubr=A/F
g TPR_ubr=B/E
g FPR_ubr2=C/F
g TPR_ubr2=D/E

g FPR_ubrxg=H/M
g TPR_ubrxg=I/L
g FPR_ubrxg2=J/M
g TPR_ubrxg2=K/L

export excel using "Census\Updated results\AUC_updt_3ubr", replace

keep FPR* TPR* 

integ TPR_ubr FPR_ubr , gen(total_aucubr)
local aucubrihs_ubr=r(integral) 
integ TPR_ubrxg FPR_ubrxg , gen(total_aucubrxg)
local aucubrxgihs_ubr=r(integral) 

integ TPR_ubr2 FPR_ubr2 , gen(total_aucubr2)
local aucubrihs_ubr2=r(integral) 
integ TPR_ubrxg2 FPR_ubrxg2 , gen(total_aucubrxg2)
local aucubrxgihs_ubr2=r(integral) 

restore

***Full50 sample
preserve
use "Census\Updated results\predcensus_xgb_IHS_full50new.dta", clear

g test=1
putexcel set "Census\Updated results\AUC_updt_3full50v2", replace

forvalues i=1(1)99 {
	
	egen ranktrue_1xg`i' = pctile(predcons_xgb_fullvill50), p(`i') 
	g ranktrue_full_xg`i'=(predcons_xgb_fullvill50<ranktrue_1xg`i')

	egen ranktrue_1`i' = pctile(predcons_census_fullvill50),  p(`i') 
	g ranktrue_full_`i'=(predcons_census_fullvill50<ranktrue_1`i')

	egen ranktrue_2xg`i' = pctile(predcons_xgb_50vill50), p(`i') 
	g ranktrue_full_2xg`i'=(predcons_xgb_50vill50<ranktrue_2xg`i')

	egen ranktrue_2`i' = pctile(predcons_census_50vill50),  p(`i') 
	g ranktrue_full2_`i'=(predcons_census_50vill50<ranktrue_2`i')
	
	egen rankpred_1`i' = pctile(predwelf_ihsxgb_full50),  p(`i') 
	
	g rankpred_full_xg`i'=(predwelf_ihsxgb_full50<ranktrue_1xg`i')
	g rankpred_full_`i'=(predwelf_ihsxgb_full50<ranktrue_1`i')
	g rankpred_full_2xg`i'=(predwelf_ihsxgb_full50<ranktrue_2xg`i')
	g rankpred_full2_`i'=(predwelf_ihsxgb_full50<ranktrue_2`i')	
	g rankpred2_full_xg`i'=(predwelf_ihsxgb_full50<rankpred_1`i')
	g rankpred2_full_`i'=(predwelf_ihsxgb_full50<rankpred_1`i')	

*drop ranktrue_1* rankpred_1*	

sum test if rankpred_full_xg`i'==1 & ranktrue_full_xg`i'==0 //false positive rate
return list
local FPf2xg`i'=r(N)
sum test if rankpred_full_xg`i'==1 & ranktrue_full_xg`i'==1 //true postive rate
return list
local TPf2xg`i'=r(N)
sum test if rankpred2_full_xg`i'==1 & ranktrue_full_xg`i'==0 //false positive rate
return list
local FP2f2xg`i'=r(N)
sum test if rankpred2_full_xg`i'==1 & ranktrue_full_xg`i'==1 //true postive rate
return list
local TP2f2xg`i'=r(N)
sum test if ranktrue_full_xg`i'==1 //total poor
return list
local Pf2xg`i'=r(N)
sum test if ranktrue_full_xg`i'==0 //total non-poor
return list
local NPf2xg`i'=r(N)

sum test if rankpred_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FPf2`i'=r(N)
sum test if rankpred_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TPf2`i'=r(N)
sum test if rankpred2_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FP2f2`i'=r(N)
sum test if rankpred2_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TP2f2`i'=r(N)
sum test if ranktrue_full_`i'==1 //total poor
return list
local Pf2`i'=r(N)
sum test if ranktrue_full_`i'==0 //total non-poor
return list
local NPf2`i'=r(N)
*/
**50full50

sum test if rankpred_full_2xg`i'==1 & ranktrue_full_2xg`i'==0 //false positive rate
return list
local FP5050fxg`i'=r(N)
sum test if rankpred_full_2xg`i'==1 & ranktrue_full_2xg`i'==1 //true postive rate
return list
local TP5050fxg`i'=r(N)
sum test if rankpred2_full_xg`i'==1 & ranktrue_full_2xg`i'==0 //false positive rate
return list
local FP25050fxg`i'=r(N)
sum test if rankpred2_full_xg`i'==1 & ranktrue_full_2xg`i'==1 //true postive rate
return list
local TP25050fxg`i'=r(N)
sum test if ranktrue_full_2xg`i'==1 //total poor
return list
local P5050fxg`i'=r(N)
sum test if ranktrue_full_2xg`i'==0 //total non-poor
return list
local NP5050fxg`i'=r(N)
di "`i'"


sum test if rankpred_full2_`i'==1 & ranktrue_full2_`i'==0 //false positive rate
return list
local FP5050f`i'=r(N)
sum test if rankpred_full2_`i'==1 & ranktrue_full2_`i'==1 //true postive rate
return list
local TP5050f`i'=r(N)
sum test if rankpred2_full_`i'==1 & ranktrue_full2_`i'==0 //false positive rate
return list
local FP25050f`i'=r(N)
sum test if rankpred2_full_`i'==1 & ranktrue_full2_`i'==1 //true postive rate
return list
local TP25050f`i'=r(N)
sum test if ranktrue_full2_`i'==1 //total poor
return list
local P5050f`i'=r(N)
sum test if ranktrue_full2_`i'==0 //total non-poor
return list
local NP5050f`i'=r(N)
di "`i'"
		
putexcel A`i'=`FPf2`i''
putexcel B`i'=`TPf2`i''
putexcel C`i'=`FP2f2`i''
putexcel D`i'=`TP2f2`i''
putexcel E`i'=`Pf2`i''
putexcel F`i'=`NPf2`i''

putexcel H`i'=`FPf2xg`i''
putexcel I`i'=`TPf2xg`i''
putexcel J`i'=`FP2f2xg`i''
putexcel K`i'=`TP2f2xg`i''
putexcel L`i'=`Pf2xg`i''
putexcel M`i'=`NPf2xg`i''	

putexcel O`i'=`FP5050f`i''
putexcel P`i'=`TP5050f`i''
putexcel Q`i'=`FP25050f`i''
putexcel R`i'=`TP25050f`i''
putexcel S`i'=`P5050f`i''
putexcel T`i'=`NP5050f`i''

putexcel V`i'=`FP5050fxg`i''
putexcel W`i'=`TP5050fxg`i''
putexcel X`i'=`FP25050fxg`i''
putexcel Y`i'=`TP25050fxg`i''
putexcel Z`i'=`P5050fxg`i''
putexcel AA`i'=`NP5050fxg`i''

}

import excel "Census\Updated results\AUC_updt_3full50v2", sheet("Sheet1") clear

g FPR_full50=A/F
g TPR_full50=B/E
g FPR_full502=C/F
g TPR_full502=D/E

g FPR_full50xg=H/M
g TPR_full50xg=I/L
g FPR_full50xg2=J/M
g TPR_full50xg2=K/L

g FPR_full5050=O/T
g TPR_full5050=P/S
g FPR_full50502=Q/T
g TPR_full50502=R/S

g FPR_full5050xg=V/AA
g TPR_full5050xg=W/Z
g FPR_full5050xg2=X/AA
g TPR_full5050xg2=Y/Z

export excel using "Census\Updated results\AUC_updt_3full50v2", replace

keep FPR* TPR* 

integ TPR_full50 FPR_full50 , gen(total_aucfull50)
local aucfull50ihs_full50=r(integral) 
integ TPR_full50xg FPR_full50xg , gen(total_aucfull50xg)
local aucfull50xgihs_full50=r(integral) 

integ TPR_full5050 FPR_full5050 , gen(total_aucfull5050)
local aucfull50ihs_full5050=r(integral) 
integ TPR_full5050xg FPR_full5050xg , gen(total_aucfull5050xg)
local aucfull50xgihs_full5050=r(integral) 

integ TPR_full502 FPR_full502 , gen(total_aucfull502)
local aucfull50ihs_full502=r(integral) 
integ TPR_full50xg2 FPR_full50xg2 , gen(total_aucfull50xg2)
local aucfull50xgihs_full502=r(integral) 

integ TPR_full50502 FPR_full50502 , gen(total_aucfull50502)
local aucfull50ihs_full50502=r(integral) 
integ TPR_full5050xg2 FPR_full5050xg2 , gen(total_aucfull5050xg2)
local aucfull50xgihs_full50502=r(integral) 

restore

*** UBR50 sample
preserve
use "Census\Updated results\predcensus_xgb_IHS_ubr50new.dta", clear

g test=1
putexcel set "Census\Updated results\AUC_updt_3ubr50v2", replace

forvalues i=1(1)99 {
	
	egen ranktrue_1xg`i' = pctile(predcons_xgb_ubrvill50),  p(`i') 
	g ranktrue_ubr_xg`i'=(predcons_xgb_ubrvill50<ranktrue_1xg`i')

	egen ranktrue_1`i' = pctile(predcons_census_ubrvill50),  p(`i') 
	g ranktrue_ubr_`i'=(predcons_census_ubrvill50<ranktrue_1`i')

	egen ranktrue_2xg`i' = pctile(predcons_xgb_50ubrvill50),  p(`i') 
	g ranktrue_ubr_2xg`i'=(predcons_xgb_50ubrvill50<ranktrue_2xg`i')

	egen ranktrue_2`i' = pctile(predcons_census_50ubrvill50),  p(`i') 
	g ranktrue_ubr2_`i'=(predcons_census_50ubrvill50<ranktrue_2`i')
	
	egen rankpred_2`i' = pctile(predwelf_ihsxgb_ubr50),  p(`i') 
	
	g rankpred_ubr_xg`i'=(predwelf_ihsxgb_ubr50<ranktrue_1xg`i')
	g rankpred_ubr_`i'=(predwelf_ihsxgb_ubr50<ranktrue_1`i')
	g rankpred_ubr_2xg`i'=(predwelf_ihsxgb_ubr50<ranktrue_2xg`i')
	g rankpred_ubr2_`i'=(predwelf_ihsxgb_ubr50<ranktrue_2`i')
	
	g rankpred2_ubr_xg`i'=(predwelf_ihsxgb_ubr50<rankpred_2`i')
	g rankpred2_ubr_`i'=(predwelf_ihsxgb_ubr50<rankpred_2`i')
	
*drop ranktrue_1* rankpred_2*	

sum test if rankpred_ubr_xg`i'==1 & ranktrue_ubr_xg`i'==0 //false positive rate
return list
local FPu2xg`i'=r(N)
sum test if rankpred_ubr_xg`i'==1 & ranktrue_ubr_xg`i'==1 //true postive rate
return list
local TPu2xg`i'=r(N)
sum test if rankpred2_ubr_xg`i'==1 & ranktrue_ubr_xg`i'==0 //false positive rate
return list
local FP2u2xg`i'=r(N)
sum test if rankpred2_ubr_xg`i'==1 & ranktrue_ubr_xg`i'==1 //true postive rate
return list
local TP2u2xg`i'=r(N)
sum test if ranktrue_ubr_xg`i'==1 //total poor
return list
local Pu2xg`i'=r(N)
sum test if ranktrue_ubr_xg`i'==0 //total non-poor
return list
local NPu2xg`i'=r(N)

sum test if rankpred_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FPu2`i'=r(N)
sum test if rankpred_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TPu2`i'=r(N)
sum test if rankpred2_ubr_`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FP2u2`i'=r(N)
sum test if rankpred2_ubr_`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TP2u2`i'=r(N)
sum test if ranktrue_ubr_`i'==1 //total poor
return list
local Pu2`i'=r(N)
sum test if ranktrue_ubr_`i'==0 //total non-poor
return list
local NPu2`i'=r(N)

***50UBR50
sum test if rankpred_ubr_2xg`i'==1 & ranktrue_ubr_2xg`i'==0 //false positive rate
return list
local FP50u2xg`i'=r(N)
sum test if rankpred_ubr_2xg`i'==1 & ranktrue_ubr_2xg`i'==1 //true postive rate
return list
local TP50u2xg`i'=r(N)
sum test if rankpred2_ubr_xg`i'==1 & ranktrue_ubr_2xg`i'==0 //false positive rate
return list
local FP250u2xg`i'=r(N)
sum test if rankpred2_ubr_xg`i'==1 & ranktrue_ubr_2xg`i'==1 //true postive rate
return list
local TP250u2xg`i'=r(N)
sum test if ranktrue_ubr_2xg`i'==1 //total poor
return list
local P50u2xg`i'=r(N)
sum test if ranktrue_ubr_2xg`i'==0 //total non-poor
return list
local NP50u2xg`i'=r(N)

sum test if rankpred_ubr2_`i'==1 & ranktrue_ubr2_`i'==0 //false positive rate
return list
local FP50u2`i'=r(N)
sum test if rankpred_ubr2_`i'==1 & ranktrue_ubr2_`i'==1 //true postive rate
return list
local TP50u2`i'=r(N)
sum test if rankpred2_ubr_`i'==1 & ranktrue_ubr2_`i'==0 //false positive rate
return list
local FP250u2`i'=r(N)
sum test if rankpred2_ubr_`i'==1 & ranktrue_ubr2_`i'==1 //true postive rate
return list
local TP250u2`i'=r(N)
sum test if ranktrue_ubr2_`i'==1 //total poor
return list
local P50u2`i'=r(N)
sum test if ranktrue_ubr2_`i'==0 //total non-poor
return list
local NP50u2`i'=r(N)
		
putexcel A`i'=`FPu2`i''
putexcel B`i'=`TPu2`i''
putexcel C`i'=`FP2u2`i''
putexcel D`i'=`TP2u2`i''
putexcel E`i'=`Pu2`i''
putexcel F`i'=`NPu2`i''

putexcel H`i'=`FPu2xg`i''
putexcel I`i'=`TPu2xg`i''
putexcel J`i'=`FP2u2xg`i''
putexcel K`i'=`TP2u2xg`i''
putexcel L`i'=`Pu2xg`i''
putexcel M`i'=`NPu2xg`i''

putexcel O`i'=`FP50u2`i''
putexcel P`i'=`TP50u2`i''
putexcel Q`i'=`FP250u2`i''
putexcel R`i'=`TP250u2`i''
putexcel S`i'=`P50u2`i''
putexcel T`i'=`NP50u2`i''

putexcel V`i'=`FP50u2xg`i''
putexcel W`i'=`TP50u2xg`i''
putexcel X`i'=`FP250u2xg`i''
putexcel Y`i'=`TP250u2xg`i''
putexcel Z`i'=`P50u2xg`i''
putexcel AA`i'=`NP50u2xg`i''

}

import excel "Census\Updated results\AUC_updt_3ubr50v2", sheet("Sheet1") clear

g FPR_ubr50=A/F
g TPR_ubr50=B/E
g FPR_ubr502=C/F
g TPR_ubr502=D/E

g FPR_ubr50xg=H/M
g TPR_ubr50xg=I/L
g FPR_ubr50xg2=J/M
g TPR_ubr50xg2=K/L

g FPR_ubr5050=O/T
g TPR_ubr5050=P/S
g FPR_ubr50502=Q/T
g TPR_ubr50502=R/S

g FPR_ubr5050xg=V/AA
g TPR_ubr5050xg=W/Z
g FPR_ubr5050xg2=X/AA
g TPR_ubr5050xg2=Y/Z

keep FPR* TPR* 

integ TPR_ubr50 FPR_ubr50 , gen(total_aucubr50)
local aucubr50ihs_ubr50=r(integral) 
integ TPR_ubr50xg FPR_ubr50xg , gen(total_aucubr50xg)
local aucubr50xgihs_ubr50=r(integral) 

integ TPR_ubr5050 FPR_ubr5050 , gen(total_aucubr5050)
local aucubr50ihs_ubr5050=r(integral) 
integ TPR_ubr5050xg FPR_ubr5050xg , gen(total_aucubr5050xg)
local aucubr50xgihs_ubr5050=r(integral) 

integ TPR_ubr502 FPR_ubr502 , gen(total_aucubr502)
local aucubr50ihs_ubr502=r(integral) 
integ TPR_ubr50xg2 FPR_ubr50xg2 , gen(total_aucubr50xg2)
local aucubr50xgihs_ubr502=r(integral) 

integ TPR_ubr50502 FPR_ubr50502 , gen(total_aucubr50502)
local aucubr50ihs_ubr50502=r(integral) 
integ TPR_ubr5050xg2 FPR_ubr5050xg2 , gen(total_aucubr5050xg2)
local aucubr50xgihs_ubr50502=r(integral) 
	
restore


*** Creating AUC Excel file
putexcel set "Census\Updated results\AUC_updating3_xgb", replace

putexcel A2="AUC"

putexcel A3="Benchmark welfare predicted with LASSO"
putexcel A4="Benchmark welfare predicted with XGBOOST"

putexcel B2="All districts-all HH in IHS & all HH in census"
putexcel D2="UBR districts-all HH in IHS & all UBR HH in census"
putexcel F2="All districts-all HH in IHS & poorest 50% HH in census"
putexcel H2="UBR districts-all HH in IHS & poorest 50% UBR HH in census"
putexcel J2="Poorest 50% HH in all districts in IHS & poorest 50% HH in census"
putexcel L2="Poorest 50% HH in UBR districts in IHS & poorest 50% UBR HH in census"

putexcel B2="One threshold"
putexcel C2="Two thresholds"
putexcel D2="One threshold"
putexcel E2="Two thresholds"
putexcel F2="One threshold"
putexcel G2="Two thresholds"
putexcel H2="One threshold"
putexcel I2="Two thresholds"
putexcel J2="One threshold"
putexcel K2="Two thresholds"
putexcel L2="One threshold"
putexcel M2="Two thresholds"

putexcel B3=`aucfullihs_full'
putexcel C3=`aucfullihs_full2'
putexcel D3=`aucubrihs_ubr'
putexcel E3=`aucubrihs_ubr2'
putexcel F3=`aucfull50ihs_full50'
putexcel G3=`aucfull50ihs_full502'
putexcel H3=`aucubr50ihs_ubr50'
putexcel I3=`aucubr50ihs_ubr502'
putexcel J3=`aucfull50ihs_full5050'
putexcel K3=`aucfull50ihs_full50502'
putexcel L3=`aucubr50ihs_ubr5050'
putexcel M3=`aucubr50ihs_ubr50502'

putexcel B4=`aucfullxgihs_full'
putexcel C4=`aucfullxgihs_full2'
putexcel D4=`aucubrxgihs_ubr'
putexcel E4=`aucubrxgihs_ubr2'
putexcel F4=`aucfull50xgihs_full50'
putexcel G4=`aucfull50xgihs_full502'
putexcel H4=`aucubr50xgihs_ubr50'
putexcel I4=`aucubr50xgihs_ubr502'
putexcel J4=`aucfull50xgihs_full5050'
putexcel K4=`aucfull50xgihs_full50502'
putexcel L4=`aucubr50xgihs_ubr5050'
putexcel M4=`aucubr50xgihs_ubr50502'

*************************************************************
*** Updating method 4: RWI
*************************************************************
*g test=1
*** Using  LASSO prediction for benchmark welfare
putexcel set "Census\Updated results\rank_correlations_lasso_rwi", replace

***R-squared
***Trimmed PMT and raw predicted consumption
foreach x in fullvill ubrvill fullvill50 ubrvill50  50vill50 50ubrvill50  {
	reg  predcons_xgb_`x' mean_rwi
	ereturn list
	local r_`x'= e(r2)
}

di `r_50vill50'  
di `r_50ubrvill50' 
di `r_fullvill'


***Rank correlations
***Average RWI and raw predicted consumption
foreach x in fullvill ubrvill fullvill50 ubrvill50 50vill50 50ubrvill50 {
	spearman  predcons_census_`x' mean_rwi
	local rho`x'=r(rho)
	local p`x'=r(p)
	local N`x'=r(N)
}

***Median RWI and raw predicted consumption
foreach x in fullvill ubrvill fullvill50 ubrvill50 50vill50 50ubrvill50 {
	spearman  predcons_census_`x' median_rwi
	local mrho`x'=r(rho)
	local mp`x'=r(p)
	local mN`x'=r(N)
}


putexcel A2="Average RWI and predicted consumption in Census"
putexcel B1="All districts-all HH in IHS & all HH in census"
putexcel B2=`rhofullvill'
putexcel B3=`pfullvill'
putexcel B4=`Nfullvill'
putexcel C1="UBR districts-all HH in IHS & all UBR HH in census"
putexcel C2=`rhoubrvill'
putexcel C3=`pubrvill'
putexcel C4=`Nubrvill'
putexcel D1="All districts-all HH in IHS & poorest 50% HH in census"
putexcel D2=`rhofullvill50'
putexcel D3=`pfullvill50'
putexcel D4=`Nfullvill50'
putexcel E1="UBR districts-all HH in IHS & poorest 50% UBR HH in census"
putexcel E2=`rhoubrvill50'
putexcel E3=`pubrvill50'
putexcel E4=`Nubrvill50'
putexcel F1="Poorest 50% HH in all districts in IHS & poorest 50% HH in census"
putexcel F2=`rho50vill50'
putexcel F3=`p50vill50'
putexcel F4=`N50vill50'
putexcel G1="Poorest 50% HH in UBR districts in IHS & poorest 50% UBR HH in census"
putexcel G2=`rho50ubrvill50'
putexcel G3=`p50ubrvill50'
putexcel G4=`N50ubrvill50'

putexcel A5="Median RWI and predicted consumption in Census"
putexcel B5=`mrhofullvill'
putexcel B6=`mpfullvill'
putexcel B7=`mNfullvill'
putexcel C5=`mrhoubrvill'
putexcel C6=`mpubrvill'
putexcel C7=`mNubrvill'
putexcel D5=`mrhofullvill50'
putexcel D6=`mpfullvill50'
putexcel D7=`mNfullvill50'
putexcel E5=`mrhoubrvill50'
putexcel E6=`mpubrvill50'
putexcel E7=`mNubrvill50'
putexcel F5=`mrho50vill50'
putexcel F6=`mp50vill50'
putexcel F7=`mN50vill50'
putexcel G5=`mrho50ubrvill50'
putexcel G6=`mp50ubrvill50'
putexcel G7=`mN50ubrvill50'

******************************************************
*** Using  XGBOOST prediction for benchmark welfare

putexcel set "Census\Updated results\rank_correlations_xgb_rwi", replace
***Rank correlations
***Average RWI and raw predicted consumption
foreach x in fullvill ubrvill fullvill50 ubrvill50  50vill50 50ubrvill50 {
	spearman  predcons_xgb_`x' mean_rwi
	local rho`x'=r(rho)
	local p`x'=r(p)
	local N`x'=r(N)
}

***Median RWI and raw predicted consumption
foreach x in fullvill ubrvill fullvill50 ubrvill50 50vill50 50ubrvill50 {
	spearman  predcons_xgb_`x' median_rwi
	local mrho`x'=r(rho)
	local mp`x'=r(p)
	local mN`x'=r(N)
}



putexcel A2="Average RWI and predicted consumption in Census"
putexcel B1="All districts-all HH in IHS & all HH in census"
putexcel B2=`rhofullvill'
putexcel B3=`pfullvill'
putexcel B4=`Nfullvill'
putexcel C1="UBR districts-all HH in IHS & all UBR HH in census"
putexcel C2=`rhoubrvill'
putexcel C3=`pubrvill'
putexcel C4=`Nubrvill'
putexcel D1="All districts-all HH in IHS & poorest 50% HH in census"
putexcel D2=`rhofullvill50'
putexcel D3=`pfullvill50'
putexcel D4=`Nfullvill50'
putexcel E1="UBR districts-all HH in IHS & poorest 50% UBR HH in census"
putexcel E2=`rhoubrvill50'
putexcel E3=`pubrvill50'
putexcel E4=`Nubrvill50'
putexcel F1="Poorest 50% HH in all districts in IHS & poorest 50% HH in census"
putexcel F2=`rho50vill50'
putexcel F3=`p50vill50'
putexcel F4=`N50vill50'
putexcel G1="Poorest 50% HH in UBR districts in IHS & poorest 50% UBR HH in census"
putexcel G2=`rho50ubrvill50'
putexcel G3=`p50ubrvill50'
putexcel G4=`N50ubrvill50'

putexcel A5="Median RWI and predicted consumption in Census"
putexcel B5=`mrhofullvill'
putexcel B6=`mpfullvill'
putexcel B7=`mNfullvill'
putexcel C5=`mrhoubrvill'
putexcel C6=`mpubrvill'
putexcel C7=`mNubrvill'
putexcel D5=`mrhofullvill50'
putexcel D6=`mpfullvill50'
putexcel D7=`mNfullvill50'
putexcel E5=`mrhoubrvill50'
putexcel E6=`mpubrvill50'
putexcel E7=`mNubrvill50'
putexcel F5=`mrho50vill50'
putexcel F6=`mp50vill50'
putexcel F7=`mN50vill50'
putexcel G5=`mrho50ubrvill50'
putexcel G6=`mp50ubrvill50'
putexcel G7=`mN50ubrvill50'

***AUC: false positve rates and true positive rates for each percentile

***Using lasso prediction for benchmark welfare

*g test=1
putexcel set "Census\Updated results\AUC_lasso_updating4", replace

forvalues i=1(1)99 {
	egen ranktrue_1`i' = pctile(predcons_census_fullvill), /*by(district)*/ p(`i') 
	g ranktrue_full_`i'=(predcons_census_fullvill<ranktrue_1`i')
	egen ranktrue_2`i' = pctile(predcons_census_ubrvill), /*by(district)*/ p(`i') 
	g ranktrue_ubr_`i'=(predcons_census_ubrvill<ranktrue_2`i')
	egen ranktrue_3`i' = pctile(predcons_census_fullvill50), /*by(district)*/ p(`i') 
	g ranktrue_full50_`i'=(predcons_census_fullvill50<ranktrue_3`i')
	egen ranktrue_4`i' = pctile(predcons_census_ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_ubr50_`i'=(predcons_census_ubrvill50<ranktrue_4`i')
	egen ranktrue_5`i' = pctile(predcons_census_50vill50), /*by(district)*/ p(`i') 
	g ranktrue_50full50_`i'=(predcons_census_50vill50<ranktrue_5`i')
	egen ranktrue_6`i' = pctile(predcons_census_50ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_50ubr50_`i'=(predcons_census_50ubrvill50<ranktrue_6`i')

	egen rankrwi`i' = pctile(mean_rwi), /*by(district)*/ p(`i') 
	g rank_rwi`i'=(mean_rwi<rankrwi`i')
	
drop rankrwi* ranktrue_4* ranktrue_3* ranktrue_2* ranktrue_1*


sum test if rank_rwi`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FPf`i'=r(N)
sum test if rank_rwi`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TPf`i'=r(N)
sum test if ranktrue_full_`i'==1 //total poor
return list
local Pf`i'=r(N)
sum test if ranktrue_full_`i'==0 //total poor
return list
local NPf`i'=r(N)

sum test if rank_rwi`i'==1 & ranktrue_full50_`i'==0 //false positive rate
return list
local FPf50`i'=r(N)
sum test if rank_rwi`i'==1 & ranktrue_full50_`i'==1 //true postive rate
return list
local TPf50`i'=r(N)
sum test if ranktrue_full50_`i'==1 //total poor
return list
local Pf50`i'=r(N)
sum test if ranktrue_full50_`i'==0 //total poor
return list
local NPf50`i'=r(N)

sum test if rank_rwi`i'==1 & ranktrue_ubr_`i'==0 //false positive rate
return list
local FPu`i'=r(N)
sum test if rank_rwi`i'==1 & ranktrue_ubr_`i'==1 //true postive rate
return list
local TPu`i'=r(N)
sum test if ranktrue_ubr_`i'==1 //total poor
return list
local Pu`i'=r(N)
sum test if ranktrue_ubr_`i'==0 //total poor
return list
local NPu`i'=r(N)

sum test if rank_rwi`i'==1 & ranktrue_ubr50_`i'==0 //false positive rate
return list
local FPu50`i'=r(N)
sum test if rank_rwi`i'==1 & ranktrue_ubr50_`i'==1 //true postive rate
return list
local TPu50`i'=r(N)
sum test if ranktrue_ubr50_`i'==1 //total poor
return list
local Pu50`i'=r(N)
sum test if ranktrue_ubr50_`i'==0 //total poor
return list
local NPu50`i'=r(N)

sum test if rank_rwi`i'==1 & ranktrue_50full50_`i'==0 //false positive rate
return list
local FPf5050`i'=r(N)
sum test if rank_rwi`i'==1 & ranktrue_50full50_`i'==1 //true postive rate
return list
local TPf5050`i'=r(N)
sum test if ranktrue_50full50_`i'==1 //total poor
return list
local Pf5050`i'=r(N)
sum test if ranktrue_50full50_`i'==0 //total poor
return list
local NPf5050`i'=r(N)

sum test if rank_rwi`i'==1 & ranktrue_50ubr50_`i'==0 //false positive rate
return list
local FPu5050`i'=r(N)
sum test if rank_rwi`i'==1 & ranktrue_50ubr50_`i'==1 //true postive rate
return list
local TPu5050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==1 //total poor
return list
local Pu5050`i'=r(N)
sum test if ranktrue_50ubr50_`i'==0 //total poor
return list
local NPu5050`i'=r(N)

putexcel A`i'=`FPf`i''
putexcel B`i'=`TPf`i''
putexcel C`i'=`Pf`i''
putexcel D`i'=`NPf`i''

putexcel E`i'=`FPu`i''
putexcel F`i'=`TPu`i''
putexcel G`i'=`Pu`i''
putexcel H`i'=`NPu`i''

putexcel I`i'=`FPf50`i''
putexcel J`i'=`TPf50`i''
putexcel K`i'=`Pf50`i''
putexcel L`i'=`NPf50`i''

putexcel M`i'=`FPu50`i''
putexcel N`i'=`TPu50`i''
putexcel O`i'=`Pu50`i''
putexcel P`i'=`NPu50`i''

putexcel Q`i'=`FPf5050`i''
putexcel R`i'=`TPf5050`i''
putexcel S`i'=`Pf5050`i''
putexcel T`i'=`NPf5050`i''

putexcel U`i'=`FPu5050`i''
putexcel V`i'=`TPu5050`i''
putexcel W`i'=`Pu5050`i''
putexcel X`i'=`NPu5050`i''

}


drop ranktrue_* rank_rwi*

*** AUC calculations
preserve
import excel "Census\Updated results\AUC_lasso_updating4.xlsx", sheet("Sheet1") clear

g FPR_full=A/D
g TPR_full=B/C

g FPR_ubr=E/H
g TPR_ubr=F/G

g FPR_full50=I/L
g TPR_full50=J/K

g FPR_ubr50=M/P
g TPR_ubr50=N/O

g FPR_50full50=Q/T
g TPR_50full50=R/S

g FPR_50ubr50=U/X
g TPR_50ubr50=V/W

export excel using "Census\Updated results\AUC_lasso_updating4.xlsx", replace

keep FPR* TPR* 

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x' FPR_`x', gen(total_auc`x')
local auclassorwi_`x'=r(integral) 
}

restore

***Using XGBOOST prediction for benchmark welfare

*g test=1
putexcel set "Census\Updated results\AUC_xgb_updating4", replace

forvalues i=1(1)99 {
	egen ranktrue_1xg`i' = pctile(predcons_xgb_fullvill), /*by(district)*/ p(`i') 
	g ranktrue_fullxg`i'=(predcons_xgb_fullvill<ranktrue_1xg`i')
	egen ranktrue_2xg`i' = pctile(predcons_xgb_ubrvill), /*by(district)*/ p(`i') 
	g ranktrue_ubrxg`i'=(predcons_xgb_ubrvill<ranktrue_2xg`i')
	egen ranktrue_3xg`i' = pctile(predcons_xgb_fullvill50), /*by(district)*/ p(`i') 
	g ranktrue_full50xg`i'=(predcons_xgb_fullvill50<ranktrue_3xg`i')
	egen ranktrue_4xg`i' = pctile(predcons_xgb_ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_ubr50xg`i'=(predcons_xgb_ubrvill50<ranktrue_4xg`i')
	egen ranktrue_5xg`i' = pctile(predcons_xgb_50vill50), /*by(district)*/ p(`i') 
	g ranktrue_50full50xg`i'=(predcons_xgb_50vill50<ranktrue_5xg`i')
	egen ranktrue_6xg`i' = pctile(predcons_xgb_50ubrvill50), /*by(district)*/ p(`i') 
	g ranktrue_50ubr50xg`i'=(predcons_xgb_50ubrvill50<ranktrue_6xg`i')
	
	egen rankrwi`i' = pctile(mean_rwi), /*by(district)*/ p(`i') 
	g rank_rwi`i'=(mean_rwi<rankrwi`i')
	
drop rankrwi* ranktrue_4xg* ranktrue_3xg* ranktrue_2xg* ranktrue_1xg*


sum test if rank_rwi`i'==1 & ranktrue_fullxg`i'==0 //false positive rate
return list
local FPf`i'=r(N)
sum test if rank_rwi`i'==1 & ranktrue_fullxg`i'==1 //true postive rate
return list
local TPf`i'=r(N)
sum test if ranktrue_fullxg`i'==1 //total poor
return list
local Pf`i'=r(N)
sum test if ranktrue_fullxg`i'==0 //total poor
return list
local NPf`i'=r(N)

sum test if rank_rwi`i'==1 & ranktrue_full50xg`i'==0 //false positive rate
return list
local FPf50`i'=r(N)
sum test if rank_rwi`i'==1 & ranktrue_full50xg`i'==1 //true postive rate
return list
local TPf50`i'=r(N)
sum test if ranktrue_full50xg`i'==1 //total poor
return list
local Pf50`i'=r(N)
sum test if ranktrue_full50xg`i'==0 //total poor
return list
local NPf50`i'=r(N)

sum test if rank_rwi`i'==1 & ranktrue_ubrxg`i'==0 //false positive rate
return list
local FPu`i'=r(N)
sum test if rank_rwi`i'==1 & ranktrue_ubrxg`i'==1 //true postive rate
return list
local TPu`i'=r(N)
sum test if ranktrue_ubrxg`i'==1 //total poor
return list
local Pu`i'=r(N)
sum test if ranktrue_ubrxg`i'==0 //total poor
return list
local NPu`i'=r(N)

sum test if rank_rwi`i'==1 & ranktrue_ubr50xg`i'==0 //false positive rate
return list
local FPu50`i'=r(N)
sum test if rank_rwi`i'==1 & ranktrue_ubr50xg`i'==1 //true postive rate
return list
local TPu50`i'=r(N)
sum test if ranktrue_ubr50xg`i'==1 //total poor
return list
local Pu50`i'=r(N)
sum test if ranktrue_ubr50xg`i'==0 //total poor
return list
local NPu50`i'=r(N)

sum test if rank_rwi`i'==1 & ranktrue_50full50xg`i'==0 //false positive rate
return list
local FPf5050`i'=r(N)
sum test if rank_rwi`i'==1 & ranktrue_50full50xg`i'==1 //true postive rate
return list
local TPf5050`i'=r(N)
sum test if ranktrue_50full50xg`i'==1 //total poor
return list
local Pf5050`i'=r(N)
sum test if ranktrue_50full50xg`i'==0 //total poor
return list
local NPf5050`i'=r(N)

sum test if rank_rwi`i'==1 & ranktrue_50ubr50xg`i'==0 //false positive rate
return list
local FPu5050`i'=r(N)
sum test if rank_rwi`i'==1 & ranktrue_50ubr50xg`i'==1 //true postive rate
return list
local TPu5050`i'=r(N)
sum test if ranktrue_50ubr50xg`i'==1 //total poor
return list
local Pu5050`i'=r(N)
sum test if ranktrue_50ubr50xg`i'==0 //total poor
return list
local NPu5050`i'=r(N)

putexcel A`i'=`FPf`i''
putexcel B`i'=`TPf`i''
putexcel C`i'=`Pf`i''
putexcel D`i'=`NPf`i''

putexcel E`i'=`FPu`i''
putexcel F`i'=`TPu`i''
putexcel G`i'=`Pu`i''
putexcel H`i'=`NPu`i''

putexcel I`i'=`FPf50`i''
putexcel J`i'=`TPf50`i''
putexcel K`i'=`Pf50`i''
putexcel L`i'=`NPf50`i''

putexcel M`i'=`FPu50`i''
putexcel N`i'=`TPu50`i''
putexcel O`i'=`Pu50`i''
putexcel P`i'=`NPu50`i''

putexcel Q`i'=`FPf5050`i''
putexcel R`i'=`TPf5050`i''
putexcel S`i'=`Pf5050`i''
putexcel T`i'=`NPf5050`i''

putexcel U`i'=`FPu5050`i''
putexcel V`i'=`TPu5050`i''
putexcel W`i'=`Pu5050`i''
putexcel X`i'=`NPu5050`i''


}

drop ranktrue_* rank_rwi*


*** AUC calculations
preserve
import excel "Census\Updated results\AUC_xgb_updating4.xlsx", sheet("Sheet1") clear

g FPR_full=A/D
g TPR_full=B/C

g FPR_ubr=E/H
g TPR_ubr=F/G

g FPR_full50=I/L
g TPR_full50=J/K

g FPR_ubr50=M/P
g TPR_ubr50=N/O

g FPR_50full50=Q/T
g TPR_50full50=R/S

g FPR_50ubr50=U/X
g TPR_50ubr50=V/W

export excel "Census\Updated results\AUC_xgb_updating4.xlsx", replace

keep FPR* TPR* 

foreach x in full ubr full50 ubr50 50full50 50ubr50 {
integ TPR_`x' FPR_`x', gen(total_auc`x')
local aucxgbrwi_`x'=r(integral) 
}

restore

putexcel set "Census\Updated results\AUC_updating4", replace

putexcel A1="AUC"
putexcel A2="Benchmark welfare predicted with LASSO"
putexcel A3="Benchmark welfare predicted with XGBOOST"

putexcel B2="All districts-all HH in IHS & all HH in census"
putexcel C2="UBR districts-all HH in IHS & all UBR HH in census"
putexcel D2="All districts-all HH in IHS & poorest 50% HH in census"
putexcel E2="UBR districts-all HH in IHS & poorest 50% UBR HH in census"
putexcel F2="Poorest 50% HH in all districts in IHS & poorest 50% HH in census"
putexcel G2="Poorest 50% HH in UBR districts in IHS & poorest 50% UBR HH in census"

putexcel B2=`auclassorwi_full'
putexcel C2=`auclassorwi_ubr'
putexcel D2=`auclassorwi_full50'
putexcel E2=`auclassorwi_ubr50'
putexcel F2=`auclassorwi_50full50'
putexcel G2=`auclassorwi_50ubr50'

putexcel B3=`aucxgbrwi_full'
putexcel C3=`aucxgbrwi_ubr'
putexcel D3=`aucxgbrwi_full50'
putexcel E3=`aucxgbrwi_ubr50'
putexcel F3=`aucxgbrwi_50full50'
putexcel G3=`aucxgbrwi_50ubr50'