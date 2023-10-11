cd "C:\Users\melyg\Desktop\Malawi"

use "Census\Census_satellite_data.dta", clear

tab district, g(district_d)

drop predcons_census_fullvill predcons_census_ubrvill predcons_census_50vill predcons_census_50ubrvill predcons_census_fullvill50 predcons_census_ubrvill50 predcons_xgb_fullvill predcons_xgb_ubrvill predcons_xgb_50vill predcons_xgb_50ubrvill predcons_xgb_fullvill50 predcons_xgb_ubrvill50

keep count density cv_area cv_length mean_barea mean_blength tot_barea tot_blength sh_urban dist_roads_mean pdensity_mean pdensity_mean_lag BSG_mean mean_rwi ///
urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean shrub_mean bare_mean ltype_12 ///
district_d1-district_d9 district ///
ltype_13 ltype_14 nightlyr ch_10 ch_09_00 ch_99_90 ch_89_85 predcons_census_50vill50 predcons_census_50ubrvill50 predcons_xgb_50vill50 predcons_xgb_50ubrvill50 id_tagvnvill_num coords_x1 coords_x2

drop if predcons_xgb_50vill50==.

order count density cv_area cv_length mean_barea mean_blength tot_barea tot_blength sh_urban dist_roads_mean pdensity_mean pdensity_mean_lag BSG_mean mean_rwi ///
urban_mean crops_mean zscore_prec zscore_ndwi precyr ndwiyr waterperm_mean waterseas_mean zscore_ndvi ndviyr soilyr grass_mean shrub_mean bare_mean ltype_12 ///
ltype_13 ltype_14 nightlyr ch_10 ch_09_00 ch_99_90 ch_89_85 district_d1-district_d9 district ///
predcons_census_50vill50 predcons_census_50ubrvill50 predcons_xgb_50vill50 predcons_xgb_50ubrvill50 id_tagvnvill_num coords_x1 coords_x2


saveold "Census\Updated results\Census_R_full5050_ubr5050_coords.dta", replace v(12)


use "Rdata\pred_pts.poly7CT.dta", clear // at village level
rename id_tgv_ id_tagvnvill_num
merge 1:m id_tagvnvill_num using "Census/census_predcons_measures.dta", keepusing(district hid)
keep if _merge==3
g uno=1
bys ID: g num=_n //1742 grids, 4424 vilalges, 83300HH
bys ID: egen HH_bygrid=sum(uno)
tab HH_bygrid
sum HH_bygrid if num==1 //48 HH by grid on average in UBR districts
table district if num==1, statistic(mean HH_bygrid)

bys id_tagvnvill_num: egen HH_byvill=sum(uno)
tab HH_byvill
sum HH_byvill if num==1 //48 HH by grid on average in UBR districts


use "Census/census_predcons_measures.dta", clear 

keep prim_edhh sec_edhh ter_edhh literacy_hh eduyr_hh hhsize wall_improved roof_improved floor_improved depen_ch depen_old id_tagvnvill_num cook_hh water_hh flushtoilet ownhouse cellphone fridge stove computer oxcart bcycle mcycle car radio television rururb
collapse (mean) rururb prim_edhh sec_edhh ter_edhh literacy_hh eduyr_hh hhsize wall_improved roof_improved floor_improved depen_ch depen_old cook_hh water_hh flushtoilet ownhouse cellphone fridge stove computer oxcart bcycle mcycle car radio television, by(id_tagvnvill_num) 

saveold "Census\Updated results\features_census.dta", replace v(12)

******************************************************************************************************
***Using predictions to create a single dataset and overlap with IHS coordinates


use "Census\Updated results\Out of sample_april\pred_xgboos_full5050_ubr5050_10_outfullxg_coords.dta", clear
destring  predcons_xgb_full predwelf_xgb_full, replace
rename V3 district
destring coords_x1 coords_x2 id_tagvnvill_num, replace

rename predcons_xgb_full predcons_xgb_full10 
rename predwelf_xgb_full predwelf_xgb_full10
tempfile pred10
save `pred10'

use "Census\Updated results\Out of sample_april\pred_xgboos_full5050_ubr5050_15_outfullxg_coords.dta", clear
destring  predcons_xgb_full predwelf_xgb_full, replace
rename V3 district
destring coords_x1 coords_x2 id_tagvnvill_num, replace

rename predcons_xgb_full predcons_xgb_full15 
rename predwelf_xgb_full predwelf_xgb_full15
tempfile pred15
save `pred15'

use "Census\Updated results\Out of sample_april\pred_xgboos_full5050_ubr5050_20_outfullxg_coords.dta", clear
destring  predcons_xgb_full predwelf_xgb_full, replace
rename V3 district
destring coords_x1 coords_x2 id_tagvnvill_num, replace

rename predcons_xgb_full predcons_xgb_full20 
rename predwelf_xgb_full predwelf_xgb_full20
tempfile pred20
save `pred20'

use `pred10', clear
merge 1:1 id_tagvnvill_num using `pred15'
rename _merge merge1015
merge 1:1 id_tagvnvill_num using `pred20'
rename _merge merge101520

rename coords_x2 latitude
rename coords_x1 longitude

saveold "Census\Updated results\Predictions_full5050xgb_OOS_census.dta", replace v(12)

***UBR

use "Census\Updated results\Out of sample_april\pred_xgboos_full5050_ubr5050_10_outubrxg_coords.dta", clear
destring  predcons_xgb_ubr predwelf_xgb_ubr, replace
rename V3 district
destring coords_x1 coords_x2 id_tagvnvill_num, replace

rename predcons_xgb_ubr predcons_xgb_ubr10 
rename predwelf_xgb_ubr predwelf_xgb_ubr10
tempfile pred10
save `pred10'

use "Census\Updated results\Out of sample_april\pred_xgboos_full5050_ubr5050_15_outubrxg_coords.dta", clear
destring  predcons_xgb_ubr predwelf_xgb_ubr, replace
rename V3 district
destring coords_x1 coords_x2 id_tagvnvill_num, replace

rename predcons_xgb_ubr predcons_xgb_ubr15 
rename predwelf_xgb_ubr predwelf_xgb_ubr15
tempfile pred15
save `pred15'

use "Census\Updated results\Out of sample_april\pred_xgboos_full5050_ubr5050_20_outubrxg_coords.dta", clear
destring  predcons_xgb_ubr predwelf_xgb_ubr, replace
rename V3 district
destring coords_x1 coords_x2 id_tagvnvill_num, replace

rename predcons_xgb_ubr predcons_xgb_ubr20 
rename predwelf_xgb_ubr predwelf_xgb_ubr20
tempfile pred20
save `pred20'

use `pred10', clear
merge 1:1 id_tagvnvill_num using `pred15'
rename _merge merge1015
merge 1:1 id_tagvnvill_num using `pred20'
rename _merge merge101520

rename coords_x2 latitude
rename coords_x1 longitude

saveold "Census\Updated results\Predictions_ubr5050xgb_OOS_census.dta", replace v(12)

********************************************************************
***After using R to overlap map_grid7 to these coordinates, merge with data obtained after same overlapping with IHS
use "Survey/Updated results/IHS_proc_2023.dta",clear

*g ln_pcconsexp=ln(pc_hhdr)
*g ln_pcconsexp_raw=ln(pc_hhdr_raw)

keep ln_pcconsexp ln_pcconsexp_raw pc_hhdr pc_hhdr_raw ID_grid7 ea_id lat_modified lon_modified

rename ID_grid7 ID

***Calculating percapita by EA
bys ea_id: egen pccons_mean=mean(pc_hhdr)
bys ea_id: egen pccons_mean_raw=mean(pc_hhdr_raw)

g ln_pccons_mean=ln(pccons_mean)
g ln_pccons_mean_raw=ln(pccons_mean_raw)


keep ea_id ln_pccons_mean ln_pccons_mean_raw lat_modified lon_modified 
drop if lat_modified==.

duplicates drop
saveold "Survey/Updated results/IHS_coords_2023.dta", replace v(12)

***traditional features
use "Survey/Updated results/IHS_proc_2023.dta",clear

***Average number of HH by grid
g uno=1
bys ID_grid7: g num=_n //691 grids in total, 239 for UBR districts
bys ID_grid7: egen HH_bygrid=sum(uno)
tab HH_bygrid
sum HH_bygrid if num==1 //18 HH by grid on average
sum HH_bygrid if num==1 & UBR==1 //18 HH by grid on average
table UBR if num==1, statistic(mean HH_bygrid) //17 HH by grid on average in UBR districts
table region2 if num==1 & UBR==1, statistic(mean HH_bygrid)

bys ea_id: egen HH_byvill=sum(uno)
tab HH_byvill
sum HH_byvill if num==1 //18 HH by grid on average
sum HH_byvill if num==1 & UBR==1 //18 HH by grid on average


keep ea_id wall_improved roof_improved floor_improved depen_ch depen_old prim_edhh sec_edhh ter_edhh literacy_hh eduyr_hh hhsize pc_hhdr ln_pcconsexp ln_pcconsexp_raw poorest50raw cook_hh water_hh flushtoilet ownhouse cellphone fridge stove computer oxcart bcycle mcycle car radio television rururb

collapse (mean) wall_improved roof_improved floor_improved depen_ch depen_old prim_edhh sec_edhh ter_edhh literacy_hh eduyr_hh hhsize pc_hhdr ln_pcconsexp ln_pcconsexp_raw cook_hh water_hh flushtoilet ownhouse cellphone fridge stove computer oxcart bcycle mcycle car radio television rururb, by(ea_id) //1742 ID, only UBR
saveold "Survey/Updated results/IHS_features.dta", replace v(12)

use "Survey/Updated results/IHS_proc_2023.dta",clear
keep ea_id wall_improved roof_improved floor_improved depen_ch depen_old prim_edhh sec_edhh ter_edhh literacy_hh eduyr_hh hhsize pc_hhdr ln_pcconsexp ln_pcconsexp_raw poorest50raw cook_hh water_hh flushtoilet ownhouse cellphone fridge stove computer oxcart bcycle mcycle car radio television rururb
collapse (mean) wall_improved roof_improved floor_improved depen_ch depen_old prim_edhh sec_edhh ter_edhh literacy_hh eduyr_hh hhsize pc_hhdr ln_pcconsexp ln_pcconsexp_raw cook_hh water_hh flushtoilet ownhouse cellphone fridge stove computer oxcart bcycle mcycle car radio television rururb if poorest50raw==1, by(ea_id) //1742 ID, only UBR
saveold "Survey/Updated results/IHS_features_poorest.dta", replace v(12)


************************************************************************************
***Using data to calculate rank correlations

use "Rdata/ihscoords_pts.poly7CT.dta", clear
bys ea_id: egen pccons_mean=mean(ln_pcc_)
bys ea_id: egen pccons_mean_raw=mean(ln_pc__)
keep ea_id pccons_mean pccons_mean_raw ID

merge m:1 ea_id using "Survey/Updated results/IHS_features.dta"
keep if _merge==3
drop _merge
duplicates drop

foreach x in wall_improved roof_improved floor_improved depen_ch depen_old prim_edhh sec_edhh ter_edhh literacy_hh eduyr_hh hhsize ln_pcconsexp_raw cook_hh water_hh flushtoilet ownhouse cellphone fridge stove computer oxcart bcycle mcycle car radio television rururb {
	rename `x' `x'_sur
}

merge m:1 ea_id using "Survey/Updated results/IHS_features_poorest.dta"
keep if _merge==3
drop _merge


foreach x in wall_improved roof_improved floor_improved depen_ch depen_old prim_edhh sec_edhh ter_edhh literacy_hh eduyr_hh hhsize ln_pcconsexp_raw cook_hh water_hh flushtoilet ownhouse cellphone fridge stove computer oxcart bcycle mcycle car radio television rururb {
	rename `x' `x'_surp
}

foreach x in wall_improved_sur roof_improved_sur floor_improved_sur depen_ch_sur depen_old_sur prim_edhh_sur sec_edhh_sur ter_edhh_sur literacy_hh_sur eduyr_hh_sur hhsize_sur cook_hh_sur water_hh_sur flushtoilet_sur ownhouse_sur cellphone_sur fridge_sur stove_sur computer_sur oxcart_sur bcycle_sur mcycle_sur car_sur radio_sur television_sur {
spearman ln_pcconsexp_raw_sur `x'
local rho`x'=r(rho)
local p`x'=r(p)
local N`x'=r(N)
}

putexcel set "Census\Updated results\correlations_census_IHS\correlations_IHS", replace

putexcel A1="Rank correlations between average percapita consumption and HH features"

putexcel B3="Correlation coefficient"
putexcel C3="p-value"
putexcel D3="Observations"

putexcel A4="% HH with Improved walls"
putexcel A5="% HH with Improved roof"
putexcel A6="% HH with Improved floor"
putexcel A7="Aver. Child dependency ratio"
putexcel A8="Aver. Elderly dependency ratio"
putexcel A9="% HH with household head with primary education"
putexcel A10="% HH with household head with secondary education"
putexcel A11="% HH with household head with terciary education"
putexcel A12="% HH with literate household head"
putexcel A13="Average education years of household head"
putexcel A14="Household size"
putexcel A15="% HH own house"
putexcel A16="% HH have cellphone"
putexcel A17="% HH have fridge"
putexcel A18="% HH have stove"
putexcel A19="% HH have computer"
putexcel A20="% HH have oxcart"
putexcel A21="% HH have bicycle"
putexcel A22="% HH have motorcycle"
putexcel A23="% HH have car"
putexcel A24="% HH have radio"
putexcel A25="% HH have tv"
putexcel A26="% HH have fuel cooking: firewood"
putexcel A27="% HH have access to piped water"
putexcel A28="% HH have access to flush toilet"


putexcel B4=`rhowall_improved_sur' 
putexcel B5=`rhoroof_improved_sur' 
putexcel B6=`rhofloor_improved_sur' 
putexcel B7=`rhodepen_ch_sur' 
putexcel B8=`rhodepen_old_sur' 
putexcel B9=`rhoprim_edhh_sur' 
putexcel B10=`rhosec_edhh_sur' 
putexcel B11=`rhoter_edhh_sur' 
putexcel B12=`rholiteracy_hh_sur' 
putexcel B13=`rhoeduyr_hh_sur' 
putexcel B14=`rhohhsize_sur'
putexcel B15=`rhoownhouse_sur'
putexcel B16=`rhocellphone_sur'
putexcel B17=`rhofridge_sur'
putexcel B18=`rhostove_sur'
putexcel B19=`rhocomputer_sur'
putexcel B20=`rhooxcart_sur'
putexcel B21=`rhobcycle_sur'
putexcel B22=`rhomcycle_sur'
putexcel B23=`rhocar_sur'
putexcel B24=`rhoradio_sur'
putexcel B25=`rhotelevision_sur'
putexcel B26=`rhocook_hh_sur'
putexcel B27=`rhowater_hh_sur'
putexcel B28=`rhoflushtoilet_sur'

putexcel C4=`pwall_improved_sur' 
putexcel C5=`proof_improved_sur' 
putexcel C6=`pfloor_improved_sur' 
putexcel C7=`pdepen_ch_sur' 
putexcel C8=`pdepen_old_sur' 
putexcel C9=`pprim_edhh_sur' 
putexcel C10=`psec_edhh_sur' 
putexcel C11=`pter_edhh_sur' 
putexcel C12=`pliteracy_hh_sur' 
putexcel C13=`peduyr_hh_sur' 
putexcel C14=`phhsize_sur'
putexcel C15=`pownhouse_sur'
putexcel C16=`pcellphone_sur'
putexcel C17=`pfridge_sur'
putexcel C18=`pstove_sur'
putexcel C19=`pcomputer_sur'
putexcel C20=`poxcart_sur'
putexcel C21=`pbcycle_sur'
putexcel C22=`pmcycle_sur'
putexcel C23=`pcar_sur'
putexcel C24=`pradio_sur'
putexcel C25=`ptelevision_sur'
putexcel C26=`pcook_hh_sur'
putexcel C27=`pwater_hh_sur'
putexcel C28=`pflushtoilet_sur'

putexcel D4=`Nwall_improved_sur' 
putexcel D5=`Nroof_improved_sur' 
putexcel D6=`Nfloor_improved_sur' 
putexcel D7=`Ndepen_ch_sur' 
putexcel D8=`Ndepen_old_sur' 
putexcel D9=`Nprim_edhh_sur' 
putexcel D10=`Nsec_edhh_sur' 
putexcel D11=`Nter_edhh_sur' 
putexcel D12=`Nliteracy_hh_sur' 
putexcel D13=`Neduyr_hh_sur' 
putexcel D14=`Nhhsize_sur'
putexcel D15=`Nownhouse_sur'
putexcel D16=`Ncellphone_sur'
putexcel D17=`Nfridge_sur'
putexcel D18=`Nstove_sur'
putexcel D19=`Ncomputer_sur'
putexcel D20=`Noxcart_sur'
putexcel D21=`Nbcycle_sur'
putexcel D22=`Nmcycle_sur'
putexcel D23=`Ncar_sur'
putexcel D24=`Nradio_sur'
putexcel D25=`Ntelevision_sur'
putexcel D26=`Ncook_hh_sur'
putexcel D27=`Nwater_hh_sur'
putexcel D28=`Nflushtoilet_sur'
              

foreach x in wall_improved_surp roof_improved_surp floor_improved_surp depen_ch_surp depen_old_surp prim_edhh_surp sec_edhh_surp ter_edhh_surp literacy_hh_surp eduyr_hh_surp hhsize_surp cook_hh_surp water_hh_surp flushtoilet_surp ownhouse_surp cellphone_surp fridge_surp stove_surp computer_surp oxcart_surp bcycle_surp mcycle_surp car_surp radio_surp television_surp {
spearman ln_pcconsexp_raw_surp `x'
local rho`x'=r(rho)
local p`x'=r(p)
local N`x'=r(N)
}

putexcel set "Census\Updated results\correlations_census_IHS\correlations_IHS_poorest", replace

putexcel A1="Rank correlations between average percapita consumption and HH features"

putexcel B3="Correlation coefficient"
putexcel C3="p-value"
putexcel D3="Observations"

putexcel A4="% HH with Improved walls"
putexcel A5="% HH with Improved roof"
putexcel A6="% HH with Improved floor"
putexcel A7="Aver. Child dependency ratio"
putexcel A8="Aver. Elderly dependency ratio"
putexcel A9="% HH with household head with primary education"
putexcel A10="% HH with household head with secondary education"
putexcel A11="% HH with household head with terciary education"
putexcel A12="% HH with literate household head"
putexcel A13="Average education years of household head"
putexcel A14="Household size"
putexcel A15="% HH own house"
putexcel A16="% HH have cellphone"
putexcel A17="% HH have fridge"
putexcel A18="% HH have stove"
putexcel A19="% HH have computer"
putexcel A20="% HH have oxcart"
putexcel A21="% HH have bicycle"
putexcel A22="% HH have motorcycle"
putexcel A23="% HH have car"
putexcel A24="% HH have radio"
putexcel A25="% HH have tv"
putexcel A26="% HH have fuel cooking: firewood"
putexcel A27="% HH have access to piped water"
putexcel A28="% HH have access to flush toilet"

putexcel B4=`rhowall_improved_surp' 
putexcel B5=`rhoroof_improved_surp' 
putexcel B6=`rhofloor_improved_surp' 
putexcel B7=`rhodepen_ch_surp' 
putexcel B8=`rhodepen_old_surp' 
putexcel B9=`rhoprim_edhh_surp' 
putexcel B10=`rhosec_edhh_surp' 
putexcel B11=`rhoter_edhh_surp' 
putexcel B12=`rholiteracy_hh_surp' 
putexcel B13=`rhoeduyr_hh_surp' 
putexcel B14=`rhohhsize_surp'
putexcel B15=`rhoownhouse_surp'
putexcel B16=`rhocellphone_surp'
putexcel B17=`rhofridge_surp'
putexcel B18=`rhostove_surp'
putexcel B19=`rhocomputer_surp'
putexcel B20=`rhooxcart_surp'
putexcel B21=`rhobcycle_surp'
putexcel B22=`rhomcycle_surp'
putexcel B23=`rhocar_surp'
putexcel B24=`rhoradio_surp'
putexcel B25=`rhotelevision_surp'
putexcel B26=`rhocook_hh_surp'
putexcel B27=`rhowater_hh_surp'
putexcel B28=`rhoflushtoilet_surp'

putexcel C4=`pwall_improved_surp' 
putexcel C5=`proof_improved_surp' 
putexcel C6=`pfloor_improved_surp' 
putexcel C7=`pdepen_ch_surp' 
putexcel C8=`pdepen_old_surp' 
putexcel C9=`pprim_edhh_surp' 
putexcel C10=`psec_edhh_surp' 
putexcel C11=`pter_edhh_surp' 
putexcel C12=`pliteracy_hh_surp' 
putexcel C13=`peduyr_hh_surp' 
putexcel C14=`phhsize_surp'
putexcel C15=`pownhouse_surp'
putexcel C16=`pcellphone_surp'
putexcel C17=`pfridge_surp'
putexcel C18=`pstove_surp'
putexcel C19=`pcomputer_surp'
putexcel C20=`poxcart_surp'
putexcel C21=`pbcycle_surp'
putexcel C22=`pmcycle_surp'
putexcel C23=`pcar_surp'
putexcel C24=`pradio_surp'
putexcel C25=`ptelevision_surp'
putexcel C26=`pcook_hh_surp'
putexcel C27=`pwater_hh_surp'
putexcel C28=`pflushtoilet_surp'

putexcel D4=`Nwall_improved_surp' 
putexcel D5=`Nroof_improved_surp' 
putexcel D6=`Nfloor_improved_surp' 
putexcel D7=`Ndepen_ch_surp' 
putexcel D8=`Ndepen_old_surp' 
putexcel D9=`Nprim_edhh_surp' 
putexcel D10=`Nsec_edhh_surp' 
putexcel D11=`Nter_edhh_surp' 
putexcel D12=`Nliteracy_hh_surp' 
putexcel D13=`Neduyr_hh_surp' 
putexcel D14=`Nhhsize_surp'
putexcel D15=`Nownhouse_surp'
putexcel D16=`Ncellphone_surp'
putexcel D17=`Nfridge_surp'
putexcel D18=`Nstove_surp'
putexcel D19=`Ncomputer_surp'
putexcel D20=`Noxcart_surp'
putexcel D21=`Nbcycle_surp'
putexcel D22=`Nmcycle_surp'
putexcel D23=`Ncar_surp'
putexcel D24=`Nradio_surp'
putexcel D25=`Ntelevision_surp'
putexcel D26=`Ncook_hh_surp'
putexcel D27=`Nwater_hh_surp'
putexcel D28=`Nflushtoilet_surp'
              
collapse (mean) wall_improved_sur roof_improved_sur floor_improved_sur depen_ch_sur depen_old_sur prim_edhh_sur sec_edhh_sur ter_edhh_sur literacy_hh_sur eduyr_hh_sur hhsize_sur cook_hh_sur water_hh_sur flushtoilet_sur ownhouse_sur cellphone_sur fridge_sur stove_sur computer_sur oxcart_sur bcycle_sur mcycle_sur car_sur radio_sur television_sur wall_improved_surp roof_improved_surp floor_improved_surp depen_ch_surp depen_old_surp prim_edhh_surp sec_edhh_surp ter_edhh_surp literacy_hh_surp eduyr_hh_surp hhsize_surp cook_hh_surp water_hh_surp flushtoilet_surp ownhouse_surp cellphone_surp fridge_surp stove_surp computer_surp oxcart_surp bcycle_surp mcycle_surp car_surp radio_surp television_surp ln_pcconsexp_raw_surp ln_pcconsexp_raw_sur rururb_sur  rururb_surp, by(ID)

tempfile IHS
save `IHS' //691 ID . NAtional level, not only UBR
 
use "Rdata\pred_pts.poly7CT.dta", clear
rename id_tgv_ id_tagvnvill_num

merge 1:1 id_tagvnvill_num using  "Census\Updated results\features_census.dta"
keep if _merge==3
drop _merge
/*
foreach x in wall_improved roof_improved floor_improved depen_ch depen_old prim_edhh sec_edhh ter_edhh literacy_hh eduyr_hh hhsize prdc__15 cook_hh water_hh flushtoilet ownhouse cellphone fridge stove computer oxcart bcycle mcycle car radio television {
spearman prdw__15 `x'
local rho`x'=r(rho)
local p`x'=r(p)
local N`x'=r(N)
}

putexcel set "Census\Updated results\correlations_census_IHS\correlations_Census15", replace

putexcel A1="Rank correlations between average predicted percapita consumption and HH features"

putexcel B3="Correlation coefficient"
putexcel C3="p-value"
putexcel D3="Observations"

putexcel A4="% HH with Improved walls"
putexcel A5="% HH with Improved roof"
putexcel A6="% HH with Improved floor"
putexcel A7="Aver. Child dependency ratio"
putexcel A8="Aver. Elderly dependency ratio"
putexcel A9="% HH with household head with primary education"
putexcel A10="% HH with household head with secondary education"
putexcel A11="% HH with household head with terciary education"
putexcel A12="% HH with literate household head"
putexcel A13="Average education years of household head"
putexcel A14="Household size"
putexcel A15="% HH own house"
putexcel A16="% HH have cellphone"
putexcel A17="% HH have fridge"
putexcel A18="% HH have stove"
putexcel A19="% HH have computer"
putexcel A20="% HH have oxcart"
putexcel A21="% HH have bicycle"
putexcel A22="% HH have motorcycle"
putexcel A23="% HH have car"
putexcel A24="% HH have radio"
putexcel A25="% HH have tv"
putexcel A26="% HH have fuel cooking: firewood"
putexcel A27="% HH have access to piped water"
putexcel A28="% HH have access to flush toilet"
putexcel A29="Imputed welfare reference measure"

putexcel B4=`rhowall_improved' 
putexcel B5=`rhoroof_improved' 
putexcel B6=`rhofloor_improved' 
putexcel B7=`rhodepen_ch' 
putexcel B8=`rhodepen_old' 
putexcel B9=`rhoprim_edhh' 
putexcel B10=`rhosec_edhh' 
putexcel B11=`rhoter_edhh' 
putexcel B12=`rholiteracy_hh' 
putexcel B13=`rhoeduyr_hh' 
putexcel B14=`rhohhsize'
putexcel B15=`rhoownhouse'
putexcel B16=`rhocellphone'
putexcel B17=`rhofridge'
putexcel B18=`rhostove'
putexcel B19=`rhocomputer'
putexcel B20=`rhooxcart'
putexcel B21=`rhobcycle'
putexcel B22=`rhomcycle'
putexcel B23=`rhocar'
putexcel B24=`rhoradio'
putexcel B25=`rhotelevision'
putexcel B26=`rhocook_hh'
putexcel B27=`rhowater_hh'
putexcel B28=`rhoflushtoilet'
putexcel B29=`rhoprdc__15'

putexcel C4=`pwall_improved' 
putexcel C5=`proof_improved' 
putexcel C6=`pfloor_improved' 
putexcel C7=`pdepen_ch' 
putexcel C8=`pdepen_old' 
putexcel C9=`pprim_edhh' 
putexcel C10=`psec_edhh' 
putexcel C11=`pter_edhh' 
putexcel C12=`pliteracy_hh' 
putexcel C13=`peduyr_hh' 
putexcel C14=`phhsize'
putexcel C15=`pownhouse'
putexcel C16=`pcellphone'
putexcel C17=`pfridge'
putexcel C18=`pstove'
putexcel C19=`pcomputer'
putexcel C20=`poxcart'
putexcel C21=`pbcycle'
putexcel C22=`pmcycle'
putexcel C23=`pcar'
putexcel C24=`pradio'
putexcel C25=`ptelevision'
putexcel C26=`pcook_hh'
putexcel C27=`pwater_hh'
putexcel C28=`pflushtoilet'
putexcel C29=`pprdc__15'

putexcel D4=`Nwall_improved' 
putexcel D5=`Nroof_improved' 
putexcel D6=`Nfloor_improved' 
putexcel D7=`Ndepen_ch' 
putexcel D8=`Ndepen_old' 
putexcel D9=`Nprim_edhh' 
putexcel D10=`Nsec_edhh' 
putexcel D11=`Nter_edhh' 
putexcel D12=`Nliteracy_hh' 
putexcel D13=`Neduyr_hh' 
putexcel D14=`Nhhsize'
putexcel D15=`Nownhouse'
putexcel D16=`Ncellphone'
putexcel D17=`Nfridge'
putexcel D18=`Nstove'
putexcel D19=`Ncomputer'
putexcel D20=`Noxcart'
putexcel D21=`Nbcycle'
putexcel D22=`Nmcycle'
putexcel D23=`Ncar'
putexcel D24=`Nradio'
putexcel D25=`Ntelevision'
putexcel D26=`Ncook_hh'
putexcel D27=`Nwater_hh'
putexcel D28=`Nflushtoilet'
putexcel D29=`Nprdc__15'
*/
collapse (mean) prdc__10 prdw__10 prdc__15 prdw__15 prdc__20 prdw__20 prim_edhh sec_edhh ter_edhh literacy_hh eduyr_hh hhsize wall_improved roof_improved floor_improved depen_ch depen_old cook_hh water_hh flushtoilet ownhouse cellphone fridge stove computer oxcart bcycle mcycle car radio television rururb, by(ID) //1742 ID, only UBR

/*
foreach x in wall_improved roof_improved floor_improved depen_ch depen_old prim_edhh sec_edhh ter_edhh literacy_hh eduyr_hh hhsize prdc__10 cook_hh water_hh flushtoilet ownhouse cellphone fridge stove computer oxcart bcycle mcycle car radio television {
spearman prdc__10 `x'
local rho`x'=r(rho)
local p`x'=r(p)
local N`x'=r(N)
}
putexcel set "Census\Updated results\correlations_census_IHS\correlations_Census_IDlevel", replace

putexcel A1="Rank correlations between average predicted percapita consumption and HH features"

putexcel B3="Correlation coefficient"
putexcel C3="p-value"
putexcel D3="Observations"

putexcel A4="% HH with Improved walls"
putexcel A5="% HH with Improved roof"
putexcel A6="% HH with Improved floor"
putexcel A7="Aver. Child dependency ratio"
putexcel A8="Aver. Elderly dependency ratio"
putexcel A9="% HH with household head with primary education"
putexcel A10="% HH with household head with secondary education"
putexcel A11="% HH with household head with terciary education"
putexcel A12="% HH with literate household head"
putexcel A13="Average education years of household head"
putexcel A14="Household size"
putexcel A15="% HH own house"
putexcel A16="% HH have cellphone"
putexcel A17="% HH have fridge"
putexcel A18="% HH have stove"
putexcel A19="% HH have computer"
putexcel A20="% HH have oxcart"
putexcel A21="% HH have bicycle"
putexcel A22="% HH have motorcycle"
putexcel A23="% HH have car"
putexcel A24="% HH have radio"
putexcel A25="% HH have tv"
putexcel A26="% HH have fuel cooking: firewood"
putexcel A27="% HH have access to piped water"
putexcel A28="% HH have access to flush toilet"

putexcel B4=`rhowall_improved' 
putexcel B5=`rhoroof_improved' 
putexcel B6=`rhofloor_improved' 
putexcel B7=`rhodepen_ch' 
putexcel B8=`rhodepen_old' 
putexcel B9=`rhoprim_edhh' 
putexcel B10=`rhosec_edhh' 
putexcel B11=`rhoter_edhh' 
putexcel B12=`rholiteracy_hh' 
putexcel B13=`rhoeduyr_hh' 
putexcel B14=`rhohhsize'
putexcel B15=`rhoownhouse'
putexcel B16=`rhocellphone'
putexcel B17=`rhofridge'
putexcel B18=`rhostove'
putexcel B19=`rhocomputer'
putexcel B20=`rhooxcart'
putexcel B21=`rhobcycle'
putexcel B22=`rhomcycle'
putexcel B23=`rhocar'
putexcel B24=`rhoradio'
putexcel B25=`rhotelevision'
putexcel B26=`rhocook_hh'
putexcel B27=`rhowater_hh'
putexcel B28=`rhoflushtoilet'
putexcel B29=`rhoprdc__15'

putexcel C4=`pwall_improved' 
putexcel C5=`proof_improved' 
putexcel C6=`pfloor_improved' 
putexcel C7=`pdepen_ch' 
putexcel C8=`pdepen_old' 
putexcel C9=`pprim_edhh' 
putexcel C10=`psec_edhh' 
putexcel C11=`pter_edhh' 
putexcel C12=`pliteracy_hh' 
putexcel C13=`peduyr_hh' 
putexcel C14=`phhsize'
putexcel C15=`pownhouse'
putexcel C16=`pcellphone'
putexcel C17=`pfridge'
putexcel C18=`pstove'
putexcel C19=`pcomputer'
putexcel C20=`poxcart'
putexcel C21=`pbcycle'
putexcel C22=`pmcycle'
putexcel C23=`pcar'
putexcel C24=`pradio'
putexcel C25=`ptelevision'
putexcel C26=`pcook_hh'
putexcel C27=`pwater_hh'
putexcel C28=`pflushtoilet'
putexcel C29=`pprdc__15'

putexcel D4=`Nwall_improved' 
putexcel D5=`Nroof_improved' 
putexcel D6=`Nfloor_improved' 
putexcel D7=`Ndepen_ch' 
putexcel D8=`Ndepen_old' 
putexcel D9=`Nprim_edhh' 
putexcel D10=`Nsec_edhh' 
putexcel D11=`Nter_edhh' 
putexcel D12=`Nliteracy_hh' 
putexcel D13=`Neduyr_hh' 
putexcel D14=`Nhhsize'
putexcel D15=`Nownhouse'
putexcel D16=`Ncellphone'
putexcel D17=`Nfridge'
putexcel D18=`Nstove'
putexcel D19=`Ncomputer'
putexcel D20=`Noxcart'
putexcel D21=`Nbcycle'
putexcel D22=`Nmcycle'
putexcel D23=`Ncar'
putexcel D24=`Nradio'
putexcel D25=`Ntelevision'
putexcel D26=`Ncook_hh'
putexcel D27=`Nwater_hh'
putexcel D28=`Nflushtoilet'
putexcel D29=`Nprdc__15'
*/
merge 1:1 ID using `IHS'
keep if _merge==3 // only 187 matched at EA level or 163 at ID level


foreach x in prdc__10 ln_pcconsexp_raw_surp ln_pcconsexp_raw_sur wall_improved roof_improved floor_improved depen_ch depen_old prim_edhh sec_edhh ter_edhh literacy_hh eduyr_hh hhsize cook_hh water_hh flushtoilet ownhouse cellphone fridge stove computer oxcart bcycle mcycle car radio television wall_improved_sur roof_improved_sur floor_improved_sur depen_ch_sur depen_old_sur prim_edhh_sur sec_edhh_sur ter_edhh_sur literacy_hh_sur eduyr_hh_sur hhsize_sur cook_hh_sur water_hh_sur flushtoilet_sur ownhouse_sur cellphone_sur fridge_sur stove_sur computer_sur oxcart_sur bcycle_sur mcycle_sur car_sur radio_sur television_sur wall_improved_surp roof_improved_surp floor_improved_surp depen_ch_surp depen_old_surp prim_edhh_surp sec_edhh_surp ter_edhh_surp literacy_hh_surp eduyr_hh_surp hhsize_surp cook_hh_surp water_hh_surp flushtoilet_surp ownhouse_surp cellphone_surp fridge_surp stove_surp computer_surp oxcart_surp bcycle_surp mcycle_surp car_surp radio_surp television_surp rururb rururb_sur rururb_surp {
spearman prdw__10 `x'
local rho`x'=r(rho)
local p`x'=r(p)
local N`x'=r(N)
}



putexcel set "Census\Updated results\correlations_census_IHS\correlations_Census_pred10", replace

putexcel A1="Rank correlations between average predicted percapita consumption and HH features"

putexcel B3="Correlation coefficient"
putexcel C3="p-value"
putexcel D3="Observations"

putexcel A4="% HH with Improved walls"
putexcel A5="% HH with Improved roof"
putexcel A6="% HH with Improved floor"
putexcel A7="Aver. Child dependency ratio"
putexcel A8="Aver. Elderly dependency ratio"
putexcel A9="% HH with household head with primary education"
putexcel A10="% HH with household head with secondary education"
putexcel A11="% HH with household head with terciary education"
putexcel A12="% HH with literate household head"
putexcel A13="Average education years of household head"
putexcel A14="Household size"
putexcel A15="% HH own house"
putexcel A16="% HH have cellphone"
putexcel A17="% HH have fridge"
putexcel A18="% HH have stove"
putexcel A19="% HH have computer"
putexcel A20="% HH have oxcart"
putexcel A21="% HH have bicycle"
putexcel A22="% HH have motorcycle"
putexcel A23="% HH have car"
putexcel A24="% HH have radio"
putexcel A25="% HH have tv"
putexcel A26="% HH have fuel cooking: firewood"
putexcel A27="% HH have access to piped water"
putexcel A28="% HH have access to flush toilet"


putexcel A29="% HH with Improved walls (survey)"
putexcel A30="% HH with Improved roof (survey)"
putexcel A31="% HH with Improved floor (survey)"
putexcel A32="Aver. Child dependency ratio (survey)"
putexcel A33="Aver. Elderly dependency ratio (survey)"
putexcel A34="% HH with household head with primary education (survey)"
putexcel A35="% HH with household head with secondary education (survey)"
putexcel A36="% HH with household head with terciary education (survey)"
putexcel A37="% HH with literate household head (survey)"
putexcel A38="Average education years of household head (survey)"
putexcel A39="Household size (survey)"
putexcel A40="% HH own house"
putexcel A41="% HH have cellphone"
putexcel A42="% HH have fridge"
putexcel A43="% HH have stove"
putexcel A44="% HH have computer"
putexcel A45="% HH have oxcart"
putexcel A46="% HH have bicycle"
putexcel A47="% HH have motorcycle"
putexcel A48="% HH have car"
putexcel A49="% HH have radio"
putexcel A50="% HH have tv"
putexcel A51="% HH have fuel cooking: firewood"
putexcel A52="% HH have access to piped water"
putexcel A53="% HH have access to flush toilet"

putexcel A54="% HH with Improved walls (survey poorest)"
putexcel A55="% HH with Improved roof (survey poorest)"
putexcel A56="% HH with Improved floor (survey poorest)"
putexcel A57="Aver. Child dependency ratio (survey poorest)"
putexcel A58="Aver. Elderly dependency ratio (survey poorest)"
putexcel A59="% HH with household head with primary education (survey poorest)"
putexcel A60="% HH with household head with secondary education (survey poorest)"
putexcel A61="% HH with household head with terciary education (survey poorest)"
putexcel A62="% HH with literate household head (survey poorest)"
putexcel A63="Average education years of household head (survey poorest)"
putexcel A64="Household size (survey poorest)"
putexcel A65="% HH own house"
putexcel A66="% HH have cellphone"
putexcel A67="% HH have fridge"
putexcel A68="% HH have stove"
putexcel A69="% HH have computer"
putexcel A70="% HH have oxcart"
putexcel A71="% HH have bicycle"
putexcel A72="% HH have motorcycle"
putexcel A73="% HH have car"
putexcel A74="% HH have radio"
putexcel A75="% HH have tv"
putexcel A76="% HH have fuel cooking: firewood"
putexcel A77="% HH have access to piped water"
putexcel A78="% HH have access to flush toilet"

putexcel A79="Imputed reference welfare measure"
putexcel A80="Average per capita consumption (survey)"
putexcel A81="Average per capita consumption (survey poorest)"

putexcel A82="% HH urban"
putexcel A83="% HH urban(survey)"
putexcel A84="% HH urban (survey poorest)"

putexcel B4=`rhowall_improved' 
putexcel B5=`rhoroof_improved' 
putexcel B6=`rhofloor_improved' 
putexcel B7=`rhodepen_ch' 
putexcel B8=`rhodepen_old' 
putexcel B9=`rhoprim_edhh' 
putexcel B10=`rhosec_edhh' 
putexcel B11=`rhoter_edhh' 
putexcel B12=`rholiteracy_hh' 
putexcel B13=`rhoeduyr_hh' 
putexcel B14=`rhohhsize'
putexcel B15=`rhoownhouse'
putexcel B16=`rhocellphone'
putexcel B17=`rhofridge'
putexcel B18=`rhostove'
putexcel B19=`rhocomputer'
putexcel B20=`rhooxcart'
putexcel B21=`rhobcycle'
putexcel B22=`rhomcycle'
putexcel B23=`rhocar'
putexcel B24=`rhoradio'
putexcel B25=`rhotelevision'
putexcel B26=`rhocook_hh'
putexcel B27=`rhowater_hh'
putexcel B28=`rhoflushtoilet'

putexcel C4=`pwall_improved' 
putexcel C5=`proof_improved' 
putexcel C6=`pfloor_improved' 
putexcel C7=`pdepen_ch' 
putexcel C8=`pdepen_old' 
putexcel C9=`pprim_edhh' 
putexcel C10=`psec_edhh' 
putexcel C11=`pter_edhh' 
putexcel C12=`pliteracy_hh' 
putexcel C13=`peduyr_hh' 
putexcel C14=`phhsize'
putexcel C15=`pownhouse'
putexcel C16=`pcellphone'
putexcel C17=`pfridge'
putexcel C18=`pstove'
putexcel C19=`pcomputer'
putexcel C20=`poxcart'
putexcel C21=`pbcycle'
putexcel C22=`pmcycle'
putexcel C23=`pcar'
putexcel C24=`pradio'
putexcel C25=`ptelevision'
putexcel C26=`pcook_hh'
putexcel C27=`pwater_hh'
putexcel C28=`pflushtoilet'

putexcel D4=`Nwall_improved' 
putexcel D5=`Nroof_improved' 
putexcel D6=`Nfloor_improved' 
putexcel D7=`Ndepen_ch' 
putexcel D8=`Ndepen_old' 
putexcel D9=`Nprim_edhh' 
putexcel D10=`Nsec_edhh' 
putexcel D11=`Nter_edhh' 
putexcel D12=`Nliteracy_hh' 
putexcel D13=`Neduyr_hh' 
putexcel D14=`Nhhsize'
putexcel D15=`Nownhouse'
putexcel D16=`Ncellphone'
putexcel D17=`Nfridge'
putexcel D18=`Nstove'
putexcel D19=`Ncomputer'
putexcel D20=`Noxcart'
putexcel D21=`Nbcycle'
putexcel D22=`Nmcycle'
putexcel D23=`Ncar'
putexcel D24=`Nradio'
putexcel D25=`Ntelevision'
putexcel D26=`Ncook_hh'
putexcel D27=`Nwater_hh'
putexcel D28=`Nflushtoilet'

putexcel B29=`rhowall_improved_sur' 
putexcel B30=`rhoroof_improved_sur' 
putexcel B31=`rhofloor_improved_sur' 
putexcel B32=`rhodepen_ch_sur' 
putexcel B33=`rhodepen_old_sur' 
putexcel B34=`rhoprim_edhh_sur' 
putexcel B35=`rhosec_edhh_sur' 
putexcel B36=`rhoter_edhh_sur' 
putexcel B37=`rholiteracy_hh_sur' 
putexcel B38=`rhoeduyr_hh_sur' 
putexcel B39=`rhohhsize_sur'
putexcel B40=`rhoownhouse_sur'
putexcel B41=`rhocellphone_sur'
putexcel B42=`rhofridge_sur'
putexcel B43=`rhostove_sur'
putexcel B44=`rhocomputer_sur'
putexcel B45=`rhooxcart_sur'
putexcel B46=`rhobcycle_sur'
putexcel B47=`rhomcycle_sur'
putexcel B48=`rhocar_sur'
putexcel B49=`rhoradio_sur'
putexcel B50=`rhotelevision_sur'
putexcel B51=`rhocook_hh_sur'
putexcel B52=`rhowater_hh_sur'
putexcel B53=`rhoflushtoilet_sur'

putexcel C29=`pwall_improved_sur' 
putexcel C30=`proof_improved_sur' 
putexcel C31=`pfloor_improved_sur' 
putexcel C32=`pdepen_ch_sur' 
putexcel C33=`pdepen_old_sur' 
putexcel C34=`pprim_edhh_sur' 
putexcel C35=`psec_edhh_sur' 
putexcel C36=`pter_edhh_sur' 
putexcel C37=`pliteracy_hh_sur' 
putexcel C38=`peduyr_hh_sur' 
putexcel C39=`phhsize_sur'
putexcel C40=`pownhouse_sur'
putexcel C41=`pcellphone_sur'
putexcel C42=`pfridge_sur'
putexcel C43=`pstove_sur'
putexcel C44=`pcomputer_sur'
putexcel C45=`poxcart_sur'
putexcel C46=`pbcycle_sur'
putexcel C47=`pmcycle_sur'
putexcel C48=`pcar_sur'
putexcel C49=`pradio_sur'
putexcel C50=`ptelevision_sur'
putexcel C51=`pcook_hh_sur'
putexcel C52=`pwater_hh_sur'
putexcel C53=`pflushtoilet_sur'

putexcel D29=`Nwall_improved_sur' 
putexcel D30=`Nroof_improved_sur' 
putexcel D31=`Nfloor_improved_sur' 
putexcel D32=`Ndepen_ch_sur' 
putexcel D33=`Ndepen_old_sur' 
putexcel D34=`Nprim_edhh_sur' 
putexcel D35=`Nsec_edhh_sur' 
putexcel D36=`Nter_edhh_sur' 
putexcel D37=`Nliteracy_hh_sur' 
putexcel D38=`Neduyr_hh_sur' 
putexcel D39=`Nhhsize_sur'
putexcel D40=`Nownhouse_sur'
putexcel D41=`Ncellphone_sur'
putexcel D42=`Nfridge_sur'
putexcel D43=`Nstove_sur'
putexcel D44=`Ncomputer_sur'
putexcel D45=`Noxcart_sur'
putexcel D46=`Nbcycle_sur'
putexcel D47=`Nmcycle_sur'
putexcel D48=`Ncar_sur'
putexcel D49=`Nradio_sur'
putexcel D50=`Ntelevision_sur'
putexcel D51=`Ncook_hh_sur'
putexcel D52=`Nwater_hh_sur'
putexcel D53=`Nflushtoilet_sur'

putexcel B54=`rhowall_improved_surp' 
putexcel B55=`rhoroof_improved_surp' 
putexcel B56=`rhofloor_improved_surp' 
putexcel B57=`rhodepen_ch_surp' 
putexcel B58=`rhodepen_old_surp' 
putexcel B59=`rhoprim_edhh_surp' 
putexcel B60=`rhosec_edhh_surp' 
putexcel B61=`rhoter_edhh_surp' 
putexcel B62=`rholiteracy_hh_surp' 
putexcel B63=`rhoeduyr_hh_surp' 
putexcel B64=`rhohhsize_surp'
putexcel B65=`rhoownhouse_surp'
putexcel B66=`rhocellphone_surp'
putexcel B67=`rhofridge_surp'
putexcel B68=`rhostove_surp'
putexcel B69=`rhocomputer_surp'
putexcel B70=`rhooxcart_surp'
putexcel B71=`rhobcycle_surp'
putexcel B72=`rhomcycle_surp'
putexcel B73=`rhocar_surp'
putexcel B74=`rhoradio_surp'
putexcel B75=`rhotelevision_surp'
putexcel B76=`rhocook_hh_surp'
putexcel B77=`rhowater_hh_surp'
putexcel B78=`rhoflushtoilet_surp'

putexcel C54=`pwall_improved_surp' 
putexcel C55=`proof_improved_surp' 
putexcel C56=`pfloor_improved_surp' 
putexcel C57=`pdepen_ch_surp' 
putexcel C58=`pdepen_old_surp' 
putexcel C59=`pprim_edhh_surp' 
putexcel C60=`psec_edhh_surp' 
putexcel C61=`pter_edhh_surp' 
putexcel C62=`pliteracy_hh_surp' 
putexcel C63=`peduyr_hh_surp' 
putexcel C64=`phhsize_surp'
putexcel C65=`pownhouse_surp'
putexcel C66=`pcellphone_surp'
putexcel C67=`pfridge_surp'
putexcel C68=`pstove_surp'
putexcel C69=`pcomputer_surp'
putexcel C70=`poxcart_surp'
putexcel C71=`pbcycle_surp'
putexcel C72=`pmcycle_surp'
putexcel C73=`pcar_surp'
putexcel C74=`pradio_surp'
putexcel C75=`ptelevision_surp'
putexcel C76=`pcook_hh_surp'
putexcel C77=`pwater_hh_surp'
putexcel C78=`pflushtoilet_surp'

putexcel D54=`Nwall_improved_surp' 
putexcel D55=`Nroof_improved_surp' 
putexcel D56=`Nfloor_improved_surp' 
putexcel D57=`Ndepen_ch_surp' 
putexcel D58=`Ndepen_old_surp' 
putexcel D59=`Nprim_edhh_surp' 
putexcel D60=`Nsec_edhh_surp' 
putexcel D61=`Nter_edhh_surp' 
putexcel D62=`Nliteracy_hh_surp' 
putexcel D63=`Neduyr_hh_surp' 
putexcel D64=`Nhhsize_surp'
putexcel D65=`Nownhouse_surp'
putexcel D66=`Ncellphone_surp'
putexcel D67=`Nfridge_surp'
putexcel D68=`Nstove_surp'
putexcel D69=`Ncomputer_surp'
putexcel D70=`Noxcart_surp'
putexcel D71=`Nbcycle_surp'
putexcel D72=`Nmcycle_surp'
putexcel D73=`Ncar_surp'
putexcel D74=`Nradio_surp'
putexcel D75=`Ntelevision_surp'
putexcel D76=`Ncook_hh_surp'
putexcel D77=`Nwater_hh_surp'
putexcel D78=`Nflushtoilet_surp'

putexcel B79=`rhoprdc__10'
putexcel B80=`rholn_pcconsexp_raw_sur'
putexcel B81=`rholn_pcconsexp_raw_surp'

putexcel C79=`pprdc__10'
putexcel C80=`pln_pcconsexp_raw_sur'
putexcel C81=`pln_pcconsexp_raw_surp'

putexcel D79=`Nprdc__10'
putexcel D80=`Nln_pcconsexp_raw_sur'
putexcel D81=`Nln_pcconsexp_raw_surp'

putexcel B82=`rhorururb'
putexcel B83=`rhorururb_sur'
putexcel B84=`rhorururb_surp'

putexcel C82=`prururb'
putexcel C83=`prururb_sur'
putexcel C84=`prururb_surp'

putexcel D82=`Nrururb'
putexcel D83=`Nrururb_sur'
putexcel D84=`Nrururb_surp'

***Rank correlations
spearman  prdw__10 pccons_mean
local rhof10=r(rho)
local pf10=r(p)
local Nf10=r(N)

spearman  prdw__15 pccons_mean
local rhof15=r(rho)
local pf15=r(p)
local Nf15=r(N)

spearman  prdw__20 pccons_mean
local rhof20=r(rho)
local pf20=r(p)
local Nf20=r(N)


**********************************************************************
**-*UBR
use "Rdata/ihscoords_pts.poly7CT.dta", clear
bys ea_id: egen pccons_mean=mean(ln_pcc_)
bys ea_id: egen pccons_mean_raw=mean(ln_pc__)
keep ea_id pccons_mean pccons_mean_raw ID

duplicates drop
tempfile IHS
save `IHS' //692 ID . NAtional level, not only UBR

use "Rdata\pred_ubr_pts.poly7CT.dta", clear
collapse (mean) prdc__10 prdw__10 prdc__15 prdw__15 prdc__20 prdw__20, by(ID) //1741 ID, only UBR

merge 1:m ID using `IHS'
keep if _merge==3 // only 163 matched

***Rank correlations
spearman  prdw__10 pccons_mean
local rhou10=r(rho)
local pu10=r(p)
local Nu10=r(N)

spearman  prdw__15 ln_pccons_mean
local rhou15=r(rho)
local pu15=r(p)
local Nu15=r(N)

spearman  prdw__20 ln_pccons_mean
local rhou20=r(rho)
local pu20=r(p)
local Nu20=r(N)



putexcel set "Census\Updated results\Out of sample_april\predictions_vs_survey_benchmark", replace

putexcel A1="Rank correlations between True and Predicted consumption"

putexcel A3="Sample 1: 10%-90%"
putexcel A6="Sample 2: 15%-85%"
putexcel A9="Sample 2: 20%-80%"

putexcel B2="Predicted consumption based on Poorest 50% HH in all districts"
putexcel C2="Predicted consumption based on Poorest 50% HH in UBR districts"

putexcel B3=`rhof10'
putexcel B4=`pf10'
putexcel B5=`Nf10'

putexcel B6=`rhof15'
putexcel B7=`pf15'
putexcel B8=`Nf15'

putexcel B9=`rhof20'
putexcel B10=`pf20'
putexcel B11=`Nf20'

putexcel C3=`rhou10'
putexcel C4=`pu10'
putexcel C5=`Nu10'

putexcel C6=`rhou15'
putexcel C7=`pu15'
putexcel C8=`Nu15'

putexcel C9=`rhou20'
putexcel C10=`pu20'
putexcel C11=`Nu20'
