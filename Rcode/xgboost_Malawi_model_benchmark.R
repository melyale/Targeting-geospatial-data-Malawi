library(xgboost)
library(caret)
library(ggplot2)
library(lattice)
library(foreign)
library(dplyr)
library(haven)
library(coefplot)

census<-data.matrix(read.dta("C:/Users/melyg/Desktop/Malawi/Census/Updated results/census_R_xgboostvf.dta"))
censuspred<-data.matrix(census[,-40:-41])

mydata <- read.dta("C:/Users/melyg/Desktop/Malawi/Survey/Updated results/IHS_full_R.dta")
#mydata <- read.dta("C:/Users/melyg/Desktop/Malawi/Survey/Updated results/IHS_full50_R.dta")

set.seed(12)

indexes = createDataPartition(mydata$ln_pcconsexp_raw, p = .5, list = F)

train = mydata[indexes, ]
test = mydata[-indexes, ]

train_x = data.matrix(train[, -40:-41])
train_y = data.matrix(train[,41])

test_x = data.matrix(test[,-40:-41])
test_y = data.matrix(test[, 41])

district<-data.matrix(test[, 40])

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
OPT = data.frame(matrix(NA, nrow = 5, ncol = 1+dim(tune_grid)[2]))
colnames(OPT) <- c("fold", colnames(tune_grid))
OPT$fold <- seq(1,5)


# LOOPING OVER FOLDS
for (folds in seq(1,5)) {

      ##############
      ### TUNING ### 
      ##############
      
      # Tuning 
      xgb_tune <- caret::train(
            x         = data.matrix(train_x),
            y         = as.double(train_y),
            trControl = tune_control,
            tuneGrid  = tune_grid,
            method    = "xgbTree",
            verbose   = FALSE,
            metric    = "RMSE"
      )
      
      # Stores optimal parameters
      OPT[folds,1:dim(tune_grid)[2]+1] = xgb_tune$bestTune
      
}

###Model
      
xgb_train = xgb.DMatrix(data = train_x, label = train_y)
xgb_test = xgb.DMatrix(data = test_x, label = test_y)

xgb <- xgboost(data             = xgb_train, 
               eta              =       mean(OPT[,"eta"]),              # Learning rate
               max_depth        = round(mean(OPT[,"max_depth"])),       # Max depth of tree 
               nround           =       mean(OPT[,"nrounds"]),          # Max number of boosting iterations
               subsample        =       mean(OPT[,"subsample"]),
               colsample_bytree =       mean(OPT[,"colsample_bytree"]), # Subsample ratio of columns when constructing each tree
)

importanceRaw<-xgb.importance(dimnames(train_x)[[2]], model = xgb)
importanceRaw

write.csv(importanceRaw, "C:/Users/melyg/Desktop/Malawi/Survey/Updated results/importanceRawfull.csv")
#write.csv(importanceRaw, "C:/Users/melyg/Desktop/Malawi/Survey/Updated results/importanceRawfull50.csv")

xgb.plot.importance(importance_matrix = importanceRaw)

pred_y = as.matrix(predict(xgb, xgb_test))

ssresid<-sum((test_y- pred_y)^2) 
sstot <- sum((test_y - mean(test_y))^2)

sprintf("percent variance explained, R^2: %1.2f%%", 100 * (1 - ssresid / sstot))

##Predictions in the census
pred_y_census = as.matrix(predict(xgb, censuspred))
colnames(pred_y_census)[1] <- "predwelf_benchxgb_full"
#colnames(pred_y_census)[1] <- "predwelf_benchxgb_full50"

final_census<-as.data.frame(cbind(census, pred_y_census))
write_dta(final_census, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/predcensus_xgb_IHSbench_full.dta")
#write_dta(final_census, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/predcensus_xgb_IHSbench_full50.dta")


#############################################################################
### UBR data
census<-data.matrix(read.dta("C:/Users/melyg/Desktop/Malawi/Census/Updated results/census_R_xgboostvf.dta"))
censuspred<-data.matrix(census[,-40:-41])

mydata <- read.dta("C:/Users/melyg/Desktop/Malawi/Survey/Updated results/IHS_ubr_R.dta")
#mydata <- read.dta("C:/Users/melyg/Desktop/Malawi/Survey/Updated results/IHS_ubr50_R.dta")

set.seed(12)

indexes = createDataPartition(mydata$ln_pcconsexp_raw, p = .5, list = F)

train = mydata[indexes, ]
test = mydata[-indexes, ]

train_x = data.matrix(train[, -40:-41])
train_y = data.matrix(train[,41])

test_x = data.matrix(test[,-40:-41])
test_y = data.matrix(test[, 41])

district<-data.matrix(test[, 40])

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
OPT = data.frame(matrix(NA, nrow = 5, ncol = 1+dim(tune_grid)[2]))
colnames(OPT) <- c("fold", colnames(tune_grid))
OPT$fold <- seq(1,5)


# LOOPING OVER FOLDS
for (folds in seq(1,5)) {
   
   ##############
   ### TUNING ### 
   ##############
   
   # Tuning 
   xgb_tune <- caret::train(
      x         = data.matrix(train_x),
      y         = as.double(train_y),
      trControl = tune_control,
      tuneGrid  = tune_grid,
      method    = "xgbTree",
      verbose   = FALSE,
      metric    = "RMSE"
   )
   
   # Stores optimal parameters
   OPT[folds,1:dim(tune_grid)[2]+1] = xgb_tune$bestTune
   
}

###Model

xgb_train = xgb.DMatrix(data = train_x, label = train_y)
xgb_test = xgb.DMatrix(data = test_x, label = test_y)

xgb <- xgboost(data             = xgb_train, 
               eta              =       mean(OPT[,"eta"]),              # Learning rate
               max_depth        = round(mean(OPT[,"max_depth"])),       # Max depth of tree 
               nround           =       mean(OPT[,"nrounds"]),          # Max number of boosting iterations
               subsample        =       mean(OPT[,"subsample"]),
               colsample_bytree =       mean(OPT[,"colsample_bytree"]), # Subsample ratio of columns when constructing each tree
)

importanceRaw<-xgb.importance(dimnames(train_x)[[2]], model = xgb)
importanceRaw

write.csv(importanceRaw, "C:/Users/melyg/Desktop/Malawi/Survey/Updated results/importanceRawubr.csv")
#write.csv(importanceRaw, "C:/Users/melyg/Desktop/Malawi/Survey/Updated results/importanceRawubr50.csv")

xgb.plot.importance(importance_matrix = importanceRaw)

pred_y = as.matrix(predict(xgb, xgb_test))

ssresid<-sum((test_y- pred_y)^2) 
sstot <- sum((test_y - mean(test_y))^2)

sprintf("percent variance explained, R^2: %1.2f%%", 100 * (1 - ssresid / sstot))

##Predictions in the census
pred_y_census = as.matrix(predict(xgb, censuspred))
colnames(pred_y_census)[1] <- "predwelf_benchxgb_ubr"
#colnames(pred_y_census)[1] <- "predwelf_benchxgb_ubr50"

final_census<-as.data.frame(cbind(census, pred_y_census))
write_dta(final_census, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/predcensus_xgb_IHSbench_ubr.dta")
#write_dta(final_census, "C:/Users/melyg/Desktop/Malawi/Census/Updated results/predcensus_xgb_IHSbench_ubr50.dta")




