library(tiff)
library(raster)
library(sp)
library(rgdal)
library(sf)
library(spatialEco)

setwd("C:/Users/melyg/Desktop/Malawi")

filepath1 <- "Worldpop/mwi_pd_2015_1km.tif"
filepath2 <- "Worldpop/mwi_pd_2016_1km.tif"
filepath3 <- "Worldpop/mwi_pd_2017_1km.tif"
filepath4 <- "Worldpop/mwi_pd_2018_1km.tif"

filepath5 <- "Worldpop/mwi_bsgme_v0a_100m_2015.tif"
filepath6 <- "Worldpop/mwi_bsgme_v0a_100m_2016.tif"
filepath7 <- "Worldpop/mwi_bsgme_v0a_100m_2017.tif"
filepath8 <- "Worldpop/mwi_bsgme_v0a_100m_2018.tif"

pd1 <- raster(filepath1)
pd2 <- raster(filepath2)
pd3 <- raster(filepath3)
pd4 <- raster(filepath4)

bsg1 <- raster(filepath1)
bsg2 <- raster(filepath2)
bsg3 <- raster(filepath3)
bsg4 <- raster(filepath4)


pd1.pts <- raster::rasterToPoints(x = pd1, spatial = TRUE)
pd2.pts <- raster::rasterToPoints(x = pd2, spatial = TRUE)
pd3.pts <- raster::rasterToPoints(x = pd3, spatial = TRUE)
pd4.pts <- raster::rasterToPoints(x = pd4, spatial = TRUE)

bsg1.pts <- raster::rasterToPoints(x = bsg1, spatial = TRUE)
bsg2.pts <- raster::rasterToPoints(x = bsg2, spatial = TRUE)
bsg3.pts <- raster::rasterToPoints(x = bsg3, spatial = TRUE)
bsg4.pts <- raster::rasterToPoints(x = bsg4, spatial = TRUE)

pd1.pts@data$PID <- as.numeric(row.names(pd1.pts@data))
pd2.pts@data$PID <- as.numeric(row.names(pd2.pts@data))
pd3.pts@data$PID <- as.numeric(row.names(pd3.pts@data))
pd4.pts@data$PID <- as.numeric(row.names(pd4.pts@data))

bsg1.pts@data$PID <- as.numeric(row.names(bsg1.pts@data))
bsg2.pts@data$PID <- as.numeric(row.names(bsg2.pts@data))
bsg3.pts@data$PID <- as.numeric(row.names(bsg3.pts@data))
bsg4.pts@data$PID <- as.numeric(row.names(bsg4.pts@data))

malawi_pd15<-as(pd1.pts, "sf")
malawi_pd16<-as(pd2.pts, "sf")
malawi_pd17<-as(pd3.pts, "sf")
malawi_pd18<-as(pd4.pts, "sf")

malawi_bgs15<-as(bsg1.pts, "sf")
malawi_bgs16<-as(bsg2.pts, "sf")
malawi_bgs17<-as(bsg3.pts, "sf")
malawi_bgs18<-as(bsg4.pts, "sf")

st_write(malawi_pd15, paste0(getwd(), "/", "Worldpop/malawi_pd15.shp"))
st_write(malawi_pd16, paste0(getwd(), "/", "Worldpop/malawi_pd16.shp")) 
st_write(malawi_pd17, paste0(getwd(), "/", "Worldpop/malawi_pd17.shp"))
st_write(malawi_pd18, paste0(getwd(), "/", "Worldpop/malawi_pd18.shp")) 

st_write(malawi_bgs15, paste0(getwd(), "/", "Worldpop/malawi_bgs15.shp"))
st_write(malawi_bgs16, paste0(getwd(), "/", "Worldpop/malawi_bgs16.shp")) 
st_write(malawi_bgs17, paste0(getwd(), "/", "Worldpop/malawi_bgs17.shp"))
st_write(malawi_bgs18, paste0(getwd(), "/", "Worldpop/malawi_bgs18.shp"))

##Reading as shapefiles
pd15 <-readOGR(
      dsn=file.path(getwd(),"Worldpop/malawi_pd15.shp")
)
pd16 <-readOGR(
      dsn=file.path(getwd(),"Worldpop/malawi_pd16.shp")
)
pd17 <-readOGR(
      dsn=file.path(getwd(),"Worldpop/malawi_pd17.shp")
)
pd18 <-readOGR(
      dsn=file.path(getwd(),"Worldpop/malawi_pd18.shp")
)

bgs15 <-readOGR(
      dsn=file.path(getwd(),"Worldpop/malawi_bgs15.shp")
)
bgs16 <-readOGR(
      dsn=file.path(getwd(),"Worldpop/malawi_bgs16.shp")
)
bgs17 <-readOGR(
      dsn=file.path(getwd(),"Worldpop/malawi_bgs17.shp")
)
bgs18 <-readOGR(
      dsn=file.path(getwd(),"Worldpop/malawi_bgs18.shp")
)

malawi2_mapCT <-readOGR(
      dsn=file.path(getwd(),"malawi_grid_final15.shp") #using 2km grid file
)

##Intersecting files with map grids 2x2
map.pd15 <- point.in.poly(pd15, malawi2_mapCT)
map.pd16 <- point.in.poly(pd16, malawi2_mapCT)
map.pd17 <- point.in.poly(pd17, malawi2_mapCT)
map.pd18 <- point.in.poly(pd18, malawi2_mapCT)

map.bgs15 <- point.in.poly(bgs15, malawi2_mapCT)
map.bgs16 <- point.in.poly(bgs16, malawi2_mapCT)
map.bgs17 <- point.in.poly(bgs17, malawi2_mapCT)
map.bgs18 <- point.in.poly(bgs18, malawi2_mapCT)

map.pd15v<-as.data.frame(map.pd15)
map.pd16v<-as.data.frame(map.pd16)
map.pd17v<-as.data.frame(map.pd17)
map.pd18v<-as.data.frame(map.pd18)

map.bgs15v<-as.data.frame(map.bgs15)
map.bgs16v<-as.data.frame(map.bgs16)
map.bgs17v<-as.data.frame(map.bgs17)
map.bgs18v<-as.data.frame(map.bgs18)

write.dta(map.pd15v, "Rdata/map_pd15.dta")
write.dta(map.pd16v, "Rdata/map_pd16.dta")
write.dta(map.pd17v, "Rdata/map_pd17.dta")
write.dta(map.pd18v, "Rdata/map_pd18.dta")

write.dta(map.bgs15v, "Rdata/map_bgs15.dta")
write.dta(map.bgs16v, "Rdata/map_bgs16.dta")
write.dta(map.bgs17v, "Rdata/map_bgs17.dta")
write.dta(map.bgs18v, "Rdata/map_bgs18.dta")

