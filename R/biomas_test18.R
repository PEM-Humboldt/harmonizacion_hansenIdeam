
                                        # This code is used to download all the forest- no forest binary masks from the 
# Global forest cover Dataset by Hansen et al  using the package ForestChange.
#It  returns maps for each one of the thresholds between 70 and 100%. The next step is to load this, stack cut it by pieces and then carry out the comparson betwee nthe maps. Everything trough maps. Another next step is to update this heading, the code does much more than that.

#It requires the package "greenbrown" available here:

 #   http://greenbrown.r-forge.r-project.org
# Load libraries 
#rm(list=ls())

getwd()
unixtools::set.tempdir('/media/mnt/Ecosistemas_Colombia/tempfiledir')
inpath <- getwd()


setwd("/media/mnt/Ecosistemas_Colombia/hansen_ideam")

library(raster)
library(rgdal)
library(forestChange)
library(parallel)
library(sf)
library(tidyverse)
library(purrr)
library(furrr)
library(diffeR)
library(useful)
library(greenbrown)
library(data.table)


dir.create('tempfiledir')

tempdir=paste(getwd(),'tempfiledir', sep="/")
rasterOptions(tmpdir=tempdir)


tempdir()
tmpDir()
# First part: Download forest maps from Hansen:
# load study area  polygon 
#############################################################
#Part 2. Crop the maps using the different spatial units. In this case, the biomas from IAVH)
#load the biomas

mun <- st_read('/media/mnt/Ecosistemas_Colombia/biomas_wgs84.shp')
labels <- (mun$BIOMA_IAvH)
mun <- as(mun, 'Spatial')
# split mun into list of independent polygons  
biomat <- mun%>%split(.$BIOMA_IAvH)
#######################################################################################################
#Get to mask over all of the 397 pieces. 
#get the names                              
names <- as.list(mun$BIOMA_IAvH)
names <- map(1:length(names), function(x) as.character(names[[x]]))
namesu <- unlist(names)

# i had to do this because bioma #7 has no valid data and the function would not run there (in the case of Ideam maps) 
namesu <- namesu[-7]

#†his part belongs to the hansen's maps.  

#stack_forests <- stack(listr)
#still dont send the stuff to process in nimbus, but keeps woking on the local machine. I decided to split it un parts for the moment
#Actually, parallelizing  can be done either setting the multicore  in future_map, or inside FCMask function. I am not sure which option is better. Will have to run a comparison test. I already solved this, I am running in my local machine (lab) but temp files are in Nimbus
#this crops the Hansen stacks in the different biomes. Will use it in a while 
mem_future <- 1000*1024^2 #this is toset the limit to 1GB
options(future.globals.maxSize= mem_future)
plan(multisession, workers=7)
a <-c(1:397)

#All this can become a single function. I alreadyu have them. 
namesu2 <- namesu[a]
biomat2 <- biomat[a]
cropped <- future_map(a, function(x) crop(stack_forests, extent(biomat[[x]])))
maskedt <-map(1:length(cropped), function(x) raster::mask(cropped[[x]], biomat2[[x]]))
mem_future <- 5000*1024^2 #this is toset the limit to 1GB
options(future.globals.maxSize= mem_future)
plan(multisession, workers=8)
stacked
map(1:length(maskedt), function(x) writeRaster(maskedt[[x]], paste('cropped_2010_2', namesu2[x], sep='_'), format='GTiff', overwrite=TRUE)) 

#########################################################################################################################

  test_match <- function(ideam1, ideam2){
    extent(ideam1)==extent(ideam2)}

############################Here I am just running it 
# this function uses the package diffeR to compare between pairs of maps. It does not produce agreement maps, only contingency matrices. It works faster and does not require that both maps have pixels form all classes
comparer2 <- function(ideam1,ideam2, perc){
    test1 <- crosstabm(ideam1, ideam2, percent=perc, population=NULL)
                                        # differences <-  diffTable(test1, digits = 2, analysis = 'error')
    return(test1)}


#compare between change maps ideam hansen at the different thresholds
# in the folder hanen_ideam3 i think is the comparisn with 2000. Do not need it right now
setwd("/media/mnt/Ecosistemas_Colombia/Agreement_ideam_2010_2017")
listr <- list.files(".", "ag_ideam")

# no idea why i did this, but suirely 152 has some issue
ideam_ag <- list()

ideam_ag <- list()
for(i in 1:length(listr)){
    ideam_ag[[i]] <- raster(listr[i])}

setwd("/media/mnt/Ecosistemas_Colombia/cont_matrices3")


listr <- list.files(".", 'hansen_ag_msk')

listr <- listr[-7]


length(listr)
 
ideam_ag <- list()

ideam_ag <- list()
for(i in 1:length(listr)){
    ideam_ag[[i]] <- raster(listr[i])}

# this was an experiment for a subset that worked well, so im going for thew whole thing. b(today in a while). Not relly, beacause this time i whill mask the whole country and then crop it, not the other way round, which was too complicated.
setwd("/media/mnt/Ecosistemas_Colombia/comp_hansen")

# load the Hansen agreement  maps. Note: This should be automatized for each threshold. For the moment it works manually
# and I need to change the level (10:100) but if i have the time will fix this.

#1. Load the data. Stack each one, mask it and save as rasters.
#2. load ideam data, do the same, mask it and save. The masked data will be procesed again to obtain square contingency matrices

listr <- list.files(".", "2010_17_99")
#listr <- listr[-152]

listr[152]

listr[8]

ideam_ag[7]

length(listr)
length(ideam_ag)

listr <- listr[-7]

getwd()


swap1 <- listr[116]
swap2 <- listr[117]
listr[116] <- swap2
listr[117] <- swap1
swap3 <- listr[169]
swap4 <- listr[170]
listr[169] <- swap4
listr[170] <- swap3
swap5 <- listr[212]
swap6 <- listr[213]
listr[212] <- swap6
listr[213] <- swap5
swap7 <- listr[268]
swap8 <- listr[269]
listr[268] <- swap8
listr[269] <- swap7
swap9 <- listr[333]
swap10 <- listr[334]
listr[333] <- swap10
listr[334] <- swap9
swap11 <- listr[378]
swap12 <- listr[379]
listr[378] <- swap12
listr[379] <- swap11

listr

comparer2 <- function(ideam1,ideam2, perc){
    test1 <- crosstabm(ideam1, ideam2, percent=perc, population=NULL)
    return(test1)}
 
############################################################
############################################################
############################################################
#Carga rasters
hansen_c <- list()
for(i in 1:length(listr)){
    hansen_c[[i]] <- raster(listr[i], band=8)}
gtest <- map(1:length(hansen_c), function(x) test_match(ideam_ag[[x]], hansen_c[[x]]))
unlist(gtest)
############################################################
############################################################
############################################################
############################################################
#namesu
                                        #namesu <- namesu[-7]
#++++++++++++++++++++SACA LASS MATRICES DE CONTINGENCIA+++++++++++++++++++++
mem_future <- 1000*1024^2 #this is toset the limit to 1GB
plan(multisession, workers=7)
options(future.globals.maxSize= mem_future)
diff_mat<- future_map(1:length(hansen_c), function(x) comparer2(ideam_ag[[x]], hansen_c[[x]], perc=FALSE))
diff_mat
names(diff_mat) <- namesu
diff_mat_99<- diff_mat
save(diff_mat_99, file='ag_HI_msk_99_10_17.RData')




#loadd the rasters back (the only reason I do this is because I don't have enough storage space) 
listr <- list.files(".", "msk")


#create an empty container list
mask_list <- list()

# load the rasters
for(i in 1:length(listr)){
  mask_list[[i]] <- raster(listr[i])}

listr <- list.files(".", "ag_ideam")

#create an empty container list
ideam_list <- list()
# load the rasters
for(i in 1:length(listr)){
  ideam_list[[i]] <- raster(listr[i])}



for(i in 1:length(listr)){
  mask_list[[i]] <- raster(listr[i])}

listr <- list.files(".", '100')

listr <- list.files(".", "2010_17")

listr. <- listr[1:14]
listr. <- list(listr.[2:14],listr[1])
listr. <- unlist(listr.)
listr. <- as.list(listr.)
listr <- listr[-c(1:14)]
hansen13 <- do.call(stack, listr.)


hansen_list <- list(hansen1,hansen2,hansen3,hansen4,hansen5,hansen6,hansen7,hansen8,hansen9,hansen10,hansen11,hansen12,hansen13)

mun <- st_read('/media/mnt/Ecosistemas_Colombia/comp_hansen/AAAAAA/selected_polygon.shp')

labels <- (mun$BIOMA_IAvH)
mun <- as(mun, 'Spatial')
# split mun into list of independent polygons  
biomat <- mun%>%split(.$BIOMA_IAvH)

#######################################################################################################
#Get to mask over all of the 397 pieces. 
#get the names
# attention, for memoy reasons, I had to split the thing in several stages, and thats why it. DON;'T FORGET to adjust this!!!!!!!!!!!!!
names <- as.list(mun$BIOMA_IAvH)
names <- map(1:length(names), function(x) as.character(names[[x]]))
namesu <- unlist(names)

namesu

plan(multisession, workers=6)
  options(future.globals.maxSize= mem_future)
ideam_msk<- map(1:length(mask_list), function(x) mask(ideam_list[[x]], mask_list[[x]], perc=FALSE))
plan(multisession, workers=6)
map(1:length(ideam_msk), function(x) writeRaster(ideam_msk[[x]], paste('ideam_ag_masked', namesu[x], sep='_'), format='GTiff', overwrite=TRUE)) 

plan(multisession, workers=6)
  options(future.globals.maxSize= mem_future)
ideam_msk<- map(1:length(mask_list), function(x) mask(hansen_list[[x]], mask_list[[x]], perc=FALSE))
plan(multisession, workers=6)
map(1:length(ideam_msk), function(x) writeRaster(ideam_msk[[x]], paste('hansen_ag_masked', namesu[x], sep='_'), format='GTiff', overwrite=TRUE)) 

listr <- list.files(".",'ideam_ag_masked') 

listr

for(i in 1:length(listr)){
  ideam_msk[[i]] <- raster(listr[i])}

ideam_msk

listr <- list.files('.', 'hansen_ag_masked')
hansen_msk <- list()
for(i in 1:length(listr)){
  hansen_msk[[i]] <- raster(listr[i], band=14)}


comparer2 <- function(ideam1,ideam2, perc){
    test1 <- crosstabm(ideam1, ideam2, percent=perc, population=NULL)
    return(test1)}
mem_future <- 1000*1024^2 #this is toset the limit to 1GB
plan(multisession, workers=7)
options(future.globals.maxSize= mem_future)
diff_mat<- future_map(1:length(hansen_msk) , function(x) comparer2(ideam_msk[[x]], hansen_msk[[x]], perc=FALSE))
diff_mat
names(diff_mat) <- namesu
diff_mat_100<- diff_mat
save(diff_mat_100, file='ag_hi_msk_100_10_17.RData')


options(future.globals.maxSize= mem_future)


# the above was to comnpare byt only for 13 or 14 biotic units 
########################################################################################################################################################################################################
########################################################################################################################################################################################################


#load ideam 90 mask
mask_ideam <- raster("/media/mnt/Ecosistemas_Colombia/mask_ideam90_17.tif")
mask_ideam <- reclassify(mask_ideam, cbind(NA,NA,0))



mem_future <- 5000*1024^2 #this is toset the limit to 1GB
options(future.globals.maxSize= mem_future)
plan(multisession, workers=6)

namesu2 <- namesu[a]
biomat2 <- biomat[a]
biomat2
cropped <-map(a, function(x) crop(mask_ideam, extent(biomat[[x]])))
maskedt <-map(1:length(cropped), function(x) raster::mask(cropped[[x]], biomat2[[x]]))
options(future.globals.maxSize= mem_future)
plan(multisession, workers=6)
namesu3 <- namesu[329:397]
map(1:length(maskedt), function(x) writeRaster(maskedt[[x]], paste('msk_ideam', namesu3[x], sep='_'), format='GTiff', overwrite=TRUE))

##########################################################################################################################################################################################################
#############################################################################3#############################################################################################################################
############################################################################################################################################################################################################

listrm <- list.files('.','msk_ideam')
msk_90 <- list()


for(i in 1:length(listrm)){
  msk_90[[i]] <- raster(listrm[i])}


setwd("/media/mnt/Ecosistemas_Colombia/comp_hansen")

msk_90 <- msk_90[-7]

#listr1 <-list.files(".", "ag_hansen_2010_17_20")
#ag_20 <- list()
#for(i in 1:length(listr1)){
 #   ag_20[[i]] <- raster(listr1)
#ag_20 <- do.call(ag_20, merge)
#listr2 <-list.files(".", "ag_hansen_2010_17_30")
#ag_30 <- list()
#for(i in 1:length(listr2)){
 #   ag_30[[i]] <- raster(listr2)
#ag_30 <- do.call(ag_30, merge)

listr3 <-list.files(".", "ag_hansen_2010_17_40")
ag_40 <- list()
for(i in 1:length(listr3)){
    ag_40[[i]] <- raster(listr3[[i]])}
ag_40 <- do.call(merge, ag_40)
writeRaster(ag_40,'hansen_col_1017_40', format='GTiff', overwrite=TRUE)

listr4 <-list.files(".", "ag_hansen_2010_17_50")
    ag_50 <- list()
for(i in 1:length(listr4)){
    ag_50[[i]] <- raster(listr4[[i]])}
ag_50 <- do.call(merge,ag_50)

writeRaster(ag_50,'hansen_col_1017_50', format='GTiff', overwrite=TRUE)

listr5 <-list.files(".", "ag_hansen_2010_17_55")
    ag_55 <- list()
for(i in 1:length(listr5)){
    ag_55[[i]] <- raster(listr5[[i]])}

ag_55 <- do.call(merge, ag_55)
writeRaster(ag_55,'hansen_col_1017_55', format='GTiff', overwrite=TRUE)

    listr6 <-list.files(".", "ag_hansen_2010_17_60")
        ag_60 <- list()
for(i in 1:length(listr1)){
    ag_60[[i]] <- raster(listr6[[i]])}
ag_60 <- do.call(ag_60, merge)

    listr7 <-list.files(".", "ag_hansen_2010_17_65")
        ag_65 <- list()
for(i in 1:length(listr7)){
    ag_65[[i]] <- raster(listr7[[i]])}
ag_65 <- do.call(merge,ag_65)
writeRaster(ag_65, 'hansen_col_1017_65', format='GTiff', overwrite=TRUE)

                                        #    listr8 <-list.files(".", "ag_hansen_2010_17_70")
 #       ag_70 <- list()
#for(i in 1:length(listr8)){
 #   ag_70[[i]] <- raster(listr8)
#ag_70 <- do.call(ag_70, merge)
    listr9 <-list.files(".", "ag_hansen_2010_17_75")
        ag_75 <- list()
for(i in 1:length(listr9)){
    ag_75[[i]] <- raster(listr9[[i]])}
ag_75 <- do.call(merge, ag_75)
writeRaster(ag_75, 'hansen_col_1017_75', format='GTiff', overwrite=TRUE)

                                        # listr10 <-list.files(".", "ag_hansen_2010_17_80")
    #    ag_80 <- list()
#for(i in 1:length(listr10)){
 #   ag_80[[i]] <- raster(listr10)
#ag_80 <- do.call(ag_80, merge)
    listr11 <-list.files(".", "ag_hansen_2010_17_85")
        ag_85 <- list()
for(i in 1:length(listr11)){
    ag_85[[i]] <- raster(listr11[[i]])}
ag_85 <- do.call(merge, ag_85)
writeRaster(ag_85, 'hansen_col_1017_85', format='GTiff', overwrite=TRUE)
#listr12 <-list.files(".", "ag_hansen_2010_17_90")
 #   ag_90 <- list()
#for(i in 1:length(listr12)){
 #   ag_90[[i]] <- raster(listr12)
                                        #ag_90 <- do.call(ag_90, merge)

    listr13 <-list.files(".", "ag_hansen_2010_17_95")

ag_95 <- list()
for(i in 1:length(listr13)){
    ag_95[[i]] <- raster(listr13[[i]])}
ag_95 <- do.call(merge, ag_95)
writeRaster(ag_95, 'hansen_col_1017_95', format='GTiff', overwrite=TRUE)

    listr14 <-list.files(".", "ag_hansen_2010_17_100")
    ag_100 <- list()
for(i in 1:length(listr1)){
    ag_100[[i]] <- raster(listr14)
ag_100 <- do.call(ag_100, merge)
#######################################################################
