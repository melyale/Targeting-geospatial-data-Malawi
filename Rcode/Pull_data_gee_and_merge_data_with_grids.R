## Calling R libraries

library(raster)
library(rgdal)
library(ggplot2)
library(dplyr)
library(SAEplus)
library(sf)
library(sp)
library('dplyr')
library('magrittr')
library(devtools)
library(rgeos)
library(dismo)

setwd("C:/Users/melyg/Desktop/Malawi")

##################################################################################
## Generating grided files

malawi_map <-readOGR(
   dsn=file.path(getwd(),"New shapefiles/gadm36_MWI_0.shp")
)

plot(malawi_map)

# Create an empty raster.
grid <- raster(extent(malawi_map))

# Choose its resolution. 
res(grid) <- 0.02485

# Make the grid have the same coordinate reference system (CRS) as the shapefile.
proj4string(grid)<-proj4string(malawi_map)

# Transform this raster into a polygon and you will have a grid.
gridpolygon <- rasterToPolygons(grid)

# Intersect our grid with Malawi's shape
malawi.grid <- intersect(malawi_map, gridpolygon)

# Plot the intersected shape to see if everything is fine.This is en "sp" "SpatialPolygonsDataFrame" format
#plot(malawi.grid)
class(malawi.grid) #is in "sp" format need to convert to "sf" format

# Generate grid ID
malawi.grid@data$ID <- as.numeric(row.names(malawi.grid@data))

malawi_grid<-as(malawi.grid, "sf")

# Generating grid area
malawi_grid$area<-st_area(malawi_grid)
mean(malawi_grid$area)/1000000 
class(malawi_grid)
#13.89km grid0.035;10.29289km grid 0.03;0.052 30.04km; grid 0.032 11.65km; grid 0.019 4.29km; grid 0.0208 5km;grid 0.02285 6km
# grid 0.02485 7.11km

# Saving shape files for GEE
writeOGR(malawi.grid, dsn=getwd(), layer="malawi_grid_final7", driver="ESRI Shapefile", overwrite_layer=T)
#st_write(malawi_grid, paste0(getwd(), "/", "malawi_grid_final5.shp")) ##it removes the centroids so cerate them later

##malawi_grid_final11 grids of 11.65km
# Add centroids to the grids: geometry, area, centroids and ID.
malawi_grid$centroid<-st_centroid(x=malawi_grid)
grided_shape <- st_read("malawi_grid_final.shp")


######################################################################
######################################################################
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
malawi_vill_coords <- read_dta(file = "vill_coords_UBRlong.dta")

## Reading as "sf" data frame
malawi_vill_coords<- st_as_sf(malawi_vill_coords, coords=c("coor_lon","coor_lat"))

## Generating polygons for each village using the 4 coordinates
vill_polys = st_sf(
   aggregate(
      malawi_vill_coords$geometry,
      list(malawi_vill_coords$id_tagvnvill_num_ubr),
      function(g){
         st_cast(st_combine(g),"POLYGON")
      }
   ))

## Generating the centroids for each village based on the polygons (this is a data.frame)
vill_polys$centroids<-st_centroid(vill_polys)
vill_polys<-st_set_geometry(vill_polys, NULL) #removing geometry of polygons

## Separate coordinates into 2 different columns(this is a data.frame)
vill_polys1<- as.data.frame(st_coordinates(vill_polys$centroids))
vill_polys1$CID <- 1:nrow(vill_polys1) #generates id for each village (it same as village ID in orig data)
coordinates(vill_polys1) = c("X","Y")  #change into "SpatialPointsDataFrame" sp class

## Transforming into sf format and saving as shapefile
malawi_centroids<-as(vill_polys1, "sf")
st_write(malawi_centroids, paste0(getwd(), "/", "malawi_villcentroids.shp")) ##it removes the centroids so cerate them later

## Merging centroids with polygons
##Shape file of malawi with polygons at TA level
malawi_mapTA <-readOGR(
   dsn=file.path(getwd(),"New shapefiles/gadm36_MWI_2.shp")
)

##Removing some columns from the data 
malawi_mapTA <- malawi_mapTA[,-(1:2)]
malawi_mapTA <- malawi_mapTA[,-(3)]
malawi_mapTA <- malawi_mapTA[,-(5:10)]

##Generating ID for each polygon of map at TA level
malawi_mapTA@data$ID <- as.numeric(row.names(malawi_mapTA@data))


## Shapefile with centroids
centroids <-readOGR(
   dsn=file.path(getwd(),"malawi_villcentroids.shp")
)

## Shape file of malawi with polygons at the grid level
malawi11_mapCT <-readOGR(
   dsn=file.path(getwd(),"final_grid_files/malawi_grid_final11.shp")
)

malawi52_mapCT <-readOGR(
   dsn=file.path(getwd(),"final_grid_files/malawi_grid_final52.shp")
)

malawi7_mapCT <-readOGR(
   dsn=file.path(getwd(),"final_grid_files/malawi_grid_final7.shp")
)

## Projecting centroids into the same CRS of map at TA level
proj4string(centroids)<-proj4string(malawi7_mapCT)
dist.crs <- CRS(proj4string(malawi7_mapCT))
centroids.projected <- spTransform(centroids, dist.crs)

## PLoting to check if it worked
plot(malawi52_mapCT)
par(new = T)
plot(centroids.projected, type = ".", col = "blue", add = T)
par(new = F)

## Intersects centroids ans map at TA level
head(malawi52_mapCT@data)  # polygons
head(centroids.projected@data) # points
plot(malawi52_mapCT)
points(centroids.projected, pch=20)

pts.polyTA <- point.in.poly(centroids.projected, malawi_mapTA)

## Intersects centroids ans map CT level
head(malawi11_mapCT@data)  # polygons
head(centroids.projected@data) # points
plot(malawi11_mapCT)
points(centroids.projected, pch=10)

pts.poly11CT <- point.in.poly(centroids.projected, malawi11_mapCT)

head(malawi52_mapCT@data)  # polygons
head(centroids.projected@data) # points
plot(malawi52_mapCT)
points(centroids.projected, pch=20)

pts.poly52CT <- point.in.poly(centroids.projected, malawi52_mapCT)


head(malawi7_mapCT@data)  # polygons
head(centroids.projected@data) # points
plot(malawi7_mapCT)
points(centroids.projected, pch=20)

pts.poly7CT <- point.in.poly(centroids.projected, malawi7_mapCT)


##Transforming into data frame
pts_poly_grids7<-as(pts.poly7CT, "sf")
st_write(pts_poly_grids7, paste0(getwd(), "/", "pts_poly_grids7.shp")) 
pts_poly_grids7<-as.data.frame(pts.poly7CT)

pts_poly_grids11<-as(pts.poly11CT, "sf")
st_write(pts_poly_grids11, paste0(getwd(), "/", "pts_poly_grids11.shp")) 
pts_poly_grids11<-as.data.frame(pts.poly11CT)

pts_poly_grids52<-as(pts.poly52CT, "sf")
st_write(pts_poly_grids52, paste0(getwd(), "/", "pts_poly_grids52.shp")) 
pts_poly_grids52<-as.data.frame(pts.poly52CT)

pts_poly_TA<-as(pts.polyTA, "sf")
st_write(pts_poly_TA, paste0(getwd(), "/", "pts_poly_TA.shp")) 
pts_poly_TA2<-as.data.frame(pts.polyTA)


##Exporting to Stata
write.dta(pts_poly_grids7, "Rdata/pts_poly_grids7.dta")
write.dta(pts_poly_grids11, "Rdata/pts_poly_grids11.dta")
write.dta(pts_poly_grids52, "Rdata/pts_poly_grids52.dta")
write.dta(pts_poly_TA2, "Rdata/pts_poly_TA2.dta")


#######################################################################################
## Using SAEplus to get some satellite data
## datasets 
#NASA/GPM_L3/IMERG_MONTHLY_V06
#COPERNICUS/Landcover/100m/Proba-V-C3/Global
#LANDSAT/LE07/C01/T1_8DAY_NDWI
#LANDSAT/LC08/C01/T1_8DAY_NDVI
#NASA_USDA/HSL/SMAP10KM_soil_moisture
#MODIS/006/MCD12Q1
#NOAA/VIIRS/DNB/MONTHLY_V1/VCMSLCFG
#Tsinghua/FROM-GLC/GAIA/v10

gee_datapull(
   email = "melanyg2@illinois.edu",
   gee_boundary = "users/melyg/gadm36_MWI_0",
   gee_polygons = "users/melyg/malawi_grid_final7",
   gee_dataname = "Tsinghua/FROM-GLC/GAIA/v10",
   gee_datestart = "2016-01-01",
   gee_dateend = "2016-12-31",
   gee_band = "ssm",
   scale = 100,
   gee_desc = "soilm7_malawi_3_15",
   gee_stat = "mean",
   gdrive_folder = "/SAEplus4",
   ldrive_dsn = "SAEplus/data2/soil/soilm7_malawi_3_15"
)

prec_malawi_1<-st_read("SAEplus/data2/GPM PREC/prec7_malawi_1_18.shp")
prec_malawi_2<-st_read("SAEplus/data2/GPM PREC/prec7_malawi_2_18.shp")

# Removing the geometry of all the files
source("C:/Users/melyg/Desktop/Malawi/Rcode/remove_geometry_gee_grid7.R")

# Saving all the files as .dta
data_names18 <- c("dprec7_malawi18_1", "dprec7_malawi18_2", "dprec7_malawi18_3", "dprec7_malawi18_4", 
                  "dprec7_malawi18_5", "dprec7_malawi18_6", "dprec7_malawi18_7", "dprec7_malawi18_8", 
                  "dprec7_malawi18_9", "dprec7_malawi18_10", "dprec7_malawi18_11", "dprec7_malawi18_12",
                  "dndwi7_malawi18_1","dndwi7_malawi18_2", "dndwi7_malawi18_3", "dndwi7_malawi18_4",
                  "dndwi7_malawi18_5", "dndwi7_malawi18_6", "dndwi7_malawi18_7", "dndwi7_malawi18_8",
                  "dndwi7_malawi18_9", "dndwi7_malawi18_10", "dndwi7_malawi18_11", "dndwi7_malawi18_12",
                  "dndvi7_malawi18_1", "dndvi7_malawi18_2", "dndvi7_malawi18_3", "dndvi7_malawi18_4",
                  "dndvi7_malawi18_5", "dndvi7_malawi18_6", "dndvi7_malawi18_7", "dndvi7_malawi18_8",
                  "dndvi7_malawi18_9", "dndvi7_malawi18_10", "dndvi7_malawi18_11", "dndvi7_malawi18_12",
                  "dsoilm7_malawi18_1","dsoilm7_malawi18_2","dsoilm7_malawi18_3","dsoilm7_malawi18_4",
                  "dsoilm7_malawi18_5","dsoilm7_malawi18_6","dsoilm7_malawi18_7","dsoilm7_malawi18_8",
                  "dsoilm7_malawi18_9","dsoilm7_malawi18_10","dsoilm7_malawi18_11","dsoilm7_malawi18_12",
                  "dbare7_malawi_18","dgrass7_malawi_18", "dmoss7_malawi_18", "dcrops7_malawi_18",
                  "dshrub7_malawi_18", "dwaterperm7_malawi_18", "dwaterseas7_malawi_18", "durban7_malawi_18",
                  "dltype7_malawi_18", "dnightl7_malawi18_1", "dnightl7_malawi18_2", "dnightl7_malawi18_3",
                  "dnightl7_malawi18_4", "dnightl7_malawi18_5", "dnightl7_malawi18_6","dnightl7_malawi18_7",
                  "dnightl7_malawi18_8", "dnightl7_malawi18_9", "dnightl7_malawi18_10", "dnightl7_malawi18_11",
                  "dnightl7_malawi18_12")

for(i in 1:length(data_names18)) {                              # Head of for-loop
   write.dta(get(data_names18[i]),                              # Write CSV files to folder
             paste0("C:/Users/melyg/Desktop/Malawi/SAEplus/data2/data_gee2/",
                    data_names18[i],
                    ".dta"))
}

data_names17 <- c("dprec7_malawi17_1", "dprec7_malawi17_2", "dprec7_malawi17_3", "dprec7_malawi17_4", 
                  "dprec7_malawi17_5", "dprec7_malawi17_6", "dprec7_malawi17_7", "dprec7_malawi17_8", 
                  "dprec7_malawi17_9", "dprec7_malawi17_10", "dprec7_malawi17_11", "dprec7_malawi17_12",
                  "dndwi7_malawi17_1","dndwi7_malawi17_2", "dndwi7_malawi17_3", "dndwi7_malawi17_4",
                  "dndwi7_malawi17_5", "dndwi7_malawi17_6", "dndwi7_malawi17_7", "dndwi7_malawi17_8",
                  "dndwi7_malawi17_9", "dndwi7_malawi17_10", "dndwi7_malawi17_11", "dndwi7_malawi17_12",
                  "dndvi7_malawi17_1", "dndvi7_malawi17_2", "dndvi7_malawi17_3", "dndvi7_malawi17_4",
                  "dndvi7_malawi17_5", "dndvi7_malawi17_6", "dndvi7_malawi17_7", "dndvi7_malawi17_8",
                  "dndvi7_malawi17_9", "dndvi7_malawi17_10", "dndvi7_malawi17_11", "dndvi7_malawi17_12",
                  "dsoilm7_malawi17_1","dsoilm7_malawi17_2","dsoilm7_malawi17_3","dsoilm7_malawi17_4",
                  "dsoilm7_malawi17_5","dsoilm7_malawi17_6","dsoilm7_malawi17_7","dsoilm7_malawi17_8",
                  "dsoilm7_malawi17_9","dsoilm7_malawi17_10","dsoilm7_malawi17_11","dsoilm7_malawi17_12",
                  "dbare7_malawi_17","dgrass7_malawi_17", "dmoss7_malawi_17", "dcrops7_malawi_17",
                  "dshrub7_malawi_17", "dwaterperm7_malawi_17", "dwaterseas7_malawi_17", "durban7_malawi_17",
                  "dltype7_malawi_17", "dnightl7_malawi17_1", "dnightl7_malawi17_2", "dnightl7_malawi17_3",
                  "dnightl7_malawi17_4", "dnightl7_malawi17_5", "dnightl7_malawi17_6","dnightl7_malawi17_7",
                  "dnightl7_malawi17_8", "dnightl7_malawi17_9", "dnightl7_malawi17_10", "dnightl7_malawi17_11",
                  "dnightl7_malawi17_12")

for(i in 1:length(data_names17)) {                              # Head of for-loop
   write.dta(get(data_names17[i]),                              # Write CSV files to folder
             paste0("C:/Users/melyg/Desktop/Malawi/SAEplus/data2/data_gee2/",
                    data_names17[i],
                    ".dta"))
}

data_names16 <- c("dprec7_malawi16_1", "dprec7_malawi16_2", "dprec7_malawi16_3", "dprec7_malawi16_4", 
                  "dprec7_malawi16_5", "dprec7_malawi16_6", "dprec7_malawi16_7", "dprec7_malawi16_8", 
                  "dprec7_malawi16_9", "dprec7_malawi16_10", "dprec7_malawi16_11", "dprec7_malawi16_12",
                  "dndwi7_malawi16_1","dndwi7_malawi16_2", "dndwi7_malawi16_3", "dndwi7_malawi16_4",
                  "dndwi7_malawi16_5", "dndwi7_malawi16_6", "dndwi7_malawi16_7", "dndwi7_malawi16_8",
                  "dndwi7_malawi16_9", "dndwi7_malawi16_10", "dndwi7_malawi16_11", "dndwi7_malawi16_12",
                  "dndvi7_malawi16_1", "dndvi7_malawi16_2", "dndvi7_malawi16_3", "dndvi7_malawi16_4",
                  "dndvi7_malawi16_5", "dndvi7_malawi16_6", "dndvi7_malawi16_7", "dndvi7_malawi16_8",
                  "dndvi7_malawi16_9", "dndvi7_malawi16_10", "dndvi7_malawi16_11", "dndvi7_malawi16_12",
                  "dsoilm7_malawi16_1","dsoilm7_malawi16_2","dsoilm7_malawi16_3","dsoilm7_malawi16_4",
                  "dsoilm7_malawi16_5","dsoilm7_malawi16_6","dsoilm7_malawi16_7","dsoilm7_malawi16_8",
                  "dsoilm7_malawi16_9","dsoilm7_malawi16_10","dsoilm7_malawi16_11","dsoilm7_malawi16_12",
                  "dbare7_malawi_16","dgrass7_malawi_16", "dmoss7_malawi_16", "dcrops7_malawi_16",
                  "dshrub7_malawi_16", "dwaterperm7_malawi_16", "dwaterseas7_malawi_16", "durban7_malawi_16",
                  "dltype7_malawi_16", "dnightl7_malawi16_1", "dnightl7_malawi16_2", "dnightl7_malawi16_3",
                  "dnightl7_malawi16_4", "dnightl7_malawi16_5", "dnightl7_malawi16_6","dnightl7_malawi16_7",
                  "dnightl7_malawi16_8", "dnightl7_malawi16_9", "dnightl7_malawi16_10", "dnightl7_malawi16_11",
                  "dnightl7_malawi16_12")

for(i in 1:length(data_names16)) {                              # Head of for-loop
   write.dta(get(data_names16[i]),                              # Write CSV files to folder
             paste0("C:/Users/melyg/Desktop/Malawi/SAEplus/data2/data_gee2/",
                    data_names16[i],
                    ".dta"))
}

data_names15 <- c("dprec7_malawi15_1", "dprec7_malawi15_2", "dprec7_malawi15_3", "dprec7_malawi15_4", 
                  "dprec7_malawi15_5", "dprec7_malawi15_6", "dprec7_malawi15_7", "dprec7_malawi15_8", 
                  "dprec7_malawi15_9", "dprec7_malawi15_10", "dprec7_malawi15_11", "dprec7_malawi15_12",
                  "dndwi7_malawi15_1","dndwi7_malawi15_2", "dndwi7_malawi15_3", "dndwi7_malawi15_4",
                  "dndwi7_malawi15_5", "dndwi7_malawi15_6", "dndwi7_malawi15_7", "dndwi7_malawi15_8",
                  "dndwi7_malawi15_9", "dndwi7_malawi15_10", "dndwi7_malawi15_11", "dndwi7_malawi15_12",
                  "dndvi7_malawi15_1", "dndvi7_malawi15_2", "dndvi7_malawi15_3", "dndvi7_malawi15_4",
                  "dndvi7_malawi15_5", "dndvi7_malawi15_6", "dndvi7_malawi15_7", "dndvi7_malawi15_8",
                  "dndvi7_malawi15_9", "dndvi7_malawi15_10", "dndvi7_malawi15_11", "dndvi7_malawi15_12",
                  "dsoilm7_malawi15_4","dsoilm7_malawi15_5","dsoilm7_malawi15_6","dsoilm7_malawi15_7","dsoilm7_malawi15_8",
                  "dsoilm7_malawi15_9","dsoilm7_malawi15_10","dsoilm7_malawi15_11","dsoilm7_malawi15_12",
                  "dbare7_malawi_15","dgrass7_malawi_15", "dmoss7_malawi_15", "dcrops7_malawi_15",
                  "dshrub7_malawi_15", "dwaterperm7_malawi_15", "dwaterseas7_malawi_15", "durban7_malawi_15",
                  "dltype7_malawi_15", "dnightl7_malawi15_1", "dnightl7_malawi15_2", "dnightl7_malawi15_3",
                  "dnightl7_malawi15_4", "dnightl7_malawi15_5", "dnightl7_malawi15_6","dnightl7_malawi15_7",
                  "dnightl7_malawi15_8", "dnightl7_malawi15_9", "dnightl7_malawi15_10", "dnightl7_malawi15_11",
                  "dnightl7_malawi15_12")

for(i in 1:length(data_names15)) {                              # Head of for-loop
   write.dta(get(data_names15[i]),                              # Write CSV files to folder
             paste0("C:/Users/melyg/Desktop/Malawi/SAEplus/data2/data_gee2/",
                    data_names15[i],
                    ".dta"))
}



data_names_prec <- c("dprec7_malawi_1", "dprec7_malawi_2","dprec7_malawi_3","dprec7_malawi_4","dprec7_malawi_5",
                     "dprec7_malawi_6","dprec7_malawi_7","dprec7_malawi_8","dprec7_malawi_9","dprec7_malawi_10",
                     "dprec7_malawi_11", "dprec7_malawi_12", "dprec7_malawi_13", "dprec7_malawi_14","dprec7_malawi_15",
                     "dprec7_malawi_16")

for(i in 1:length(data_names_prec)) {                              # Head of for-loop
   write.dta(get(data_names_prec[i]),                              # Write CSV files to folder
             paste0("C:/Users/melyg/Desktop/Malawi/SAEplus/data2/data_gee2/",
                    data_names_prec[i],
                    ".dta"))
}

data_names_ndvi <- c("dndvi7_malawi_1", "dndvi7_malawi_2","dndvi7_malawi_3","dndvi7_malawi_4","dndvi7_malawi_5",
                     "dndvi7_malawi_6","dndvi7_malawi_7","dndvi7_malawi_8","dndvi7_malawi_9","dndvi7_malawi_10",
                     "dndvi7_malawi_11", "dndvi7_malawi_12", "dndvi7_malawi_13", "dndvi7_malawi_14","dndvi7_malawi_15",
                     "dndvi7_malawi_16")

for(i in 1:length(data_names_ndvi)) {                              # Head of for-loop
   write.dta(get(data_names_ndvi[i]),                              # Write CSV files to folder
             paste0("C:/Users/melyg/Desktop/Malawi/SAEplus/data2/data_gee2/",
                    data_names_ndvi[i],
                    ".dta"))
}

data_names_ndwi <- c("dndwi7_malawi_1", "dndwi7_malawi_2","dndwi7_malawi_3","dndwi7_malawi_4","dndwi7_malawi_5",
                     "dndwi7_malawi_6","dndwi7_malawi_7","dndwi7_malawi_8","dndwi7_malawi_9","dndwi7_malawi_10",
                     "dndwi7_malawi_11", "dndwi7_malawi_12", "dndwi7_malawi_13", "dndwi7_malawi_14","dndwi7_malawi_15",
                     "dndwi7_malawi_16")

for(i in 1:length(data_names_ndwi)) {                              # Head of for-loop
   write.dta(get(data_names_ndwi[i]),                              # Write CSV files to folder
             paste0("C:/Users/melyg/Desktop/Malawi/SAEplus/data2/data_gee2/",
                    data_names_ndwi[i],
                    ".dta"))
}


###Impervious
gee_pullimage(
   email = "melanyg2@illinois.edu",
   gee_polygons = "users/melyg/malawi_grid_final7",
   gee_dataname = "Tsinghua/FROM-GLC/GAIA/v10",
   gee_band = "change_year_index",
   scale = 30,
   gee_desc = "impervious_cmr",
   gee_stat = "median",
   gdrive_folder = "/SAEplus4",
   ldrive_dsn = "SAEplus/data2/pixels/impervious_malawi"
)

imperv_malawi<-st_read("SAEplus/data2/pixels/impervious_malawi.shp")
imperv_malawi<-st_set_geometry(imperv_malawi, NULL)
imperv_malawi1<-as.data.frame(imperv_malawi)
write.dta(imperv_malawi, "Rdata/imperv_malawi.dta")


#####################################################################################
##Coordinates in IHS

## File that contains 4 coordinates per village (min lat min lon max lat max lon)
ihs_coords <- read_dta(file = "Survey/2016 IHS IV/IHS_coords.dta")

## Reading as "sf" data frame
ihs_coords<- st_as_sf(ihs_coords, coords=c("lon_modified","lat_modified"))
st_write(ihs_coords, paste0(getwd(), "/", "ihs_coords.shp")) 

ihs_coords_map <-readOGR(
   dsn=file.path(getwd(),"ihs_coords.shp")
)

malawi2_mapCT <-readOGR(
   dsn=file.path(getwd(),"malawi_grid_final15.shp") #using 2km grid file
)

proj4string(ihs_coords_map)<-proj4string(malawi7_mapCT)
dist.crs <- CRS(proj4string(malawi7_mapCT))
ihscoords.projected <- spTransform(ihs_coords_map, dist.crs)


ihspts.poly7CT <- point.in.poly(ihscoords.projected, malawi7_mapCT)
ihs_pts.poly7CT<-as.data.frame(ihspts.poly7CT)
write.dta(ihs_pts.poly7CT, "Rdata/ihs_pts.poly7CT.dta")

ihspts.poly2CT <- point.in.poly(ihscoords.projected, malawi2_mapCT)
ihs_pts.poly2CT<-as.data.frame(ihspts.poly2CT)
write.dta(ihs_pts.poly2CT, "Rdata/ihs_pts.poly2CT.dta")


#####################################################################################
##Coordinates in UBR

ubr_coords <- read_dta(file = "C:/Users/melyg/Desktop/Malawi/UBR/UBR Data/UBR_coords_v2.dta")

## Reading as "sf" data frame
ubr_coords<- st_as_sf(ubr_coords, coords=c("gps_longitude","gps_latitude"))
st_write(ubr_coords, paste0(getwd(), "/", "ubr_coords.shp")) 

ubr_coords_map <-readOGR(
   dsn=file.path(getwd(),"ubr_coords.shp")
)

malawi2_mapCT <-readOGR(
   dsn=file.path(getwd(),"malawi_grid_final15.shp") #using 2km grid file
)

malawi7_mapCT <-readOGR(
   dsn=file.path(getwd(),"final_grid_files/malawi_grid_final7.shp")
)

proj4string(ubr_coords_map)<-proj4string(malawi7_mapCT)
dist.crs <- CRS(proj4string(malawi7_mapCT))
ubrcoords.projected <- spTransform(ubr_coords_map, dist.crs)


ubrpts.poly7CT <- point.in.poly(ubrcoords.projected, malawi7_mapCT)
ubr_pts.poly7CT<-as.data.frame(ubrpts.poly7CT)
write.dta(ubr_pts.poly7CT, "Rdata/ubr_pts.poly7CT.dta")

ubrpts.poly2CT <- point.in.poly(ubrcoords.projected, malawi2_mapCT)
ubr_pts.poly2CT<-as.data.frame(ubrpts.poly2CT)
write.dta(ubr_pts.poly2CT, "Rdata/ubr_pts.poly2CT.dta")

##################################################################################
### Getting districts for RWI analysis
malawi_map <-readOGR(
   dsn=file.path(getwd(),"New shapefiles/gadm36_MWI_1.shp")
)

malawi_TAmap<-as(malawi_mapTA, "sf")
malawi_TAmap$centroids<-st_centroid(malawi_TAmap)

districts2CT <- point.in.poly(malawi_TAmap, malawi2_mapCT)
districts2CT<-as(districts2CT, "sf")
districts2CT<-st_set_geometry(districts2CT, NULL)
districts2CT<-as.data.frame(districts2CT)

df<-subset(districts2CT, select = c(NAME_1,NAME_2,ID) )

write.dta(df, "Rdata/districts2CT.dta")

