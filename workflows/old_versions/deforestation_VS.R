# CALCULATING DEFORESTATION
# AUTHOR: VICTORIA SARMIENTO
# CREATED: Summer 2021-JAN 2022#
# UPDATED: JERONIMO RODRIGUEZ/ 2022 APRIL
# Note June 2024. This script can be optimized. Is just a change function

#Necesary packages-------------------------------------------------------
paks<-c('terra', 'rgdal','sp', 'tidyverse', 'furrr')
sapply(packs, require, character.only = TRUE)

#This needs to be converted into using gdal or terra. Not raster anymore

                                        # Setting working directory and temporary folder -----------------------------------------
path=("/storage/home/TU/tug76452/biotablero/binary/Container_tmp")
setwd(path)
#path=("/storage/home/TU/tug76452/biotablero/binary/outputs")
#setwd(path)

#Set temporary folder.
dir.create('tempfiledir')
tempdir=paste(getwd(),'tempfiledir', sep="/")
rasterOptions(tmpdir=tempdir)

#1. Cargar los raster de Bosque Armonizados de Hansen ------------

tiffs<-list.files('.', pattern='tif')

tiffs <- tiffs[c(14:18)]

#remove the last from list 1, and the first from list 2.
r.list<-lapply(tiffs[-(length(tiffs)-1)], rast)

r.list2<-list()
for(i in 2:length(tiffs)){
  r.list2[i]<-raster(tiffs[i])
}

r.list2 <- r.list2[-1]
#extract bi annual forest loss
 floss <-function(raso, rasi){
    def <- raso-rasi
    return(def)}

reclv <- c(1:length(r.list))
#Update the pixel value by the forest loss year
mult_one <- function(var1, var2)
{
    def <- var1*var2
    return(def)
}

namer <- map(1:length(tiffs), function(x) substr(tiffs[x], 8,11))
namer <- unlist(namer)
namer <- namer[-1]

path=here("outputs")
setwd(path)

#2. Calculate Forest loss between years ------

deforest <- map(1:length(r.list), function(x) floss(r.list[[x]],r.list2[[x]]))
                                        # Reclassify values by the year offorest loss
deforest <-map(1:length(deforest), function(x) mult_one(deforest[[x]], reclv[x]))
                                        # save rasters
map(1:length(deforest), function(x) writeRaster(deforest[[x]], paste('def_2',namer[x], sep='_'), format='GTiff', overwrite=TRUE))

    ############################### Pending: parallelize this. Not really urgent, don't know wheter necessary but keep  for future reference


