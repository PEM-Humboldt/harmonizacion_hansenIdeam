
# This code is used to download all the forest- no forest binary masks from the 
# Global forest cover Dataset by Hansen et al  using the package ForestChange.
#It  returns maps for each one of the thresholds between 70 and 100%. The next step is to load this, stack cut it by pieces and then carry out the comparson betwee nthe maps. Everything trough maps.
#It requires the package "greenbrown" available here:
http://greenbrown.r-forge.r-project.org
# Load libraries 
rm(list=ls())


setwd("inpath")

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

mun <- st_read('.','/biomas_wgs84.shp')
labels <- (mun$BIOMA_IAvH)
mun <- as(mun, 'Spatial')
# split mun into list of independent polygons  
biomat <- mun%>%split(.$BIOMA_IAvH)
# attention, for memoy reasons, I had to split the thing in several stages, and thats why it. DON;'T FORGET to adjust this!!!!!!!!!!!!!
names <- as.list(mun$BIOMA_IAvH)
names <- map(1:length(names), function(x) as.character(names[[x]]))
namesu <- unlist(names)
namesu <- namesu[-7]
# load the ideam maps 
# listr <- list.files(".", "ideam_2017")
# ideam17 <- list()
# for(i in 1:length(listr)){
#   ideam17[[i]] <- raster(listr[i])}
# # stack the rasters to build a multi band rasterstack. 
# #load the masked Rasters
# 
# ideam17
listr <- list.files(".", "ideam_2010_")
listr <- listr[(88:483)]
listr <- listr[c(1:396)]
      
ideam10 <- list()
for(i in 1:length(listr)){
  ideam10[[i]] <- raster(listr[i])}
listr <- list.files(".", "ideam_2000")
listr <- listr[c(129:524)]
ideam00 <- list()
for(i in 1:length(listr)){
  ideam00[[i]] <- raster(listr[i])}

test <- function(ideam1, ideam2){
    extent(ideam1)==extent(ideam2)}
gtest <- map(1:length(ideam10), function(x) test(ideam00[[x]], ideam10[[x]]))
unlist(gtest)  
b#############################

comparer <- function(ideam1,ideam2,namesu., writeraster, plotAgMap){
  suma <- ideam1-ideam2
  #x.stats <- data.frame(x.mean=cellStats(suma, "mean"))
  #return(x.stats)}
  #if(x.stats==0){
  x.mean <- cellStats(ideam1, "mean")
  y.mean <- cellStats(ideam2, "mean")
  if(x.mean==0|y.mean==0){
    DT <-  data.table(
      change <-  c(0,0,0,100),
      no_change <-  c(0, ncell(ideam1), ncell(ideam1), 100),
      Sum <-  c(0, ncell(ideam1),ncell(ideam1), NA),
      UserAccuracy <-  c(100,100,NA,100)
    )
    kappa <- 1
    DT <- as.data.frame(DT)
    rownames(DT) <- c('change', 'no-change', 'Sum','ProducerAccuracy')
    colnames(DT) <- c('change', 'no-change', 'Sum','UserAccuracy')
    comparedata <- list(ideam1,DT,kappa)
    names(comparedata) <- c('raster', 'table', 'kappa')
    class(comparedata) <- "CompareClassification"
    if(writeraster==TRUE){
       writeRaster(comparedata$raster, paste(namesu., 'ag_ideam_2000_2010_x', sep='_'), format='GTiff', overwrite=TRUE)}
       rm(suma, x.mean, y.mean, DT, kappa)
     }
  #return(comparedata)}
  else  
    {comparedata<- CompareClassification(ideam1, ideam2, names = list('Ideam_2000'=c('no-Forest','forest'),'Ideam_2010'=c('no-Forest','forest')), samplefrac = 1)
    if(writeraster==TRUE){
    writeRaster(comparedata$raster, paste(namesu., 'ag_ideam_2000_2010', sep='_'), format='GTiff', overwrite=TRUE)}}
    if(plotAgMap==TRUE){
       plot(comparedata)}
    #table <- as.data.frame(test1$table)
return(comparedata$table)}
############################
setwd("/folderto put your ouptut")

mem_future <- 1000*1024^2 #this is toset the limit to 1GB
  plan(multisession, workers=12)
  options(future.globals.maxSize= mem_future)
c_test2 <- future_map(300:396, function(x) comparer(ideam00[[x]], ideam10[[x]], namesu[x], writeraster=TRUE, plotAgMap=FALSE))
names(c_test2) <- namesu

###############Use DiffeR because it is faster than compareRaster and avoids its main idasdvantage (it does not work unless thera re pixels from all classes in 
                      #BOTH rasters, which is not necessarily always the case) and the contingency tables (with basically the same data but thr functions in DiffeE
                     # allow an easier manipulation of the contingency tables)

comparer2 <- function(ideam1,ideam2, perc){
  ideam_t <- ideam1
  hansen_t <- ideam2
  # mem_future <- 1000*1024^2 #this is toset the limit to 1GB
  # plan(multisession, workers=14)
  # options(future.globals.maxSize= mem_future)
  test1 <- crosstabm(ideam1, ideam2, percent=perc, population=NULL)
  differences <-  diffTablej(test1, digits = 2, analysis = 'error')
  return(list(test1, differences))}

mem_future <- 1000*1024^2 #this is toset the limit to 1GB
plan(multisession, workers=13)
options(future.globals.maxSize= mem_future)
diff_mat <- future_map(1:396, function(x) comparer2(ideam10[[x]], ideam17[[x]], perc=FALSE))

# produce difference Tables:                       
                       
diffTables <- function(diff_mat, digits, Type){
    table <- diffTablej(diff_mat, digits=digits, analysis=Type)
    return(table)}
tableR <- map(1:length(diff_mat), function(x) diffTables(diff_mat[[x]], digits=3, Type='change'))
names(tableR) <- namesu

