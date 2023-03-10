library(xgboost)
library(caret)
library(ggplot2)
library(lattice)
library(foreign)
library(dplyr)
library(haven)

##################################################################################
### FUll 50 and UBR 50 with Lasso and xgboost prediction

mydata <- read.dta("C:/Users/melyg/Desktop/Malawi/Census/Updated results/Census_R_full50_ubr50_updte3.dta")

set.seed(12)

#indexes = createDataPartition(mydata$predcons_xgb_fullvill50, p = .2, list = F)
indexesfull50 = createDataPartition(mydata$predcons_census_fullvill50, p = .2, list = F)
indexesubr50 = createDataPartition(mydata$predcons_census_ubrvill50, p = .2, list = F)
indexesfull50xg = createDataPartition(mydata$predcons_xgb_fullvill50, p = .2, list = F)
indexesubr50xg = createDataPartition(mydata$predcons_xgb_ubrvill50, p = .2, list = F)

#train = mydata[indexes, ]
trainfull50 = mydata[indexesfull50, ]
trainubr50 = mydata[indexesubr50, ]
trainfull50xg = mydata[indexesfull50xg, ]
trainubr50xg = mydata[indexesubr50xg, ]

test = mydata[,]

#test = mydata[-indexes, ]
#testfull50 = mydata[-indexesfull50, ]
#testubr50 = mydata[-indexesubr50, ]
#testfull50xg = mydata[-indexesfull50xg, ]
#testubr50xg = mydata[-indexesubr50xg, ]

#train_x = data.matrix(train[, -46:-50])
train_xfull = data.matrix(trainfull50[, -46:-50])
train_xubr = data.matrix(trainubr50[, -46:-50])
train_xfullxg = data.matrix(trainfull50xg[, -46:-50])
train_xubrxg = data.matrix(trainubr50xg[, -46:-50])

#train_yfull = data.matrix(train[,49])
#train_yubr = data.matrix(train[,50])
#train_yfullxg = data.matrix(train[,47])
#train_yubrxg = data.matrix(train[,48])
train_yfull = data.matrix(trainfull50[,49])
train_yubr = data.matrix(trainubr50[,50])
train_yfullxg = data.matrix(trainfull50xg[,47])
train_yubrxg = data.matrix(trainubr50xg[,48])

test_x = data.matrix(test[,-46:-50])
#test_xfull = data.matrix(testfull50[,-46:-50])
#test_xubr = data.matrix(testubr50[,-46:-50])
#test_xfullxg = data.matrix(testfull50xg[,-46:-50])
#test_xubrxg = data.matrix(testubr50xg[,-46:-50])

test_yfull = data.matrix(test[, 49])
test_yubr = data.matrix(test[, 50])
test_yfullxg = data.matrix(test[,47])
test_yubrxg = data.matrix(test[, 48])
#test_yfull = data.matrix(testfull50[, 49])
#test_yubr = data.matrix(testubr50[, 50])
#test_yfullxg = data.matrix(testfull50xg[,47])
#test_yubrxg = data.matrix(testubr50xg[, 48])

distrainfull<-data.matrix(trainfull50[, 46])
distrainubr<-data.matrix(trainubr50[, 46])
distrainfullxg<-data.matrix(trainfull50xg[, 46])
distrainubrxg<-data.matrix(trainubr50xg[, 46])

distest<-data.matrix(test[, 46])


############################
### PREPARING FOR TUNING ###
############################

# Tuning grid
tune_grid <- expand.grid(
      nrounds            = seq(from = 50, to = 200, by = 50),
      max_depth          = c(2,4),
      eta                = c(0.1,0.3),
      gamma              = 0,
      colsample_bytree   = seq(0.5,0.7,0.2),
      min_child_weight   = 1,
      subsample          =  seq(0.6,0.8,0.2)
)
dim(tune_grid)

# Cross validation settings
tune_control <- caret::trainControl(
      method        = "cv", # cross-validation
      number        = 5, # with n folds 
      verboseIter   = TRUE, # no training log
      allowParallel = TRUE # FALSE for reproducible results 
)

# Creates a matrix that will contain the optimal parameter values by fold
OPT_full = data.frame(matrix(NA, nrow = 5, ncol = 1+dim(tune_grid)[2]))
colnames(OPT_full) <- c("fold", colnames(tune_grid))
OPT_full$fold <- seq(1,5)

OPT_ubr = data.frame(matrix(NA, nrow = 5, ncol = 1+dim(tune_grid)[2]))
colnames(OPT_ubr) <- c("fold", colnames(tune_grid))
OPT_ubr$fold <- seq(1,5)

OPT_fullxg = data.frame(matrix(NA, nrow = 5, ncol = 1+dim(tune_grid)[2]))
colnames(OPT_fullxg) <- c("fold", colnames(tune_grid))
OPT_fullxg$fold <- seq(1,5)

OPT_ubrxg = data.frame(matrix(NA, nrow = 5, ncol = 1+dim(tune_grid)[2]))
colnames(OPT_ubrxg) <- c("fold", colnames(tune_grid))
OPT_ubrxg$fold <- seq(1,5)


# LOOPING OVER FOLDS
for (folds in seq(1,5)) {

      ##############
      ### TUNING ### 
      ##############
      
      # Tuning
      # FUll
      xgb_tune_full <- caret::train(
            x         = data.matrix(train_xfull),
            y         = as.double(train_yfull),
            trControl = tune_control,
            tuneGrid  = tune_grid,
            method    = "xgbTree",
            verbose   = FALSE,
            metric    = "RMSE"
      )
      
      # Stores optimal parameters
      OPT_full[folds,1:dim(tune_grid)[2]+1] = xgb_tune_full$bestTune
      
      #UBR
      xgb_tune_ubr <- caret::train(
            x         = data.matrix(train_xubr),
            y         = as.double(train_yubr),
            trControl = tune_control,
            tuneGrid  = tune_grid,
            method    = "xgbTree",
            verbose   = FALSE,
            metric    = "RMSE"
      )

      # Stores optimal parameters
      OPT_ubr[folds,1:dim(tune_grid)[2]+1] = xgb_tune_ubr$bestTune

      # FUll XGBOOST
      xgb_tune_fullxg <- caret::train(
         x         = data.matrix(train_xfullxg),
         y         = as.double(train_yfullxg),
         trControl = tune_control,
         tuneGrid  = tune_grid,
         method    = "xgbTree",
         verbose   = FALSE,
         metric    = "RMSE"
      )
      
      # Stores optimal parameters
      OPT_fullxg[folds,1:dim(tune_grid)[2]+1] = xgb_tune_fullxg$bestTune

      #UBR XGBOOST
      xgb_tune_ubrxg <- caret::train(
         x         = data.matrix(train_xubrxg),
         y         = as.double(train_yubrxg),
         trControl = tune_control,
         tuneGrid  = tune_grid,
         method    = "xgbTree",
         verbose   = FALSE,
         metric    = "RMSE"
      )
      
      # Stores optimal parameters
      OPT_ubrxg[folds,1:dim(tune_grid)[2]+1] = xgb_tune_ubrxg$bestTune      
}
      # Renames the matrices with the results such that all result matrix will be kept
      #assign(paste('OPT', sample,sep="_"),OPT)
     # write_dta(OPT, paste('C:/Users/melyg/Desktop/Malawi/Census/Tuning/grbo_',noquote(full),'_',noquote(sample),'.dta',sep=""))
      
      
      # End cross-validation loop
#}


## Matrices for xgboost      
xgb_train_full = xgb.DMatrix(data = train_xfull, label = train_yfull)
xgb_test_full = xgb.DMatrix(data = test_x, label = test_yfull)

xgb_train_ubr = xgb.DMatrix(data = train_xubr, label = train_yubr)
xgb_test_ubr = xgb.DMatrix(data = test_x, label = test_yubr)

xgb_train_fullxg = xgb.DMatrix(data = train_xfullxg, label = train_yfullxg)
xgb_test_fullxg = xgb.DMatrix(data = test_x, label = test_yfullxg)

xgb_train_ubrxg = xgb.DMatrix(data = train_xubrxg, label = train_yubrxg)
xgb_test_ubrxg = xgb.DMatrix(data = test_x, label = test_yubrxg)

##Models
## FULL
xgb_full <- xgboost(data             = xgb_train_full, 
               eta              =       mean(OPT_full[,"eta"]),              # Learning rate
               max_depth        = round(mean(OPT_full[,"max_depth"])),       # Max depth of tree 
               nround           =       mean(OPT_full[,"nrounds"]),          # Max number of boosting iterations
               subsample        =       mean(OPT_full[,"subsample"]),
               colsample_bytree =       mean(OPT_full[,"colsample_bytree"]), # Subsample ratio of columns when constructing each tree
)

importanceRaw<-xgb.importance(dimnames(train_xfull)[[2]], model = xgb_full)
write.csv(importanceRaw, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/importancefull50_updt3.csv")

xgb.plot.importance(importance_matrix = importanceRaw)

pred_y_full = as.matrix(predict(xgb_full, xgb_test_full))

mse_full = mean((test_yfull - pred_y_full)^2)
mae_full = caret::MAE(test_yfull, pred_y_full)
rmse_full = caret::RMSE(test_yfull, pred_y_full)
cat("MSE: ", mse_full, "MAE: ", mae_full, " RMSE: ", rmse_full)

## UBR
xgb_ubr <- xgboost(data             = xgb_train_ubr, 
               eta              =       mean(OPT_ubr[,"eta"]),              # Learning rate
               max_depth        = round(mean(OPT_ubr[,"max_depth"])),       # Max depth of tree 
               nround           =       mean(OPT_ubr[,"nrounds"]),          # Max number of boosting iterations
               subsample        =       mean(OPT_ubr[,"subsample"]),
               colsample_bytree =       mean(OPT_ubr[,"colsample_bytree"]), # Subsample ratio of columns when constructing each tree
)

importanceRaw<-xgb.importance(dimnames(train_xubr)[[2]], model = xgb_ubr)
write.csv(importanceRaw, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/importanceubr50_updt3.csv")

xgb.plot.importance(importance_matrix = importanceRaw)

pred_y_ubr = as.matrix(predict(xgb_ubr, xgb_test_ubr))

mse_ubr = mean((test_yubr - pred_y_ubr)^2)
mae_ubr = caret::MAE(test_yubr, pred_y_ubr)
rmse_ubr = caret::RMSE(test_yubr, pred_y_ubr)
cat("MSE: ", mse_ubr, "MAE: ", mae_ubr, " RMSE: ", rmse_ubr)


## FULL XGBOOST
xgb_fullxg <- xgboost(data             = xgb_train_fullxg, 
                    eta              =       mean(OPT_fullxg[,"eta"]),              # Learning rate
                    max_depth        = round(mean(OPT_fullxg[,"max_depth"])),       # Max depth of tree 
                    nround           =       mean(OPT_fullxg[,"nrounds"]),          # Max number of boosting iterations
                    subsample        =       mean(OPT_fullxg[,"subsample"]),
                    colsample_bytree =       mean(OPT_fullxg[,"colsample_bytree"]), # Subsample ratio of columns when constructing each tree
)

importanceRaw<-xgb.importance(dimnames(train_xfullxg)[[2]], model = xgb_fullxg)
write.csv(importanceRaw, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/importancefull50xg_updt3.csv")

xgb.plot.importance(importance_matrix = importanceRaw)

pred_y_fullxg = as.matrix(predict(xgb_fullxg, xgb_test_fullxg))

mse_fullxg = mean((test_yfullxg - pred_y_fullxg)^2)
mae_fullxg = caret::MAE(test_yfullxg, pred_y_fullxg)
rmse_fullxg = caret::RMSE(test_yfullxg, pred_y_fullxg)
cat("MSE: ", mse_fullxg, "MAE: ", mae_fullxg, " RMSE: ", rmse_fullxg)

## UBR XGBOOST
xgb_ubrxg <- xgboost(data             = xgb_train_ubrxg, 
                   eta              =       mean(OPT_ubrxg[,"eta"]),              # Learning rate
                   max_depth        = round(mean(OPT_ubrxg[,"max_depth"])),       # Max depth of tree 
                   nround           =       mean(OPT_ubrxg[,"nrounds"]),          # Max number of boosting iterations
                   subsample        =       mean(OPT_ubrxg[,"subsample"]),
                   colsample_bytree =       mean(OPT_ubrxg[,"colsample_bytree"]), # Subsample ratio of columns when constructing each tree
)

importanceRaw<-xgb.importance(dimnames(train_xubrxg)[[2]], model = xgb_ubrxg)
write.csv(importanceRaw, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/importanceubr50xg_updt3.csv")

xgb.plot.importance(importance_matrix = importanceRaw)

pred_y_ubrxg = as.matrix(predict(xgb_ubrxg, xgb_test_ubrxg))

mse_ubrxg = mean((test_yubrxg - pred_y_ubrxg)^2)
mae_ubrxg = caret::MAE(test_yubrxg, pred_y_ubrxg)
rmse_ubrxg = caret::RMSE(test_yubrxg, pred_y_ubrxg)
cat("MSE: ", mse_ubrxg, "MAE: ", mae_ubrxg, " RMSE: ", rmse_ubrxg)


ssresidfull<-sum((test_yfull- pred_y_full)^2) 
ssresidubr<-sum((test_yubr- pred_y_ubr)^2) 
ssresidfullxg<-sum((test_yfullxg- pred_y_fullxg)^2) 
ssresidubrxg<-sum((test_yubrxg- pred_y_ubrxg)^2)

sstotfull <- sum((test_yfull - mean(test_yfull))^2)
sstotubr <- sum((test_yubr - mean(test_yubr))^2)
sstotfullxg <- sum((test_yfullxg - mean(test_yfullxg))^2)
sstotubrxg <- sum((test_yubrxg - mean(test_yubrxg))^2)

sprintf("percent variance explained, R^2: %1.2f%%", 100 * (1 - ssresidfull / sstotfull))
sprintf("percent variance explained, R^2: %1.2f%%", 100 * (1 - ssresidubr / sstotubr))
sprintf("percent variance explained, R^2: %1.2f%%", 100 * (1 - ssresidfullxg / sstotfullxg))
sprintf("percent variance explained, R^2: %1.2f%%", 100 * (1 - ssresidubrxg / sstotubrxg))


colnames(test_yfull)[1] <- "predcons_census_full"
colnames(pred_y_full) <- c("predwelf_census_full")
colnames(test_yubr)[1] <- "predcons_census_ubr"
colnames(pred_y_ubr) <- c("predwelf_census_ubr")
colnames(test_yfullxg)[1] <- "predcons_xgb_full"
colnames(pred_y_fullxg) <- c("predwelf_xgb_full")
colnames(test_yubrxg)[1] <- "predcons_xgb_ubr"
colnames(pred_y_ubrxg) <- c("predwelf_xgb_ubr")

colnames(train_yfull)[1] <- "predcons_census_full"
colnames(train_yubr)[1] <- "predcons_census_ubr"
colnames(train_yfullxg)[1] <- "predcons_xgb_full"
colnames(train_yubrxg)[1] <- "predcons_xgb_ubr"


#final<-as.data.frame(cbind(test_yfull, pred_y_full, test_yubr, pred_y_ubr, test_yfullxg, pred_y_fullxg, test_yubrxg, pred_y_ubrxg, district))
finalout<-as.data.frame(cbind(test_yfull, pred_y_full, test_yubr, pred_y_ubr, test_yfullxg, pred_y_fullxg, test_yubrxg, pred_y_ubrxg, distest))
#finaltrain<-as.data.frame(cbind(train_yfull, train_yubr, train_yfullxg, train_yubrxg, distrain))

#write_dta(finalout, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_full50_ubr50_10_outs.dta")
#write_dta(finalout, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_full50_ubr50_15_outs.dta")
write_dta(finalout, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_full50_ubr50_20_outs.dta")

#write_dta(finaltrain, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_full50_ubr50_10_train.dta")
#write_dta(finaltrain, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_full50_ubr50_15_train.dta")
#write_dta(finaltrain, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_full50_ubr50_20_train.dta")



##################################################################################
### FUll and UBR with Lasso prediction

mydata <- read.dta("C:/Users/melyg/Desktop/Malawi/Census/Updated results/Census_R_full_ubr_updte3.dta")

set.seed(12)

#indexes = createDataPartition(mydata$predcons_census_fullvill, p = .1, list = F)
indexesfull = createDataPartition(mydata$predcons_census_fullvill, p = .2, list = F)
indexesubr = createDataPartition(mydata$predcons_census_ubrvill, p = .2, list = F)

#train = mydata[indexes, ]
trainfull = mydata[indexesfull, ]
trainubr = mydata[indexesubr, ]

test = mydata[,]

#test = mydata[-indexes, ]
#testfull = mydata[-indexesfull, ]
#testubr = mydata[-indexesubr, ]

#train_x = data.matrix(train[, -46:-48])
train_xfull = data.matrix(trainfull[, -46:-48])
train_xubr = data.matrix(trainubr[, -46:-48])

#train_yfull = data.matrix(train[,47])
#train_yubr = data.matrix(train[,48])
train_yfull = data.matrix(trainfull[,47])
train_yubr = data.matrix(trainubr[,48])

test_x = data.matrix(test[,-46:-48])
#test_xfull = data.matrix(testfull[,-46:-48])
#test_xubr = data.matrix(testubr[,-46:-48])

test_yfull = data.matrix(test[, 47])
test_yubr = data.matrix(test[, 48])
#test_yfull = data.matrix(testfull[, 47])
#test_yubr = data.matrix(testubr[, 48])

distrainfull<-data.matrix(trainfull[, 46])
distrainubr<-data.matrix(trainubr[, 46])

distest<-data.matrix(test[, 46])


############################
### PREPARING FOR TUNING ###
############################

# Tuning grid
tune_grid <- expand.grid(
   nrounds            = seq(from = 50, to = 200, by = 50),
   max_depth          = c(2,4),
   eta                = c(0.1,0.3),
   gamma              = 0,
   colsample_bytree   = seq(0.5,0.7,0.2),
   min_child_weight   = 1,
   subsample          =  seq(0.6,0.8,0.2)
)
dim(tune_grid)

# Cross validation settings
tune_control <- caret::trainControl(
   method        = "cv", # cross-validation
   number        = 5, # with n folds 
   verboseIter   = TRUE, # no training log
   allowParallel = TRUE # FALSE for reproducible results 
)

# Creates a matrix that will contain the optimal parameter values by fold
OPT_full = data.frame(matrix(NA, nrow = 5, ncol = 1+dim(tune_grid)[2]))
colnames(OPT_full) <- c("fold", colnames(tune_grid))
OPT_full$fold <- seq(1,5)

OPT_ubr = data.frame(matrix(NA, nrow = 5, ncol = 1+dim(tune_grid)[2]))
colnames(OPT_ubr) <- c("fold", colnames(tune_grid))
OPT_ubr$fold <- seq(1,5)

# LOOPING OVER FOLDS
for (folds in seq(1,5)) {
   
   ##############
   ### TUNING ### 
   ##############
   
   # Tuning
   # FUll
   xgb_tune_full <- caret::train(
      x         = data.matrix(train_xfull),
      y         = as.double(train_yfull),
      trControl = tune_control,
      tuneGrid  = tune_grid,
      method    = "xgbTree",
      verbose   = FALSE,
      metric    = "RMSE"
   )
   
   # Stores optimal parameters
   OPT_full[folds,1:dim(tune_grid)[2]+1] = xgb_tune_full$bestTune
   
   #UBR
   xgb_tune_ubr <- caret::train(
      x         = data.matrix(train_xubr),
      y         = as.double(train_yubr),
      trControl = tune_control,
      tuneGrid  = tune_grid,
      method    = "xgbTree",
      verbose   = FALSE,
      metric    = "RMSE"
   )
   
   # Stores optimal parameters
   OPT_ubr[folds,1:dim(tune_grid)[2]+1] = xgb_tune_ubr$bestTune
   
}
# Renames the matrices with the results such that all result matrix will be kept
#assign(paste('OPT', sample,sep="_"),OPT)
# write_dta(OPT, paste('C:/Users/melyg/Desktop/Malawi/Census/Tuning/grbo_',noquote(full),'_',noquote(sample),'.dta',sep=""))


# End cross-validation loop
#}


## Matrices for xgboost      
xgb_train_full = xgb.DMatrix(data = train_xfull, label = train_yfull)
xgb_test_full = xgb.DMatrix(data = test_x, label = test_yfull)

xgb_train_ubr = xgb.DMatrix(data = train_xubr, label = train_yubr)
xgb_test_ubr = xgb.DMatrix(data = test_x, label = test_yubr)

##Models
## FULL
xgb_full <- xgboost(data             = xgb_train_full, 
                    eta              =       mean(OPT_full[,"eta"]),              # Learning rate
                    max_depth        = round(mean(OPT_full[,"max_depth"])),       # Max depth of tree 
                    nround           =       mean(OPT_full[,"nrounds"]),          # Max number of boosting iterations
                    subsample        =       mean(OPT_full[,"subsample"]),
                    colsample_bytree =       mean(OPT_full[,"colsample_bytree"]), # Subsample ratio of columns when constructing each tree
)

importanceRaw<-xgb.importance(dimnames(train_xfull)[[2]], model = xgb_full)
write.csv(importanceRaw, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/importancefull_updt3.csv")

xgb.plot.importance(importance_matrix = importanceRaw)

pred_y_full = as.matrix(predict(xgb_full, xgb_test_full))

mse_full = mean((test_yfull - pred_y_full)^2)
mae_full = caret::MAE(test_yfull, pred_y_full)
rmse_full = caret::RMSE(test_yfull, pred_y_full)
cat("MSE: ", mse_full, "MAE: ", mae_full, " RMSE: ", rmse_full)

## UBR
xgb_ubr <- xgboost(data             = xgb_train_ubr, 
                   eta              =       mean(OPT_ubr[,"eta"]),              # Learning rate
                   max_depth        = round(mean(OPT_ubr[,"max_depth"])),       # Max depth of tree 
                   nround           =       mean(OPT_ubr[,"nrounds"]),          # Max number of boosting iterations
                   subsample        =       mean(OPT_ubr[,"subsample"]),
                   colsample_bytree =       mean(OPT_ubr[,"colsample_bytree"]), # Subsample ratio of columns when constructing each tree
)

importanceRaw<-xgb.importance(dimnames(train_xubr)[[2]], model = xgb_ubr)
write.csv(importanceRaw, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/importanceubr_updt3.csv")

xgb.plot.importance(importance_matrix = importanceRaw)

pred_y_ubr = as.matrix(predict(xgb_ubr, xgb_test_ubr))

mse_ubr = mean((test_yubr - pred_y_ubr)^2)
mae_ubr = caret::MAE(test_yubr, pred_y_ubr)
rmse_ubr = caret::RMSE(test_yubr, pred_y_ubr)
cat("MSE: ", mse_ubr, "MAE: ", mae_ubr, " RMSE: ", rmse_ubr)


ssresidfull<-sum((test_yfull- pred_y_full)^2) 
ssresidubr<-sum((test_yubr- pred_y_ubr)^2) 

sstotfull <- sum((test_yfull - mean(test_yfull))^2)
sstotubr <- sum((test_yubr - mean(test_yubr))^2)


sprintf("percent variance explained, R^2: %1.2f%%", 100 * (1 - ssresidfull / sstotfull))
sprintf("percent variance explained, R^2: %1.2f%%", 100 * (1 - ssresidubr / sstotubr))



colnames(test_yfull)[1] <- "predcons_census_full"
colnames(pred_y_full) <- c("predwelf_census_full")
colnames(test_yubr)[1] <- "predcons_census_ubr"
colnames(pred_y_ubr) <- c("predwelf_census_ubr")

colnames(train_yfull)[1] <- "predcons_census_full"
colnames(train_yubr)[1] <- "predcons_census_ubr"

#final<-as.data.frame(cbind(test_yfull, pred_y_full, test_yubr, pred_y_ubr, district))
finalout<-as.data.frame(cbind(test_yfull, pred_y_full, test_yubr, pred_y_ubr, distest))
#finaltrain<-as.data.frame(cbind(train_yfull, train_yubr, distrain))


#write_dta(finalout, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_full_ubr_10_outs.dta")
#write_dta(finalout, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_full_ubr_15_outs.dta")
write_dta(finalout, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_full_ubr_20_outs.dta")

#write_dta(finaltrain, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_full_ubr_10_train.dta")
#write_dta(finaltrain, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_full_ubr_15_train.dta")
#write_dta(finaltrain, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_full_ubr_20_train.dta")


##################################################################################
### FUll and UBR with XGBOOST prediction

mydata <- read.dta("C:/Users/melyg/Desktop/Malawi/Census/Updated results/Census_R_full_ubr_xgb_updte3.dta")

set.seed(12)

#indexes = createDataPartition(mydata$predcons_xgb_fullvill, p = .2, list = F)
indexesfull = createDataPartition(mydata$predcons_xgb_fullvill, p = .2, list = F)
indexesubr = createDataPartition(mydata$predcons_xgb_ubrvill, p = .2, list = F)

#train = mydata[indexes, ]
trainfull = mydata[indexesfull, ]
trainubr = mydata[indexesubr, ]

test = mydata[,]

#test = mydata[-indexes, ]
#testfull = mydata[-indexesfull, ]
#testubr = mydata[-indexesubr, ]

#train_x = data.matrix(train[, -46:-48])
train_xfull = data.matrix(trainfull[, -46:-48])
train_xubr = data.matrix(trainubr[, -46:-48])

#train_yfull = data.matrix(train[,47])
#train_yubr = data.matrix(train[,48])
train_yfull = data.matrix(trainfull[,47])
train_yubr = data.matrix(trainubr[,48])

test_x = data.matrix(test[,-46:-48])
#test_xfull = data.matrix(testfull[,-46:-48])
#test_xubr = data.matrix(testubr[,-46:-48])

test_yfull = data.matrix(test[, 47])
test_yubr = data.matrix(test[, 48])
#test_yfull = data.matrix(testfull[, 47])
#test_yubr = data.matrix(testubr[, 48])

distrainfull<-data.matrix(trainfull[, 46])
distrainubr<-data.matrix(trainubr[, 46])

distest<-data.matrix(test[, 46])

############################
### PREPARING FOR TUNING ###
############################

# Tuning grid
tune_grid <- expand.grid(
   nrounds            = seq(from = 50, to = 200, by = 50),
   max_depth          = c(2,4),
   eta                = c(0.1,0.3),
   gamma              = 0,
   colsample_bytree   = seq(0.5,0.7,0.2),
   min_child_weight   = 1,
   subsample          =  seq(0.6,0.8,0.2)
)
dim(tune_grid)

# Cross validation settings
tune_control <- caret::trainControl(
   method        = "cv", # cross-validation
   number        = 5, # with n folds 
   verboseIter   = TRUE, # no training log
   allowParallel = TRUE # FALSE for reproducible results 
)

# Creates a matrix that will contain the optimal parameter values by fold
OPT_full = data.frame(matrix(NA, nrow = 5, ncol = 1+dim(tune_grid)[2]))
colnames(OPT_full) <- c("fold", colnames(tune_grid))
OPT_full$fold <- seq(1,5)

OPT_ubr = data.frame(matrix(NA, nrow = 5, ncol = 1+dim(tune_grid)[2]))
colnames(OPT_ubr) <- c("fold", colnames(tune_grid))
OPT_ubr$fold <- seq(1,5)

# LOOPING OVER FOLDS
for (folds in seq(1,5)) {
   
   ##############
   ### TUNING ### 
   ##############
   
   # Tuning
   # FUll
   xgb_tune_full <- caret::train(
      x         = data.matrix(train_xfull),
      y         = as.double(train_yfull),
      trControl = tune_control,
      tuneGrid  = tune_grid,
      method    = "xgbTree",
      verbose   = FALSE,
      metric    = "RMSE"
   )
   
   # Stores optimal parameters
   OPT_full[folds,1:dim(tune_grid)[2]+1] = xgb_tune_full$bestTune
   
   #UBR
   xgb_tune_ubr <- caret::train(
      x         = data.matrix(train_xubr),
      y         = as.double(train_yubr),
      trControl = tune_control,
      tuneGrid  = tune_grid,
      method    = "xgbTree",
      verbose   = FALSE,
      metric    = "RMSE"
   )
   
   # Stores optimal parameters
   OPT_ubr[folds,1:dim(tune_grid)[2]+1] = xgb_tune_ubr$bestTune
   
}
# Renames the matrices with the results such that all result matrix will be kept
#assign(paste('OPT', sample,sep="_"),OPT)
# write_dta(OPT, paste('C:/Users/melyg/Desktop/Malawi/Census/Tuning/grbo_',noquote(full),'_',noquote(sample),'.dta',sep=""))


# End cross-validation loop
#}


## Matrices for xgboost      
xgb_train_full = xgb.DMatrix(data = train_xfull, label = train_yfull)
xgb_test_full = xgb.DMatrix(data = test_x, label = test_yfull)

xgb_train_ubr = xgb.DMatrix(data = train_xubr, label = train_yubr)
xgb_test_ubr = xgb.DMatrix(data = test_x, label = test_yubr)

##Models
## FULL
xgb_full <- xgboost(data             = xgb_train_full, 
                    eta              =       mean(OPT_full[,"eta"]),              # Learning rate
                    max_depth        = round(mean(OPT_full[,"max_depth"])),       # Max depth of tree 
                    nround           =       mean(OPT_full[,"nrounds"]),          # Max number of boosting iterations
                    subsample        =       mean(OPT_full[,"subsample"]),
                    colsample_bytree =       mean(OPT_full[,"colsample_bytree"]), # Subsample ratio of columns when constructing each tree
)

importanceRaw<-xgb.importance(dimnames(train_xfull)[[2]], model = xgb_full)
write.csv(importanceRaw, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/importancefull_updt3.csv")

xgb.plot.importance(importance_matrix = importanceRaw)

pred_y_full = as.matrix(predict(xgb_full, xgb_test_full))

mse_full = mean((test_yfull - pred_y_full)^2)
mae_full = caret::MAE(test_yfull, pred_y_full)
rmse_full = caret::RMSE(test_yfull, pred_y_full)
cat("MSE: ", mse_full, "MAE: ", mae_full, " RMSE: ", rmse_full)

## UBR
xgb_ubr <- xgboost(data             = xgb_train_ubr, 
                   eta              =       mean(OPT_ubr[,"eta"]),              # Learning rate
                   max_depth        = round(mean(OPT_ubr[,"max_depth"])),       # Max depth of tree 
                   nround           =       mean(OPT_ubr[,"nrounds"]),          # Max number of boosting iterations
                   subsample        =       mean(OPT_ubr[,"subsample"]),
                   colsample_bytree =       mean(OPT_ubr[,"colsample_bytree"]), # Subsample ratio of columns when constructing each tree
)

importanceRaw<-xgb.importance(dimnames(train_xubr)[[2]], model = xgb_ubr)
write.csv(importanceRaw, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/importanceubr_updt3.csv")

xgb.plot.importance(importance_matrix = importanceRaw)

pred_y_ubr = as.matrix(predict(xgb_ubr, xgb_test_ubr))

mse_ubr = mean((test_yubr - pred_y_ubr)^2)
mae_ubr = caret::MAE(test_yubr, pred_y_ubr)
rmse_ubr = caret::RMSE(test_yubr, pred_y_ubr)
cat("MSE: ", mse_ubr, "MAE: ", mae_ubr, " RMSE: ", rmse_ubr)


ssresidfull<-sum((test_yfull- pred_y_full)^2) 
ssresidubr<-sum((test_yubr- pred_y_ubr)^2) 

sstotfull <- sum((test_yfull - mean(test_yfull))^2)
sstotubr <- sum((test_yubr - mean(test_yubr))^2)


sprintf("percent variance explained, R^2: %1.2f%%", 100 * (1 - ssresidfull / sstotfull))
sprintf("percent variance explained, R^2: %1.2f%%", 100 * (1 - ssresidubr / sstotubr))

colnames(test_yfull)[1] <- "predcons_census_full"
colnames(pred_y_full) <- c("predwelf_census_full")
colnames(test_yubr)[1] <- "predcons_census_ubr"
colnames(pred_y_ubr) <- c("predwelf_census_ubr")

colnames(train_yfull)[1] <- "predcons_census_full"
colnames(train_yubr)[1] <- "predcons_census_ubr"

finalout<-as.data.frame(cbind(test_yfull, pred_y_full, test_yubr, pred_y_ubr, distest))
#finaltrain<-as.data.frame(cbind(train_yfull, train_yubr, distrain))


#write_dta(finalout, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_fullxg_ubrxg_10_outs.dta")
#write_dta(finalout, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_fullxg_ubrxg_15_outs.dta")
write_dta(finalout, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_fullxg_ubrxg_20_outs.dta")

#write_dta(finaltrain, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_fullxg_ubrxg_10_train.dta")
#write_dta(finaltrain, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_fullxg_ubrxg_15_train.dta")
#write_dta(finaltrain, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/full_sample_pred/pred_xgboos_fullxg_ubrxg_20_train.dta")


