##polygons of villages in UBR
library(tidyverse)
library(haven)
require(foreign)
require(spatialEco)
require(sp)
library(sp)
library(spatialEco)

setwd("C:/Users/melyg/Desktop/Malawi")

## Centroids of the villages

## File that contains 4 coordinates per village (min lat min lon max lat max lon)
malawi_RWI <- read.csv(file = "RWI/mwi_relative_wealth_index.csv")

## Reading as "sf" data frame
malawi_RWI_coords<- st_as_sf(malawi_RWI, coords=c("longitude","latitude"))

##Generating ID in facebook data
malawi_RWI_coords$FID <- 1:nrow(malawi_RWI_coords) #generates id for each village (it same as village ID in orig data)

##Saving the shape file
st_write(malawi_RWI_coords, paste0(getwd(), "/", "malawi_RWI_coords.shp")) ##it removes the centroids so cerate them later

##Reading files to intersect
malawi_RWIshp <-readOGR(
      dsn=file.path(getwd(),"malawi_RWI_coords.shp")
)

malawi2_mapCT <-readOGR(
      dsn=file.path(getwd(),"malawi_grid_final15.shp") #using 2km grid file
)


## Projecting centroids into the same CRS of map at TA level
proj4string(malawi_RWIshp)<-proj4string(malawi2_mapCT)
dist.crs <- CRS(proj4string(malawi2_mapCT))
RWI.projected <- spTransform(malawi_RWIshp, dist.crs)

##Intersecting
RWI.poly2CT <- point.in.poly(RWI.projected, malawi2_mapCT)

##Saving in Stata format
RWI_poly2CT<-as.data.frame(RWI.poly2CT)

write.dta(RWI_poly2CT, "Rdata/RWI_poly2CT.dta")

