packs <- c('raster','rgdal','parallel','sense', 'R.utils', 'rvest','xml2','tidyverse', 'landscapemetrics', 'sf','dplyr','httr','getPass','gdalUtils','gdalUtilities','rgeos', 'viridis', 'rasterVis','rlang', 'rasterDT')
sapply(packs, require, character.only = TRUE)

install.packages("remotes")
remotes::install_github("skiptoniam/sense")

rm(list=ls())

freq(mr[[1]])

setwd(dir.)
m
#Set rout to folder where the harmonized rasters are stored
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


## Mosaicing the whole layers in directory band_2000 into an out.tif layer

path.  <- '/storage/home/TU/tug76452/Align/Hansen19_20/outs'# first change folder path

toimp <- dir(path.)[grepl('.tif',dir(path.))]
nwp <- file.path(path., toimp)
dst <- file.path('/storage/home/TU/tug76452/Align/merged_19_20.tif')# later move it to elsewhere 

## set any crs:
cr.  <- "+proj=tmerc +lat_0=4.596200416666666 +lon_0=-74.07750791666666 +k=1 +x_0=1000000 +y_0=1000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"  


## develop the mosaicing process
system.time(
  mr <- gdalUtils::mosaic_rasters(
    gdalfile=nwp,
    dst_dataset=dst,
    output_Raster = TRUE,
    #gdalwarp_params = list(t_srs = cr.),
    verbose = TRUE)
)

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

