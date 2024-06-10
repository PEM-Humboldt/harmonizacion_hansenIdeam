
packs <- c('raster','rgdal','parallel', 'R.utils', 'rvest','xml2','tidyverse', 'landscapemetrics', 
           'sf','dplyr','httr','getPass','gdalUtils', 'ecochange', 'gdalUtilities','rgeos', 
           'rasterVis','rlang', 'rasterDT')
sapply(packs, require, character.only = TRUE)

# check GDAL
gdalUtils::gdal_setInstallation()
valid_install <- !is.null(getOption("gdalUtils_gdalPath"))


install.packages('pacman')
library(pacman)
# Set target year
year. <- 19

# Set the polygon for the area (in this case, the whole extent of Colombia)
mun <- st_read('/storage/home/TU/tug76452//Ecosistemas_Colombia/ContornoColombia.geojson')
#Drop potewntial empty geometries
mun <- mun[!st_is_empty(mun),,drop=FALSE]

                                        #make sure that your vectorfile is in crs=WGS84, as this is the one of the gobal forest dataset.
                                        # if necessary, use this to reproject:
                                        #mun <- spTransform(mun, crs='+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0')
                                        #Do not do this here, it messes with the encoding of accents!!!!!!!!!!!!!!!!!!!!
                                        #Sys.setlocale(locale="C")
                                        # # convert map into spatial polygon dataframe.
#Fix invalid geometries
mun <- st_make_valid(mun)
mun <- as(mun, 'Spatial')
                                        # # create vector withe the threshold you want to iterate.
                                       # # Warning, this process requires a lot of temp memory, so make sure to have enough storage space or split your process in smaller chuncks
######################
########## If the study area is small, just run the whole thing. Larger areas can become problematic to iterate.
perc2 <- c(94,93)#,92,91,90)#,85,80,75,70,65,60,55,50,40,30,20)
                                        # # this creates a vector of names from the vector
perccar <- as.character(perc2)
                                        # # set a temporary working folder.
# this has laready been written in  another repository (rastermangmt, but here is where we apply it- 
                                        
dir.create('tempfiledir')
tempdir=paste(getwd(),'tempfiledir', sep="/")
rasterOptions(tmpdir=tempdir)

year.=2019
test_map <- map(1:length(perccar), function(x) FCMask(mun, year=year., cummask=TRUE, perc=perc2[x]:100, mc.cores=14))
mem_future <- 1000*1024^2 #this is toset the limit to 1GB
plan(multisession, workers=6)
options(future.globals.maxSize= mem_future)
 future <- map(1:length(test_map), function(x) writeRaster(test_map[[x]], paste(year., 'cum', perccar[x], sep='_'), format='GTiff')) 
