cd "C:\Users\melyg\Desktop\Malawi\SAEplus\data2\data_gee2"

***Monthly data
foreach name in ndvi ndwi prec nightl {
	forvalues x=15(1)18 {
		forvalues i=1(1)12 {
		use d`name'7_malawi`x'_`i', clear  
		drop GID_0 NAME_0
		rename mean  `name'_mean_`i'_`x'
		save "final/f`name'7_malawi`x'_`i'", replace
}
}
}

forvalues x=16(1)18 {
forvalues i=1(1)12 {
	use dsoilm7_malawi`x'_`i', clear  
	drop GID_0 NAME_0
	rename mean  soilm_mean_`i'_`x'
	save "final/fsoilm7_malawi`x'_`i'", replace
}
}

forvalues i=4(1)12 {
	use dsoilm7_malawi15_`i', clear  
	drop GID_0 NAME_0
	rename mean  soilm_mean_`i'_15
	save "final/fsoilm7_malawi15_`i'", replace
}

***Annual data
foreach name in crops moss grass shrub bare waterperm waterseas urban {
	forvalues x=15(1)18 {
		use d`name'7_malawi_`x', clear  
		drop GID_0 NAME_0
		rename mean  `name'_mean_`x'
		save "final/f`name'7_malawi_`x'", replace
}
}

	forvalues x=15(1)18 {
		use dltype7_malawi_`x', clear  
		drop GID_0 NAME_0
		rename median  ltype_median_`x'
		save "final/fltype7_malawi_`x'", replace
}

***Annual data for historical means
foreach name in prec ndvi ndwi {
	forvalues x=1(1)16 {
		use d`name'7_malawi_`x', clear  
		drop GID_0 NAME_0
		rename mean  h`name'_mean_`x'
		save "hist/h`name'7_malawi_`x'", replace
}
}

***Creating pooled datasets for annual data
forvalues v=15(1)18 {
use "final/fcrops7_malawi_`v'", clear  
foreach name in grass moss shrub bare waterperm waterseas urban ltype {
	merge 1:1 ID using "final/f`name'7_malawi_`v'.dta"
	drop _merge
	order ID
}
save "complete/copernicus7_malawi_`v'", replace
}

***Creating pooled data for historical means of prec, ndvi and ndwi
foreach name in prec ndvi ndwi {
use "hist/h`name'7_malawi_1", clear  
forvalues v=2(1)16 {
	merge 1:1 ID using "hist/h`name'7_malawi_`v'.dta"
	drop _merge
	order ID
}
save "complete/historical7_malawi_`name'", replace
}

***Creating annual datasets for monthly data
foreach name in ndvi ndwi prec nightl  {
forvalues v=15(1)18 {
use "final/f`name'7_malawi`v'_1", clear  
forvalues i=2(1)12 {
	merge 1:1 ID using "final/f`name'7_malawi`v'_`i'"
	drop _merge
	order ID
}
save "complete/c`name'7_malawi`v'", replace
}
}

forvalues v=16(1)18 {
use "final/fsoilm7_malawi`v'_1", clear  
forvalues i=2(1)12 {
	merge 1:1 ID using "final/fsoilm7_malawi`v'_`i'"
	drop _merge
	order ID
}
save "complete/csoilm7_malawi`v'", replace
}

use "final/fsoilm7_malawi15_4", clear  
forvalues i=5(1)12 {
	merge 1:1 ID using "final/fsoilm7_malawi15_`i'"
	drop _merge
	order ID
}
save "complete/csoilm7_malawi15", replace

**Creating data from copernicus
use "complete/copernicus7_malawi_15", clear
merge 1:1 ID using "complete/copernicus7_malawi_16"
drop _merge
merge 1:1 ID using "complete/copernicus7_malawi_17"
drop _merge
merge 1:1 ID using "complete/copernicus7_malawi_18"
drop _merge
save "def/copernicus7_malawi_wide", replace

reshape long crops_mean_ grass_mean_ moss_mean_ class_mean_ shrub_mean_ bare_mean_ urban_mean waterperm_mean_ waterseas_mean_ ltype_median_, i(ID) j(year)
recode year (15=2015) (16=2016) (17=2017) (18=2018)
save "def/copernicus7_malawi_long", replace

***Processing monthly data

***Precipitation
***Creating annual variable y seasonal variable
use "complete/cprec7_malawi15", clear
merge 1:1 ID using  "complete/cprec7_malawi16"
drop _merge
merge 1:1 ID using  "complete/cprec7_malawi17"
drop _merge
merge 1:1 ID using  "complete/cprec7_malawi18"
drop _merge

***Seasonal precipitation
***Dry seasonal
forvalues i=15(1)18 {
egen dry`i'=rmean(prec_mean_5_`i' prec_mean_6_`i' prec_mean_7_`i' prec_mean_8_`i' prec_mean_9_`i' prec_mean_10_`i')
egen wet`i'_1=rmean(prec_mean_1_`i' prec_mean_2_`i' prec_mean_3_`i' prec_mean_4_`i')
egen wet`i'_2=rmean(prec_mean_11_`i' prec_mean_12_`i')
}
egen precseas15=rmean(dry15 wet15_1 wet15_2)
egen precseas16=rmean(wet15_2 dry16 wet16_1 wet16_2)
egen precseas17=rmean(wet16_2 dry17 wet17_1 wet17_2)
egen precseas18=rmean(wet17_2 dry18 wet18_1 wet18_2)

***Average annual precipitation
forvalues i=15(1)18 {
egen precyr`i'=rmean(prec_mean_1_`i' prec_mean_2_`i' prec_mean_3_`i' prec_mean_4_`i' prec_mean_5_`i' prec_mean_6_`i' prec_mean_7_`i' prec_mean_8_`i' prec_mean_9_`i' prec_mean_10_`i' prec_mean_11_`i' prec_mean_12_`i')
}
drop wet* dry*
keep precseas15 precseas16 precseas17 precseas18 precyr15 precyr16 precyr17 precyr18 ID
save "def/prec7_malawi", replace

***Creating short dataset only with annual ans seasonal variables
reshape long precseas precyr , i(ID) j(year)
recode year (15=2015) (16=2016) (17=2017) (18=2018)
save "def/prec7_malawi_short", replace


***Vegetation index
***Creating annual variable y seasonal variable
use "complete/cndvi7_malawi15", clear
merge 1:1 ID using  "complete/cndvi7_malawi16"
drop _merge
merge 1:1 ID using  "complete/cndvi7_malawi17"
drop _merge
merge 1:1 ID using  "complete/cndvi7_malawi18"
drop _merge

***Seasonal ndvi
***Dry seasonal
forvalues i=15(1)18 {
egen dry`i'=rmean(ndvi_mean_5_`i' ndvi_mean_6_`i' ndvi_mean_7_`i' ndvi_mean_8_`i' ndvi_mean_9_`i' ndvi_mean_10_`i')
egen wet`i'_1=rmean(ndvi_mean_1_`i' ndvi_mean_2_`i' ndvi_mean_3_`i' ndvi_mean_4_`i')
egen wet`i'_2=rmean(ndvi_mean_11_`i' ndvi_mean_12_`i')
}

egen ndviseas15=rmean(dry15 wet15_1 wet15_2)
egen ndviseas16=rmean(wet15_2 dry16 wet16_1 wet16_2)
egen ndviseas17=rmean(wet16_2 dry17 wet17_1 wet17_2)
egen ndviseas18=rmean(wet17_2 dry18 wet18_1 wet18_2)

***Average annual ndvi
forvalues i=15(1)18 {
egen ndviyr`i'=rmean(ndvi_mean_1_`i' ndvi_mean_2_`i' ndvi_mean_3_`i' ndvi_mean_4_`i' ndvi_mean_5_`i' ndvi_mean_6_`i' ndvi_mean_7_`i' ndvi_mean_8_`i' ndvi_mean_9_`i' ndvi_mean_10_`i' ndvi_mean_11_`i' ndvi_mean_12_`i')
}
drop wet* dry*
keep ndviseas15 ndviseas16 ndviseas17 ndviseas18 ndviyr15 ndviyr16 ndviyr17 ndviyr18 ID
save "def/ndvi7_malawi", replace

***Creating short dataset only with annual ans seasonal variables
reshape long ndviseas ndviyr , i(ID) j(year)
recode year (15=2015) (16=2016) (17=2017) (18=2018)
save "def/ndvi7_malawi_short", replace


***Water index
***Creating annual variable y seasonal variable
use "complete/cndwi7_malawi15", clear
merge 1:1 ID using  "complete/cndwi7_malawi16"
drop _merge
merge 1:1 ID using  "complete/cndwi7_malawi17"
drop _merge
merge 1:1 ID using  "complete/cndwi7_malawi18"
drop _merge

***Seasonal ndwi
***Dry seasonal
forvalues i=15(1)18 {
egen dry`i'=rmean(ndwi_mean_5_`i' ndwi_mean_6_`i' ndwi_mean_7_`i' ndwi_mean_8_`i' ndwi_mean_9_`i' ndwi_mean_10_`i')
egen wet`i'_1=rmean(ndwi_mean_1_`i' ndwi_mean_2_`i' ndwi_mean_3_`i' ndwi_mean_4_`i')
egen wet`i'_2=rmean(ndwi_mean_11_`i' ndwi_mean_12_`i')
}

egen ndwiseas15=rmean(dry15 wet15_1 wet15_2)
egen ndwiseas16=rmean(wet15_2 dry16 wet16_1 wet16_2)
egen ndwiseas17=rmean(wet16_2 dry17 wet17_1 wet17_2)
egen ndwiseas18=rmean(wet17_2 dry18 wet18_1 wet18_2)

***Average annual ndwi
forvalues i=15(1)18 {
egen ndwiyr`i'=rmean(ndwi_mean_1_`i' ndwi_mean_2_`i' ndwi_mean_3_`i' ndwi_mean_4_`i' ndwi_mean_5_`i' ndwi_mean_6_`i' ndwi_mean_7_`i' ndwi_mean_8_`i' ndwi_mean_9_`i' ndwi_mean_10_`i' ndwi_mean_11_`i' ndwi_mean_12_`i')
}
drop wet* dry*
keep ndwiseas15 ndwiseas16 ndwiseas17 ndwiseas18 ndwiyr15 ndwiyr16 ndwiyr17 ndwiyr18 ID
save "def/ndwi7_malawi", replace

***Creating short dataset only with annual ans seasonal variables
reshape long ndwiseas ndwiyr , i(ID) j(year)
recode year  (15=2015) (16=2016) (17=2017) (18=2018)
save "def/ndwi7_malawi_short", replace

***Soil moisture
***Creating annual variable y seasonal variable
use "complete/csoilm7_malawi15", clear
merge 1:1 ID using  "complete/csoilm7_malawi16"
drop _merge
merge 1:1 ID using  "complete/csoilm7_malawi17"
drop _merge
merge 1:1 ID using  "complete/csoilm7_malawi18"
drop _merge


***Seasonal soil
***Dry seasonal
forvalues i=16(1)18 {
egen dry`i'=rmean(soilm_mean_5_`i' soilm_mean_6_`i' soilm_mean_7_`i' soilm_mean_8_`i' soilm_mean_9_`i' soilm_mean_10_`i')
egen wet`i'_1=rmean(soilm_mean_1_`i' soilm_mean_2_`i' soilm_mean_3_`i' soilm_mean_4_`i')
egen wet`i'_2=rmean(soilm_mean_11_`i' soilm_mean_12_`i')
}

egen dry15=rmean(soilm_mean_5_15 soilm_mean_6_15 soilm_mean_7_15 soilm_mean_8_15 soilm_mean_9_15 soilm_mean_10_15)
egen wet15_1=rmean(soilm_mean_4_15)
egen wet15_2=rmean(soilm_mean_11_15 soilm_mean_12_15)

egen soilseas15=rmean(dry15 wet15_1 wet15_2)
egen soilseas16=rmean(wet15_2 dry16 wet16_1 wet16_2)
egen soilseas17=rmean(wet16_2 dry17 wet17_1 wet17_2)
egen soilseas18=rmean(wet17_2 dry18 wet18_1 wet18_2)

***Average annual soil
forvalues i=16(1)18 {
egen soilyr`i'=rmean(soilm_mean_1_`i' soilm_mean_2_`i' soilm_mean_3_`i' soilm_mean_4_`i' soilm_mean_5_`i' soilm_mean_6_`i' soilm_mean_7_`i' soilm_mean_8_`i' soilm_mean_9_`i' soilm_mean_10_`i' soilm_mean_11_`i' soilm_mean_12_`i')
}
egen soilyr15=rmean(soilm_mean_4_15 soilm_mean_5_15 soilm_mean_6_15 soilm_mean_7_15 soilm_mean_8_15 soilm_mean_9_15 soilm_mean_10_15 soilm_mean_11_15 soilm_mean_12_15)


drop wet* dry*
keep soilseas15 soilseas16 soilseas17 soilseas18 soilyr15 soilyr16 soilyr17 soilyr18 ID

save "def/soil7_malawi", replace

***Creating short dataset only with annual ans seasonal variables
reshape long soilseas soilyr , i(ID) j(year)
recode year  (15=2015) (16=2016) (17=2017) (18=2018)
save "def/soil7_malawi_short", replace

***Nigthlights
***Creating annual variable y seasonal variable
use "complete/cnightl7_malawi15", clear
merge 1:1 ID using  "complete/cnightl7_malawi16"
drop _merge
merge 1:1 ID using  "complete/cnightl7_malawi17"
drop _merge
merge 1:1 ID using  "complete/cnightl7_malawi18"
drop _merge

***Seasonal
forvalues i=15(1)18 {
egen dry`i'=rmean(nightl_mean_5_`i' nightl_mean_6_`i' nightl_mean_7_`i' nightl_mean_8_`i' nightl_mean_9_`i' nightl_mean_10_`i')
egen wet`i'_1=rmean(nightl_mean_1_`i' nightl_mean_2_`i' nightl_mean_3_`i' nightl_mean_4_`i')
egen wet`i'_2=rmean(nightl_mean_11_`i' nightl_mean_12_`i')
}

egen nightlseas15=rmean(dry15 wet15_1 wet15_2)
egen nightlseas16=rmean(wet15_2 dry16 wet16_1 wet16_2)
egen nightlseas17=rmean(wet16_2 dry17 wet17_1 wet17_2)
egen nightlseas18=rmean(wet17_2 dry18 wet18_1 wet18_2)

***Average annual nightlights
forvalues i=15(1)18 {
egen nightlyr`i'=rmean(nightl_mean_1_`i' nightl_mean_2_`i' nightl_mean_3_`i' nightl_mean_4_`i' nightl_mean_5_`i' nightl_mean_6_`i' nightl_mean_7_`i' nightl_mean_8_`i' nightl_mean_9_`i' nightl_mean_10_`i' nightl_mean_11_`i' nightl_mean_12_`i')
}
drop wet* dry*
keep nightlseas15 nightlseas16 nightlseas17 nightlseas18 nightlyr15 nightlyr16 nightlyr17 nightlyr18 ID
save "def/nightl7_malawi", replace

***Creating short dataset only with annual ans seasonal variables
reshape long nightlseas nightlyr , i(ID) j(year)
recode year  (15=2015) (16=2016) (17=2017) (18=2018)
save "def/nightl7_malawi_short", replace


**********************************************************************************
***Creating one daaset with all data from GEE
use "def/copernicus7_malawi_long", clear
merge 1:1 ID year using "def/prec7_malawi_short"
drop _merge
merge 1:1 ID year using "def/ndvi7_malawi_short"
drop _merge
merge 1:1 ID year using "def/ndwi7_malawi_short"
drop _merge
merge 1:1 ID year using "def/soil7_malawi_short"
drop _merge
merge 1:1 ID year using "def/nightl7_malawi_short"
drop _merge

save "def/data_GEE2015_2018_long", replace

use "def/copernicus7_malawi_wide", clear
merge 1:1 ID using "def/prec7_malawi"
drop _merge
merge 1:1 ID using "def/ndvi7_malawi"
drop _merge
merge 1:1 ID using "def/ndwi7_malawi"
drop _merge
merge 1:1 ID using "def/soil7_malawi"
drop _merge
merge 1:1 ID using "def/nightl7_malawi"
drop _merge
merge 1:1 ID using "complete/historical7_malawi_prec"
drop _merge
merge 1:1 ID using "complete/historical7_malawi_ndvi"
drop _merge
merge 1:1 ID using "complete/historical7_malawi_ndwi"
drop _merge

save "def/data_GEE2015_2018_wide", replace

**********************************************************************************
***Merge with village info in Census
use "C:\Users\melyg\Desktop\Malawi\vill_coords_UBRlong.dta", clear
bys id_tagvnvill: g obs=_n
keep if obs==1
tempfile vill_id
save `vill_id'

use "C:\Users\melyg\Desktop\Malawi\Rdata\pts_poly_grids7.dta", clear
drop GID_0 NAME_0 layer
rename CID id_tagvnvill_num_ubr
sort ID
merge m:1 ID using "def/data_GEE2015_2018_wide"
keep if _merge==3 //some villges are not in the grids because probably some measurmeent error they dont lie within malawi map
drop _merge
merge 1:m id_tagvnvill_num_ubr using `vill_id', keepusing(id_tagvnvill)
keep if _merge==3
drop _merge

order id_tagvnvill_num_ubr id_tagvnvill ID coords_x1 coords_x2

save "def/villinfo_GEE_wide", replace 

***Merging with census data
merge 1:1 id_tagvnvill using "C:\Users\melyg\Desktop\Malawi\Census\data_vill_level_census.dta", keepusing(ta_census ta_census_orig gvh_name village_name id_ta_gvh) 
tab _merge
keep if _merge==3
drop _merge

save "C:\Users\melyg\Desktop\Malawi\Census\census_GEE2.dta", replace

**********************************************************************************
***Merge with HH info in IHS
use "C:\Users\melyg\Desktop\Malawi\Rdata\ihs_pts.poly7CT.dta", clear
drop GID_0 NAME_0 layer coords_x1 coords_x2
sort ID
merge m:1 ID using "def/data_GEE2015_2018_wide"
drop if _merge==2
drop _merge
save "C:\Users\melyg\Desktop\Malawi\Survey\IHS_GEEdata.dta", replace

**********************************************************************************
***Merge with UBR coordinates
use "C:\Users\melyg\Desktop\Malawi\Rdata\ubr_pts.poly7CT.dta", clear
drop GID_0 NAME_0 layer coords_x1 coords_x2
sort ID
merge m:1 ID using "def/data_GEE2015_2018_wide"
drop if _merge==2
drop _merge
rename id_tgvn id_tagvnvill
rename id_tg__ id_tagvnvill_num_ubr
save "C:\Users\melyg\Desktop\Malawi\Rdata\UBR_GEEdata.dta", replace