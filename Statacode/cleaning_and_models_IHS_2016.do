*cd "C:\Users\melyg\Desktop\Malawi\Survey"
cd "C:/Users/melyg/Desktop/Malawi"
*cd "\\Client\C$\Users\melyg\Desktop\Malawi\Survey"
set more off
/*
use "2016 IHS IV/MWI_2016_IHS-IV_v01_M_v03_A_SSAPOV_I.dta", clear

keep hid wta_hh pid ageyrs sex relathh9 relathhcs marital6 literacy everattd ///
educat7 educat5 educat4 educat_ISCED primarycomp educyrs atschool atschltyp atslevattd
sort hid pid
tempfile individual
save `individual'


use "2016 IHS IV/MWI_2016_IHS-IV_v01_M_v03_A_SSAPOV_H.dta", clear //12447 households
keep hid wta_hh ownhouse rooms wall floor roof toiletcs toiletshared fuelcookcs fuellighcs garbdispcs *_exp fuelcook fuelligh piped toilet6 cellphone fridge computer stove internet ///
fan airconditioner oxcart bcycle mcycle car radio television television_cable landphone
sort hid
tempfile household
save `household'

use "2016 IHS IV/MWI_2016_IHS-IV_v01_M_v03_A_SSAPOV_P.dta", clear
keep rururb region1 region2 subnatidsurvey strata hid hid_orig hhsize ctry_adq wta_hh wta_pop wta_cadq pc_fd pc_hh padq_fd padq_hh wel_PPPdr wel_PPPnom pc_fddr pc_hhdr padq_fddr padq_hhdr poor_ext poor_fd poor_abs
sort hid
tempfile consumption
save `consumption'

use `individual', clear
merge m:1 hid using `household'
drop _merge
merge m:1 hid using `consumption'
drop _merge

save "2016 IHS IV/IHS_allmodules.dta", replace

***Geo variables
use "2016 IHS IV/householdgeovariablesihs4.dta", clear

rename case_id hid
g hid_orig=hid
save "2016 IHS IV/geovars.dta", replace

keep hid lat_modified lon_modified
drop if lat_modified==.
save "2016 IHS IV/IHS_coords.dta", replace

***Area identifiers
use "C:\Users\melyg\Desktop\Malawi\Survey\MWI_2016_IHS-IV_v04_M_STATA14\MWI_2016_IHS-IV_v04_M_STATA14\household\hh_mod_a_filt.dta", clear

rename case_id hid
g hid_orig=hid
keep hid ea_id
save "2016 IHS IV/IHS_hid_ea.dta", replace

***Social protectin programs
use "MWI_2016_IHS-IV_v04_M_STATA14\MWI_2016_IHS-IV_v04_M_STATA14\household\hh_mod_r.dta", clear
rename case_id hid

keep if hh_r0a==104 | hh_r0a==105 | hh_r0a==111 | hh_r0a==1032 | hh_r0a==1031

g rec=1 if hh_r01==1
bys hid: egen received_ag=sum(rec)
g received=1 if received_ag>=1
replace received=0 if received_ag==0

bys hid: g obs=_n
keep if obs==1

keep hid received 

save "2016 IHS IV/IHS_hid_socprograms.dta", replace


*/
********************************************************************************
use "Survey/2016 IHS IV/IHS_allmodules.dta", clear

*** Generation of variables at household level

***Education

***If the household head attained certain level of education
g prim_eduhh=.
replace prim_eduhh=(educat5==3 & relathh9==1 & educat5!=.)
g sec_eduhh=.
replace sec_eduhh=(educat5 == 4 & relathh9==1 & educat5!=.)
g ter_eduhh=.
replace ter_eduhh=(educat5 == 5 & relathh9==1 & educat5!=.)

foreach x in prim sec ter {
bys hid: egen `x'_edhh=max(`x'_eduhh)
}

drop *_eduhh


***Most educated women and men attained certain level of education
bys hid: egen max_edu_men=max(educyrs) if sex==1
bys hid: egen max_edu_fem=max(educyrs) if sex==0

bys hid: egen medu_max=max(max_edu_men)
bys hid: egen fedu_max=max(max_edu_fem)

g medu_maxid=1 if educyrs==medu_max & medu_max!=. & sex==1
bys hid: egen mnum=sum(medu_maxid)

g fedu_maxid=1 if educyrs==fedu_max & fedu_max!=. & sex==0
bys hid: egen fnum=sum(fedu_maxid)

bys hid: g meducalvl= educat5 if medu_maxid==1
bys hid: g feducalvl= educat5 if fedu_maxid==1

bys hid: egen macedulvl_max=max(meducalvl)
bys hid: egen facedulvl_max=max(feducalvl)

replace meducalvl=. if meducalvl!=macedulvl_max
replace feducalvl=. if feducalvl!=facedulvl_max

***Most educated men attained certain level of education
g mprim_maxedu=.
replace mprim_maxedu=(meducalvl==3 & medu_maxid==1 & educat5!=.)
g msec_maxedu=.
replace msec_maxedu=(meducalvl ==4 & medu_maxid==1 & educat5!=.)
g mter_maxedu=.
replace mter_maxedu=(meducalvl ==5 & medu_maxid==1 & educat5!=.)

foreach x in mprim msec mter {
bys hid: egen `x'_maxed=max(`x'_maxedu)
}

***Most educated women attained certain level of education
g fprim_maxedu=.
replace fprim_maxedu=(feducalvl==3 & fedu_maxid==1 & educat5!=.)
g fsec_maxedu=.
replace fsec_maxedu=(feducalvl ==4 & fedu_maxid==1 & educat5!=.)
g fter_maxedu=.
replace fter_maxedu=(feducalvl ==5 & fedu_maxid==1 & educat5!=.)

foreach x in fprim fsec fter {
bys hid: egen `x'_maxed=max(`x'_maxedu)
}

drop *lvl* *_maxedu *_maxid *num max_edu_men max_edu_fem medu_max fedu_max

***Literacy of the household head
g literacyhh=.
replace literacyhh=(literacy==1 & relathh9==1)
bys hid: egen literacy_hh=max(literacyhh)
drop literacyhh

***Average years of education
g educyrs1=educyrs
replace educyrs=0 if educyrs==. & educat5==1 

bys hid: egen aeduyr_fem=mean(educyrs) if sex==0 & ageyrs>=15 & ageyrs<=64 //for women 15-64
bys hid: egen eduyr_fem=max(aeduyr_fem) 

bys hid: egen aeduyr_men=mean(educyrs) if sex==1 & ageyrs>=15 & ageyrs<=64 //for men 15-64
bys hid: egen eduyr_men=max(aeduyr_men) 

bys hid: egen aeduyr_hh=mean(educyrs) if relathh9==1 //for household head
bys hid: egen eduyr_hh=max(aeduyr_hh) 

drop aeduyr_*

***Age of the household head
g agehh=ageyrs if relathh9==1
bys hid: egen age_hh=max(agehh)

g age2_hh=age_hh^2

***Dependency ratios
***Children
g id_child=(ageyrs>=0 & ageyrs<=14)
g num=(ageyrs>=15 & ageyrs<=64)

bys hid: egen no_child=sum(id_child)
bys hid: egen tot15_64=sum(num)

g depen_ch=no_child/hhsize //do not use pop15-64 as denominator because some households only have children and elderly so, the dependency ratio would be missing

replace depen_ch=0 if no_child==0 & hhsize!=0

***Elderly
g id_old=(ageyrs>=65 & ageyrs!=.)

bys hid: egen no_old=sum(id_old)

g depen_old=no_old/hhsize
replace depen_old=0 if no_old==0 & hhsize!=0 //do not use pop15-64 as denominator because some households only have children and elderly so, the dependency ratio would be missing

***Total
g total_dep= no_old+no_child
g depen_tot=total_dep/tot15_64

drop id_* no_* tot15_64 num
***********************************************************************************
***Keeping only oneobservation per HH
bys hid: gen obs=_n
keep if obs==1

***Merge with geo variables
merge 1:1 hid using "Survey/2016 IHS IV/geovars.dta"
drop _merge

***Merge with ea codes
merge 1:1 hid using "Survey/2016 IHS IV/IHS_hid_ea.dta"
drop _merge

***Merge with social protection programs
merge 1:1 hid using "Survey/2016 IHS IV/IHS_hid_socprograms.dta"
drop _merge

***Merge with GEE data
merge 1:1 hid using "Survey/IHS_GEEdata.dta"
drop _merge
merge 1:1 hid using "SAEplus\data2\pixels\IHS_imperv.dta"
drop _merge

***Merge with WorldPop data
merge 1:1 hid using "Survey/IHS_WPdensity.dta"
drop _merge
merge 1:1 hid using "Survey/IHS_WPbsg.dta"
drop _merge
merge 1:1 hid using "Survey/IHS_WPbsg.dta"
drop _merge
merge 1:1 hid using "buildings\final\IHS_buildings.dta"
drop _merge
merge 1:1 hid using "buildings\final\IHS_distroads.dta"
drop _merge

***Merge with facebook data
merge 1:1 hid using "Rdata\IHS_RWI.dta"
drop _merge

***Mereg with infor form ATLAS
merge 1:1 hid using "Survey/IHS_ATLAS.dta"
drop _merge

***Merge with grids ID
drop ID
merge 1:1 hid using "Rdata\ihs_pts.poly2CT.dta"
rename ID ID_grid2
drop _merge
merge 1:1 hid using "Rdata\ihs_pts.poly7CT.dta"
rename ID ID_grid7
drop _merge

***Region dummy variables
tab region1, g(region_)

***Districts
g district=.
replace district=1 if subnatidsurvey=="Balaka"
replace district=2 if subnatidsurvey=="Blantyre" /*UBR*/
replace district=3 if subnatidsurvey=="Blantayre City"
replace district=4 if subnatidsurvey=="Chikwawa"
replace district=5 if subnatidsurvey=="Chiradzulu" /*UBR*/
replace district=6 if subnatidsurvey=="Chitipa"
replace district=7 if subnatidsurvey=="Dedza"
replace district=8 if subnatidsurvey=="Dowa" /*UBR*/
replace district=9 if subnatidsurvey=="Karonga" /*UBR*/
replace district=10 if subnatidsurvey=="Kasungu" /*UBR*/
replace district=11 if subnatidsurvey=="Likoma"
replace district=12 if subnatidsurvey=="Lilongwe" /*UBR*/
replace district=13 if subnatidsurvey=="Lilongwe City"
replace district=14 if subnatidsurvey=="Machinga"
replace district=15 if subnatidsurvey=="Mangochi"
replace district=16 if subnatidsurvey=="Mchinji"
replace district=17 if subnatidsurvey=="Mulanje"
replace district=18 if subnatidsurvey=="Mwanza"
replace district=19 if subnatidsurvey=="Mzimba"
replace district=20 if subnatidsurvey=="Mzuzu City"
replace district=21 if subnatidsurvey=="Neno"
replace district=22 if subnatidsurvey=="Nkhatabay"
replace district=23 if subnatidsurvey=="Nkhotakota" /*UBR*/
replace district=24 if subnatidsurvey=="Nsanje"
replace district=25 if subnatidsurvey=="Ntcheu" /*UBR*/
replace district=26 if subnatidsurvey=="Ntchisi" /*UBR*/
replace district=27 if subnatidsurvey=="Phalombe"
replace district=28 if subnatidsurvey=="Rumphi" /*UBR*/
replace district=29 if subnatidsurvey=="Salima"
replace district=30 if subnatidsurvey=="Thyolo"
replace district=31 if subnatidsurvey=="Zomba City"
replace district=32 if subnatidsurvey=="Zomba Non-City"

g UBR=inlist(district, 2,5,8,9,10,12,23,25,26,28)
g all=1

***Basic services
g elec_hh=(fuelligh==5 & fuelligh!=.) //electricity
g cook_hh=(fuelcook==1 & fuelcook!=.) //firewood
g water_hh=(piped==1 & piped!=.) //piped water

***House ownership
rename ownhouse ownhouse1
g ownhouse=(ownhouse1==1 & ownhouse1!=.)

***HH size squared
g hhsize2=hhsize^2

***Overcrowding
g overcrwd=hhsize/rooms

***Flush toilet
g flushtoilet=(toilet6==1 & toilet6!=.)

***House materials
g wall_improved  = inlist(wall, 12,13,15,18)  
g roof_improved  = inlist(roof, 10,11,12,14)   
g floor_improved = inlist(floor, 9,10,11)    

***Assets
/*use cellphone fridge stove computer*/
/*Other assets:fan airconditioner oxcart bcycle mcycle car radio television television_cable landphone*/

replace oxcart=0 if oxcart==.

***Trimming consumption p95
gen pc_hhdr_raw = pc_hhdr

forvalues x=1(1)32 {
	display `x'
	_pctile pc_hhdr if district == `x', p(95) 
	replace pc_hhdr = . if (pc_hhdr > r(r1)) & district == `x' 
}

g ln_pcconsexp=ln(pc_hhdr)
g ln_pcconsexp_raw=ln(pc_hhdr_raw)

ihstrans pc_hhdr, p(ihs_)
ihstrans pc_hhdr_raw, p(ihs_)


***Now selecting the poorest 50% HH in the EA
egen locp50 = pctile(pc_hhdr) , by(ea_id) p(50) 
g poorest50=(pc_hhdr<=locp50)

egen locp50raw = pctile(pc_hhdr_raw) , by(ea_id) p(50) 
g poorest50raw=(pc_hhdr_raw<=locp50raw)

***Creating quintiles 
/* Programs included: Input for work programme, School feeding program, Food/cash fro work program, MASAF-Public Work program, Direct cash transfer from government*/
egen quintile = xtile(pc_hhdr_raw), n(5) by(ea_id)
tab quintile receive, row nof // share of HH that receive transfers by quintile
 
 
label var overcrwd "Household overcrowding"
label var wall_improved "House with improved walls"
label var roof_improved "House with improved roof"
label var floor_improved "House with improved floor"
label var flushtoilet "Access to flush toilet"
label var ownhouse "House owner"
label var elec_hh "Fuel lighting: electricity"
label var cook_hh "Fuel cooking: firewood"
label var water_hh "Access topiped water"
label var depen_old "Aged dependency ratio"
label var depen_ch "Child dependency ratio"
label var eduyr_fem "Ave.years of education women 15-64 y/o"
label var eduyr_men "Ave.years of education men 15-64 y/o"
label var eduyr_hh "Ave.years of education HH head"
label var literacy_hh "HH head literacy"
label var mprim_maxed "Highest educated men attained primary"
label var msec_maxed "Highest educated men attained secondary"
label var mter_maxed "Highest educated men attained tertiary"
label var fprim_maxed "Highest educated women attained primary"
label var fsec_maxed "Highest educated women attained secondary"
label var fter_maxed "Highest educated women attained tertiary"
label var prim_edhh "HH head attained primary"
label var sec_edhh "HH head  attained secondary"
label var ter_edhh "HH head attained tertiary"
label var hhsize2 "Household size (squared)"

****************************************************************************************
***Globals for regressions using satellite data

forvalues i=15(1)18 {
rename ltype_median_`i' tltype_median_`i'
g ltype_median_`i'=tltype_median_`i'
}

forvalues i=15(1)18 {
label var crops_mean_`i' "% vegetation cover for cropland"
label var grass_mean_`i' "% vegetation cover for grass"
label var moss_mean_`i' "% vegetation cover for moss"
label var shrub_mean_`i' "% vegetation cover for shrub"
label var bare_mean_`i' "% vegetation cover for bare-sparce vegetation"
label var waterperm_mean_`i' "% ground cover for permanent water"
label var waterseas_mean_`i' "% ground cover for seasonal water"
label var urban_mean_`i' "% ground cover for built-up land cover class"
label var ltype_median_`i' "Land Cover Type"
label var precyr`i' "Seasonal precipitation (mm/h)"
label var ndviyr`i' "Normalized Difference Vegetation Index"
label var ndwiyr`i' "Normalized Difference Water Index"
label var soilyr`i' "Surface soil moisture (mm)"
label var nightlyr`i' "Average DNB radiance values"
}

forvalues i=15(1)18 {
label var precseas`i' "Seasonal precipitation (mm/h)"
label var ndviseas`i' "Normalized Difference Vegetation Index"
label var ndwiseas`i' "Normalized Difference Water Index"
label var soilseas`i' "Surface soil moisture (mm)"
}

forvalues i=15(1)18 {
tab ltype_median_`i', g(ltype_`i'_)
}

rename ltype_15_6 ltype_15_12
rename ltype_16_6 ltype_16_12
rename ltype_17_6 ltype_17_12
rename ltype_18_6 ltype_18_12

rename ltype_15_7 ltype_15_13
rename ltype_16_7 ltype_16_13
rename ltype_17_7 ltype_17_13
rename ltype_18_7 ltype_18_13

rename ltype_15_8 ltype_15_14
rename ltype_16_8 ltype_16_14
rename ltype_17_8 ltype_17_14
rename ltype_18_8 ltype_18_14

forvalues i=15(1)18 {
label var ltype_`i'_12 "If in a grid 50% croplands"
label var ltype_`i'_13 "If in a grid 50% urban and build-up" 
label var ltype_`i'_14 "If in a grid 50% croplands/natural vegetation mosaics" 
}

***Historical means and stdev.
foreach name in prec ndvi ndwi {
egen hist_`name'=rmean(h`name'_mean_* )
}

foreach name in prec ndvi ndwi {
egen stdev_`name'=rowsd(h`name'_mean_* )
}

***Calculating deviations from the mean in prec, ndvi, ndwi
foreach name in prec ndvi ndwi {
forvalues i=15(1)18 {
g devmean_`name'`i'=`name'yr`i'-hist_`name'
g zscore_`name'`i'=(`name'yr`i'-hist_`name')/stdev_`name'
}
}

forvalues i=15(1)18 {
label var devmean_prec`i' "Deviation of hist.mean prec"
label var devmean_ndvi`i' "Deviation of hist.mean ndvi"
label var devmean_ndwi`i' "Deviation of hist.mean ndwi"
}

forvalues i=16(1)18 {
label var zscore_prec`i' "z-score for prec"
label var zscore_ndvi`i' "z-score for ndvi"
label var zscore_ndwi`i' "z-score for ndwi"
}

***Dummy for pervious to impervious
g ch_10_18=(mean_yr_change>=1 & mean_yr_change<=9)
g ch_09_00=(mean_yr_change>=10 & mean_yr_change<=19)
g ch_99_90=(mean_yr_change>=20 & mean_yr_change<=29)
g ch_89_85=(mean_yr_change>=30 & mean_yr_change<=64)

label var ch_10_18 "If changed pervious to impervious in 2010-2018"
label var ch_09_00 "If changed pervious to impervious in 2000-2009"
label var ch_99_90 "If changed pervious to impervious in 1990-1999"
label var ch_89_85 "If changed pervious to impervious in 1985-1989"


***Rename to general names to use in different models with different datasets
rename urban_mean_15 urban_mean_lag
rename crops_mean_15 crops_mean_lag
rename zscore_prec15 zscore_prec_lag
rename zscore_ndwi15 zscore_ndwi_lag
rename precyr15 precyr_lag
rename ndwiyr15 ndwiyr_lag
rename waterperm_mean_15 waterperm_mean_lag
rename waterseas_mean_15 waterseas_mean_lag
rename zscore_ndvi15 zscore_ndvi_lag
rename ndviyr15 ndviyr_lag
rename soilyr15 soilyr_lag
rename grass_mean_15 grass_mean_lag
rename shrub_mean_15 shrub_mean_lag
rename bare_mean_15 bare_mean_lag
rename ltype_15_12 ltype_12_lag
rename ltype_15_13 ltype_13_lag
rename ltype_15_14 ltype_14_lag
rename nightlyr15  nightlyr_lag
rename pdensity15_mean  pdensity_mean_lag
rename BSG15_mean BSG_mean_lag
rename moss_mean_15 moss_mean_lag

rename urban_mean_16 urban_mean
rename crops_mean_16 crops_mean
rename zscore_prec16 zscore_prec
rename zscore_ndwi16 zscore_ndwi
rename precyr16 precyr
rename ndwiyr16 ndwiyr
rename waterperm_mean_16 waterperm_mean
rename waterseas_mean_16 waterseas_mean
rename zscore_ndvi16 zscore_ndvi
rename ndviyr16 ndviyr
rename soilyr16 soilyr
rename grass_mean_16 grass_mean
rename shrub_mean_16 shrub_mean
rename bare_mean_16 bare_mean
rename ltype_16_12 ltype_12
rename ltype_16_13 ltype_13
rename ltype_16_14 ltype_14
rename nightlyr16  nightlyr
rename pdensity16_mean  pdensity_mean
rename BSG16_mean BSG_mean
rename moss_mean_16 moss_mean

save "Survey/Updated results/IHS_proc.dta", replace

***Collapse at village level
preserve
collapse (mean) ln_pcconsexp ln_pcconsexp_raw *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove computer oxcart bcycle mcycle car radio television urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean moss_mean shrub_mean bare_mean nightlyr density cv_area cv_length mean_barea mean_blength  sh_urban dist_roads_mean pdensity_mean pdensity_mean_lag BSG_mean BSG_mean_lag mean_rwi urban_mean_lag crops_mean_lag zscore_prec_lag zscore_ndwi_lag precyr_lag ndwiyr_lag waterperm_mean_lag waterseas_mean_lag zscore_ndvi_lag ndviyr_lag soilyr_lag grass_mean_lag moss_mean_lag  shrub_mean_lag bare_mean_lag nightlyr_lag ch_10_18 ch_09_00 ch_99_90 ch_89_85 count tot_barea tot_blength district q_asset_1 q_asset_2 q_asset_3 q_asset_4 q_asset_5 q_asset_6 q_asset_7 q_asset_8 electricity2 (median) ltype_12 ltype_13 ltype_14 ltype_12_lag ltype_13_lag ltype_14_lag (max) UBR all /*(p80) ID */, by(ea_id)
save "Survey/Updated results\IHS_satell_trad_vill.dta", replace
restore

preserve
collapse (mean) ln_pcconsexp ln_pcconsexp_raw *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove computer oxcart bcycle mcycle car radio television urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean moss_mean shrub_mean bare_mean nightlyr density cv_area cv_length mean_barea mean_blength  sh_urban dist_roads_mean pdensity_mean pdensity_mean_lag BSG_mean BSG_mean_lag mean_rwi urban_mean_lag crops_mean_lag zscore_prec_lag zscore_ndwi_lag precyr_lag ndwiyr_lag waterperm_mean_lag waterseas_mean_lag zscore_ndvi_lag ndviyr_lag soilyr_lag grass_mean_lag moss_mean_lag  shrub_mean_lag bare_mean_lag nightlyr_lag ch_10_18 ch_09_00 ch_99_90 ch_89_85 count tot_barea tot_blength district q_asset_1 q_asset_2 q_asset_3 q_asset_4 q_asset_5 q_asset_6 q_asset_7 q_asset_8 electricity2 (median) ltype_12 ltype_13 ltype_14 ltype_12_lag ltype_13_lag ltype_14_lag (max) UBR all /*(p80) ID */ if poorest50raw==1, by(ea_id)
save "Survey/Updated results\IHS_satell_trad_vill50raw.dta", replace
restore

preserve
collapse (mean) ln_pcconsexp ln_pcconsexp_raw *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove computer oxcart bcycle mcycle car radio television urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean moss_mean shrub_mean bare_mean nightlyr density cv_area cv_length mean_barea mean_blength  sh_urban dist_roads_mean pdensity_mean pdensity_mean_lag BSG_mean BSG_mean_lag mean_rwi urban_mean_lag crops_mean_lag zscore_prec_lag zscore_ndwi_lag precyr_lag ndwiyr_lag waterperm_mean_lag waterseas_mean_lag zscore_ndvi_lag ndviyr_lag soilyr_lag grass_mean_lag moss_mean_lag  shrub_mean_lag bare_mean_lag nightlyr_lag ch_10_18 ch_09_00 ch_99_90 ch_89_85 count tot_barea tot_blength district q_asset_1 q_asset_2 q_asset_3 q_asset_4 q_asset_5 q_asset_6 q_asset_7 q_asset_8 electricity2 (median) ltype_12 ltype_13 ltype_14 ltype_12_lag ltype_13_lag ltype_14_lag (max) UBR all /*(p80) ID */ if poorest50==1, by(ea_id)
save "Survey/Updated results\IHS_satell_trad_vill50.dta", replace
restore

***Setting globals
global indepvar11="urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean moss_mean shrub_mean bare_mean ltype_12 ltype_13 ltype_14 nightlyr ch_10_18 ch_09_00 ch_99_90 ch_89_85" 
global indepvar12="count density cv_area cv_length mean_barea mean_blength tot_barea tot_blength sh_urban dist_roads_mean pdensity_mean_lag pdensity_mean BSG_mean_lag BSG_mean mean_rwi" 
global indepvar21="urban_mean_lag crops_mean_lag zscore_prec_lag zscore_ndwi_lag precyr_lag ndwiyr_lag waterperm_mean_lag waterseas_mean_lag zscore_ndvi_lag ndviyr_lag soilyr_lag grass_mean_lag moss_mean_lag shrub_mean_lag bare_mean_lag ltype_12_lag ltype_13_lag ltype_14_lag nightlyr_lag ch_10_18 ch_09_00 ch_99_90 ch_89_85"
global indepvar13="q_asset_1 q_asset_2 q_asset_3 q_asset_4 q_asset_5 q_asset_6 electricity2"

global sample="UBR" //all or UBR
local sample="$sample"
 
***Trimmed
reg ln_pcconsexp  i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'.xls",  replace drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("1.District FE")
reg ln_pcconsexp  $indepvar21 i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("2.GEE 2015+(1)")
reg ln_pcconsexp  $indepvar11 i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("3.GEE 2016+(1)")
reg ln_pcconsexp  $indepvar12 i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("4.WorldPop+(1)")
reg ln_pcconsexp  $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("5.ATLAS+(1)")
reg ln_pcconsexp  $indepvar21 $indepvar12 i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("6.(2)+(4)")
reg ln_pcconsexp  $indepvar11 $indepvar12 i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("7.(3)+(4)")
reg ln_pcconsexp  $indepvar21 $indepvar12 $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("8.(2)+(4)+(5)")
reg ln_pcconsexp  $indepvar11 $indepvar12 $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("9.(3)+(4)+(5)")

***Raw
reg ln_pcconsexp_raw  i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'.xls",  replace drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("1.District FE")
reg ln_pcconsexp_raw  $indepvar21 i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("2.GEE 2015+(1)")
reg ln_pcconsexp_raw  $indepvar11 i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("3.GEE 2016+(1)")
reg ln_pcconsexp_raw  $indepvar12 i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("4.WorldPop+(1)")
reg ln_pcconsexp_raw  $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("5.ATLAS+(1)")
reg ln_pcconsexp_raw $indepvar21 $indepvar12 i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("6.(2)+(4)")
reg ln_pcconsexp_raw  $indepvar11 $indepvar12 i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("7.(3)+(4)")
reg ln_pcconsexp_raw $indepvar21 $indepvar12 $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("8.(2)+(4)+(5)")
reg ln_pcconsexp_raw  $indepvar11 $indepvar12 $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("9.(3)+(4)+(5)")

***Checking with lasso
splitsample , generate(sample) split(.50 .50) rseed(12345)
label define slabel 1 "Training" 2 "Validation", modify
label values sample slabel

splitsample if UBR==1 , generate(sample_UBR) split(.50 .50) rseed(12345)
label define slabel2 1 "Training" 2 "Validation", modify
label values sample_UBR slabel2

***In all districts
***Trimmed
reg ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, r 
estimates store olsihs
lassogof olsihs if sample==2

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, nolog rseed(12345) 
estimates store cvihs

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, nolog rseed(12345) selection(adaptive)
estimates store adaptiveihs

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, selection(plugin) 
estimates store pluginihs

***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, r 
estimates store ols_raw
lassogof ols_raw, over(sample)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, nolog rseed(12345) 
estimates store cv_raw

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_raw

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, selection(plugin) 
estimates store plugin_raw

lassogof olsihs cvihs adaptiveihs pluginihs if sample==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS
lassogof ols_raw cv_raw adaptive_raw plugin_raw if sample==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS

***NO ATLAS
***Trimmed
reg ln_pcconsexp $indepvar11 $indepvar12  i.district if sample==1, r 
estimates store olsihs_atl
lassogof olsihs_atl if sample==2

lasso linear ln_pcconsexp $indepvar11 $indepvar12 i.district if sample==1, nolog rseed(12345) 
estimates store cvihs_atl

lasso linear ln_pcconsexp $indepvar11 $indepvar12 i.district if sample==1, nolog rseed(12345) selection(adaptive)
estimates store adaptiveihs_atl

lasso linear ln_pcconsexp $indepvar11 $indepvar12 i.district if sample==1, selection(plugin) 
estimates store pluginihs_atl

***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1, r 
estimates store ols_raw_atl
lassogof ols_raw, over(sample)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample==1, nolog rseed(12345) 
estimates store cv_raw_atl

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_raw_atl

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample==1, selection(plugin) 
estimates store plugin_raw_atl

lassogof olsihs_atl cvihs_atl adaptiveihs_atl pluginihs_atl if sample==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS
lassogof ols_raw_atl cv_raw_atl adaptive_raw_atl plugin_raw_atl if sample==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS


***In UBR districts
***Trimmed
reg ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, r 
estimates store olsihsubr
lassogof olsihsubr if  UBR==1, over(sample_UBR)

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) 
estimates store cvihsubr

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) selection(adaptive)
estimates store adaptiveihsubr

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, selection(plugin) 
estimates store pluginihsubr

***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, r 
estimates store ols_rawubr
lassogof ols_rawubr if  UBR==1, over(sample_UBR)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) 
estimates store cv_rawubr

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_rawubr

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, selection(plugin) 
estimates store plugin_rawubr

lassogof olsihsubr cvihsubr adaptiveihsubr pluginihsubr if UBR==1 & sample_UBR==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS
lassogof ols_rawubr cv_rawubr adaptive_rawubr plugin_rawubr if UBR==1 & sample_UBR==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS


***NO ATLAS
***Trimmed
reg ln_pcconsexp $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, r 
estimates store olsihsubr_at
lassogof olsihsubr_at if  UBR==1, over(sample_UBR)

lasso linear ln_pcconsexp $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) 
estimates store cvihsubr_at

lasso linear ln_pcconsexp $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) selection(adaptive)
estimates store adaptiveihsubr_at

lasso linear ln_pcconsexp $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, selection(plugin) 
estimates store pluginihsubr_at

***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, r 
estimates store ols_rawubr_at
lassogof ols_rawubr_at if  UBR==1, over(sample_UBR)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) 
estimates store cv_rawubr_at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_rawubr_at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, selection(plugin) 
estimates store plugin_rawubr_at

lassogof olsihsubr_at cvihsubr_at adaptiveihsubr_at pluginihsubr_at if UBR==1 & sample_UBR==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS
lassogof ols_rawubr_at cv_rawubr_at adaptive_rawubr_at plugin_rawubr_at if UBR==1 & sample_UBR==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS


*************************
***Poorest 50% of HH

global sample="UBR" //all or UBR
local sample="$sample"
 
***Trimmed
reg ln_pcconsexp  i.district if `sample'==1 & poorest50==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'50.xls",  replace drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("1.District FE")
reg ln_pcconsexp  $indepvar21 i.district if `sample'==1 & poorest50==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("2.GEE 2015+(1)")
reg ln_pcconsexp  $indepvar11 i.district if `sample'==1 & poorest50==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("3.GEE 2016+(1)")
reg ln_pcconsexp  $indepvar12 i.district if `sample'==1 & poorest50==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("4.WorldPop+(1)")
reg ln_pcconsexp  $indepvar13 i.district if `sample'==1 & poorest50==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("5.ATLAS+(1)")
reg ln_pcconsexp  $indepvar21 $indepvar12 i.district if `sample'==1 & poorest50==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("6.(2)+(4)")
reg ln_pcconsexp  $indepvar11 $indepvar12 i.district if `sample'==1 & poorest50==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("7.(3)+(4)")
reg ln_pcconsexp  $indepvar21 $indepvar12 $indepvar13 i.district if `sample'==1 & poorest50==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("8.(2)+(4)+(5)")
reg ln_pcconsexp  $indepvar11 $indepvar12 $indepvar13 i.district if `sample'==1 & poorest50==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("9.(3)+(4)+(5)")
***Raw
reg ln_pcconsexp_raw  i.district if `sample'==1 & poorest50raw==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'50.xls",  replace drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("1.District FE")
reg ln_pcconsexp_raw  $indepvar21 i.district if `sample'==1 & poorest50raw==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("2.GEE 2015+(1)")
reg ln_pcconsexp_raw  $indepvar11 i.district if `sample'==1 & poorest50raw==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("3.GEE 2016+(1)")
reg ln_pcconsexp_raw  $indepvar12 i.district if `sample'==1 & poorest50raw==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("4.WorldPop+(1)")
reg ln_pcconsexp_raw  $indepvar13 i.district if `sample'==1 & poorest50raw==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("5.ATLAS+(1)")
reg ln_pcconsexp_raw $indepvar21 $indepvar12 i.district if `sample'==1 & poorest50raw==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("6.(2)+(4)")
reg ln_pcconsexp_raw  $indepvar11 $indepvar12 i.district if `sample'==1 & poorest50raw==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("7.(3)+(4)")
reg ln_pcconsexp_raw $indepvar21 $indepvar12 $indepvar13 i.district if `sample'==1 & poorest50raw==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("8.(2)+(4)+(5)")
reg ln_pcconsexp_raw  $indepvar11 $indepvar12 $indepvar13 i.district if `sample'==1 & poorest50raw==1, r 
outreg2 using "Survey/Updated results\Malawi_welfare_ihsgee_raw_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("9.(3)+(4)+(5)")


***In all districts
***Trimmed
reg ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1 & poorest50==1, r 
estimates store olsihs50
lassogof olsihs50, over(sample)

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1 & poorest50==1, nolog rseed(12345) 
estimates store cvihs50

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1 & poorest50==1, nolog rseed(12345) selection(adaptive)
estimates store adaptiveihs50

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1 & poorest50==1, selection(plugin) 
estimates store pluginihs50

***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1 & poorest50raw==1, r 
estimates store ols_raw50
lassogof ols_raw50, over(sample)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1 & poorest50raw==1, nolog rseed(12345) 
estimates store cv_raw50

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1 & poorest50raw==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_raw50

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1 & poorest50raw==1, selection(plugin) 
estimates store plugin_raw50

lassogof olsihs50 cvihs50 adaptiveihs50 pluginihs50 if  poorest50==1 & sample==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS
lassogof ols_raw50 cv_raw50 adaptive_raw50 plugin_raw50 if  poorest50raw==1 & sample==2  //adaptative has the smallest MSE and largest R2 but very small difference with OLS


***NO ATLAS
***Trimmed
reg ln_pcconsexp $indepvar11 $indepvar12  i.district if sample==1 & poorest50==1, r 
estimates store olsihs50_at
lassogof olsihs50_at, over(sample)

lasso linear ln_pcconsexp $indepvar11 $indepvar12  i.district if sample==1 & poorest50==1, nolog rseed(12345) 
estimates store cvihs50_at

lasso linear ln_pcconsexp $indepvar11 $indepvar12  i.district if sample==1 & poorest50==1, nolog rseed(12345) selection(adaptive)
estimates store adaptiveihs50_at

lasso linear ln_pcconsexp $indepvar11 $indepvar12  i.district if sample==1 & poorest50==1, selection(plugin) 
estimates store pluginihs50_at

***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1 & poorest50raw==1, r 
estimates store ols_raw50_at
lassogof ols_raw50_at, over(sample)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1 & poorest50raw==1, nolog rseed(12345) 
estimates store cv_raw50_at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1 & poorest50raw==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_raw50_at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1 & poorest50raw==1, selection(plugin) 
estimates store plugin_raw50_at

lassogof olsihs50_at cvihs50_at adaptiveihs50_at pluginihs50_at if  poorest50==1 & sample==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS
lassogof ols_raw50_at cv_raw50_at adaptive_raw50_at plugin_raw50_at if  poorest50raw==1 & sample==2  //adaptative has the smallest MSE and largest R2 but very small difference with OLS


***In UBR districts
***Trimmed
reg ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 & poorest50==1, r 
estimates store olsihsubr50
lassogof olsihsubr50, over(sample_UBR)

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 & poorest50==1, nolog rseed(12345) 
estimates store cvihsubr50

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 & poorest50==1, nolog rseed(12345) selection(adaptive)
estimates store adaptiveihsubr50

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 & poorest50==1, selection(plugin) 
estimates store pluginihsubr50

***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 & poorest50raw==1, r 
estimates store ols_rawubr50
lassogof ols_raw, over(sample_UBR)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 & poorest50raw==1, nolog rseed(12345) 
estimates store cv_rawubr50

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 & poorest50raw==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_rawubr50

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 & poorest50raw==1, selection(plugin) 
estimates store plugin_rawubr50

lassogof olsihsubr50 cvihsubr50 adaptiveihsubr50 pluginihsubr50 if UBR==1 & poorest50==1 & sample_UBR==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS
lassogof ols_rawubr50 cv_rawubr50 adaptive_rawubr50 plugin_rawubr50 if UBR==1 & poorest50raw==1 & sample_UBR==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS

***NO ATLAS
***Trimmed
reg ln_pcconsexp $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 & poorest50==1, r 
estimates store olsihsubr50at
lassogof olsihsubr50at, over(sample_UBR)

lasso linear ln_pcconsexp $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 & poorest50==1, nolog rseed(12345) 
estimates store cvihsubr50at

lasso linear ln_pcconsexp $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 & poorest50==1, nolog rseed(12345) selection(adaptive)
estimates store adaptiveihsubr50at

lasso linear ln_pcconsexp $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 & poorest50==1, selection(plugin) 
estimates store pluginihsubr50at

***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 & poorest50raw==1, r 
estimates store ols_rawubr50at
lassogof ols_rawubr50at, over(sample_UBR)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 & poorest50raw==1, nolog rseed(12345) 
estimates store cv_rawubr50at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 & poorest50raw==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_rawubr50at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 & poorest50raw==1, selection(plugin) 
estimates store plugin_rawubr50at

lassogof olsihsubr50at cvihsubr50at adaptiveihsubr50at pluginihsubr50at if UBR==1 & poorest50==1 & sample_UBR==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS
lassogof ols_rawubr50at cv_rawubr50at adaptive_rawubr50at plugin_rawubr50at if UBR==1 & poorest50raw==1 & sample_UBR==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS

**********************************************************************************************************************************************
***Model at village level using satellite data
*preserve

use "Survey/Updated results\IHS_satell_trad_vill.dta", clear
global indepvar11="urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean moss_mean shrub_mean bare_mean ltype_12 ltype_13 ltype_14 nightlyr ch_10_18 ch_09_00 ch_99_90 ch_89_85" 
global indepvar12="count density cv_area cv_length mean_barea mean_blength tot_barea tot_blength sh_urban dist_roads_mean pdensity_mean_lag pdensity_mean BSG_mean_lag BSG_mean mean_rwi" 
global indepvar21="urban_mean_lag crops_mean_lag zscore_prec_lag zscore_ndwi_lag precyr_lag ndwiyr_lag waterperm_mean_lag waterseas_mean_lag zscore_ndvi_lag ndviyr_lag soilyr_lag grass_mean_lag moss_mean_lag shrub_mean_lag bare_mean_lag ltype_12_lag ltype_13_lag ltype_14_lag nightlyr_lag ch_10_18 ch_09_00 ch_99_90 ch_89_85"
global indepvar13="q_asset_1 q_asset_2 q_asset_3 q_asset_4 q_asset_5 q_asset_6 electricity2"

global sample="UBR" //all or UBR
local sample="$sample"
 
 
***Trimmed
reg ln_pcconsexp  i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'.xls",  replace drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("1.District FE")
reg ln_pcconsexp  $indepvar21 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("2.GEE 2015+(1)")
reg ln_pcconsexp  $indepvar11 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("3.GEE 2016+(1)")
reg ln_pcconsexp  $indepvar12 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("4.WorldPop+(1)")
reg ln_pcconsexp  $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("5.ATLAS+(1)")
reg ln_pcconsexp  $indepvar21 $indepvar12 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("6.(2)+(4)")
reg ln_pcconsexp  $indepvar11 $indepvar12  i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("7.(3)+(4)")
reg ln_pcconsexp  $indepvar21 $indepvar12 $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("8.(2)+(4)+(5)")
reg ln_pcconsexp  $indepvar11 $indepvar12 $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("9.(3)+(4)+(5)")

***Raw
reg ln_pcconsexp_raw  i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_raw`sample'.xls",  replace drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("1.District FE")
reg ln_pcconsexp_raw  $indepvar21 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_raw`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("2.GEE 2015+(1)")
reg ln_pcconsexp_raw  $indepvar11 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_raw`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("3.GEE 2016+(1)")
reg ln_pcconsexp_raw  $indepvar12 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_raw`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("4.WorldPop+(1)")
reg ln_pcconsexp_raw  $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_raw`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("5.ATLAS+(1)")
reg ln_pcconsexp_raw  $indepvar21 $indepvar12 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_raw`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("6.(2)+(4)")
reg ln_pcconsexp_raw  $indepvar11 $indepvar12  i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_raw`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("7.(3)+(4)")
reg ln_pcconsexp_raw  $indepvar21 $indepvar12 $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_raw`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("8.(2)+(4)+(5)")
reg ln_pcconsexp_raw  $indepvar11 $indepvar12 $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_raw`sample'.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("9.(3)+(4)+(5)")


***Checking with lasso
splitsample , generate(sample) split(.50 .50) rseed(12345)
label define slabel 1 "Training" 2 "Validation", modify
label values sample slabel

splitsample if UBR==1 , generate(sample_UBR) split(.5 .5) rseed(12345)
label define slabel2 1 "Training" 2 "Validation", modify
label values sample_UBR slabel2

***In all districts
***Trimmed
reg ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, r 
estimates store olsihs
lassogof olsihs if sample==2

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, nolog rseed(12345) 
estimates store cvihs
lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =29
cvplot
estimates store minBICihs

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, nolog rseed(12345) selection(adaptive)
estimates store adaptiveihs

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, selection(plugin) 
estimates store pluginihs


***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, r 
estimates store ols_raw
lassogof ols_raw, over(sample)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, nolog rseed(12345) 
estimates store cv_raw
lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =21
cvplot
estimates store minBICihs_raw

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_raw

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, selection(plugin) 
estimates store plugin_raw

lassogof olsihs cvihs adaptiveihs pluginihs minBICihs if sample==2, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS
lassogof ols_raw cv_raw adaptive_raw plugin_raw minBICihs_raw if sample==2, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS

***NO ATLAS
***Trimmed
reg ln_pcconsexp $indepvar11 $indepvar12  i.district if sample==1, r 
estimates store olsihs_atl
lassogof olsihs_atl if sample==2

lasso linear ln_pcconsexp $indepvar11 $indepvar12 i.district if sample==1, nolog rseed(12345) 
estimates store cvihs_atl
lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =24
cvplot
estimates store minBICihs_atl

lasso linear ln_pcconsexp $indepvar11 $indepvar12 i.district if sample==1, nolog rseed(12345) selection(adaptive)
estimates store adaptiveihs_atl

lasso linear ln_pcconsexp $indepvar11 $indepvar12 i.district if sample==1, selection(plugin) 
estimates store pluginihs_atl

***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1, r 
estimates store ols_raw_atl
lassogof ols_raw, over(sample)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample==1, nolog rseed(12345) 
estimates store cv_raw_atl
lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =25
cvplot
estimates store minBICihs_raw_atl

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_raw_atl

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample==1, selection(plugin) 
estimates store plugin_raw_atl

lassogof olsihs_atl cvihs_atl adaptiveihs_atl pluginihs_atl minBICihs_atl if sample==2, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS
lassogof ols_raw_atl cv_raw_atl adaptive_raw_atl plugin_raw_atl minBICihs_raw_atl if sample==2, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS


***In UBR districts
***Trimmed
reg ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, r 
estimates store olsihsubr
lassogof olsihsubr if  UBR==1, over(sample_UBR)

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) 
estimates store cvihsubr
lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =10
cvplot
estimates store minBICihsubr

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) selection(adaptive)
estimates store adaptiveihsubr

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, selection(plugin) 
estimates store pluginihsubr

***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, r 
estimates store ols_rawubr
lassogof ols_rawubr if  UBR==1, over(sample_UBR)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) 
estimates store cv_rawubr
lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =16
cvplot
estimates store minBICihs_rawubr

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_rawubr

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, selection(plugin) 
estimates store plugin_rawubr

lassogof olsihsubr cvihsubr adaptiveihsubr pluginihsubr minBICihsubr if UBR==1 & sample_UBR==2, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS
lassogof ols_rawubr cv_rawubr adaptive_rawubr plugin_rawubr minBICihs_rawubr if UBR==1 & sample_UBR==2, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS


***NO ATLAS
***Trimmed
reg ln_pcconsexp $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, r 
estimates store olsihsubr_at
lassogof olsihsubr_at if  UBR==1, over(sample_UBR)

lasso linear ln_pcconsexp $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) 
estimates store cvihsubr_at
lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =11
cvplot
estimates store minBICihsubr_at

lasso linear ln_pcconsexp $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) selection(adaptive)
estimates store adaptiveihsubr_at

lasso linear ln_pcconsexp $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, selection(plugin) 
estimates store pluginihsubr_at

***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, r 
estimates store ols_rawubr_at
lassogof ols_rawubr_at if  UBR==1, over(sample_UBR)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) 
estimates store cv_rawubr_at
lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =17
cvplot
estimates store minBICihs_rawubr_at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_rawubr_at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, selection(plugin) 
estimates store plugin_rawubr_at

lassogof olsihsubr_at cvihsubr_at adaptiveihsubr_at pluginihsubr_at minBICihsubr_at if UBR==1 & sample_UBR==2, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS
lassogof ols_rawubr_at cv_rawubr_at adaptive_rawubr_at plugin_rawubr_at minBICihs_rawubr_at if UBR==1 & sample_UBR==2, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS

*restore

***Final models: Models with full sample, better the adaptive. Models only with UBR districts: min BIC but R2 [10,15], so not good. Best models include ATLAS, so ignore no ATLAS
lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, nolog rseed(12345) selection(adaptive)
estimates store final_adapihs_vill
*predict predcons_satell_allvill
lassogof final_adapihs_vill if sample==2, postselection

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) selection(adaptive)
estimates store final_adapihsubr_vill
*predict predcons_satell_ubrvill
lassogof final_adapihsubr_vill if sample_UBR==2 & UBR==1, postselection

***Correlation with the true data
corr ln_pcconsexp_raw predcons_satell_allvill predcons_satell_ubrvill
spearman ln_pcconsexp_raw predcons_satell_allvill
spearman ln_pcconsexp_raw predcons_satell_ubrvill

preserve
keep ln_pcconsexp_raw predcons_satell_allvill predcons_satell_ubrvill ea_id district
save "Survey/Updated results\predictions_all_satell.dta", replace
restore



*****************************************
***Poorest 50 raw
***Raw values
*preserve
use "Survey/Updated results\IHS_satell_trad_vill50raw.dta", clear
global indepvar11="urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean moss_mean shrub_mean bare_mean ltype_12 ltype_13 ltype_14 nightlyr ch_10_18 ch_09_00 ch_99_90 ch_89_85" 
global indepvar12="count density cv_area cv_length mean_barea mean_blength tot_barea tot_blength sh_urban dist_roads_mean pdensity_mean_lag pdensity_mean BSG_mean_lag BSG_mean mean_rwi" 
global indepvar21="urban_mean_lag crops_mean_lag zscore_prec_lag zscore_ndwi_lag precyr_lag ndwiyr_lag waterperm_mean_lag waterseas_mean_lag zscore_ndvi_lag ndviyr_lag soilyr_lag grass_mean_lag moss_mean_lag shrub_mean_lag bare_mean_lag ltype_12_lag ltype_13_lag ltype_14_lag nightlyr_lag ch_10_18 ch_09_00 ch_99_90 ch_89_85"
global indepvar13="q_asset_1 q_asset_2 q_asset_3 q_asset_4 q_asset_5 q_asset_6 electricity2"

global sample="UBR" //all or UBR
local sample="$sample"

 ***Raw
reg ln_pcconsexp_raw  i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50raw.xls",  replace drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("1.District FE")
reg ln_pcconsexp_raw  $indepvar21 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50raw.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("2.GEE 2015+(1)")
reg ln_pcconsexp_raw  $indepvar11 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50raw.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("3.GEE 2016+(1)")
reg ln_pcconsexp_raw  $indepvar12 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50raw.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("4.WorldPop+(1)")
reg ln_pcconsexp_raw  $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50raw.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("5.ATLAS+(1)")
reg ln_pcconsexp_raw  $indepvar21 $indepvar12 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50raw.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("6.(2)+(4)")
reg ln_pcconsexp_raw  $indepvar11 $indepvar12 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50raw.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("7.(3)+(4)")
reg ln_pcconsexp_raw  $indepvar21 $indepvar12 $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50raw.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("8.(2)+(4)+(5)")
reg ln_pcconsexp_raw  $indepvar11 $indepvar12 $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50raw.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("9.(3)+(4)+(5)")

***Checking with lasso
splitsample , generate(sample) split(.50 .50) rseed(12345)
label define slabel 1 "Training" 2 "Validation", modify
label values sample slabel

splitsample if UBR==1 , generate(sample_UBR) split(.5 .5) rseed(12345)
label define slabel2 1 "Training" 2 "Validation", modify
label values sample_UBR slabel2


***In all districts
***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, r 
estimates store ols_raw50
lassogof ols_raw50, over(sample)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, nolog rseed(12345) 
estimates store cv_raw50
lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =22
cvplot
estimates store minBIC_raw50

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_raw50

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, selection(plugin) 
estimates store plugin_raw50


***NO ATLAS
***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1, r 
estimates store ols_raw50_at
lassogof ols_raw50_at, over(sample)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1, nolog rseed(12345) 
estimates store cv_raw50_at
lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =27
cvplot
estimates store minBIC_raw50_at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_raw50_at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1, selection(plugin) 
estimates store plugin_raw50_at

lassogof ols_raw50 cv_raw50 adaptive_raw50 plugin_raw50 minBIC_raw50 if   sample==2, postselection  //adaptative has the smallest MSE and largest R2 but very small difference with OLS
lassogof ols_raw50_at cv_raw50_at adaptive_raw50_at plugin_raw50_at minBIC_raw50_at if   sample==2, postselection  //adaptative has the smallest MSE and largest R2 but very small difference with OLS


***In UBR districts
***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 , r 
estimates store ols_rawubr50
lassogof ols_raw, over(sample_UBR)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 , nolog rseed(12345) 
estimates store cv_rawubr50
lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =11
cvplot
estimates store minBIC_rawubr50

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 , nolog rseed(12345) selection(adaptive)
estimates store adaptive_rawubr50

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 , selection(plugin) 
estimates store plugin_rawubr50


***NO ATLAS
***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 , r 
estimates store ols_rawubr50at
lassogof ols_rawubr50at, over(sample_UBR)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 , nolog rseed(12345) 
estimates store cv_rawubr50at
lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =13
cvplot
estimates store minBIC_rawubr50at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 , nolog rseed(12345) selection(adaptive)
estimates store adaptive_rawubr50at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 , selection(plugin) 
estimates store plugin_rawubr50at

lassogof ols_rawubr50 cv_rawubr50 adaptive_rawubr50 plugin_rawubr50 minBIC_rawubr50 if UBR==1 &  sample_UBR==2, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS
lassogof ols_rawubr50at cv_rawubr50at adaptive_rawubr50at plugin_rawubr50at minBIC_rawubr50at if UBR==1 &  sample_UBR==2, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS


***Final models: Models with full sample, better the adaptive. Models only with UBR districts: min BIC but R2 around 10, so not good. Best models include ATLAS, so ignore no ATLAS
lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample==1, nolog rseed(12345) selection(adaptive)
estimates store final_adapihs_vill50
*predict predcons_satell_allvill50, xb
lassogof final_adapihs_vill50 if sample==2, postselection

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 , nolog rseed(12345) selection(adaptive)
estimates store final_adapihsubr_vill50
*predict predcons_satell_ubrvill50, xb
lassogof final_adapihsubr_vill50 if sample_UBR==2, postselection

***Correlation with the true data
corr ln_pcconsexp_raw predcons_satell_allvill50 predcons_satell_ubrvill50
spearman ln_pcconsexp_raw predcons_satell_allvill50
spearman ln_pcconsexp_raw predcons_satell_ubrvill50

preserve
rename ln_pcconsexp_raw  ln_pcconsexp_raw50 
keep ln_pcconsexp_raw50 predcons_satell_allvill50 predcons_satell_ubrvill50 ea_id district
save "Survey/Updated results\predictions_all50_satell.dta", replace
restore


*restore

***************************
/* activate it if need to check. Otherwise these ones are not used
***Trimmed
*preserve
use "Survey/Updated results\IHS_satell_trad_vill50.dta", clear
global indepvar11="urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean moss_mean shrub_mean bare_mean ltype_12 ltype_13 ltype_14 nightlyr ch_10_18 ch_09_00 ch_99_90 ch_89_85" 
global indepvar12="count density cv_area cv_length mean_barea mean_blength tot_barea tot_blength sh_urban dist_roads_mean pdensity_mean_lag pdensity_mean BSG_mean_lag BSG_mean mean_rwi" 
global indepvar21="urban_mean_lag crops_mean_lag zscore_prec_lag zscore_ndwi_lag precyr_lag ndwiyr_lag waterperm_mean_lag waterseas_mean_lag zscore_ndvi_lag ndviyr_lag soilyr_lag grass_mean_lag moss_mean_lag shrub_mean_lag bare_mean_lag ltype_12_lag ltype_13_lag ltype_14_lag nightlyr_lag ch_10_18 ch_09_00 ch_99_90 ch_89_85"
global indepvar13="q_asset_1 q_asset_2 q_asset_3 q_asset_4 q_asset_5 q_asset_6 electricity2"

global sample="UBR" //all or UBR
local sample="$sample"

***Raw
reg ln_pcconsexp  i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50.xls",  replace drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("1.District FE")
reg ln_pcconsexp $indepvar21 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("2.GEE 2015+(1)")
reg ln_pcconsexp  $indepvar11 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("3.GEE 2016+(1)")
reg ln_pcconsexp  $indepvar12 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("4.WorldPop+(1)")
reg ln_pcconsexp  $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("5.ATLAS+(1)")
reg ln_pcconsexp  $indepvar21 $indepvar12 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("6.(2)+(4)")
reg ln_pcconsexp  $indepvar11 $indepvar12 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("7.(3)+(4)")
reg ln_pcconsexp  $indepvar21 $indepvar12 $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("8.(2)+(4)+(5)")
reg ln_pcconsexp  $indepvar11 $indepvar12 $indepvar13 i.district if `sample'==1, r 
outreg2 using "Survey\Updated results\Malawi_welfare_ihsgeevill_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) nonotes label ctitle("9.(3)+(4)+(5)")

***Checking with lasso
splitsample , generate(sample) split(.50 .50) rseed(12345)
label define slabel 1 "Training" 2 "Validation", modify
label values sample slabel

splitsample if UBR==1 , generate(sample_UBR) split(.5 .5) rseed(12345)
label define slabel2 1 "Training" 2 "Validation", modify
label values sample_UBR slabel2


***In all districts
***Trimmed
reg ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1 , r 
estimates store olsihs50
lassogof olsihs50, over(sample)

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1 , nolog rseed(12345) 
estimates store cvihs50
lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =23
cvplot
estimates store minBICihs50

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1 , nolog rseed(12345) selection(adaptive)
estimates store adaptiveihs50

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1 , selection(plugin) 
estimates store pluginihs50

***NO ATLAS
***Trimmed
reg ln_pcconsexp $indepvar11 $indepvar12  i.district if sample==1 , r 
estimates store olsihs50_at
lassogof olsihs50_at, over(sample)

lasso linear ln_pcconsexp $indepvar11 $indepvar12  i.district if sample==1 , nolog rseed(12345) 
estimates store cvihs50_at

lasso linear ln_pcconsexp $indepvar11 $indepvar12  i.district if sample==1 , nolog rseed(12345) selection(adaptive)
estimates store adaptiveihs50_at
lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =88
cvplot
estimates store minBICihs50_at

lasso linear ln_pcconsexp $indepvar11 $indepvar12  i.district if sample==1 , selection(plugin) 
estimates store pluginihs50_at

lassogof olsihs50 cvihs50 adaptiveihs50 pluginihs50 minBICihs50 if   sample==2, postselection  //adaptative has the smallest MSE and largest R2 but very small difference with OLS
lassogof olsihs50_at cvihs50_at adaptiveihs50_at pluginihs50_at minBICihs50_at if   sample==2, postselection  //adaptative has the smallest MSE and largest R2 but very small difference with OLS

***In UBR districts
***Trimmed
reg ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 , r 
estimates store olsihsubr50
lassogof olsihsubr50, over(sample_UBR)

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 , nolog rseed(12345) 
estimates store cvihsubr50
lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =6
cvplot
estimates store minBICihsubr50

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 , nolog rseed(12345) selection(adaptive)
estimates store adaptiveihsubr50

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 , selection(plugin) 
estimates store pluginihsubr50

***NO ATLAS
***Trimmed
reg ln_pcconsexp $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 , r 
estimates store olsihsubr50at
lassogof olsihsubr50at, over(sample_UBR)

lasso linear ln_pcconsexp $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 , nolog rseed(12345) 
estimates store cvihsubr50at
lassoknots, display(nonzero osr2 bic) // not valid bc only one varibale selected in the min BIC
*lassoselect id =6
*cvplot
*estimates store minBICihsubr50

lasso linear ln_pcconsexp $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 , nolog rseed(12345) selection(adaptive)
estimates store adaptiveihsubr50at

lasso linear ln_pcconsexp $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 , selection(plugin) 
estimates store pluginihsubr50at

lassogof olsihsubr50 cvihsubr50 adaptiveihsubr50 pluginihsubr50 minBICihsubr50 if   sample_UBR==2,postselection  //adaptative has the smallest MSE and largest R2 but very small difference with OLS
lassogof olsihsubr50at cvihsubr50at adaptiveihsubr50at pluginihsubr50at if   sample_UBR==2, postselection  //adaptative has the smallest MSE and largest R2 but very small difference with OLS

***Final models: Models with full sample, better the adaptive. Models only with UBR districts: min BIC but R2 around 10, so not good. Best models include ATLAS, so ignore no ATLAS
lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample==1 , nolog rseed(12345) selection(adaptive)
estimates store final_adapihs_vill50

lasso linear ln_pcconsexp $indepvar11 $indepvar12 $indepvar13 i.district if sample_UBR==1 & UBR==1 , nolog rseed(12345) selection(adaptive) //best with UBR districts, min BIC not valid here,
estimates store final_adapihs_vill50ubr

*restore
*/
******************************************************************************************
******************************************************************************************
***Predict consumption in census: using adaptive models full sample and ubr sample with raw consumption. Poorest 50, using minBIC models raw full sample and ubr sample with raw consumption. Not using poorest 50 trimmed.
***Using model with traditional data
use "Census\Census_satellite_data.dta", clear 

estimates restore final_adapihs_vill // all districts
predict predcons_satell_allvill, xb postselection

estimates restore final_adapihsubr_vill //best with UBR districts
predict predcons_satell_ubrvill, xb postselection

estimates restore final_adapihs_vill50 //all distrcits with 50% poorest HH
predict predcons_satell_allvill50, xb postselection

estimates restore final_adapihsubr_vill50 //best with UBR districts with 50% poorest HH
predict predcons_satell_ubrvill50, xb postselection

keep id_tagvnvill predcons_satell_allvill predcons_satell_ubrvill predcons_satell_allvill50 predcons_satell_ubrvill50

save "Census/Updated results/predcons_satellite_UBRvillage.dta", replace


******************************************************************************************************************************************************
***Welfare model with traditional data
use "Survey/Updated results/IHS_proc.dta", clear

/* Dependent variable: log(consumption per capita)
   Determinants: education of the HH head (dummies or number of years), literacy, demographic composition of the HH (dependency ratios)
   household size (adjusted), house ownership, basic services, assets.
*/

global indepvar11="*_maxed literacy_hh hhsize hhsize2 overcrwd rururb" 
global indepvar12="*_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch" 
global indepvar13="*_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet" 
global indepvar14="*_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved" 
global indepvar15="*_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove computer"
global indepvar16="*_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove computer oxcart bcycle mcycle car radio television"

/*
global indepvar21="*_edhh eduyr_fem eduyr_men hhsize hhsize2 rururb overcrwd" 
global indepvar22="*_edhh eduyr_fem eduyr_men hhsize hhsize2 rururb overcrwd depen_old depen_ch" 
global indepvar23="*_edhh eduyr_fem eduyr_men hhsize hhsize2 rururb overcrwd depen_old depen_ch cook_hh water_hh flushtoilet" 
global indepvar24="*_edhh eduyr_fem eduyr_men hhsize hhsize2 rururb overcrwd depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved"
global indepvar25="*_edhh eduyr_fem eduyr_men hhsize hhsize2 rururb overcrwd depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove computer"
*/
global sample="UBR" //all or UBR
local sample="$sample"

reg ln_pcconsexp_raw $indepvar11 i.district if `sample'==1, r
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\Malawi_welfare_`sample'_g1.xls",  replace adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, No, Basic services, No, House characteristics, No, Assets, No)  nonotes label ctitle(" ")
reg ln_pcconsexp_raw $indepvar12 i.district if `sample'==1, r
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\Malawi_welfare_`sample'_g1.xls",  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, No, House characteristics, No, Assets, No)  nonotes label ctitle(" ")
reg ln_pcconsexp_raw $indepvar13 i.district if `sample'==1, r //elec_hh was omitted for multicolinearity so I  removed it
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\Malawi_welfare_`sample'_g1.xls",  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, No, Assets, No)  nonotes label ctitle(" ")
reg ln_pcconsexp_raw $indepvar14 i.district if `sample'==1, r 
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\Malawi_welfare_`sample'_g1.xls",  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, Yes, Assets, No)  nonotes label ctitle(" ")
reg ln_pcconsexp_raw $indepvar15 i.district if `sample'==1, r 
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\Malawi_welfare_`sample'_g1.xls",  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, Yes, Assets, Yes)  nonotes label ctitle(" ")
reg ln_pcconsexp_raw $indepvar16 i.district if `sample'==1, r 
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\Malawi_welfare_`sample'_g1.xls",  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, Yes, Assets, Yes)  nonotes label ctitle(" ")

/*
***Using hyperbolica transformation (se obtiene los mismos resultados)
local sample="$sample"

reg ihs_pc_hhdr $indepvar11 i.district if `sample'==1, r
local Ftest=e(F)
local obs=e(N)
outreg2 using Malawi_welfare_`sample'_g1ihs.xls,  replace adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, No, Basic services, No, House characteristics, No, Assets, No)  nonotes label ctitle(" ")
reg ihs_pc_hhdr $indepvar12 i.district if `sample', r
local Ftest=e(F)
local obs=e(N)
outreg2 using Malawi_welfare_`sample'_g1ihs.xls,  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, No, House characteristics, No, Assets, No)  nonotes label ctitle(" ")
reg ihs_pc_hhdr $indepvar13 i.district if `sample', r //elec_hh was omitted for multicolinearity so I  removed it
local Ftest=e(F)
local obs=e(N)
outreg2 using Malawi_welfare_`sample'_g1ihs.xls,  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, No, Assets, No)  nonotes label ctitle(" ")
reg ihs_pc_hhdr $indepvar14 i.district if `sample', r 
local Ftest=e(F)
local obs=e(N)
outreg2 using Malawi_welfare_`sample'_g1ihs.xls,  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, Yes, Assets, No)  nonotes label ctitle(" ")
reg ihs_pc_hhdr $indepvar15 i.district if `sample', r 
local Ftest=e(F)
local obs=e(N)
outreg2 using Malawi_welfare_`sample'_g1ihs.xls,  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, Yes, Assets, Yes)  nonotes label ctitle(" ")
reg ihs_pc_hhdr $indepvar16 i.district if `sample', r 
local Ftest=e(F)
local obs=e(N)
outreg2 using Malawi_welfare_`sample'_g1ihs.xls,  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, Yes, Assets, Yes)  nonotes label ctitle(" ")
*/

***Poorest 50%
global sample="UBR" //all or UBR
local sample="$sample"

reg ln_pcconsexp $indepvar11 i.district if `sample'==1 & poorest50==1, r
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\Malawi_welfare_`sample'_g1_50p.xls",  replace adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, No, Basic services, No, House characteristics, No, Assets, No)  nonotes label ctitle(" ")
reg ln_pcconsexp $indepvar12 i.district if `sample'==1 & poorest50==1, r
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\Malawi_welfare_`sample'_g1_50p.xls",  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, No, House characteristics, No, Assets, No)  nonotes label ctitle(" ")
reg ln_pcconsexp $indepvar13 i.district if `sample'==1 & poorest50==1, r //elec_hh was omitted for multicolinearity so I  removed it
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\Malawi_welfare_`sample'_g1_50p.xls",  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, No, Assets, No)  nonotes label ctitle(" ")
reg ln_pcconsexp $indepvar14 i.district if `sample'==1 & poorest50==1, r 
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\Malawi_welfare_`sample'_g1_50p.xls",  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, Yes, Assets, No)  nonotes label ctitle(" ")
reg ihs_pc_hhdr $indepvar15 i.district if `sample'==1 & poorest50==1, r 
*local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\Malawi_welfare_`sample'_g1_50p.xls",  append /*adds("F-statistic",`Ftest')*/ drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, Yes, Assets, Yes)  nonotes label ctitle(" ")
reg ln_pcconsexp $indepvar16 i.district if `sample'==1 & poorest50==1, r 
*local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\Malawi_welfare_`sample'_g1_50p.xls",  append /*adds("F-statistic",`Ftest')*/ drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, Yes, Assets, Yes)  nonotes label ctitle(" ")


***************************
***Lasso regressions
***generating training and validation samples for Lasso regressions
***Full sample all districts
splitsample , generate(sample1) split(.5 .5) rseed(12345)
label define slabel 1 "Training" 2 "Validation", modify
label values sample1 slabel
tabulate sample1
***Full sample UBR districts
splitsample if UBR==1, generate(sample2) split(.5 .5) rseed(12345)
label define slabel 1 "Training" 2 "Validation", modify
label values sample2 slabel
tabulate sample2
***Full sample, poorest 50% all districts
splitsample if poorest50raw==1, generate(sample3) split(.5 .5) rseed(12345)
label define slabel 1 "Training" 2 "Validation", modify
label values sample3 slabel
tabulate sample3
***Full sample, poorest 50% in UBR districts
splitsample if poorest50raw==1 & UBR==1, generate(sample4) split(.5 .5) rseed(12345)
label define slabel 1 "Training" 2 "Validation", modify
label values sample4 slabel
tabulate sample4

***Full sample all districts
reg ln_pcconsexp_raw $indepvar16 i.district if sample1==1, r 
estimates store ols
lassogof ols, over(sample1)

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample1==1, nolog rseed(12345) cluster(district)
estimates store cv
lassocoef cv, display(coef, postselection)
lassogof cv, over(sample1)  postselection

*lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
*lassoselect id =75 //same as CV
cvplot
*estimates store minBIC

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample1==1, nolog rseed(12345) selection(adaptive)
estimates store adaptivefv
lassocoef adaptivefv, display(coef, postselection)
lassogof adaptivefv, over(sample1)  postselection

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample1==1, selection(plugin)
estimates store plugin

*lassogof ols cv adaptative plugin minBIC if sample1==2 
lassogof ols cv adaptivefv plugin if sample1==2, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS

***Full sample UBR districts
reg ln_pcconsexp_raw $indepvar16 i.district if sample2==1 & UBR==1, r 
estimates store olsubr
lassogof ols, over(sample2)

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample2==1 & UBR==1, nolog rseed(12345) cluster(district)
estimates store cvubr
lassocoef cvubr, display(coef, postselection)
lassogof cvubr, over(sample2)  postselection

*lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
*lassoselect id =74 //same as CV
*cvplot
*estimates store minBICubr

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample2==1 & UBR==1, nolog rseed(12345) selection(adaptive)
estimates store adaptiveubrfv
lassocoef adaptiveubrfv, display(coef, postselection)
lassogof adaptiveubrfv if UBR==1, over(sample2)  postselection


lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample2==1 & UBR==1, selection(plugin)
estimates store pluginubr

*lassogof olsubr cvubr adaptiveubr pluginubr minBICubr if sample2==2 & UBR==1
lassogof olsubr cvubr adaptiveubrfv pluginubr  if sample2==2 & UBR==1, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS

***Poorest 50% HH-all districts
reg ln_pcconsexp_raw $indepvar16 i.district if sample3==1 & poorest50raw==1, r 
estimates store ols50
lassogof ols50, over(sample3)

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample3==1 & poorest50raw==1, nolog rseed(12345) cluster(district)
estimates store cv50
lassocoef cv50, display(coef, postselection)
lassogof cv50, over(sample3)  postselection

/*lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =51
cvplot
estimates store minBIC50*/

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample3==1 & poorest50raw==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive50fv

lassocoef adaptive50fv, display(coef, postselection)
lassogof adaptive50fv if  poorest50raw==1, over(sample3)  postselection

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample3==1 & poorest50raw==1, selection(plugin)
estimates store plugin50

*lassogof ols50 cv50 adaptive50 plugin50 minBIC50 if sample3==2 & poorest50==1
lassogof ols50 cv50 adaptive50fv plugin50 if sample3==2 & poorest50raw==1, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS

***Poorest 50% HH-UBR districts
reg ln_pcconsexp_raw $indepvar16 i.district if sample4==1 & poorest50raw==1 & UBR==1, r 
estimates store olsubr50
lassogof olsubr50, over(sample4)

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample4==1 & poorest50raw==1 & UBR==1, nolog rseed(12345) cluster(district)
estimates store cvubr50
lassocoef cvubr50, display(coef, postselection)
lassogof cvubr50, over(sample4)  postselection

/*lassoknots, display(nonzero osr2 bic) //to select model with the lowest BIC 
lassoselect id =22
cvplot
estimates store minBICubr50*/

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample4==1 & poorest50raw==1 & UBR==1, nolog rseed(12345) selection(adaptive)
estimates store adaptiveubr50fv
lassocoef adaptiveubr50fv, display(coef, postselection)
lassogof adaptiveubr50fv if  poorest50raw==1 & UBR==1, over(sample4)  postselection


lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample4==1 & poorest50raw==1 & UBR==1, selection(plugin)
estimates store pluginubr50

*lassogof olsubr50 cvubr50 adaptiveubr50 pluginubr50 minBICubr50 if sample4==2 & poorest50==1 & UBR==1
lassogof olsubr50 cvubr50 adaptiveubr50fv pluginubr50  if sample4==2 & poorest50raw==1 & UBR==1, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS

*********************************************
*** Final models 
***Full sample all districts
estimates restore cv
predict predcons_ihs_cvfull, postselection

***Full sample UBR districts
estimates restore cvubr
predict predcons_ihs_cvubr, postselection

***Poorest 50 all districts
estimates restore cv50
predict predcons_ihs_cv50, postselection

***Poorest 50 UBR districts
estimates restore cvubr50
predict predcons_ihs_cvubr50, postselection

corr predcons_ihs_cvfull ln_pcconsexp_raw 
corr predcons_ihs_cvubr ln_pcconsexp_raw //if UBR==1
corr predcons_ihs_cv50 ln_pcconsexp_raw //if poorest50==1
corr predcons_ihs_cvubr50 ln_pcconsexp_raw //if UBR==1 & poorest50==1

reg predcons_ihs_cvfull ln_pcconsexp_raw 
reg predcons_ihs_cvubr ln_pcconsexp_raw //if UBR==1
reg predcons_ihs_cv50 ln_pcconsexp_raw //if poorest50==1
reg predcons_ihs_cvubr50 ln_pcconsexp_raw //if UBR==1 & poorest50==1


***************************************************************************************
***Predict consumption in census
***Using model with traditional data

use "UBR\Updated results\UBR_proc_village_level.dta", clear
keep id_tagvnvill pmt* richbetter_vill poorsh_vill poorersh_vill poorestsh_vill richsh_vill
tempfile pmt_vill
save `pmt_vill'

use "Census\census_proc_full", clear 
rename full_ta_code tacode_census
rename VILLAGE_NAME village_name
rename GVH_NAME gvh_name

drop if gvh_name==""
drop if village_name==""

merge m:1 tacode_census using "Census/TA_codes.dta"
keep if _merge==3
drop _merge
drop if taubr==""

*** Cleaning variable for group village name
rename gvh_name gvh_name_orig
g gvh_name0=strlower(gvh_name_orig)
g gvh_name1=strrtrim(gvh_name0)
g gvh_name2=ustrltrim(gvh_name1)
g gvh_name=subinstr(gvh_name2,"'","",.)
replace gvh_name=subinstr(gvh_name,"`","",.)

*** Cleaning variable for village name
rename village_name village_name_orig
g vill_name0=strlower(village_name_orig)
g vill_name1=strrtrim(vill_name0)
g vill_name2=ustrltrim(vill_name1)
g village_name=subinstr(vill_name2,"'","",.)
replace village_name=subinstr(village_name,"`","",.)
replace village_name=subinstr(village_name,"_","",.)


egen id_ta_gvh=concat(taubr gvh_name), punct("_")
egen id_ta_gvh_num=group(taubr gvh_name)

egen id_tagvnvill=concat(id_ta_gvh village_name), punct("_")
egen id_tagvnvill_num=group(id_ta_gvh village_name)

***Predict in the census using previous models
***Full sample all districts
estimates restore cv
predict predcons_ihs_cvfull, postselection

***Full sample UBR districts
estimates restore cvubr
predict predcons_ihs_cvubr, postselection

***Poorest 50 all districts
estimates restore cv50
predict predcons_ihs_cv50, postselection

***Poorest 50 UBR districts
estimates restore cvubr50
predict predcons_ihs_cvubr50, postselection


corr predcons_ihs_cvfull predcons_ihs_cvubr predcons_ihs_cv50 predcons_ihs_cvubr50 

sort district id_tagvnvill
g line_id=_n

save "Census/census_predcons_measures.dta", replace

***Merging with GEE data (only for matched villages)
*merge m:1 id_tagvnvill using "census_GEE.dta"
merge m:1 id_tagvnvill using "Census/census_GEE2.dta"

preserve 
g id_merge=(_merge==3)

***number of HH in the village
bys id_tagvnvill: gen hhnum_vill=_N

collapse (mean)  *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove computer oxcart bcycle mcycle car radio television id_merge hhnum_vill district, by(id_tagvnvill)

global vars="mprim_maxed msec_maxed mter_maxed fprim_maxed fsec_maxed fter_maxed literacy_hh hhsize overcrwd  depen_old depen_ch cook_hh water_hh flushtoilet ownhouse wall_improved roof_improved floor_improved cellphone fridge stove computer oxcart bcycle mcycle car radio television"
foreach var in $vars {
	ttest `var', by(id_merge)
	return list
	local um_`var'=r(mu_1) //mu_1 unmerged
	local m_`var'=r(mu_2)
	local p_`var'=r(p) 
}

putexcel set "merged_unmerged_incensus", replace

putexcel A2="Highest educated man: primary education"
putexcel A3="Highest educated man: secondary education"
putexcel A4="Highest educated man: tertiary education"
putexcel A5="Highest educated woman: primary education"
putexcel A6="Highest educated woman: secondary education"
putexcel A7="Highest educated woman: tertiary education"
putexcel A8="Literacy of the household head"
putexcel A9="Household size"
putexcel A10="Overcrowding"
putexcel A11="Elderly dependency ratio"
putexcel A12="Children dependency ratio"
putexcel A13="Firewood for cooking"
putexcel A14="Access to pipe water"
putexcel A15="Access to flush toilet"
putexcel A16="Share of HH that own a house"
putexcel A17="Share of HH with improved walls"
putexcel A18="Share of HH with improved roof"
putexcel A19="Share of HH with improved floor"
putexcel A20="Share of HH with cellphone"
putexcel A21="Share of HH with fridge"
putexcel A22="Share of HH with stove"
putexcel A23="Share of HH with computer"
putexcel A24="Share of HH with oxcart"
putexcel A25="Share of HH with bycicle"
putexcel A26="Share of HH with motocycle"
putexcel A27="Share of HH with car"
putexcel A28="Share of HH with radio"
putexcel A29="Share of HH with television"

            
putexcel C2=`m_mprim_maxed'
putexcel D2=`um_mprim_maxed'
putexcel E2=`p_mprim_maxed'

putexcel C3=`m_msec_maxed'
putexcel D3=`um_msec_maxed'
putexcel E3=`p_msec_maxed'

putexcel C4=`m_mter_maxed'
putexcel D4=`um_mter_maxed'
putexcel E4=`p_mter_maxed'

putexcel C5=`m_fprim_maxed'
putexcel D5=`um_fprim_maxed'
putexcel E5=`p_fprim_maxed'

putexcel C6=`m_fsec_maxed'
putexcel D6=`um_fsec_maxed'
putexcel E6=`p_fsec_maxed'

putexcel C7=`m_fter_maxed'
putexcel D7=`um_fter_maxed'
putexcel E7=`p_fter_maxed'

putexcel C8=`m_literacy_hh'
putexcel D8=`um_literacy_hh'
putexcel E8=`p_literacy_hh'

putexcel C9=`m_hhsize'
putexcel D9=`um_hhsize'
putexcel E9=`p_hhsize'

putexcel C10=`m_overcrwd'
putexcel D10=`um_overcrwd'
putexcel E10=`p_overcrwd'

putexcel C11=`m_depen_old'
putexcel D11=`um_depen_old'
putexcel E11=`p_depen_old'

putexcel C12=`m_depen_ch'
putexcel D12=`um_depen_ch'
putexcel E12=`p_depen_ch'
          
putexcel C13=`m_cook_hh'
putexcel D13=`um_cook_hh'
putexcel E13=`p_cook_hh'

putexcel C14=`m_water_hh'
putexcel D14=`um_water_hh'
putexcel E14=`p_water_hh'

putexcel C15=`m_flushtoilet'
putexcel D15=`um_flushtoilet'
putexcel E15=`p_flushtoilet'

putexcel C16=`m_ownhouse'
putexcel D16=`um_ownhouse'
putexcel E16=`p_ownhouse'

putexcel C17=`m_wall_improved'
putexcel D17=`um_wall_improved'
putexcel E17=`p_wall_improved'

putexcel C18=`m_roof_improved'
putexcel D18=`um_roof_improved'
putexcel E18=`p_roof_improved'

putexcel C19=`m_floor_improved'
putexcel D19=`um_floor_improved'
putexcel E19=`p_floor_improved'

putexcel C20=`m_cellphone'
putexcel D20=`um_cellphone'
putexcel E20=`p_cellphone'

putexcel C21=`m_fridge'
putexcel D21=`um_fridge'
putexcel E21=`p_fridge'

putexcel C22=`m_stove'
putexcel D22=`um_stove'
putexcel E22=`p_stove'

putexcel C23=`m_computer'
putexcel D23=`um_computer'
putexcel E23=`p_computer'

putexcel C24=`m_oxcart'
putexcel D24=`um_oxcart'
putexcel E24=`p_oxcart'

putexcel C25=`m_bcycle'
putexcel D25=`um_bcycle'
putexcel E25=`p_bcycle'

putexcel C26=`m_mcycle'
putexcel D26=`um_mcycle'
putexcel E26=`p_mcycle'

putexcel C27=`m_car'
putexcel D27=`um_car'
putexcel E27=`p_car'

putexcel C28=`m_radio'
putexcel D28=`um_radio'
putexcel E28=`p_radio'

putexcel C29=`m_television'
putexcel D29=`um_television'
putexcel E29=`p_television'

***Using regression
foreach var in $vars {
reg `var' id_merge [w= hhnum_vill], r cl( district)
estadd ysumm
local p_`var'=e(ymean)
return list
mat A=r(table)
local m_`var'=A[1,1]
local um_`var'=A[4,1]
}

putexcel set "merged_unmerged_incensus_regression", replace

putexcel A2="Highest educated man: primary education"
putexcel A3="Highest educated man: secondary education"
putexcel A4="Highest educated man: tertiary education"
putexcel A5="Highest educated woman: primary education"
putexcel A6="Highest educated woman: secondary education"
putexcel A7="Highest educated woman: tertiary education"
putexcel A8="Literacy of the household head"
putexcel A9="Household size"
putexcel A10="Overcrowding"
putexcel A11="Elderly dependency ratio"
putexcel A12="Children dependency ratio"
putexcel A13="Firewood for cooking"
putexcel A14="Access to pipe water"
putexcel A15="Access to flush toilet"
putexcel A16="Share of HH that own a house"
putexcel A17="Share of HH with improved walls"
putexcel A18="Share of HH with improved roof"
putexcel A19="Share of HH with improved floor"
putexcel A20="Share of HH with cellphone"
putexcel A21="Share of HH with fridge"
putexcel A22="Share of HH with stove"
putexcel A23="Share of HH with computer"
putexcel A24="Share of HH with oxcart"
putexcel A25="Share of HH with bycicle"
putexcel A26="Share of HH with motocycle"
putexcel A27="Share of HH with car"
putexcel A28="Share of HH with radio"
putexcel A29="Share of HH with television"

            
putexcel C2=`m_mprim_maxed'
putexcel D2=`um_mprim_maxed'
putexcel E2=`p_mprim_maxed'

putexcel C3=`m_msec_maxed'
putexcel D3=`um_msec_maxed'
putexcel E3=`p_msec_maxed'

putexcel C4=`m_mter_maxed'
putexcel D4=`um_mter_maxed'
putexcel E4=`p_mter_maxed'

putexcel C5=`m_fprim_maxed'
putexcel D5=`um_fprim_maxed'
putexcel E5=`p_fprim_maxed'

putexcel C6=`m_fsec_maxed'
putexcel D6=`um_fsec_maxed'
putexcel E6=`p_fsec_maxed'

putexcel C7=`m_fter_maxed'
putexcel D7=`um_fter_maxed'
putexcel E7=`p_fter_maxed'

putexcel C8=`m_literacy_hh'
putexcel D8=`um_literacy_hh'
putexcel E8=`p_literacy_hh'

putexcel C9=`m_hhsize'
putexcel D9=`um_hhsize'
putexcel E9=`p_hhsize'

putexcel C10=`m_overcrwd'
putexcel D10=`um_overcrwd'
putexcel E10=`p_overcrwd'

putexcel C11=`m_depen_old'
putexcel D11=`um_depen_old'
putexcel E11=`p_depen_old'

putexcel C12=`m_depen_ch'
putexcel D12=`um_depen_ch'
putexcel E12=`p_depen_ch'
          
putexcel C13=`m_cook_hh'
putexcel D13=`um_cook_hh'
putexcel E13=`p_cook_hh'

putexcel C14=`m_water_hh'
putexcel D14=`um_water_hh'
putexcel E14=`p_water_hh'

putexcel C15=`m_flushtoilet'
putexcel D15=`um_flushtoilet'
putexcel E15=`p_flushtoilet'

putexcel C16=`m_ownhouse'
putexcel D16=`um_ownhouse'
putexcel E16=`p_ownhouse'

putexcel C17=`m_wall_improved'
putexcel D17=`um_wall_improved'
putexcel E17=`p_wall_improved'

putexcel C18=`m_roof_improved'
putexcel D18=`um_roof_improved'
putexcel E18=`p_roof_improved'

putexcel C19=`m_floor_improved'
putexcel D19=`um_floor_improved'
putexcel E19=`p_floor_improved'

putexcel C20=`m_cellphone'
putexcel D20=`um_cellphone'
putexcel E20=`p_cellphone'

putexcel C21=`m_fridge'
putexcel D21=`um_fridge'
putexcel E21=`p_fridge'

putexcel C22=`m_stove'
putexcel D22=`um_stove'
putexcel E22=`p_stove'

putexcel C23=`m_computer'
putexcel D23=`um_computer'
putexcel E23=`p_computer'

putexcel C24=`m_oxcart'
putexcel D24=`um_oxcart'
putexcel E24=`p_oxcart'

putexcel C25=`m_bcycle'
putexcel D25=`um_bcycle'
putexcel E25=`p_bcycle'

putexcel C26=`m_mcycle'
putexcel D26=`um_mcycle'
putexcel E26=`p_mcycle'

putexcel C27=`m_car'
putexcel D27=`um_car'
putexcel E27=`p_car'

putexcel C28=`m_radio'
putexcel D28=`um_radio'
putexcel E28=`p_radio'

putexcel C29=`m_television'
putexcel D29=`um_television'
putexcel E29=`p_television'

restore

keep if _merge==3 //4716 villages
drop _merge

***Merge with pmt score in UBR
merge m:1 id_tagvnvill using `pmt_vill'
keep if _merge==3 //4716 villages
drop _merge

*save "census_GEE_consumption.dta", replace
save "Census/census_GEE_consumption2.dta", replace

*****************************************************************************************************
*****************************************************************************************************
***Using a model at village level using traditional data 
use "Survey/Updated results\IHS_satell_trad_vill.dta", clear

global indepvar11="*_maxed literacy_hh hhsize hhsize2 overcrwd rururb" 
global indepvar12="*_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch" 
global indepvar13="*_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet" 
global indepvar14="*_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved" 
global indepvar15="*_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove computer"
global indepvar16="*_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove computer oxcart bcycle mcycle car radio television"

global sample="UBR" //all or UBR
local sample="$sample"

reg ln_pcconsexp_raw $indepvar11 i.district if `sample'==1, r
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\model_traditional_vill_`sample'.xls",  replace adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, No, Basic services, No, House characteristics, No, Assets, No)  nonotes label ctitle(" ")
reg ln_pcconsexp_raw $indepvar12 i.district if `sample'==1, r
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\model_traditional_vill_`sample'.xls",  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, No, House characteristics, No, Assets, No)  nonotes label ctitle(" ")
reg ln_pcconsexp_raw $indepvar13 i.district if `sample'==1, r //elec_hh was omitted for multicolinearity so I  removed it
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\model_traditional_vill_`sample'.xls",  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, No, Assets, No)  nonotes label ctitle(" ")
reg ln_pcconsexp_raw $indepvar14 i.district if `sample'==1, r 
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\model_traditional_vill_`sample'.xls",  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, Yes, Assets, No)  nonotes label ctitle(" ")
reg ln_pcconsexp_raw $indepvar15 i.district if `sample'==1, r 
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\model_traditional_vill_`sample'.xls",  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, Yes, Assets, Yes)  nonotes label ctitle(" ")
reg ln_pcconsexp_raw $indepvar16 i.district if `sample'==1, r 
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\model_traditional_vill_`sample'.xls",  append adds("F-statistic",`Ftest') drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, Yes, Assets, Yes)  nonotes label ctitle(" ")

***Checking with LASSO models
***Full sample all districts
splitsample , generate(sample1) split(.5 .5) rseed(12345)
label define slabel 1 "Training" 2 "Validation", modify
label values sample1 slabel
tabulate sample1
***Full sample UBR districts
splitsample if UBR==1, generate(sample2) split(.5 .5) rseed(12345)
label define slabel 1 "Training" 2 "Validation", modify
label values sample2 slabel
tabulate sample2

***Full sample all districts
reg ln_pcconsexp_raw $indepvar16 i.district if sample1==1, r 
estimates store ols_v
lassogof ols_v, over(sample1)

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample1==1, nolog rseed(12345)
estimates store cv_v

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample1==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_v

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample1==1, selection(plugin)
estimates store plugin_v

lassogof ols_v cv_v adaptive_v plugin_v if sample1==2 
lassogof ols_v cv_v adaptive_v plugin_v if sample1==2, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS

***Full sample UBR districts
reg ln_pcconsexp_raw $indepvar16 i.district if sample2==1 & UBR==1, r 
estimates store ols2_v
lassogof ols2_v, over(sample2)

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample2==1 & UBR==1, nolog rseed(12345)
estimates store cv2_v

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample2==1 & UBR==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive2_v

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample2==1 & UBR==1, selection(plugin)
estimates store plugin2_v

lassogof ols2_v cv2_v adaptive2_v plugin2_v if sample2==2 & UBR==1
lassogof ols2_v cv2_v adaptive2_v plugin2_v if sample2==2 & UBR==1, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS

***Final models
reg ln_pcconsexp_raw $indepvar16 i.district if all==1, r 
estimates store ols_allfinal
predict predcons_tradi_allvill, xb

reg ln_pcconsexp_raw $indepvar16 i.district if UBR==1, r 
estimates store ols_ubrfinal
predict predcons_tradi_ubrvill, xb

***Correlation with the true data
corr ln_pcconsexp_raw predcons_tradi_allvill predcons_tradi_ubrvill
spearman ln_pcconsexp_raw predcons_tradi_allvill
spearman ln_pcconsexp_raw predcons_tradi_ubrvill

preserve
keep ln_pcconsexp_raw predcons_tradi_allvill predcons_tradi_ubrvill ea_id district
save "Survey/Updated results\predictions_all_tradi.dta", replace
restore

******************************************
***Raw poorest
use "Survey/Updated results\IHS_satell_trad_vill50raw.dta", clear

global indepvar11="*_maxed literacy_hh hhsize hhsize2 overcrwd rururb" 
global indepvar12="*_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch" 
global indepvar13="*_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet" 
global indepvar14="*_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved" 
global indepvar15="*_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove computer"
global indepvar16="*_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove computer oxcart bcycle mcycle car radio television"

global sample="UBR" //all or UBR
local sample="$sample"

reg ln_pcconsexp_raw $indepvar11 i.district if `sample'==1, r
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\model_traditional_vill_`sample'50.xls",  replace  drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, No, Basic services, No, House characteristics, No, Assets, No)  nonotes label ctitle(" ")
reg ln_pcconsexp_raw $indepvar12 i.district if `sample'==1, r
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\model_traditional_vill_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, No, House characteristics, No, Assets, No)  nonotes label ctitle(" ")
reg ln_pcconsexp_raw $indepvar13 i.district if `sample'==1, r //elec_hh was omitted for multicolinearity so I  removed it
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\model_traditional_vill_`sample'50.xls",  append drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, No, Assets, No)  nonotes label ctitle(" ")
reg ln_pcconsexp_raw $indepvar14 i.district if `sample'==1, r 
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\model_traditional_vill_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, Yes, Assets, No)  nonotes label ctitle(" ")
reg ln_pcconsexp_raw $indepvar15 i.district if `sample'==1, r 
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\model_traditional_vill_`sample'50.xls",  append drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, Yes, Assets, Yes)  nonotes label ctitle(" ")
reg ln_pcconsexp_raw $indepvar16 i.district if `sample'==1, r 
local Ftest=e(F)
local obs=e(N)
outreg2 using "Survey\Updated results\model_traditional_vill_`sample'50.xls",  append  drop(i.district) tex(pretty landscape) dec(3) addtext(Basic model, Yes, Dependency, Yes, Basic services, Yes, House characteristics, Yes, Assets, Yes)  nonotes label ctitle(" ")

***Checking with LASSO models
***Full sample all districts
splitsample , generate(sample1) split(.75 .25) rseed(12345)
label define slabel 1 "Training" 2 "Validation", modify
label values sample1 slabel
tabulate sample1
***Full sample UBR districts
splitsample if UBR==1, generate(sample2) split(.5 .5) rseed(12345)
label define slabel 1 "Training" 2 "Validation", modify
label values sample2 slabel
tabulate sample2

***Full sample all districts
reg ln_pcconsexp_raw $indepvar16 i.district if sample1==1, r 
estimates store ols_v50
lassogof ols_v50, over(sample1)

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample1==1, nolog rseed(12345)
estimates store cv_v50

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample1==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_v50

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample1==1, selection(plugin)
estimates store plugin_v50

lassogof ols_v50 cv_v50 adaptive_v50 plugin_v50 if sample1==2 
lassogof ols_v50 cv_v50 adaptive_v50 plugin_v50 if sample1==2, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS

***Full sample UBR districts
reg ln_pcconsexp_raw $indepvar16 i.district if sample2==1 & UBR==1, r 
estimates store ols2_v50
lassogof ols2_v50, over(sample2)

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample2==1 & UBR==1, nolog rseed(12345)
estimates store cv2_v50

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample2==1 & UBR==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive2_v50

lasso linear ln_pcconsexp_raw $indepvar16 i.district if sample2==1 & UBR==1, selection(plugin)
estimates store plugin2_v50

lassogof ols2_v50 cv2_v50 adaptive2_v50 plugin2_v50 if sample2==2 & UBR==1
lassogof ols2_v50 cv2_v50 adaptive2_v50 plugin2_v50 if sample2==2 & UBR==1, postselection //adaptative has the smallest MSE and largest R2 but very small difference with OLS

***Final models
reg ln_pcconsexp_raw $indepvar16 i.district if all==1, r 
estimates store ols_allfinal50
predict predcons_tradi_allvill50, xb

reg ln_pcconsexp_raw $indepvar16 i.district if UBR==1, r 
estimates store ols_ubrfinal50
predict predcons_tradi_ubrvill50, xb

***Correlation with the true data
corr ln_pcconsexp_raw predcons_tradi_allvill50 predcons_tradi_ubrvill50
spearman ln_pcconsexp_raw predcons_tradi_allvill50
spearman ln_pcconsexp_raw predcons_tradi_ubrvill50

preserve
rename ln_pcconsexp_raw  ln_pcconsexp_raw50 
keep ln_pcconsexp_raw50 predcons_tradi_allvill50 predcons_tradi_ubrvill50 ea_id district UBR
save "Survey/Updated results\predictions_all50_tradi.dta", replace
restore

***Comparing all the predictions with the actual measument of consumption
use "Survey/Updated results\predictions_all_satell.dta", clear
merge 1:1 ea_id using "Survey/Updated results\predictions_all50_satell.dta"
drop _merge
merge 1:1 ea_id using "Survey/Updated results\predictions_all_tradi.dta"
drop _merge
merge 1:1 ea_id using "Survey/Updated results\predictions_all50_tradi.dta"
drop _merge

corr ln_pcconsexp_raw predcons_satell_allvill predcons_satell_ubrvill
corr ln_pcconsexp_raw predcons_satell_allvill50 predcons_satell_ubrvill50
corr ln_pcconsexp_raw predcons_tradi_allvill predcons_tradi_ubrvill
corr ln_pcconsexp_raw predcons_tradi_allvill50 predcons_tradi_ubrvill50

***Correlations between true and predicted variables

***All HH
spearman ln_pcconsexp_raw predcons_satell_allvill
	local sarho=r(rho)
	local sap=r(p)
	local saN=r(N)
spearman ln_pcconsexp_raw predcons_satell_ubrvill if UBR==1
	local surho=r(rho)
	local sup=r(p)
	local suN=r(N)
spearman ln_pcconsexp_raw predcons_tradi_allvill
	local tarho=r(rho)
	local tap=r(p)
	local taN=r(N)
spearman ln_pcconsexp_raw predcons_tradi_ubrvill if UBR==1
	local turho=r(rho)
	local tup=r(p)
	local tuN=r(N)
***Only poorest 50% HH
spearman ln_pcconsexp_raw50 predcons_satell_allvill50
	local sa50rho=r(rho)
	local sa50p=r(p)
	local sa50N=r(N)
spearman ln_pcconsexp_raw50 predcons_satell_ubrvill50 if UBR==1
	local su50rho=r(rho)
	local su50p=r(p)
	local su50N=r(N)
spearman ln_pcconsexp_raw50 predcons_tradi_allvill50
	local ta50rho=r(rho)
	local ta50p=r(p)
	local ta50N=r(N)
spearman ln_pcconsexp_raw50 predcons_tradi_ubrvill50 if UBR==1
	local tu50rho=r(rho)
	local tu50p=r(p)
	local tu50N=r(N)
	
putexcel set "Survey\Updated results\correlations_precited_true", replace

putexcel A1="Correlations between true and predicted consumption (at village level). The agreggation was made averaging the variables of all households in the village"

putexcel A2="Predicted variable using model with all districts"
putexcel A5="Predicted variable using model with UBR districts"
putexcel B1="Model with satellite data"
putexcel B2=`sarho'
putexcel B3=`sap'
putexcel B4=`saN'
putexcel B5=`surho'
putexcel B6=`sup'
putexcel B7=`suN'
putexcel C1="Model with traditional data"
putexcel C2=`tarho'
putexcel C3=`tap'
putexcel C4=`taN'
putexcel C5=`turho'
putexcel C6=`tup'
putexcel C7=`tuN'

putexcel E1="Correlations between true and predicted consumption (at village level). The agreggation was made averaging the variables of the poorest 50% of households in the village"

putexcel E2="Predicted variable using model with all districts"
putexcel E5="Predicted variable using model with UBR districts"
putexcel F1="Model with satellite data"
putexcel F2=`sa50rho'
putexcel F3=`sa50p'
putexcel F4=`sa50N'
putexcel F5=`su50rho'
putexcel F6=`su50p'
putexcel F7=`su50N'
putexcel G1="Model with traditional data"
putexcel G2=`ta50rho'
putexcel G3=`ta50p'
putexcel G4=`ta50N'
putexcel G5=`tu50rho'
putexcel G6=`tu50p'
putexcel G7=`tu50N'

***Correlations between two predicted variables
***All HH
spearman predcons_tradi_allvill predcons_satell_allvill
	local starho=r(rho)
	local stap=r(p)
	local staN=r(N)
spearman predcons_tradi_ubrvill predcons_satell_ubrvill if UBR==1
	local sturho=r(rho)
	local stup=r(p)
	local stuN=r(N)
***Only poorest 50% HH
spearman predcons_tradi_allvill50 predcons_satell_allvill50
	local sta50rho=r(rho)
	local sta50p=r(p)
	local sta50N=r(N)
spearman predcons_tradi_ubrvill50 predcons_satell_ubrvill50 if UBR==1
	local stu50rho=r(rho)
	local stu50p=r(p)
	local stu50N=r(N)


putexcel set "Survey\Updated results\correlations_precited_satell_tradi", replace

putexcel A1="Correlations between the predicted consumption variables using models with satellite data and traditional data(at village level)"

putexcel A2="Predicted variable using model with all districts"
putexcel A5="Predicted variable using model with UBR districts"
putexcel B1="Agregation at village level including all HH"
putexcel B2=`starho'
putexcel B3=`stap'
putexcel B4=`staN'
putexcel B5=`sturho'
putexcel B6=`stup'
putexcel B7=`stuN'
putexcel C1="Agregation at village level including poorest 50% of HH"
putexcel C2=`sta50rho'
putexcel C3=`sta50p'
putexcel C4=`sta50N'
putexcel C5=`stu50rho'
putexcel C6=`stu50p'
putexcel C7=`stu50N'


***************************************************************************************
***Predict consumption in census
***Using model with traditional data
use "Census\census_proc_full", clear 
rename full_ta_code tacode_census
rename VILLAGE_NAME village_name
rename GVH_NAME gvh_name

drop if gvh_name==""
drop if village_name==""

merge m:1 tacode_census using "Census/TA_codes.dta"
keep if _merge==3
drop _merge
drop if taubr==""

*** Cleaning variable for group village name
rename gvh_name gvh_name_orig
g gvh_name0=strlower(gvh_name_orig)
g gvh_name1=strrtrim(gvh_name0)
g gvh_name2=ustrltrim(gvh_name1)
g gvh_name=subinstr(gvh_name2,"'","",.)
replace gvh_name=subinstr(gvh_name,"`","",.)

*** Cleaning variable for village name
rename village_name village_name_orig
g vill_name0=strlower(village_name_orig)
g vill_name1=strrtrim(vill_name0)
g vill_name2=ustrltrim(vill_name1)
g village_name=subinstr(vill_name2,"'","",.)
replace village_name=subinstr(village_name,"`","",.)
replace village_name=subinstr(village_name,"_","",.)


egen id_ta_gvh=concat(taubr gvh_name), punct("_")
egen id_ta_gvh_num=group(taubr gvh_name)

egen id_tagvnvill=concat(id_ta_gvh village_name), punct("_")
egen id_tagvnvill_num=group(id_ta_gvh village_name)

***I can collapse only using the total number of households because I cannot get the poorest 50% without a welfare measure. Also, this is only for UBR districts since the TA codes are coded only for those districts.
collapse (mean) *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove computer oxcart bcycle mcycle car radio television district (max) UBR all, by(id_tagvnvill)

***Poorest 50% traditional data
estimates restore ols_allfinal
predict predcons_tradi_allvill, xb

estimates restore ols_ubrfinal
predict predcons_tradi_ubrvill, xb

estimates restore ols_allfinal50
predict predcons_tradi_allvill50, xb

estimates restore ols_ubrfinal50
predict predcons_tradi_ubrvill50, xb

keep id_tagvnvill predcons_tradi_allvill predcons_tradi_allvill50 predcons_tradi_ubrvill predcons_tradi_ubrvill50

save "Census/Updated results/predcons_traditional_UBRvillage.dta", replace

****************************************************
****Data for xgboost
***Benchmark model
***All districts-allHH
use "Survey/Updated results/IHS_proc.dta", clear

tab district, g(district_d)

keep district *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge ///
stove computer oxcart bcycle mcycle car radio television district_d1-district_d9 ln_pcconsexp_raw

order *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove ///
computer oxcart bcycle mcycle car radio television district_d1-district_d9 district ln_pcconsexp_raw

saveold "Survey/Updated results/IHS_full_R.dta", replace v(12)

***All districts-50 poorest HH
use "Survey/Updated results/IHS_proc.dta", clear

keep if poorest50==1
tab district, g(district_d)

keep district *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge ///
stove computer oxcart bcycle mcycle car radio television district_d1-district_d9 ln_pcconsexp_raw

order *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove ///
computer oxcart bcycle mcycle car radio television district_d1-district_d9 district ln_pcconsexp_raw

saveold "Survey/Updated results/IHS_full50_R.dta", replace v(12)

***UBR districts-all HH
use "Survey/Updated results/IHS_proc.dta", clear

keep if UBR==1
tab district, g(district_d)

keep district *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge ///
stove computer oxcart bcycle mcycle car radio television district_d1-district_d9 ln_pcconsexp_raw

order *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove ///
computer oxcart bcycle mcycle car radio television district_d1-district_d9 district ln_pcconsexp_raw

saveold "Survey/Updated results/IHS_ubr_R.dta", replace v(12)

***UBR districts-50 poorest HH
use "Survey/Updated results/IHS_proc.dta", clear

keep if UBR==1 & poorest50==1
tab district, g(district_d)

keep district *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge ///
stove computer oxcart bcycle mcycle car radio television district_d1-district_d9 ln_pcconsexp_raw

order *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove ///
computer oxcart bcycle mcycle car radio television district_d1-district_d9 district ln_pcconsexp_raw

saveold "Survey/Updated results/IHS_ubr50_R.dta", replace v(12)

****************************************************
****Data for xgboost
*** IHS model updated model 4
***All districts-allHH
*global indepvar13="q_asset_1 q_asset_2 q_asset_3 q_asset_4 q_asset_5 q_asset_6 electricity2"

use "Survey/Updated results/IHS_proc.dta", clear

tab district, g(district_d)

keep district urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean shrub_mean bare_mean ltype_12 ///
ltype_13 ltype_14 nightlyr ch_10_18 ch_09_00 ch_99_90 ch_89_85 count density cv_area cv_length mean_barea mean_blength tot_barea tot_blength sh_urban dist_roads_mean pdensity_mean_lag ///
pdensity_mean BSG_mean mean_rwi district_d1-district_d9 ln_pcconsexp_raw

order count density cv_area cv_length mean_barea mean_blength tot_barea tot_blength sh_urban dist_roads_mean pdensity_mean pdensity_mean_lag BSG_mean mean_rwi ///
urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean shrub_mean bare_mean ltype_12 ///
ltype_13 ltype_14 nightlyr ch_10 ch_09_00 ch_99_90 ch_89_85 district_d1-district_d9 district ln_pcconsexp_raw

saveold "Survey/Updated results/IHS_satellfull_R.dta", replace v(12)

***All districts-50 poorest HH
use "Survey/Updated results/IHS_proc.dta", clear

keep if poorest50==1
tab district, g(district_d)

keep district urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean shrub_mean bare_mean ltype_12 ///
ltype_13 ltype_14 nightlyr ch_10_18 ch_09_00 ch_99_90 ch_89_85 count density cv_area cv_length mean_barea mean_blength tot_barea tot_blength sh_urban dist_roads_mean pdensity_mean_lag ///
pdensity_mean BSG_mean mean_rwi district_d1-district_d9 ln_pcconsexp_raw

order count density cv_area cv_length mean_barea mean_blength tot_barea tot_blength sh_urban dist_roads_mean pdensity_mean pdensity_mean_lag BSG_mean mean_rwi ///
urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean shrub_mean bare_mean ltype_12 ///
ltype_13 ltype_14 nightlyr ch_10 ch_09_00 ch_99_90 ch_89_85 district_d1-district_d9 district ln_pcconsexp_raw

saveold "Survey/Updated results/IHS_satellfull50_R.dta", replace v(12)

***UBR districts-all HH
use "Survey/Updated results/IHS_proc.dta", clear

keep if UBR==1
tab district, g(district_d)

keep district urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean shrub_mean bare_mean ltype_12 ///
ltype_13 ltype_14 nightlyr ch_10_18 ch_09_00 ch_99_90 ch_89_85 count density cv_area cv_length mean_barea mean_blength tot_barea tot_blength sh_urban dist_roads_mean pdensity_mean_lag ///
pdensity_mean BSG_mean mean_rwi district_d1-district_d9 ln_pcconsexp_raw

order count density cv_area cv_length mean_barea mean_blength tot_barea tot_blength sh_urban dist_roads_mean pdensity_mean pdensity_mean_lag BSG_mean mean_rwi ///
urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean shrub_mean bare_mean ltype_12 ///
ltype_13 ltype_14 nightlyr ch_10 ch_09_00 ch_99_90 ch_89_85 district_d1-district_d9 district ln_pcconsexp_raw

saveold "Survey/Updated results/IHS_satellubr_R.dta", replace v(12)

***UBR districts-50 poorest HH
use "Survey/Updated results/IHS_proc.dta", clear

keep if UBR==1 & poorest50==1
tab district, g(district_d)

keep district urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean shrub_mean bare_mean ltype_12 ///
ltype_13 ltype_14 nightlyr ch_10_18 ch_09_00 ch_99_90 ch_89_85 count density cv_area cv_length mean_barea mean_blength tot_barea tot_blength sh_urban dist_roads_mean pdensity_mean_lag ///
pdensity_mean BSG_mean mean_rwi district_d1-district_d9 ln_pcconsexp_raw

order count density cv_area cv_length mean_barea mean_blength tot_barea tot_blength sh_urban dist_roads_mean pdensity_mean pdensity_mean_lag BSG_mean mean_rwi ///
urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean shrub_mean bare_mean ltype_12 ///
ltype_13 ltype_14 nightlyr ch_10 ch_09_00 ch_99_90 ch_89_85 district_d1-district_d9 district ln_pcconsexp_raw

saveold "Survey/Updated results/IHS_satellubr50_R.dta", replace v(12)


******************************************************************
*** Census data for xgboost
use "Census/census_predcons_measures.dta", clear //this dataset only contains UBR districts.26150 villages (this is before merging with satellite data when we lose more sample)

tab district, g(district_d)

keep *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge ///
stove computer oxcart bcycle mcycle car radio television district_d1-district_d9 district line_id

order *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove ///
computer oxcart bcycle mcycle car radio television district_d1-district_d9 district line_id

saveold "Census/Updated results/census_R_xgboostvf.dta", replace v(12)

***Other samples
use "Census/census_predcons_measures.dta", clear //this dataset only contains UBR districts.26150 villages (this is before merging with satellite data when we lose more sample)
tab district, g(district_d)

keep *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge ///
stove computer oxcart bcycle mcycle car radio television district_d1-district_d9 district line_id id_tagvnvill

order *_maxed literacy_hh  hhsize hhsize2 overcrwd rururb depen_old depen_ch cook_hh water_hh flushtoilet ownhouse *_improved cellphone fridge stove ///
computer oxcart bcycle mcycle car radio television district_d1-district_d9 district line_id id_tagvnvill

bys id_tagvnvill: g num=_N

preserve
keep if num>4 //villages with more than 4 HH, 12031 villages
drop num id_tagvnvill
saveold "Census/Updated results/census_R_xgboostvf_more4.dta", replace v(12)
restore

preserve 
keep if num>9 //villages with more than 9 HH, 6266 villages 
drop num id_tagvnvill
saveold "Census/Updated results/census_R_xgboostvf_more9.dta", replace v(12)
restore

preserve 
keep if num<12 //villages with less than 12 HH, 20925 villages 
drop num id_tagvnvill
saveold "Census/Updated results/census_R_xgboostvf_less12.dta", replace v(12)
restore

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

***In all districts
***Raw
reg ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample==1, r 
estimates store ols_raw
lassogof ols_raw, over(sample)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1, nolog rseed(12345) cluster(district)
estimates store cv_raw

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_raw

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1, selection(plugin) 
estimates store plugin_raw

lassogof ols_raw cv_raw adaptive_raw plugin_raw if sample==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS


***In UBR districts
reg ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, r 
estimates store ols_rawubr_at
lassogof ols_rawubr_at if  UBR==1, over(sample_UBR)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) cluster(district)
estimates store cv_rawubr_at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_rawubr_at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, selection(plugin) 
estimates store plugin_rawubr_at

lassogof ols_rawubr_at cv_rawubr_at adaptive_rawubr_at plugin_rawubr_at if UBR==1 & sample_UBR==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS


*************************
***Poorest 50% of HH
***In all districts
reg ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1 & poorest50raw==1, r 
estimates store ols_raw50_at
lassogof ols_raw50_at, over(sample)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1 & poorest50raw==1, nolog rseed(12345) cluster(district)
estimates store cv_raw50_at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1 & poorest50raw==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_raw50_at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1 & poorest50raw==1, selection(plugin) 
estimates store plugin_raw50_at

lassogof ols_raw50_at cv_raw50_at adaptive_raw50_at plugin_raw50_at if  poorest50raw==1 & sample==2  //adaptative has the smallest MSE and largest R2 but very small difference with OLS


***In UBR districts
reg ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 & poorest50raw==1, r 
estimates store ols_rawubr50at
lassogof ols_rawubr50at, over(sample_UBR)

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 & poorest50raw==1, nolog rseed(12345) cluster(district)
estimates store cv_rawubr50at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 & poorest50raw==1, nolog rseed(12345) selection(adaptive)
estimates store adaptive_rawubr50at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 & poorest50raw==1, selection(plugin) 
estimates store plugin_rawubr50at

lassogof ols_rawubr50at cv_rawubr50at adaptive_rawubr50at plugin_rawubr50at if UBR==1 & poorest50raw==1 & sample_UBR==2 //adaptative has the smallest MSE and largest R2 but very small difference with OLS

***********************************************
***Final models
lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1, nolog rseed(12345) cluster(district)
estimates store cv_raw

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) cluster(district)
estimates store cv_rawubr_at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1 & poorest50raw==1, nolog rseed(12345) cluster(district)
estimates store cv_raw50_at

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 & poorest50raw==1, nolog rseed(12345) cluster(district)
estimates store cv_rawubr50at

***Clustering at grid level
lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1, nolog rseed(12345) cluster(ID_grid7)
estimates store cv_raw2

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample_UBR==1 & UBR==1, nolog rseed(12345) cluster(ID_grid7)
estimates store cv_rawubr_at2

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12  i.district if sample==1 & poorest50raw==1, nolog rseed(12345) cluster(ID_grid7)
estimates store cv_raw50_at2

lasso linear ln_pcconsexp_raw $indepvar11 $indepvar12 i.district if sample_UBR==1 & UBR==1 & poorest50raw==1, nolog rseed(12345) cluster(ID_grid7)
estimates store cv_rawubr50at2


use "Census\Census_satellite_data.dta", clear 

estimates restore cv_raw // all districts
predict predcons_satell_ihs_full, xb postselection

estimates restore cv_rawubr_at //best with UBR districts
predict predcons_satell_ihs_ubr, xb postselection

estimates restore cv_raw50_at //all distrcits with 50% poorest HH
predict predcons_satell_ihs_full50, xb postselection

estimates restore cv_rawubr50at //best with UBR districts with 50% poorest HH
predict predcons_satell_ihs_ubr50, xb postselection


estimates restore cv_raw2 // all districts
predict predcons_satell_ihs_full2, xb postselection

estimates restore cv_rawubr_at2 //best with UBR districts
predict predcons_satell_ihs_ubr2, xb postselection

estimates restore cv_raw50_at2 //all distrcits with 50% poorest HH
predict predcons_satell_ihs_full502, xb postselection

estimates restore cv_rawubr50at2 //best with UBR districts with 50% poorest HH
predict predcons_satell_ihs_ubr502, xb postselection

***Rank correlations


***Correlations between LASSO and xgboost predictions in the census (village level)
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
	/*
putexcel set "Census\Updated results\Correlations_census_precited_IHS_LASSO_updt4", replace

***Rank correlations
putexcel A3="When 'true'consumption estimated using LASSO"
putexcel A6="When 'true'consumption estimated using XGBOOST"

putexcel B2="Predicted consumption based on all districts in IHS"
putexcel C2="Predicted consumption based on UBR districts in IHS"
putexcel D2="Predicted consumption based on Poorest 50% HH in all districts in IHS"
putexcel E2="Predicted consumption based on Poorest 50% HH in UBR districts in IHS"
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
*/
***Models clustered at grid level
***Correlations between LASSO and xgboost predictions in the census (village level)
spearman predcons_census_fullvill predcons_satell_ihs_full2
	local rhofull=r(rho)
	local pfull=r(p)
	local Nfull=r(N)
spearman predcons_census_ubrvill predcons_satell_ihs_ubr2
	local rhoubr=r(rho)
	local pubr=r(p)
	local Nubr=r(N)
spearman predcons_census_fullvill50 predcons_satell_ihs_full502
	local rhofull50=r(rho)
	local pfull50=r(p)
	local Nfull50=r(N)
spearman predcons_census_ubrvill50 predcons_satell_ihs_ubr502
	local rhoubr50=r(rho)
	local pubr50=r(p)
	local Nubr50=r(N)
	
spearman predcons_xgb_fullvill predcons_satell_ihs_full2
	local rhofullxg=r(rho)
	local pfullxg=r(p)
	local Nfullxg=r(N)
spearman predcons_xgb_ubrvill predcons_satell_ihs_ubr2
	local rhoubrxg=r(rho)
	local pubrxg=r(p)
	local Nubrxg=r(N)
spearman predcons_xgb_fullvill50 predcons_satell_ihs_full502
	local rhofullxg50=r(rho)
	local pfullxg50=r(p)
	local Nfullxg50=r(N)
spearman predcons_xgb_ubrvill50 predcons_satell_ihs_ubr502
	local rhoubrxg50=r(rho)
	local pubrxg50=r(p)
	local Nubrxg50=r(N)
/*	
putexcel set "Census\Updated results\Correlations_census_precited_IHS_LASSO_updt4_2", replace

***Rank correlations
putexcel A3="When 'true'consumption estimated using LASSO"
putexcel A6="When 'true'consumption estimated using XGBOOST"

putexcel B2="Predicted consumption based on all districts in IHS"
putexcel C2="Predicted consumption based on UBR districts in IHS"
putexcel D2="Predicted consumption based on Poorest 50% HH in all districts in IHS"
putexcel E2="Predicted consumption based on Poorest 50% HH in UBR districts in IHS"
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
*/
*********************************************
***AUC
g test=1
putexcel set "Census\Updated results\AUC_updt_3_lasso_lasso", replace

***True consumption using xgb
forvalues i=1(1)99 {
	egen ranktrue_11`i' = pctile(predcons_census_fullvill), by(district) p(`i') 
	g ranktrue_full_`i'=(predcons_xgb_fullvill<ranktrue_11`i')
	egen ranktrue_12`i' = pctile(predcons_census_ubrvill), by(district) p(`i') 
	g ranktrue_ubr_`i'=(predcons_xgb_ubrvill<ranktrue_12`i')
	egen ranktrue_13`i' = pctile(predcons_census_fullvill50), by(district) p(`i') 
	g ranktrue_full50_`i'=(predcons_xgb_fullvill50<ranktrue_13`i')
	egen ranktrue_14`i' = pctile(predcons_census_ubrvill50), by(district) p(`i') 
	g ranktrue_ubr50_`i'=(predcons_xgb_ubrvill50<ranktrue_14`i')

	*egen rankpred_11`i' = pctile(predwelfare_full1), by(district) p(`i') 
	g rankpred_full_`i'=(predcons_satell_ihs_full<ranktrue_11`i')
	*egen rankpred_12`i' = pctile(predwelfare_ubr1), by(district) p(`i') 
	g rankpred_ubr_`i'=(predcons_satell_ihs_ubr<ranktrue_12`i')
	*egen rankpred_13`i' = pctile(predwelfare_50full1), by(district) p(`i') 
	g rankpred_full50_`i'=(predcons_satell_ihs_full50<ranktrue_13`i')
	*egen rankpred_14`i' = pctile(predwelfare_50ubr1), by(district) p(`i') 
	g rankpred_ubr50_`i'=(predcons_satell_ihs_ubr50<ranktrue_14`i')

sum test if rankpred_full_`i'==1 & ranktrue_full_`i'==0 //false positive rate
return list
local FPf1`i'=r(N)
sum test if rankpred_full_`i'==1 & ranktrue_full_`i'==1 //true postive rate
return list
local TPf1`i'=r(N)
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
sum test if ranktrue_ubr50_`i'==1 //total poor
return list
local Pu150`i'=r(N)
sum test if ranktrue_ubr50_`i'==0 //total non-poor
return list
local NPu150`i'=r(N)
		
putexcel A`i'=`FPf1`i''
putexcel B`i'=`TPf1`i''
putexcel C`i'=`Pf1`i''
putexcel D`i'=`NPf1`i''

putexcel E`i'=`FPu1`i''
putexcel F`i'=`TPu1`i''
putexcel G`i'=`Pu1`i''
putexcel H`i'=`NPu1`i''

putexcel I`i'=`FPf150`i''
putexcel J`i'=`TPf150`i''
putexcel K`i'=`Pf150`i''
putexcel L`i'=`NPf150`i''

putexcel M`i'=`FPu150`i''
putexcel N`i'=`TPu150`i''
putexcel O`i'=`Pu150`i''
putexcel P`i'=`NPu150`i''	
}

putexcel set "Census\Updated results\AUC_updt_3_xgb_lasso", replace

***True consumption using xgb
forvalues i=1(1)99 {
	egen ranktrue_21`i' = pctile(predcons_xgb_fullvill), by(district) p(`i') 
	g ranktrue2_full_`i'=(predcons_xgb_fullvill<ranktrue_21`i')
	egen ranktrue_22`i' = pctile(predcons_xgb_ubrvill), by(district) p(`i') 
	g ranktrue2_ubr_`i'=(predcons_xgb_ubrvill<ranktrue_22`i')
	egen ranktrue_23`i' = pctile(predcons_xgb_fullvill50), by(district) p(`i') 
	g ranktrue2_full50_`i'=(predcons_xgb_fullvill50<ranktrue_23`i')
	egen ranktrue_24`i' = pctile(predcons_xgb_ubrvill50), by(district) p(`i') 
	g ranktrue2_ubr50_`i'=(predcons_xgb_ubrvill50<ranktrue_24`i')

	*egen rankpred_11`i' = pctile(predwelfare_full1), by(district) p(`i') 
	g rankpred2_full_`i'=(predcons_satell_ihs_full<ranktrue_21`i')
	*egen rankpred_12`i' = pctile(predwelfare_ubr1), by(district) p(`i') 
	g rankpred2_ubr_`i'=(predcons_satell_ihs_ubr<ranktrue_22`i')
	*egen rankpred_13`i' = pctile(predwelfare_50full1), by(district) p(`i') 
	g rankpred2_full50_`i'=(predcons_satell_ihs_full50<ranktrue_23`i')
	*egen rankpred_14`i' = pctile(predwelfare_50ubr1), by(district) p(`i') 
	g rankpred2_ubr50_`i'=(predcons_satell_ihs_ubr50<ranktrue_24`i')

sum test if rankpred2_full_`i'==1 & ranktrue2_full_`i'==0 //false positive rate
return list
local FPf1`i'=r(N)
sum test if rankpred2_full_`i'==1 & ranktrue2_full_`i'==1 //true postive rate
return list
local TPf1`i'=r(N)
sum test if ranktrue2_full_`i'==1 //total poor
return list
local Pf1`i'=r(N)
sum test if ranktrue2_full_`i'==0 //total non-poor
return list
local NPf1`i'=r(N)

sum test if rankpred2_full50_`i'==1 & ranktrue2_full50_`i'==0 //false positive rate
return list
local FPf150`i'=r(N)
sum test if rankpred2_full50_`i'==1 & ranktrue2_full50_`i'==1 //true postive rate
return list
local TPf150`i'=r(N)
sum test if ranktrue2_full50_`i'==1 //total poor
return list
local Pf150`i'=r(N)
sum test if ranktrue2_full50_`i'==0 //total non-poor
return list
local NPf150`i'=r(N)

sum test if rankpred2_ubr_`i'==1 & ranktrue2_ubr_`i'==0 //false positive rate
return list
local FPu1`i'=r(N)
sum test if rankpred2_ubr_`i'==1 & ranktrue2_ubr_`i'==1 //true postive rate
return list
local TPu1`i'=r(N)
sum test if ranktrue2_ubr_`i'==1 //total poor
return list
local Pu1`i'=r(N)
sum test if ranktrue2_ubr_`i'==0 //total non-poor
return list
local NPu1`i'=r(N)

sum test if rankpred2_ubr50_`i'==1 & ranktrue2_ubr50_`i'==0 //false positive rate
return list
local FPu150`i'=r(N)
sum test if rankpred2_ubr50_`i'==1 & ranktrue2_ubr50_`i'==1 //true postive rate
return list
local TPu150`i'=r(N)
sum test if ranktrue2_ubr50_`i'==1 //total poor
return list
local Pu150`i'=r(N)
sum test if ranktrue2_ubr50_`i'==0 //total non-poor
return list
local NPu150`i'=r(N)
		
putexcel A`i'=`FPf1`i''
putexcel B`i'=`TPf1`i''
putexcel C`i'=`Pf1`i''
putexcel D`i'=`NPf1`i''

putexcel E`i'=`FPu1`i''
putexcel F`i'=`TPu1`i''
putexcel G`i'=`Pu1`i''
putexcel H`i'=`NPu1`i''

putexcel I`i'=`FPf150`i''
putexcel J`i'=`TPf150`i''
putexcel K`i'=`Pf150`i''
putexcel L`i'=`NPf150`i''

putexcel M`i'=`FPu150`i''
putexcel N`i'=`TPu150`i''
putexcel O`i'=`Pu150`i''
putexcel P`i'=`NPu150`i''	
}
	
***************************************************************************************
*** True measure LASSO, prediction XGB
import excel "C:\Users\melyg\Desktop\Malawi\Census\Updated results\FTR_TPR_lasso_lasso_updt3.xlsx", sheet("Sheet1") firstrow clear

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
		title("True:LASSO", size(8pt)) ///
		legend(order(1 "Full" 2 "UBR" 3 "Full50" 4 "UBR50") size(vsmall) cols(4))  saving(auc1, replace)

		
***Area under the curve
foreach x in full ubr full50 ubr50 {
	integ TPR_`x' FPR_`x', gen(total_auc`x')
	local auc1_`x'=r(integral) 
}

*** True measure XGB, prediction XGB
import excel "C:\Users\melyg\Desktop\Malawi\Census\Updated results\FTR_TPR_xgb_lasso_updt3.xlsx", sheet("Sheet1") firstrow clear

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
		title("True:XGB", size(8pt)) ///
		legend(order(1 "Full" 2 "UBR" 3 "Full50" 4 "UBR50") size(vsmall) cols(4))  saving(auc2, replace)
		
***Area under the curve
foreach x in full ubr full50 ubr50 {
	integ  TPR_`x' FPR_`x', gen(total_auc`x')
	local auc2_`x'=r(integral) 
}



graph combine auc1.gph auc2.gph, ///
title("False positive rates vs. True positive rates using LASSO in IHS" , size(8pt)) 
graph export "Census\Updated results\auc_pred_lasso_updt3.pdf", replace

putexcel set "Census\Updated results\AUC_predictions_lasso_updt3", replace

putexcel B1="Full"
putexcel C1="UBR"
putexcel D1="Full50"
putexcel E1="UBR50"

putexcel A2="True measure estimated with LASSO"
putexcel A3="True measure estimated with XGB"

putexcel B2=`auc1_full'
putexcel C2=`auc1_ubr'
putexcel D2=`auc1_full50'
putexcel E2=`auc1_ubr50'

putexcel B3=`auc2_full'
putexcel C3=`auc2_ubr'
putexcel D3=`auc2_full50'
putexcel E3=`auc2_ubr50'


***Ranking using predicted welfare measures
global cutoff = "20" 
local cutoff = "$cutoff"

egen ranktrue_11 = pctile(predcons_census_fullvill), by(district) p(`cutoff') 
g ranktrue_full=(predcons_census_fullvill<ranktrue_11)
egen ranktrue_12 = pctile(predcons_census_ubrvill), by(district) p(`cutoff') 
g ranktrue_ubr=(predcons_census_ubrvill<ranktrue_12)
egen ranktrue_13 = pctile(predcons_census_fullvill50), by(district) p(`cutoff') 
g ranktrue_full50=(predcons_census_fullvill50<ranktrue_13)
egen ranktrue_14 = pctile(predcons_census_ubrvill50), by(district) p(`cutoff') 
g ranktrue_ubr50=(predcons_census_ubrvill50<ranktrue_14)

egen ranktrue_11xg = pctile(predcons_xgb_fullvill), by(district) p(`cutoff') 
g ranktrue_fullxg=(predcons_xgb_fullvill<ranktrue_11xg)
egen ranktrue_12xg = pctile(predcons_xgb_ubrvill), by(district) p(`cutoff') 
g ranktrue_ubrxg=(predcons_xgb_ubrvill<ranktrue_12xg)
egen ranktrue_13xg = pctile(predcons_xgb_fullvill50), by(district) p(`cutoff') 
g ranktrue_full50xg=(predcons_xgb_fullvill50<ranktrue_13xg)
egen ranktrue_14xg = pctile(predcons_xgb_ubrvill50), by(district) p(`cutoff') 
g ranktrue_ubr50xg=(predcons_xgb_ubrvill50<ranktrue_14xg)

egen rankpred_31 = pctile(predcons_satell_ihs_full), by(district) p(`cutoff') 
g rankpred3_full=(predcons_satell_ihs_full<rankpred_31)
egen rankpred_32 = pctile(predcons_satell_ihs_ubr), by(district) p(`cutoff') 
g rankpred3_ubr=(predcons_satell_ihs_ubr<rankpred_32)
egen rankpred_33 = pctile(predcons_satell_ihs_full50), by(district) p(`cutoff') 
g rankpred3_full50=(predcons_satell_ihs_full50<rankpred_33)
egen rankpred_34 = pctile(predcons_satell_ihs_ubr50), by(district) p(`cutoff') 
g rankpred3_ubr50=(predcons_satell_ihs_ubr50<rankpred_34)

***Accuracy
tabout ranktrue_full rankpred3_full using "Census\Updated results\accuracy`cutoff'ihs.csv", /// 
append cells(freq row col) format(1) clab(Freq Row_% Col_%) percent style(csv) layout(cb) show(all) font(bold)			

tabout ranktrue_ubr rankpred3_ubr using "Census\Updated results\accuracy`cutoff'ihs.csv", /// 
append cells(freq row col) format(1) clab(Freq Row_% Col_%) percent style(csv) layout(cb) show(all) font(bold)			

tabout ranktrue_full50 rankpred3_full50 using "Census\Updated results\accuracy`cutoff'ihs.csv", /// 
append cells(freq row col) format(1) clab(Freq Row_% Col_%) percent style(csv) layout(cb) show(all) font(bold)			

tabout ranktrue_ubr50 rankpred3_ubr50 using "Census\Updated results\accuracy`cutoff'ihs.csv", /// 
append cells(freq row col) format(1) clab(Freq Row_% Col_%) percent style(csv) layout(cb) show(all) font(bold)			


tabout ranktrue_fullxg rankpred3_full using "Census\Updated results\accuracy`cutoff'ihsxgb.csv", /// 
append cells(freq row col) format(1) clab(Freq Row_% Col_%) percent style(csv) layout(cb) show(all) font(bold)			

tabout ranktrue_ubrxg rankpred3_ubr using "Census\Updated results\accuracy`cutoff'ihsxgb.csv", /// 
append cells(freq row col) format(1) clab(Freq Row_% Col_%) percent style(csv) layout(cb) show(all) font(bold)			

tabout ranktrue_full50xg rankpred3_full50 using "Census\Updated results\accuracy`cutoff'ihsxgb.csv", /// 
append cells(freq row col) format(1) clab(Freq Row_% Col_%) percent style(csv) layout(cb) show(all) font(bold)			

tabout ranktrue_ubr50xg rankpred3_ubr50 using "Census\Updated results\accuracy`cutoff'ihsxgb.csv", /// 
append cells(freq row col) format(1) clab(Freq Row_% Col_%) percent style(csv) layout(cb) show(all) font(bold)			

