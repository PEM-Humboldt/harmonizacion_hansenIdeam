packs <- c('raster','rgdal','parallel','sense', 'R.utils', 'rvest','xml2','tidyverse', 'landscapemetrics', 'sf','dplyr','httr','getPass','gdalUtils','gdalUtilities','rgeos', 'viridis', 'rasterVis','rlang', 'rasterDT')
sapply(packs, require, character.only = TRUE)

install.packages("remotes")
remotes::install_github("skiptoniam/sense")

rm(list=ls())

freq(mr[[1]])

setwd(dir.)
m
#Set rout to folder where the armonized rasters are stored
dir. <- "/Users/sputnik/Documents/bosque-nobosque/IDEAMfnf/outs"
dir()

#set list of if files to align
tiffes <- list.files(dir., pattern = "rec")
tiffes1 <- file.path(dir.,tiffes)
#create folder to store the new rasters 
dir.create('outs')
dir()

#set path to the refernece file
reference. <-"/Users/sputnik/Documents/bosque-nobosque/mask_colombia.tif"


tiffes2  <- file.path(dir.,'outs',tiffes)

system.time(
  malr <- Map(function(x,y)
    align_rasters(
      unaligned=x,
      reference=reference.,
      dstfile=y,
      nThreads=8,
      verbose=TRUE),
    tiffes1,tiffes2)
)

getwd()

setwd('/storage/home/TU/tug76452/Align')

## Mosaicing the whole layers in directory band_2000 into an out.tif layer
##<------------------------------------------------------------------

path.  <- '/storage/home/TU/tug76452/Align/Hansen19_20/outs'# first change folder path

toimp <- dir(path.)[grepl('.tif',dir(path.))]
nwp <- file.path(path., toimp)
dst <- file.path('/storage/home/TU/tug76452/Align/merged_19_20.tif')# later move it to elsewhere 

## set any crs:
cr.  <- "+proj=tmerc +lat_0=4.596200416666666 +lon_0=-74.07750791666666 +k=1 +x_0=1000000 +y_0=1000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"  

#"+proj=longlat +datum=WGS84 +no_defs"
getwd()

## develop the mosaicing process
system.time(
  mr <- gdalUtils::mosaic_rasters(
    gdalfile=nwp,
    dst_dataset=dst,
    output_Raster = TRUE,
    #gdalwarp_params = list(t_srs = cr.),
    verbose = TRUE)
)
writeRaster(mr[[1]], 'merged_2019a', format='GTiff', overwrite=TRUE)
writeRaster(mr[[2]], 'merged_2020a', format='GTiff', overwrite=TRUE)

freq(mr[[1]])



rass <- raster('/Users/sputnik/Documents/bosque-nobosque/IDEAMfnf/outs/rec_SBQ_SMBYC_BQNBQ_V5_2000.tif')
m <- c(-0.1,Inf,1)
m <- matrix(m, ncol=3, byrow=TRUE)
rass <- reclassify(rass, m)

msk1 <- raster(reference.)

msk1 <- mask(msk1, rass)
rass <- mask(rass,msk1)
writeRaster(rass, 'msk_SMBYC_GLAD.tif')



Mask stuff
dir. <- "/Users/sputnik/Documents/bosque-nobosque/IDEAMfnf"
dir()

setwd(dir.)

#set list of if files to align
tiffes <- list.files(dir., pattern = "rec")
tiffes1 <- file.path(dir.,tiffes)
#create folder to store the new rasters 
dir.create('outs2')
dir()

reference. <- '/Users/sputnik/Documents/bosque-nobosque/IDEAMfnf/msk_SMBYC_GLAD.tif'
tiffes2  <- file.path(dir.,'outs2',tiffes)

system.time(
  malr <- Map(function(x,y)
    gdalMask(
      inpath = x,
      mask=reference.,
      outpath=y),
    #return.raster = FALSE,
      #nThreads=8,
      #verbose=TRUE),
    tiffes1,tiffes2)
)

gdalMask(tiffes1[1], reference., tiffes2[1], quiet = FALSE, return.raster = TRUE)

gdalMask

id <- list()
for(i in 1:length(tiffes1)){
  id[i] <- raster(tiffes1[i])
}


msk <- raster(reference.)

id <- do.call(stack, id)

id <- mask(id,msk)


