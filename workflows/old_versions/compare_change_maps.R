# This code reviewd on 18/04/2022

##############################
library(terra)
library(ecoChange)
library(parallel)
library(sf)
library(tidyverse)
library(purrr)
library(furrr)
library(diffeR)
library(useful)
library(data.table)


dir.create('tempfiledir')

tempdir=paste(getwd(),'tempfiledir', sep="/")
rasterOptions(tmpdir=tempdir)
unixtools::set.tempdir('/media/mnt/Ecosistemas_Colombia/tempfiledir')

setwd("/Forest_armonization/Ecosistemas_Colombia/hansen_ideam")

mun <- st_read('/media/mnt/Ecosistemas_Colombia/biomas_wgs84.shp')
labels <- (mun$BIOMA_IAvH)
mun <- as(mun, 'Spatial')
# split mun into list of independent polygons  
biomat <- mun%>%split(.$BIOMA_IAvH)

#######################################################################################################
#Chreate vector with the names 
names <- as.list(mun$BIOMA_IAvH)
names <- map(1:length(names), function(x) as.character(names[[x]]))
namesu <- unlist(names)

# i had to do this because bioma #7 has no valid data and the function would not run there (in the case of Ideam maps) 
namesu <- namesu[-7]


# this function uses the package diffeR to compare between pairs of maps. It does not produce agreement maps, only contingency matrices. It works faster and does not require that both maps have pixels form all classes
#######################THIS IS THE FUNCTION THAT I NEED TO USE NOW (03/03/2021) Here we are, on 18/04/2022
# still messing with this thing, but i finally know where we're going. 


comparer2 <- function(ideam1,ideam2, perc){
  test1 <- crosstabm(ideam1, ideam2, percent=perc, population=NULL)
  return(test1)}

#1. Load the agreement maps:
  
  setwd()
#ideam Agreement (change) maps
listr <- list.files('.', 'ag_id_msk')
ideam_ag <- list()
for(i in 1:length(listr)){
  ideam_ag[[i]] <- raster(listr[i])}


setwd('/Forest_armonization/Ecosistemas_Colombia/agreement_masked')
test_match <- function(ideam1, ideam2){
    extent(ideam1)==extent(ideam2)}

length(namesu)
#don't know what happened here
namesu2 <- namesu[-250]

# load the masked Hansen agreement maps. Remember to change the band number for each threshold. 
#Band 1 is threshold= 20%, 9 is t=100% (it goes up to 22 with the last review) 

listr <- list.files(".", "ag_ha_msk")
###########There msut be a reason for this, no idea which one. Don't know if it matters. 
ideam_ag. <- ideam_ag[-250]
hansen.<- hansen[-250]
############
#This section is supposed to map over the whole list of biomes and compare each pair of maps 
# and load them by threshold and run the comparison for the change maps between ideam and hansen 
 #create an empty container list
#date 2
bnd <- 1
#we move this part
bnd2 <- 20
hansen <- list()
for(i in 1:length(listr)){
    hansen[[i]] <- raster(listr[i], band=bnd)}
hansen.<- hansen[-250]
gtest <- map(1:length(hansen.), function(x) test_match(hansen.[[x]], ideam_ag.[[x]]))
unlist(gtest)
mem_future <- 1000*1024^2 #this is to set the limit to 1GB
plan(multisession, workers=7)
options(future.globals.maxSize= mem_future)
diff_mat<- future_map(1:length(hansen.), function(x) comparer2(ideam_ag.[[x]], hansen.[[x]], perc=FALSE))
names(diff_mat) <- namesu2
namer <- paste('ag_id_ha', bnd2, sep='_')

#I remember here, This code has issues (line 104) onwards as it names and stores the list of rdatas without messing wit hte names of the
#object, which is the result of the function, but this can be fixed somehow (don't know how for the moment)


##############################
#I had to do this because i did not know (and would have surely been better to solve than to do what
# I did whic was repeating the thing and manually changing the names of the objects (and less likely to 
# commit errors)

diff_mat_20 <- diff_mat
save(diff_mat_20, file=paste(namer, '.RData', sep=''))

diff_mat_30 <- diff_mat
save(diff_mat_30, file=paste(namer, '.RData', sep=''))

#diff_mat_40 <- diff_mat
#save(diff_mat_40, file=paste(namer, '.RData', sep=''))
#diff_mat_50 <- diff_mat
#save(diff_mat_50, file=paste(namer, '.RData', sep=''))
#diff_mat_55 <- diff_mat
#save(diff_mat_55, file=paste(namer, '.RData', sep=''))
#diff_mat_60 <- diff_mat
#save(diff_mat_60, file=paste(namer, '.RData', sep=''))
#diff_mat_65 <- diff_mat
#save(diff_mat_65, file=paste(namer, '.RData', sep=''))
#diff_mat_70 <- diff_mat
#save(diff_mat_70, file=paste(namer, '.RData', sep=''))
#diff_mat_75 <- diff_mat
#save(diff_mat_75, file=paste(namer, '.RData', sep=''))
#diff_mat_80 <- diff_mat
#save(diff_mat_80, file=paste(namer, '.RData', sep=''))
#diff_mat_85 <- diff_mat
#save(diff_mat_85, file=paste(namer, '.RData', sep=''))
#diff_mat_90 <- diff_mat
#save(diff_mat_90, file=paste(namer, '.RData', sep=''))
#diff_mat_95 <- diff_mat
#save(diff_mat_95, file=paste(namer, '.RData', sep=''))
diff_mat_100 <- diff_mat
save(diff_mat_100, file=paste(namer, '.RData', sep=''))
############################################

#The difference matrices are not complete (only 14, the others shpuld be somewhere, i'll find them)
# This see,s like an attempt to solve the problem i just mentioned, Past me seems to have already 
# noticed this issue, and surely spent some time grunting about it,

save([assign(paste('ag_id_ha', bnd2, sep='_')], diff_mat_30)),file=paste(namer, '.RData', sep='')


assign(paste('ag_id_ha', bnd2, sep='_'), diff_mat_30)

assign(paste('ag_id_ha', bnd2, sep='_')) <- diff_mat_20 

msk <- raster('mask_ideam90_17.tif')




setwd('/media/mnt/Ecosistemas_Colombia/Agreement_ideam_2010_2017')


ideam_ag <- raster('change10_17_col.tif')

ideam_ag <- mask(ideam_ag,msk)

mem_future <- 5000*1024^2 #this is toset the limit to 1GB
options(future.globals.maxSize= mem_future)
plan(multisession, workers=7)
a <-c(351:397)
namesu2 <- namesu[a]
biomat2 <- biomat[a]
cropped <- future_map(a, function(x) crop(ideam_ag, extent(biomat[[x]])))
maskedt <-map(1:length(cropped), function(x) raster::mask(cropped[[x]], biomat2[[x]]))
#mem_future <- 20000*1024^2 #this is toset the limit to 1GB
#options(future.globals.maxSize= mem_future)
#plan(multisession, workers=7)

setwd('/media/mnt/Ecosistemas_Colombia/agreement_masked')

map(1:length(maskedt), function(x) writeRaster(maskedt[[x]], paste('ag_id_msk', namesu2[x], sep='_'), format='GTiff', overwrite=TRUE))




extent(biomat[[1]])

namesu
a <-c(329:397)
namesu2 <- namesu[a]
biomat2 <- biomat[a]
biomat2
cropped <-map(a, function(x) crop(mask <- ideam, extent(biomat[[x]])))
maskedt <-map(1:length(cropped), function(x) raster::mask(cropped[[x]], biomat2[[x]]))
options(future.globals.maxSize= mem <- future)
plan(multisession, workers=6)
namesu3 <- namesu[329:397]
map(1:length(maskedt), function(x) writeRaster(maskedt[[x]], paste('msk_ideam', namesu3[x], sep='_'), format='GTiff', overwrite=TRUE))
