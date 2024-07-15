# I think this is also not necessary anymore. The new process is way better, keep it as reference for the moment, then move to old versions before removing definitively
library(tidyverse)
library(raster)
library(furrr)

rm(list=ls())

listr <- list.files('.','masked')
rasters <- list()
for(i in 1:length(listr)){
  rasters[i] <- raster(listr[i])
}

namer <- list()
namer <- map(1:length(rasters), function(x) (rasters[[x]]@data@names))
namer <- unlist(namer)
mskf <- raster('/Users/sputnik/Documents/Merged_f/rasterized_msk.tif')
msk <- raster('/Users/sputnik/Documents/biomas_iavh/selected_areas/mask_ideam90_17.tif')
mem_future <- 5000*1024^2 #this is toset the limit to 1GB
options(future.globals.maxSize= mem_future)
plan(multisession, workers=14)
rasters <- future_map(1:length(rasters), function(x) merge(mskf, rasters[[x]]))

future_map(10:length(rasters), function(x) writeRaster(rasters[[x]], paste(namer[x]), format='GTiff', overwrite=TRUE))
listr <- list.files('.','masked')
rasters <- list()
for(i in 1:length(listr)){
  rasters[i] <- raster(listr[i])
}

r_2004 <- raster(listr[5])
r_2004 <- merge(mskf, r_2004)

writeRaster(r_2004, 'mergedt_2004', format='GTiff')

rasters <- future_map(1:length(rasters), function(x) raster::mask(rasters[[x]], msk))
future_map(1:lenght(rasters), function(x) writeRaster(rasters[[x]], paste(namer[x], 'masked', sep='_'), format='GTiff', overwrite=TRUE))
