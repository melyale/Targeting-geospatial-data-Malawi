cd "C:\Users\melyg\Desktop\Malawi"

clear
shp2dta using "final_grid_files\malawi_grid_final1.shp", database(grids1) coordinates(gridcoord1)  replace


use "C:\Users\melyg\Desktop\Malawi\vill_coords_UBRlong.dta", clear
bys id_tagvnvill: g obs=_n
keep if obs==1
tempfile vill_id
save `vill_id'

use "C:\Users\melyg\Desktop\Malawi\Rdata\pts_poly_grids1.dta", clear
drop GID_0 NAME_0 layer
rename CID id_tagvnvill_num_ubr
sort ID
merge 1:m id_tagvnvill_num_ubr using `vill_id', keepusing(id_tagvnvill)
keep if _merge==3
drop _merge
rename ID ID_1
tempfile coords
save `coords'


 use "Census\Updated results\data_updt1lasso_updt2_updt3lasso_updt4.dta", clear
 merge 1:1 id_tagvnvill using `coords'
 keep if _merge==3
 drop _merge
 
 bys ID_1: egen pmt_grid=mean(pmtscore_mean_vill)
 bys ID_1: egen bench_grid=mean(predcons_xgb_50vill50)

 bys ID_1: g obs=_n
 keep if obs==1
 keep pmt_grid bench_grid ID_1
 rename ID_1 ID
 merge 1:1 ID using "final_grid_files\grids1.dta"
*replace pmt_grid=0 if pmt_grid==.
 
spmap pmt_grid using gridcoord, id(_ID) fcolor(Heat)  ocolor(gs16) osize(vthin)  ndo(gs12) mosize(vthin) mocolor(gs16) ///
legend(pos(5) row(3) ring(1) size(*.75) symx(*.75) symy(*.75) forcesize ) ///
title("Average PMT scores", size(*0.5))        
graph save PMT, replace

spmap bench_grid using gridcoord, id(_ID) osize(vvthin) fcolor(Heat) ocolor(white)  ndo(gs13) mosize(vthin) mocolor(gs16)  ///
legend(pos(5) row(3) ring(1) size(*.75) symx(*.75) symy(*.75) forcesize ) ///
title("Average Benchmark Welfare", size(*0.5))   		
		graph save bench, replace

graph combine PMT.gph bench.gph 

****************************************************************************************************
clear
shp2dta using "final_grid_files\malawi_grid_final7.shp", database(grids2) coordinates(gridcoord2)  replace

 use "Census\Updated results\data_updt1lasso_updt2_updt3lasso_updt4.dta", clear
 bys ID: egen pmt_grid=mean(pmtscore_mean_vill)
 bys ID: egen bench_grid=mean(predcons_xgb_50vill50)
 bys ID: egen rwi_grid=mean(mean_rwi)

 bys ID: g obs=_n
 keep if obs==1
 keep pmt_grid bench_grid ID rwi_grid
 
  merge m:1 ID using "final_grid_files\grids2.dta"
*replace pmt_grid=0 if pmt_grid==.
 
spmap pmt_grid using gridcoord2, id(_ID) fcolor(Heat)  ocolor(gs16) osize(vvvthin)  nds(vthin) ndo(gs12) mosize(vvvthin) mocolor(gs16) ///
legend(off) ///
title("Average PMT scores", size(*0.75))        
graph save PMT, replace

spmap bench_grid using gridcoord2, id(_ID) fcolor(Heat)  ocolor(gs16) osize(none)  nds(vthin) ndo(gs12) mosize(none) mocolor(gs16) ///
legend(off) ///
title("Benchmark Welfare", size(*0.75))     		
graph save bench, replace

spmap rwi_grid using gridcoord2, id(_ID) fcolor(Heat)  ocolor(gs16) osize(none)  nds(vthin) ndo(gs12) mosize(none) mocolor(gs16) ///
legend(off) ///
title("Average RWI", size(*0.75))     		
graph save rwi, replace
		
***Partial registry

use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_outfullxgv2.dta", clear
rename predcons_xgb_full predcons_census_full 
rename predwelf_xgb_full predwelf_census_full
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_outfullxgnv2.dta", replace

use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_outubrxgv2.dta", clear
rename predcons_xgb_ubr predcons_census_ubr 
rename predwelf_xgb_ubr predwelf_census_ubr
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_outubrxgnv2.dta", replace

use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_trainfullxgv2.dta", clear
rename predcons_xgb_full predcons_census_full 
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_trainfullxgnv2.dta", replace

use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_trainubrxgv2.dta", clear
rename predcons_xgb_ubr predcons_census_ubr 
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_trainubrxgnv2.dta", replace

use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_outfullv2.dta", clear
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_outfullnv2.dta", replace
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_outubrv2.dta", clear
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_outubrnv2.dta", replace
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_trainfullv2.dta", clear
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_trainfullnv2.dta", replace
use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_trainubrv2.dta", clear
save "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_trainubrnv2.dta", replace

use "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_outfullxgnv2.dta", clear
append using "Census\Updated results\out_of_sample_updt1_xgb\pred_xgboos_full5050_ubr5050_10_trainfullxgnv2.dta"
destring  predcons_census_full predwelf_census_full, replace
replace predwelf_census_full=predcons_census_full if predwelf_census_full==. //replacing the missing in the training sample as the actual values

rename V4 ID
destring ID, replace

bys ID: egen bench_grid=mean(predcons_census_full)
bys ID: egen pred_grid=mean(predwelf_census_full)

bys ID: g obs=_n
keep if obs==1
 
merge m:1 ID using "final_grid_files\grids2.dta"

spmap pred_grid using gridcoord2, id(_ID) fcolor(Heat)  ocolor(gs16) osize(vvvthin)  nds(vthin) ndo(gs12) mosize(vvvthin) mocolor(gs16) ///
legend(off) ///
title("Partial registry predictions", size(*0.75))        
graph save partial, replace



**********IHS
use "C:\Users\melyg\Desktop\Malawi\Census\Updated results\predcensus_xgb_IHS_full50newv2.dta",clear

*bys ID: egen bench_grid=mean(predcons_census_full)
bys ID: egen ihs_grid=mean(predwelf_ihsxgb_full50)

bys ID: g obs=_n
keep if obs==1

merge m:1 ID using "final_grid_files\grids2.dta"

spmap ihs_grid using gridcoord2, id(_ID) fcolor(Heat)  ocolor(gs16) osize(vvvthin)  nds(vthin) ndo(gs12) mosize(vvvthin) mocolor(gs16) ///
legend(off) ///
title("IHS predictions", size(*0.80))        
graph save ihs, replace

