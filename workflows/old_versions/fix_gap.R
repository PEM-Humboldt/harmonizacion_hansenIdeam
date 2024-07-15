#July 8 2024 It seems that thisis not necessary anymore. The new method seems to deal with the gaps better. Candidate for delete.

packs <- c('raster','rgdal','parallel', 'R.utils', 'rvest','xml2','tidyverse', 'landscapemetrics', 'sf',
           'dplyr','httr','getPass','gdalUtils','gdalUtilities','rgeos', 'viridis', 'rasterVis','rlang', 'rasterDT', 'furrr')
sapply(packs, require, character.only = TRUE)


tiffs <- list.files('.', pattern='tif')

tiffs <- tiffs[c(13,20,23)]


borders <- raster("Y:/biotablero/rasterized_msk.tif")
summary(borders)
rast <- list()

for(i in 1:length(tiffs)){
  rast[i] <- raster(tiffs[i])
}

  dir.create('tempfiledir')
  #obtain string with the path
  tempdir=paste(getwd(),'tempfiledir', sep="/")
  rasterOptions(tmpdir=tempdir)
  #Set the memory limit for parallel running
  mem_future <- 5000*1024^2
  plan(multisession, workers=3)
  options(future.globals.maxSize= mem_future)


  tiffs<-list('masked_2021')#, 'masked_2019')
  tiffs<-unlist(tiffs)


  rast<-future_map(1:length(rast), function(x) merge(borders, rast[[x]]))
  #rast<-future_map(1:length(rast), function(x) mask(rast[[x]], msk))
  future_map(1:length(rast), function(x)  writeRaster(rast[[x]], paste('fix', tiffs[x], sep='_'),format='GTiff', overwrite=TRUE))


  rast1 <- merge(borders, rast[[1]])
  rast2 <- merge(borders, rast[[2]])
  rast3 <- merge(borders, rast[[3]])

  writeRaster(rast1, 'fix_masked_2009.tif')
  writeRaster(rast2, 'fix_masked_2016.tif')
  writeRaster(rast3, 'fix_masked_2019.tif')



