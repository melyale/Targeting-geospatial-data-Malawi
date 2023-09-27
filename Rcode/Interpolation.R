library(gstat)
library(sp)
library(xgboost)
library(caret)
library(ggplot2)
library(lattice)
library(foreign)
library(dplyr)
library(haven)
library(rgdal)
library(devtools)
library(rgeos)
library(raster)


##################################################
setwd("C:/Users/melyg/Desktop/Malawi")

mydata <- read.dta("interpolation/census_welfare_coords_data.dta")

set.seed(12)

indexesfull = createDataPartition(mydata$predcons_xgb_fullvill, p = .2, list = F)
indexesubr = createDataPartition(mydata$predcons_xgb_ubrvill, p = .2, list = F)
indexesfull50 = createDataPartition(mydata$predcons_xgb_full50vill, p = .2, list = F)
indexesubr50 = createDataPartition(mydata$predcons_xgb_ubr50vill, p = .2, list = F)

trainfull = mydata[indexesfull, ]
trainubr = mydata[indexesubr, ]
trainfull50 = mydata[indexesfull50, ]
trainubr50 = mydata[indexesubr50, ]

testfull = mydata[-indexesfull, ]
testubr = mydata[-indexesubr, ]
testfull50 = mydata[-indexesfull50, ]
testubr50 = mydata[-indexesubr50, ]


coordinates(trainfull) = ~longitude+latitude
proj4string(trainfull) <- CRS("+proj=longlat +datum=WGS84")

coordinates(trainubr) = ~longitude+latitude
proj4string(trainubr) <- CRS("+proj=longlat +datum=WGS84")

coordinates(trainfull50) = ~longitude+latitude
proj4string(trainfull50) <- CRS("+proj=longlat +datum=WGS84")

coordinates(trainubr50) = ~longitude+latitude
proj4string(trainubr50) <- CRS("+proj=longlat +datum=WGS84")


coordinates(testfull) = ~longitude+latitude
proj4string(testfull) <- CRS("+proj=longlat +datum=WGS84")

coordinates(testubr) = ~longitude+latitude
proj4string(testubr) <- CRS("+proj=longlat +datum=WGS84")

coordinates(testfull50) = ~longitude+latitude
proj4string(testfull50) <- CRS("+proj=longlat +datum=WGS84")

coordinates(testubr50) = ~longitude+latitude
proj4string(testubr50) <- CRS("+proj=longlat +datum=WGS84")


trainfull <- data.frame(geom(trainfull)[,c("x", "y")], as.data.frame(trainfull))
trainfull50 <- data.frame(geom(trainfull50)[,c("x", "y")], as.data.frame(trainfull50))
trainubr <- data.frame(geom(trainubr)[,c("x", "y")], as.data.frame(trainubr))
trainubr50 <- data.frame(geom(trainubr50)[,c("x", "y")], as.data.frame(trainubr50))


testfull <- data.frame(geom(testfull)[,c("x", "y")], as.data.frame(testfull))
testfull50 <- data.frame(geom(testfull50)[,c("x", "y")], as.data.frame(testfull50))
testubr <- data.frame(geom(testubr)[,c("x", "y")], as.data.frame(testubr))
testubr50 <- data.frame(geom(testubr50)[,c("x", "y")], as.data.frame(testubr50))


gs_full <- gstat(formula=predcons_xgb_fullvill~1, locations=~x+y, data=trainfull)
gs_full50 <- gstat(formula=predcons_xgb_full50vill~1, locations=~x+y, data=trainfull50)
gs_ubr <- gstat(formula=predcons_xgb_ubrvill~1, locations=~x+y, data=trainubr)
gs_ubr50 <- gstat(formula=predcons_xgb_ubr50vill~1, locations=~x+y, data=trainubr50)

predfull <- predict(gs_full, testfull, debug.level=0)
predfull50 <- predict(gs_full50, testfull50, debug.level=0)
predubr <- predict(gs_ubr, testubr, debug.level=0)
predubr50 <- predict(gs_ubr50, testubr50, debug.level=0)


rmsefull <- RMSE(testfull$predcons_xgb_fullvill, predfull$var1.pred)
rmsefull
rmsefull50 <- RMSE(testfull50$predcons_xgb_full50vill, predfull50$var1.pred)
rmsefull50
rmseubr <- RMSE(testubr$predcons_xgb_ubrvill, predubr$var1.pred)
rmseubr
rmseubr50 <- RMSE(testubr50$predcons_xgb_ubr50vill, predubr50$var1.pred)
rmseubr50

colnames(predfull)[3] <- "pred_full"
colnames(predfull50)[3] <- "pred_full50"
colnames(predubr)[3] <- "pred_ubr"
colnames(predubr50)[3] <- "pred_ubr50"

predfull <- predfull[ -c(4) ]
predfull50 <- predfull50[ -c(4) ]
predubr <- predubr[ -c(4) ]
predubr50 <- predubr50[ -c(4) ]


ssresidfull<-sum((testfull$predcons_xgb_fullvill- predfull$pred_full)^2) 
sstotfull <- sum((testfull$predcons_xgb_fullvill - mean(testfull$predcons_xgb_fullvill))^2)
ssresidfull50<-sum((testfull50$predcons_xgb_full50vill- predfull50$pred_full50)^2) 
sstotfull50 <- sum((testfull50$predcons_xgb_full50vill - mean(testfull50$predcons_xgb_full50vill))^2)
ssresidubr<-sum((testubr$predcons_xgb_ubrvill- predubr$pred_ubr)^2) 
sstotubr <- sum((testubr$predcons_xgb_ubrvill - mean(testubr$predcons_xgb_ubrvill))^2)
ssresidubr50<-sum((testubr$predcons_xgb_ubr50vill- predubr50$pred_ubr50)^2) 
sstotubr50 <- sum((testubr$predcons_xgb_ubr50vill - mean(testubr50$predcons_xgb_ubr50vill))^2)

sprintf("percent variance explained, R^2: %1.2f%%", 100 * (1 - ssresidfull / sstotfull))
sprintf("percent variance explained, R^2: %1.2f%%", 100 * (1 - ssresidfull50 / sstotfull50))
sprintf("percent variance explained, R^2: %1.2f%%", 100 * (1 - ssresidubr / sstotubr))
sprintf("percent variance explained, R^2: %1.2f%%", 100 * (1 - ssresidubr50 / sstotubr50))



outfull<-as.data.frame(cbind(testfull, predfull))
outfull50<-as.data.frame(cbind(testfull50, predfull50))
outubr<-as.data.frame(cbind(testubr, predubr))
outubr50<-as.data.frame(cbind(testubr50, predubr50))

#write_dta(outfull, "interpolation/predictions/predfull_10.dta")
#write_dta(outfull50, "interpolation/predictions/predfull50_10.dta")
#write_dta(outubr, "interpolation/predictions/predubr_10.dta")
#write_dta(outubr50, "interpolation/predictions/predubr50_10.dta")

#write_dta(outfull, "interpolation/predictions/predfull_15.dta")
#write_dta(outfull50, "interpolation/predictions/predfull50_15.dta")
#write_dta(outubr, "interpolation/predictions/predubr_15.dta")
#write_dta(outubr50, "interpolation/predictions/predubr50_15.dta")

write_dta(outfull, "interpolation/predictions/predfull_20.dta")
write_dta(outfull50, "interpolation/predictions/predfull50_20.dta")
write_dta(outubr, "interpolation/predictions/predubr_20.dta")
write_dta(outubr50, "interpolation/predictions/predubr50_20.dta")


