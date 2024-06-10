# This code reviewed on 18/04/2022


##############################
packs<-c('raster', 'rgdal', 'tidyverse', 'useful','diffeR', 'greenbrown', 'gdalUtils', 'gdalUtilities', 'furrr')
sapply(packs, require, character.only = TRUE) 

#Ready environment
#dir.create('tempfiledir')
tempdir=paste(getwd(),'tempfiledir', sep="/")
rasterOptions(tmpdir=tempdir)

#1. Reproject/align
hansen19<-raster('/media/mnt/Forest_Armonization/Armonized_nomsk/armonized_2019a.tif')

target<-'/media/mnt/Forest_Armonization/SMBYC_Data/cambio_2018_2019_v8_200707_3116.img'
reference. <-"/media/mnt/Forest_Armonization/mask_ideam90_17.tif"
dst.<-'/media/mnt/Forest_Armonization/cambio18_19.tif'
align_rasters(unaligned=target, reference=reference., dstfile=dst., nthreads=6, verbose= TRUE)

#Homologue Classes
ideam19<-raster('/media/mnt/Forest_Armonization/cambio18_19.tif')
m<-c(1.9, 2.1, 5, 3.9, 4.1, 1)
m<-matrix(m, ncol=3, byrow=TRUE)
##### r
ideam19<-reclassify(ideam19, m)                                        # imagen a alienar
 writeRaster(ideam19, 'ideamfnF2019.tif')
msk<-raster('/media/mnt2/BiomapCol_22/mask_colombia.tif')
m<-c(4.9, 5.1, 0, 0,0, NA)
m<-matrix(m, ncol=3, byrow=TRUE)
ideam19<-reclassify(ideam19, m)                                     

ideam19<-mask(ideam19, msk)
writeRaster(ideam19,'ideamfnF2019_rec.tif', overwrite=TRUE)
m<-c(NA, NA, 0)
m<-matrix(m, ncol=3, byrow=TRUE)

hansen19<-reclassify(hansen19, m)
hansen19<-mask(hansen19, msk)
writeRaster(hansen19, 'hansen2019_bin.tif', overwrite=TRUE)

#load hansen ideam
ideam19<-raster('ideamfnF2019_rec.tif')
hansen19<-raster('hansen2019_bin.tif')

#Use split rast to diovide the maps into smaller chunks. The
SplitRas <- function(raster,ppside,save,plot){
    h        <- ceiling(ncol(raster)/ppside)
    v        <- ceiling(nrow(raster)/ppside)
    agg      <- aggregate(raster,fact=c(h,v))
    agg[]    <- 1:ncell(agg)
    agg_poly <- rasterToPolygons(agg)
    names(agg_poly) <- "polis"
    r_list <- list()
    for(i in 1:ncell(agg)){
        e1          <- extent(agg_poly[agg_poly$polis==i,])
        r_list[[i]] <- crop(raster,e1)
    }
    if(save==T){
        for(i in 1:length(r_list)){
            writeRaster(r_list[[i]],filename=paste("SplitRas",i,sep=""),
                        format="GTiff",datatype="FLT4S",overwrite=TRUE)
        }
    }
    if(plot==T){
        par(mfrow=c(ppside,ppside))
        for(i in 1:length(r_list)){
            plot(r <- list[[i]],axes=F,legend=F,bty="n",box=FALSE)
        }
    }
    return(r_list)
        }


m<-c(2.1,3.1,NA)
m<-matrix(m, ncol=3,byrow=TRUE)
ideam19<-reclassify(ideam19,m)
ideam19sp<-SplitRas(ideam19, ppside=12, save=FALSE, plot=FALSE)
hansen19sp<-SplitRas(hansen19, ppside=12, save=FALSE, plot=FALSE)
ideam19sp<-ideam19sp[-c(1:4,9:15,20:25,32:37, 46:49,61,73,107, 109,110,111,119:125, 131:140,143,144)]   
hansen19sp<-hansen19sp[-c(1:4,9:15,20:25,32:37, 46:49,61,73,107, 109,110,111,119:125, 131:140,143,144)]  
rm(ideam19, hansen19)
mem_future <- 5000*1024^2 #this is toset the limit to 1GB
plan(multisession, workers=5)
options(future.globals.maxSize= mem_future)
comparedata<- future_map(1:length(ideam19sp), function(x) CompareClassification(ideam19sp[[x]], hansen19sp[[x]], names = list('Ideam_19'=c('no-Forest','forest'),'Hansen_19'=c('no-Forest','forest')), samplefrac = 1))
#Extract rassters from comparedata object
rat<-list()
for(i in 1:length(comparedata)){
    rat[i]<-comparedata[[i]][[1]]
}
#merge rasters 
agg<-do.call(merge, rat)

writeRaster(agg, 'agg_for_19.tif')
 
                        write.csv(comparedata$table, file='cont_mat.csv')


getwd()

agg

