cd "C:\Users\melyg\Desktop\Malawi\Census"

use "only_id_census_string.dta", clear //dataset at village level only for UBR districts.
drop rururb UBR obs

/* Done in the server with complete sample
rename full_ta_code tacode_census
rename VILLAGE_NAME village_name
rename GVH_NAME gvh_name

drop if gvh_name==""
drop if village_name==""
*/

merge m:1 tacode_census using "TA_codes.dta"
keep if _merge==3
drop _merge
drop if taubr==""

/* Done in the server with complete sample
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
*/

egen id_ta_gvh=concat(taubr gvh_name), punct("_")
egen id_ta_gvh_num=group(taubr gvh_name)

egen id_tagvnvill=concat(id_ta_gvh village_name), punct("_")
egen id_tagvnvill_num=group(id_ta_gvh village_name)

duplicates lis id_tagvnvill // no duplicates

drop gvh_name0 gvh_name1 gvh_name2 vill_name0 vill_name1 vill_name2

*** Creating dataset for use matchit command later
preserve 
keep district id_tagvnvill id_tagvnvill_num
save "data_matchit_census", replace
restore

save "data_vill_level_census.dta", replace

*** Creating dataset for use matchit command later by district
foreach x in 102 104 201 202 203 204 206 209 304 305 {
use "data_matchit_census", clear
preserve
keep if district==`x'
save "data_matchit_census_`x'", replace
restore
}

************************************************************************************
use "C:\Users\melyg\Desktop\Malawi\UBR\UBR Data\UBR_comp_final.dta", clear
rename traditional_authority_name taubr
rename district_code district
rename group_village_head_name gvh_name_ubr

*** Cleaning variable for GVN
rename gvh_name_ubr gvh_name_ubr_orig
g gvh_name_ubr0=strlower(gvh_name_ubr_orig)
g gvh_name_ubr1=strrtrim(gvh_name_ubr0)
g gvh_name_ubr2=ustrltrim(gvh_name_ubr1)
g gvh_name_ubr=subinstr(gvh_name_ubr2,"'","",.)
replace gvh_name_ubr=subinstr(gvh_name_ubr,"`","",.)

*** Cleaning variable for village name
rename village_name village_name_orig
g vill_name0=strlower(village_name_orig)
g vill_name1=strrtrim(vill_name0)
g vill_name2=ustrltrim(vill_name1)
g village_name_ubr=subinstr(vill_name2,"'","",.)
replace village_name_ubr=subinstr(village_name_ubr,"`","",.)
replace village_name_ubr=subinstr(village_name_ubr,"_","",.)

recode district (324=305) (323=304) (210=204) (208=201) (215=206) (211=202) (209=203) (214=209) //recode district to have the same codes as in the census

***Renaming some GVH names to correct potential typos
do "rename_GVN_final.do"

bys  district taubr gvh_name_ubr village_name_ubr: g num=_n 
tab num if num <20
keep if num==1  //14983 villages in 10 districts ini UBR

egen id_ta_gvh=concat(taubr gvh_name_ubr), punct("_")
egen id_ta_gvh_num_ubr=group(taubr gvh_name_ubr)

merge m:1 id_ta_gvh using "GVN_matching_final.dta", keepusing(merge_gvn_final) // only 11089 villages were matched at GVN level/3894 unmatched
tab _merge
keep if _merge==3 //keep only the 11089=74.01%
drop _merge

egen id_tagvnvill=concat(id_ta_gvh village_name_ubr), punct("_")
egen id_tagvnvill_num_ubr=group(id_ta_gvh village_name_ubr)

duplicates list id_tagvnvill //0 duplicates

g  id_tagvnvill_ubr= id_tagvnvill

merge 1:1 id_tagvnvill using "data_vill_level_census.dta", keepusing(ta_census ta_census_orig gvh_name village_name id_ta_gvh) //first merge using the 11089 villages
tab _merge
drop if _merge==2
rename _merge merge_vill_1 //only 3423 merged 30.8% , 7666 villages unmatched

drop gvh_name_ubr0 gvh_name_ubr1 gvh_name_ubr2 num  vill_name0 vill_name1 vill_name2

*** Creating dataset for use matchit command later
preserve 
keep if merge_vill_1==1 //only the ones that were not matched 7666
keep district id_tagvnvill_ubr id_tagvnvill_num_ubr
save "unmatched1_for_matchit_ubr", replace
restore

keep district merge_vill_1 district_name taubr gvh_name_ubr_orig village_name_orig village_name_ubr id_ta_gvh id_tagvnvill id_tagvnvill_ubr ta_census gvh_name village_name
save "data_vill_level_UBR.dta", replace

keep if merge_vill_1==3
save "matched1_villages_UBR.dta", replace

*** Creating dataset for use matchit command later by district
use "unmatched1_for_matchit_ubr", clear
foreach x in 102 104 201 202 203 204 206 209 304 305 {
preserve
keep if district==`x'
save "data_matchit_ubr_`x'", replace
restore
}

*************************************************************************************
***Matching only allowing scores >= 0.9 by district
foreach x in 102 104 201 202 203 204 206 209 304 305 {
use "data_matchit_ubr_`x'", clear
matchit id_tagvnvill_num_ubr id_tagvnvill_ubr using "data_matchit_census_`x'.dta" , idu(id_tagvnvill_num) txtu(id_tagvnvill) threshold(0.9)
save matchit_vill_`x', replace
}

***Append the not cleaned matching in all districts
use matchit_vill_102, clear
append using matchit_vill_104
append using matchit_vill_201
append using matchit_vill_203
append using matchit_vill_204
append using matchit_vill_206
append using matchit_vill_209
append using matchit_vill_304
append using matchit_vill_305

save "not_cleanest_match_all", replace

***Selecting only unique matches: if the id in the census it's been used only one time
use "not_cleanest_match_all", clear
sort id_tagvnvill_ubr similscore

bys id_tagvnvill_ubr: egen double max_score=max(similscore)
drop if similscore!=max_score //keeping matched with highest score end up with 1903 cases

bys id_tagvnvill_ubr: gen obs=_N
tab obs
drop if obs==2 //checked and none of the duplicates were valid so delete them. 1893 cases
drop obs

bys id_tagvnvill: g times_used=_N //check duplicates in census villages matched to ubr villages
tab times_used //387 duplicates

bys id_tagvnvill: egen double max_score_used=max(similscore)
drop if similscore!=max_score_used & times_used>3 //for census villages used more than 3 times, keep the match with the highest score. 1771 cases

bys id_tagvnvill: g times_used2=_N
tab times_used2 //243 duplicates that have to clean manually
drop times_used max_score_used max_score

save "villages_after_matchit", replace

***Merge unmatched data with matchit data to get TA and district info for rename
use "unmatched1_for_matchit_ubr", clear
merge 1:1 id_tagvnvill_ubr using "villages_after_matchit"
keep if _merge==3
drop _merge

split id_tagvnvill_ubr, p("_")
egen id_tagvh_match_ubr=concat(id_tagvnvill_ubr1 id_tagvnvill_ubr2), punct("_")
drop id_tagvnvill_ubr1 id_tagvnvill_ubr2
split id_tagvnvill, p("_")
egen id_tagvh_match=concat(id_tagvnvill1 id_tagvnvill2), punct("_")
drop id_tagvnvill1 id_tagvnvill2

rename id_tagvnvill_ubr3 village_name_ubr
rename id_tagvnvill3 village_name

***Check the ones that have at least the same TA and GVN
g check=1 if id_tagvh_match_ubr==id_tagvh_match
br if check==.
drop if check==. //1727 cases to clean manually/*after cleaning 1379

************************************************************************************
************************************************************************************
***Final matching after rename
use "C:\Users\melyg\Desktop\Malawi\UBR\UBR Data\UBR_comp_final_v2.dta", clear
rename traditional_authority_name taubr
rename district_code district
rename group_village_head_name gvh_name_ubr

*** Cleaning variable for GVN
rename gvh_name_ubr gvh_name_ubr_orig
g gvh_name_ubr0=strlower(gvh_name_ubr_orig)
g gvh_name_ubr1=strrtrim(gvh_name_ubr0)
g gvh_name_ubr2=ustrltrim(gvh_name_ubr1)
g gvh_name_ubr=subinstr(gvh_name_ubr2,"'","",.)
replace gvh_name_ubr=subinstr(gvh_name_ubr,"`","",.)

*** Cleaning variable for village name
rename village_name village_name_orig
g vill_name0=strlower(village_name_orig)
g vill_name1=strrtrim(vill_name0)
g vill_name2=ustrltrim(vill_name1)
g village_name_ubr=subinstr(vill_name2,"'","",.)
replace village_name_ubr=subinstr(village_name_ubr,"`","",.)
replace village_name_ubr=subinstr(village_name_ubr,"_","",.)

recode district (324=305) (323=304) (210=204) (208=201) (215=206) (211=202) (209=203) (214=209) //recode district to have the same codes as in the census
drop gvh_name_ubr0 gvh_name_ubr1 gvh_name_ubr2 vill_name0 vill_name1 vill_name2

***Renaming some GVH names to correct potential typos
do "Code/rename_GVN_final.do"

***Generating ID for GVN
egen id_ta_gvh=concat(taubr gvh_name_ubr), punct("_")
egen id_ta_gvh_num_ubr=group(taubr gvh_name_ubr)

***Final rename after matchit
do "Code/rename_vill_final.do"

***Generating ID for villages
egen id_tagvnvill=concat(id_ta_gvh village_name_ubr), punct("_")
egen id_tagvnvill_num_ubr=group(id_ta_gvh village_name_ubr)

***Generating variables at village level
bys id_tagvnvill household_id: g obs=_n //keeping data at household level 
keep if obs==1

*** House ownership
g house_own=0 if house_ownership!=""
replace house_own=1 if house_ownership=="Owned"
label var house_own "HHs own house"

*** House condition
g house_cond=0 if house_condition!=""
replace house_cond=1 if house_condition=="Bad"
label var house_cond "HHs house in bad condition" //compared with average and good

***Wall improved
g wall_improved= 1 if wall_type!=""
replace wall_improved=0 if wall_type=="Burnt Bricks" | wall_type=="Grass" | wall_type=="Mud"
label var wall_improved "House with improved walls"

***Floor improved
g floor_improved= 1 if floor_type!=""
replace floor_improved=0 if floor_type=="Mud" | floor_type=="Sand" | floor_type=="Other"
label var floor_improved "House with improved floor"

***Toilet improved
g toilet_improved= 1 if latrine_type!=""
replace toilet_improved=0 if latrine_type=="Latrine W/O Roof" | latrine_type=="No Toilet" | latrine_type=="Other Toilet" 
label var toilet_improved "House with improved latrine or flush toilet"

*** Owns land
g land_own=0 if land_ownership!=""
replace land_own=1 if land_ownership=="YES"
label var land_own "HHs own land"

*** Has irrigated land
g irrig_land=0 if irrigated_land!=""
replace irrig_land=1 if irrigated_land=="YES"
label var irrig_land "HHs have irrigated land"

*** Crop failure
g crop_failure1=0 if crop_failure!=""
replace crop_failure1=1 if crop_failure=="YES"
label var crop_failure1 "HHs had crop failure"

*** Crop failure
g assistance_received1=0 if assistance_received!=""
replace assistance_received1=1 if assistance_received=="YES"
label var assistance_received1 "HHs received assitance"

*** Wealth quintile
g richbetter=0 if wealth_quintile!=""
replace richbetter=1 if wealth_quintile=="Better-off" | wealth_quintile=="Rich"
label var richbetter "Rich/betteroff HHs"

g poors=0 if wealth_quintile!=""
replace poors=1 if wealth_quintile=="Poorest"
label var poors "Poorest HHs"

*** Poor foods
g poor_food=.
replace poor_food=1 if meals=="1 meal per day" | meals=="None"
replace poor_food=0 if poor_food==.

*** Savings
g save=.
replace save=1 if savings=="YES" 
replace save=0 if save==.

***Determinants of pmt_score
reg pmt_score house_own house_cond wall_improved floor_improved toilet_improved land_own irrig_land crop_failure1 assistance_received1 richbetter poors poor_food save,r
outreg2 using "Results/pmt_determinants.xls",  replace  tex(pretty landscape) dec(3) addtext(District FE, No)  nonotes label ctitle(" ")
reg pmt_score house_own house_cond wall_improved floor_improved toilet_improved land_own irrig_land crop_failure1 assistance_received1 richbetter poors poor_food save i.district,r
outreg2 using "Results/pmt_determinants.xls",  append drop(i.district) tex(pretty landscape) dec(3) addtext(District FE, Yes)  nonotes label ctitle(" ")

bys id_tagvnvill: egen hhsize_vill=median(household_size)
bys id_tagvnvill: gen hhnum_vill=_N
bys id_tagvnvill: egen pmtmean_vill=mean(pmt_score)
bys id_tagvnvill: egen pmtmax_vill=max(pmt_score)
bys id_tagvnvill: egen pmtmin_vill=min(pmt_score)
bys id_tagvnvill: egen houseown_vill=mean(house_own)
bys id_tagvnvill: egen housebad_vill=mean(house_cond)
bys id_tagvnvill: egen wallimprov_vill=mean(wall_improved)
bys id_tagvnvill: egen floorimprov_vill=mean(floor_improved)
bys id_tagvnvill: egen toiletimprov_vill=mean(toilet_improved)
bys id_tagvnvill: egen landown_vill=mean(land_own)
bys id_tagvnvill: egen landirr_vill=mean(irrig_land)
bys id_tagvnvill: egen arabland_vill=median(arable_land_owned)
bys id_tagvnvill: egen wetland_vill=median(wet_land_owned)
bys id_tagvnvill: egen richbetter_vill=mean(richbetter)
bys id_tagvnvill: egen poors_vill=mean(poors)
bys id_tagvnvill: egen cropfail_vill=mean(crop_failure1)
bys id_tagvnvill: egen assitsreceived_vill=mean(assistance_received1)
bys id_tagvnvill: egen poorsh_vill=mean(poors)
bys id_tagvnvill: egen richsh_vill=mean(richbetter)
bys id_tagvnvill: egen poorfoodsh_vill=mean(poor_food)
bys id_tagvnvill: egen savesh_vill=mean(save)

label var hhsize_vill "Average HH size per village"
label var hhnum_vill "NUmber of HH per village"
label var pmtmean_vill "Average PMT score per village"
label var pmtmax_vill "Max. PMT score per village"
label var pmtmin_vill "Min. PMT score per village"
label var houseown_vill "Share of HH own house"
label var housebad_vill "Share of HH in bad house"
label var wallimprov_vill "Share of HH with improved walls"
label var floorimprov_vill "Share of HH with improved floor"
label var toiletimprov_vill "Share of HH with improved toilet"
label var landown_vill "Share of HH that own land"
label var landirr_vill "Share of HH have irrigation land"
label var arabland_vill "Average area of arable land"
label var wetland_vill "Average area of wet land"
label var richbetter_vill "Share of richest/better off HH"
label var poors_vill "Share of poor HH"
label var cropfail_vill "Share of HH with crop failure"
label var assitsreceived_vill "Share of HHs received help"
label var poorsh_vill "Share of poor HH"
label var richsh_vill "Share of rich HH"
label var poorfoodsh_vill "Share of HH that have <=1 meal per day"
label var savesh_vill "Share of HH that have savings"

***Determinants of pmt_score at village level
reg pmtmean_vill hhsize_vill hhnum_vill houseown_vill housebad_vill wallimprov_vill floorimprov_vill toiletimprov_vill landown_vill landirr_vill arabland_vill wetland_vill richbetter_vill  poorsh_vill cropfail_vill assitsreceived_vill poorfoodsh_vill savesh_vill,r
outreg2 using "Results/villpmt_determinants.xls",  replace  tex(pretty landscape) dec(3) addtext(District FE, No)  nonotes label ctitle("Mean PMT")
reg pmtmean_vill hhsize_vill hhnum_vill houseown_vill housebad_vill wallimprov_vill floorimprov_vill toiletimprov_vill landown_vill landirr_vill arabland_vill wetland_vill richbetter_vill  poorsh_vill cropfail_vill assitsreceived_vill poorfoodsh_vill savesh_vill i.district,r
outreg2 using "Results/villpmt_determinants.xls",  append drop(i.district) tex(pretty landscape) dec(3) addtext(District FE, Yes)  nonotes label ctitle("Mean PMT")

reg pmtmax_vill hhsize_vill hhnum_vill houseown_vill housebad_vill wallimprov_vill floorimprov_vill toiletimprov_vill landown_vill landirr_vill arabland_vill wetland_vill richbetter_vill  poorsh_vill cropfail_vill assitsreceived_vill poorfoodsh_vill savesh_vill,r
outreg2 using "Results/villpmt_determinants.xls",  append  tex(pretty landscape) dec(3) addtext(District FE, No)  nonotes label ctitle("Max PMT")
reg pmtmax_vill hhsize_vill hhnum_vill houseown_vill housebad_vill wallimprov_vill floorimprov_vill toiletimprov_vill landown_vill landirr_vill arabland_vill wetland_vill richbetter_vill  poorsh_vill cropfail_vill assitsreceived_vill poorfoodsh_vill savesh_vill i.district,r
outreg2 using "Results/villpmt_determinants.xls",  append drop(i.district) tex(pretty landscape) dec(3) addtext(District FE, Yes)  nonotes label ctitle("Max PMT")

reg pmtmin_vill hhsize_vill hhnum_vill houseown_vill housebad_vill wallimprov_vill floorimprov_vill toiletimprov_vill landown_vill landirr_vill arabland_vill wetland_vill richbetter_vill  poorsh_vill cropfail_vill assitsreceived_vill poorfoodsh_vill savesh_vill,r
outreg2 using "Results/villpmt_determinants.xls",  append  tex(pretty landscape) dec(3) addtext(District FE, No)  nonotes label ctitle("Min PMT")
reg pmtmin_vill hhsize_vill hhnum_vill houseown_vill housebad_vill wallimprov_vill floorimprov_vill toiletimprov_vill landown_vill landirr_vill arabland_vill wetland_vill richbetter_vill poorsh_vill cropfail_vill assitsreceived_vill poorfoodsh_vill savesh_vill i.district,r
outreg2 using "Results/villpmt_determinants.xls",  append drop(i.district) tex(pretty landscape) dec(3) addtext(District FE, Yes)  nonotes label ctitle("Min PMT")


***Keeping data at village level
bys  district taubr gvh_name_ubr village_name_ubr: g num=_n 
tab num if num <20
keep if num==1  //14908 villages in 10 districts ini UBR

merge m:1 id_ta_gvh using "GVN_matching_final.dta", keepusing(merge_gvn_final) // only 11014 villages were matched at GVN level/3894 unmatched
tab _merge
keep if _merge==3 //keep only the 11014=73.88%
drop _merge

duplicates list id_tagvnvill //0 duplicates

g  id_tagvnvill_ubr= id_tagvnvill

merge 1:1 id_tagvnvill using "data_vill_level_census.dta", keepusing(ta_census ta_census_orig gvh_name village_name id_ta_gvh) //first merge using the 11014 villages
tab _merge
drop if _merge==2
rename _merge merge_vill_2 //only 4727 merged 42.9% , 6287 villages unmatched


*** Creating dataset for use matchit command later
preserve 
keep if merge_vill_2==1 //only the ones that were not matched 6287
save "villages_unmatched_ubr2", replace
restore

recode merge_vill_2 (3=0) (1=1)
label define merge_vill_2 0 "Unmerged" 1 "Merged"
label value merge_vill_2 merge_vill_2

*keep if merge_vill_2==3
save "village_matching_final.dta", replace

*****************************************************************************************
use "village_matching_final.dta", clear
g unmerged=1 if merge_vill_2==0
replace unmerged=0 if merge_vill_2==1
tab unmerged

label define unmerged 1 "Unmerged" 0 "Merged"
label value unmerged unmerged

label define district 102 "Karonga" 104 "Rumphi" 201 "Kasungu" 202 "Nkhotakota" 203 "Ntchisi" 204 "Dowa" 206 "Lilongwe Rural" 209 "Ntcheu" 304 "Chiradzulu" 305 "Blantyre Rural"
label value district district

tab district merge_vill_2
tab district poors_vill

estpost ttest hhsize_vill hhnum_vill pmtmean_vill /*pmtmax_vill pmtmin_vill*/ houseown_vill ///
housebad_vill wallimprov_vill floorimprov_vill toiletimprov_vill landown_vill landirr_vill ///
arabland_vill wetland_vill richbetter_vill poors_vill cropfail_vil assitsreceived_vill , by(merge_vill_2)
esttab, wide nonumber mtitle("diff.")
esttab . using Table1.csv, replace wide nonumber mtitle("diff.")

***Checking matched vs. unmatched villages 
foreach x in 102 104 201 202 203 204 206 209 304 305 {

estpost ttest hhsize_vill hhnum_vill pmtmean_vill /*pmtmax_vill pmtmin_vill*/ houseown_vill ///
housebad_vill wallimprov_vill floorimprov_vill toiletimprov_vill landown_vill landirr_vill ///
arabland_vill wetland_vill richbetter_vill poors_vill cropfail_vil assitsreceived_vill if district==`x', by(merge_vill_2)
esttab, wide nonumber mtitle("diff.")
esttab . using Table1`x'.csv, replace wide nonumber mtitle("diff.")
}

global vars = "hhsize_vill hhnum_vill pmtmean_vill houseown_vill housebad_vill wallimprov_vill floorimprov_vill toiletimprov_vill landown_vill landirr_vill arabland_vill wetland_vill richbetter_vill poors_vill cropfail_vil assitsreceived_vill"

foreach var in $vars {
	ttest `var', by(merge_vill_2)
	return list
	local m_`var'=r(mu_1)
	local um_`var'=r(mu_2)
	local p_`var'=r(p)
}

putexcel set "merged_unmerged", replace

putexcel A2="Avg. household size"
putexcel A3="Avg.number of HH in the village"
putexcel A4="Avg PMT score"
putexcel A5="Share of HH that own a house"
putexcel A6="Share of HH in houses in bad conditions"
putexcel A7="Share of HH with improved walls"
putexcel A8="Share of HH with improved floor"
putexcel A9="Share of HH with improved toilet"
putexcel A10="Share of HH that own a land"
putexcel A11="Share of HH that own irrigated land"
putexcel A12="Share of HH that own arable land"
putexcel A13="Share of HH that own wet land"
putexcel A14="Share of HH in highest percentile"
putexcel A15="Share of HH in poorest percentile"
putexcel A16="Share of HH that have failed crop"
putexcel A17="Share of HH that received assitance"


putexcel C2=`m_hhsize_vill'
putexcel D2=`um_hhsize_vill'
putexcel E2=`p_hhsize_vill'

putexcel C3=`m_hhnum_vill'
putexcel D3=`um_hhnum_vill'
putexcel E3=`p_hhnum_vill'

putexcel C4=`m_pmtmean_vill'
putexcel D4=`um_pmtmean_vill'
putexcel E4=`p_pmtmean_vill'

putexcel C5=`m_houseown_vill'
putexcel D5=`um_houseown_vill'
putexcel E5=`p_houseown_vill'

putexcel C6=`m_housebad_vill'
putexcel D6=`um_housebad_vill'
putexcel E6=`p_housebad_vill'

putexcel C7=`m_wallimprov_vill'
putexcel D7=`um_wallimprov_vill'
putexcel E7=`p_wallimprov_vill'

putexcel C8=`m_floorimprov_vill'
putexcel D8=`um_floorimprov_vill'
putexcel E8=`p_floorimprov_vill'

putexcel C9=`m_toiletimprov_vill'
putexcel D9=`um_toiletimprov_vill'
putexcel E9=`p_toiletimprov_vill'

putexcel C10=`m_landown_vill'
putexcel D10=`um_landown_vill'
putexcel E10=`p_landown_vill'

putexcel C11=`m_landirr_vill'
putexcel D11=`um_landirr_vill'
putexcel E11=`p_landirr_vill'

putexcel C12=`m_arabland_vill'
putexcel D12=`um_arabland_vill'
putexcel E12=`p_arabland_vill'

putexcel C13=`m_wetland_vill'
putexcel D13=`um_wetland_vill'
putexcel E13=`p_wetland_vill'

putexcel C14=`m_richbetter_vill'
putexcel D14=`um_richbetter_vill'
putexcel E14=`p_richbetter_vill'

putexcel C15=`m_poors_vill'
putexcel D15=`um_poors_vill'
putexcel E15=`p_poors_vill'

putexcel C16=`m_cropfail_vil'
putexcel D16=`um_cropfail_vil'
putexcel E16=`p_cropfail_vil'

putexcel C17=`m_assitsreceived_vill'
putexcel D17=`um_assitsreceived_vill'
putexcel E17=`p_assitsreceived_vill'

***Using regression
foreach var in $vars {
reg `var' merge_vill_2 [w= hhnum_vill], r cl( district)
estadd ysumm
local p_`var'=e(ymean)
return list
mat A=r(table)
local m_`var'=A[1,1]
local um_`var'=A[4,1]
}

putexcel set "merged_unmerged_regression", replace

putexcel A2="Avg. household size"
putexcel A3="Avg.number of HH in the village"
putexcel A4="Avg PMT score"
putexcel A5="Share of HH that own a house"
putexcel A6="Share of HH in houses in bad conditions"
putexcel A7="Share of HH with improved walls"
putexcel A8="Share of HH with improved floor"
putexcel A9="Share of HH with improved toilet"
putexcel A10="Share of HH that own a land"
putexcel A11="Share of HH that own irrigated land"
putexcel A12="Share of HH that own arable land"
putexcel A13="Share of HH that own wet land"
putexcel A14="Share of HH in highest percentile"
putexcel A15="Share of HH in poorest percentile"
putexcel A16="Share of HH that have failed crop"
putexcel A17="Share of HH that received assitance"

putexcel C2=`m_hhsize_vill'
putexcel D2=`um_hhsize_vill'
putexcel E2=`p_hhsize_vill'

putexcel C3=`m_hhnum_vill'
putexcel D3=`um_hhnum_vill'
putexcel E3=`p_hhnum_vill'

putexcel C4=`m_pmtmean_vill'
putexcel D4=`um_pmtmean_vill'
putexcel E4=`p_pmtmean_vill'

putexcel C5=`m_houseown_vill'
putexcel D5=`um_houseown_vill'
putexcel E5=`p_houseown_vill'

putexcel C6=`m_housebad_vill'
putexcel D6=`um_housebad_vill'
putexcel E6=`p_housebad_vill'

putexcel C7=`m_wallimprov_vill'
putexcel D7=`um_wallimprov_vill'
putexcel E7=`p_wallimprov_vill'

putexcel C8=`m_floorimprov_vill'
putexcel D8=`um_floorimprov_vill'
putexcel E8=`p_floorimprov_vill'

putexcel C9=`m_toiletimprov_vill'
putexcel D9=`um_toiletimprov_vill'
putexcel E9=`p_toiletimprov_vill'

putexcel C10=`m_landown_vill'
putexcel D10=`um_landown_vill'
putexcel E10=`p_landown_vill'

putexcel C11=`m_landirr_vill'
putexcel D11=`um_landirr_vill'
putexcel E11=`p_landirr_vill'

putexcel C12=`m_arabland_vill'
putexcel D12=`um_arabland_vill'
putexcel E12=`p_arabland_vill'

putexcel C13=`m_wetland_vill'
putexcel D13=`um_wetland_vill'
putexcel E13=`p_wetland_vill'

putexcel C14=`m_richbetter_vill'
putexcel D14=`um_richbetter_vill'
putexcel E14=`p_richbetter_vill'

putexcel C15=`m_poors_vill'
putexcel D15=`um_poors_vill'
putexcel E15=`p_poors_vill'

putexcel C16=`m_cropfail_vil'
putexcel D16=`um_cropfail_vil'
putexcel E16=`p_cropfail_vil'

putexcel C17=`m_assitsreceived_vill'
putexcel D17=`um_assitsreceived_vill'
putexcel E17=`p_assitsreceived_vill'



