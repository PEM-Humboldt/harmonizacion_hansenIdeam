
setwd('/Users/sputnik/Documents/bosque-nobosque/IDEAMfnf')

dir()

library(raster)
library(tidyverse)
library(landscapemetrics)
library(furrr)

setwd('/storage/home/TU/tug76452/Forest_Armonization/bin_masked/outs') 

tiffes1 <- list.files('.', pattern='rec')
tiffes1 <- list(tiffes1[1],tiffes1[2],tiffes1[3],tiffes1[5],tiffes1[4])
tiffes1 <- unlist(tiffes1)
tiffes2 <- list.files('.', pattern='bin')

rat <- list()
for (i in 1:length(tiffes1)){
  rat[i] <- raster(tiffes1[i])
}
rat2 <- list()
for (i in 1:length(tiffes2)){
  rat2[i] <- raster(tiffes2[i])
}

rat[1]
rat2[1]


tiffes1
tiffes2

                                        #create temporary dir
dir.create('tempfiledir')
                                        #obtain string with the path
tempdir=paste(getwd(),'tempfiledir', sep="/")
rasterOptions(tmpdir=tempdir)

                                        #Set the memory limit for parallel running
mem_future <- 5000*1024^2 #this is toset the limit to 5GB
plan(multisession, workers=7)
 options(future.globals.maxSize= mem_future)


rat
                                        #rat <- do.call(stack, rat)
areas <- future_map(1:length(rat), function(x) freq(rat[[x]]))
areas <- map(1:length(areas), function(x) as_tibble(areas[[x]]))

dir()

# For SMBYC (4L)
                                        #create identifier
nam <- rep('V1', 5)
year. <- rep(c(2000, 2005, 2010, 2015, 2019),4)
year. <- matrix(year., ncol=5, byrow=TRUE)
year. <- as_tibble(year.)
src <- rep(c('SMBYC','GLAD'),4)
src <- matrix(src, ncol=2, byrow=TRUE)
src <- as_tibble(src)
areas <- map(1:5, function(x) cbind(areas[[x]], year.[x]))
areas <-map(1:5, function(x) cbind(areas[[x]], src[1])) 
names. <- c('value','count','year','src') 
areas <- map(areas, set_names, names.) 
areas. <- do.call(rbind, areas)
####Oops...
#src. <- rep('SMBYC', 20)
#src. <- as_tibble(src.)
#areas. <- areas.[-4]
#areas. <- cbind(areas.,src.)
names(areas.) <- names(areas_g)
save(areas., file="areas_smbyc.RData")

# For GLAD (3L)

areas <- future_map(1:length(rat2), function(x) freq(rat2[[x]]))
areas <- map(1:length(areas), function(x) as_tibble(areas[[x]]))
nam <- rep('V1', 5)
year. <- rep(c(2000, 2005, 2010, 2015, 2019),3)
year. <- matrix(year., ncol=5, byrow=TRUE)
year. <- as_tibble(year.)
src <- rep(c('SMBYC','GLAD'),3)
src <- matrix(src, ncol=2, byrow=TRUE)
src <- as_tibble(src)
areas <- map(1:5, function(x) cbind(areas[[x]], year.[x]))
areas <-map(1:5, function(x) cbind(areas[[x]], src[2])) 
names. <- c('value','count','year','src') 
areas <- map(areas, set_names, names.) 

areas_g <- do.call(rbind, areas)
#save(areas., file="areas_smbyc.RData")
save(areas_g, file="areas_glad.RData")
areas_f <- rbind(areas.,areas_g)
save(areas_f, file="areas_fin.RData")

areas_f


load('/Users/sputnik/Documents/bosque-nobosque/areas_fin.RData')



areas_f%>%group_by(year, src) 

areas_f <- as_tibble(areas_f)
areas_f%>%group_by(year,src)%>%summarise(a_sum=sum(count)require(scales)

areas_f <- areas_f%>%mutate(area_ha = count*0.09)
areas_f <- areas_f%>%drop_na(value)
areas_f <- areas_f%>%mutate(clase= case_when(value==0 ~'no Bosque',
                                             value==1 ~'Bosque',
                                             value==3 ~'sin información')) 
 
save(areas_f, file= 'areas_f.RData') 
ggplot(areas_f)
jpeg(file='plot2c.jpeg',
     width = 16, height=9, units= 'in', res=300) # this exports the ggplots as jpegs, 
# and sets the size and resolution. ayou can plot inside Rstudio instead  # by dropping this 
# here, i created line graps, but ypu will need to use barplots
ggplot (areas_f%>%filter(value!=3), aes(x = year, y= area_ha, color= interaction(clase,src), group=interaction(value,src)))+
  geom_line(size=1.5)+
  geom_point(size=4)+
  scale_y_continuous(labels = comma)+
  labs (
    title = "Bosque/no Bosque 2000-2019",
    subtitle = "SMBYC vs GLAD",
    x = "Año",
    y = "Total Area (ha)"
  )
#stops graphic device. Necessary for new plots 
dev.off()

jpeg(file='plot3c.jpeg',
     width = 16, height=9, units= 'in', res=300) 
ggplot (areas_f, aes(x = year, y= area_ha, color= interaction(clase,src), group=interaction(value,src)))+
  geom_line(size=1.5)+
  geom_point(size=4)+
  scale_y_continuous(labels = comma)+
  labs (
    title = "Bosque/no Bosque 2000-2019",
    subtitle = "SMBYC vs GLAD",
    x = "Año",
    y = "Total Area (ha)"
  )
dev.off()
qplot(round, price, data=firm, group=id, color=id, geom='line') +  
  geom_smooth(aes(group=interaction(size, type)))



1370/2

library(raster)

ras_2019 <- raster('/Users/sputnik/Documents/bosque-nobosque/merged_2019a.tif')
border <- raster('/Users/sputnik/Documents/bosque-nobosque/borders/borderd_biomes_msk.tif')

merged <- merge(border, ras_2019)
writeRaster(merged, 'armonized_2019a.tif')

id_2019 <- raster('/Users/sputnik/Documents/bosque-nobosque/IDEAMfnf/rec SBQ_SMBYC_BQNBQ_V5_2019.tif')

mskd <- mask(merged, id_2019, filename='diff_2019.tif', maskvalue=1)




