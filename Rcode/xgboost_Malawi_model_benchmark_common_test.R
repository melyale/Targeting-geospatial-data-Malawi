library(xgboost)
library(caret)
library(ggplot2)
library(lattice)
library(foreign)
library(dplyr)
library(haven)
library(coefplot)


##Common testing sample
#sample <- read.dta("C:/Users/melyg/Desktop/Malawi/Survey/Updated results/IHS_full_R.dta")
#sample <- read.dta("C:/Users/melyg/Desktop/Malawi/Survey/Updated results/IHS_ubr_R.dta")
#sample <- read.dta("C:/Users/melyg/Desktop/Malawi/Survey/Updated results/IHS_full50_R.dta")
sample <- read.dta("C:/Users/melyg/Desktop/Malawi/Survey/Updated results/IHS_ubr50_R.dta")

set.seed(12)

index = createDataPartition(sample$ln_pcconsexp_raw, p = .5, list = F)

train_sample = sample[index, ]
test_sample = sample[-index, ]

#train_sample_x = data.matrix(train[, -40:-41])
#train_y = data.matrix(train[,41])

test_sample_x = data.matrix(test_sample[,-40:-41])
test_sample_y = data.matrix(test_sample[, 41])

########################################
##FULL
mydata <- read.dta("C:/Users/melyg/Desktop/Malawi/Survey/Updated results/IHS_full_R.dta")

set.seed(12)

indexes = createDataPartition(mydata$ln_pcconsexp_raw, p = .5, list = F)

train = mydata[indexes, ]
test = mydata[-indexes, ]

train_x = data.matrix(train[, -40:-41])
train_y = data.matrix(train[,41])


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
xgb_test = xgb.DMatrix(data = test_sample_x, label = test_sample_y)

xgb <- xgboost(data             = xgb_train, 
               eta              =       mean(OPT[,"eta"]),              # Learning rate
               max_depth        = round(mean(OPT[,"max_depth"])),       # Max depth of tree 
               nround           =       mean(OPT[,"nrounds"]),          # Max number of boosting iterations
               subsample        =       mean(OPT[,"subsample"]),
               colsample_bytree =       mean(OPT[,"colsample_bytree"]), # Subsample ratio of columns when constructing each tree
)


pred_y = as.matrix(predict(xgb, xgb_test))

ssresid1<-sum((test_sample_y- pred_y)^2) 
sstot1 <- sum((test_sample_y - mean(test_sample_y))^2)


#################################
##FULL 50
mydata <- read.dta("C:/Users/melyg/Desktop/Malawi/Survey/Updated results/IHS_full50_R.dta")

set.seed(12)

indexes = createDataPartition(mydata$ln_pcconsexp_raw, p = .5, list = F)

train = mydata[indexes, ]
test = mydata[-indexes, ]

train_x = data.matrix(train[, -40:-41])
train_y = data.matrix(train[,41])


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
xgb_test = xgb.DMatrix(data = test_sample_x, label = test_sample_y)

xgb <- xgboost(data             = xgb_train, 
               eta              =       mean(OPT[,"eta"]),              # Learning rate
               max_depth        = round(mean(OPT[,"max_depth"])),       # Max depth of tree 
               nround           =       mean(OPT[,"nrounds"]),          # Max number of boosting iterations
               subsample        =       mean(OPT[,"subsample"]),
               colsample_bytree =       mean(OPT[,"colsample_bytree"]), # Subsample ratio of columns when constructing each tree
)


pred_y = as.matrix(predict(xgb, xgb_test))

ssresid2<-sum((test_sample_y- pred_y)^2) 
sstot2 <- sum((test_sample_y - mean(test_sample_y))^2)


######################################
### UBR 

mydata <- read.dta("C:/Users/melyg/Desktop/Malawi/Survey/Updated results/IHS_ubr_R.dta")

set.seed(12)

indexes = createDataPartition(mydata$ln_pcconsexp_raw, p = .5, list = F)

train = mydata[indexes, ]
test = mydata[-indexes, ]

train_x = data.matrix(train[, -40:-41])
train_y = data.matrix(train[,41])


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
xgb_test = xgb.DMatrix(data = test_sample_x, label = test_sample_y)

xgb <- xgboost(data             = xgb_train, 
               eta              =       mean(OPT[,"eta"]),              # Learning rate
               max_depth        = round(mean(OPT[,"max_depth"])),       # Max depth of tree 
               nround           =       mean(OPT[,"nrounds"]),          # Max number of boosting iterations
               subsample        =       mean(OPT[,"subsample"]),
               colsample_bytree =       mean(OPT[,"colsample_bytree"]), # Subsample ratio of columns when constructing each tree
)

pred_y = as.matrix(predict(xgb, xgb_test))

ssresid3<-sum((test_sample_y- pred_y)^2) 
sstot3 <- sum((test_sample_y - mean(test_sample_y))^2)


######################################
### UBR 50

mydata <- read.dta("C:/Users/melyg/Desktop/Malawi/Survey/Updated results/IHS_ubr50_R.dta")

set.seed(12)

indexes = createDataPartition(mydata$ln_pcconsexp_raw, p = .5, list = F)

train = mydata[indexes, ]
test = mydata[-indexes, ]

train_x = data.matrix(train[, -40:-41])
train_y = data.matrix(train[,41])


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
xgb_test = xgb.DMatrix(data = test_sample_x, label = test_sample_y)

xgb <- xgboost(data             = xgb_train, 
               eta              =       mean(OPT[,"eta"]),              # Learning rate
               max_depth        = round(mean(OPT[,"max_depth"])),       # Max depth of tree 
               nround           =       mean(OPT[,"nrounds"]),          # Max number of boosting iterations
               subsample        =       mean(OPT[,"subsample"]),
               colsample_bytree =       mean(OPT[,"colsample_bytree"]), # Subsample ratio of columns when constructing each tree
)

pred_y = as.matrix(predict(xgb, xgb_test))

ssresid4<-sum((test_sample_y- pred_y)^2) 
sstot4 <- sum((test_sample_y - mean(test_sample_y))^2)



sprintf("FULL, R^2: %1.2f%%", 100 * (1 - ssresid1 / sstot1))
sprintf("UBR, R^2: %1.2f%%", 100 * (1 - ssresid3 / sstot3))
sprintf("FULL50, R^2: %1.2f%%", 100 * (1 - ssresid2 / sstot2))
sprintf("UBR50, R^2: %1.2f%%", 100 * (1 - ssresid4 / sstot4))
