
Description of the do-files:

1. 'creation_final_dataset': creates a dataset that contains all the predicted welfare variables using lasso models to evaluate them and compare their AUC and correlation with the benchmark welfare. It doesn't contain the correlation between the welfare variables predicted with xgboost models.
2. 'cleaning_and_models_IHS_2016': this do-file cleans the IHS survey, generates the variables used to estimate the benchmark welfare model, and estimmates the model.
3. 'cleaning_and_censusmerging_ubr_2017': cleans the UBR dataset and merge it with census data at village level.
4. 'auc_correlations_XGB_predictions': calculates the AUC and correlations between predicted welfare ands benchmark welfare, both estimates with XGBoost models. It includes out of sample predictions and our preferred predicted variables: out of sample+true values).
5. 'auc_correlations_XGB_predictions_fullsample': same as do-file number (4) but for full sample predictions.
6. 'heat_maps': creates heat maps comparing the benchmark welfare with all other welfare measures.
7. 'process_impervious_data': process impervious data from GEE.
8. 'gee_data_creation': genarates a dataset that includes all the satellite indicators pulled from Google Earth Engine.
