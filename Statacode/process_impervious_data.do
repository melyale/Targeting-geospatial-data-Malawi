cd "C:\Users\melyg\Desktop\Malawi\Rdata"

use "imperv_malawi.dta", clear
drop NAME_0 GID_0

drop if ID==.
g mean1=round(mean)
rename mean1 mean_yr_change

tempfile imperv
save `imperv'


***Villages
use "C:\Users\melyg\Desktop\Malawi\vill_coords_UBRlong.dta", clear
bys id_tagvnvill: g obs=_n
keep if obs==1
tempfile vill_id
save `vill_id'

***Merging with village IDs
use "C:\Users\melyg\Desktop\Malawi\Rdata\pts_poly_grids7.dta", clear
merge m:1 ID using `imperv'
keep if _merge==3
drop GID_0 NAME_0 layer coords_x1 coords_x2 _merge
rename CID id_tagvnvill_num_ubr
merge 1:m id_tagvnvill_num_ubr using `vill_id', keepusing(id_tagvnvill)
keep if _merge==3 //44not merged
drop _merge mean
order id_tagvnvill_num_ubr id_tagvnvill ID
save "C:\Users\melyg\Desktop\Malawi\SAEplus\data2\pixels\villinfo_imperv", replace 

***Merging with HH ID in IHS 2016
use "C:\Users\melyg\Desktop\Malawi\Rdata\ihs_pts.poly7CT.dta", clear
merge m:1 ID using `imperv'
keep if _merge==3
drop GID_0 NAME_0 layer coords_x1 coords_x2 _merge mean

save "C:\Users\melyg\Desktop\Malawi\SAEplus\data2\pixels\IHS_imperv.dta", replace

***Merging with UBR coordinates 2017
use "C:\Users\melyg\Desktop\Malawi\Rdata\ubr_pts.poly7CT.dta", clear
merge m:1 ID using `imperv'
keep if _merge==3
drop GID_0 NAME_0 layer coords_x1 coords_x2 _merge mean
rename id_tgvn id_tagvnvill
rename id_tg__ id_tagvnvill_num_ubr
save "C:\Users\melyg\Desktop\Malawi\SAEplus\data2\pixels\UBR_imperv.dta", replace


