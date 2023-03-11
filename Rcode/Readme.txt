Decription of the Scripts:

1. 'Pull_data_gee_and_merge_data_with_grids': it creates grided shapefiles using the coordinates from the UBR dataset. Also it contains the code used to pull the satellite indicators from GEE.
2. 'remove_geometry_gee' and 'remove_geometry_gee_grid7': process the GEE data and removes geometry features (cleaning scripts).
3. 'WorldPop_pdensity': it merges Worldpop data with shapefiles.
4. 'RWI_facebook': it merges RWI data with shapefiles.
5. 'xgboost_Malawi_model_benchmark': estimate the benchmark welfare models using XGBoost.
6. 'xgboost_Malawi_model_IHS': estimates welfare model combining IHS and geospatial data using XGBoost models.
7. 'xgboost_Malawi_model_fullsamplepred': estimates welfare model combining census extract with geospatial data and calculates predictions using the full sample.
8. 'xgboost_Malawi_modeloutsamplepred': estimates welfare model combining census extract with geospatial data and calculates out of sample predictions.
