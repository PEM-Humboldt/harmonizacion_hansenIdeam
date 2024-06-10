<<<<<<< HEAD
packs <- c('raster','rgdal', 'tidyverse', 'fasterize', 'landscapemetrics', 'sf','gdalUtils','gdalUtilities', 'rgeos', 'rasterDT', 'ecochange', 'furrr')
out.. <-  sapply(packs, require, character.only = TRUE)


setwd('/storage/home/TU/tug76452/Forest_Armonization')


dir.create('tempfiledir')
                                        #obtain string with the path
tempdir=paste(getwd(),'tempfiledir', sep="/")
rasterOptions(tmpdir=tempdir)

#  Load 0 background raster   to rasterize
temp <- raster('/storage/home/TU/tug76452/Forest_Armonization/bin_masked/msk_0.tif')#load harmonized masked 
mskwd <- '/storage/share/BiomapCol_22/Maps_hansen/Armonized_msk'
=======
#Run comparison between SINAP forest maps and Harmonizerd
#setwd('/storage/home/TU/tug76452/Forest_Armonization')
#lab
setwd('/media/mnt/Forest_Armonization')
#Laptop
setwd('/Volumes/tug76452/Forest_Armonization')
#obtain string with the path
dir()

td <- '/Users/sputnik/Documents/bosque-nobosque/SINAP_areas'
setwd(td)
#Load vector data as SF
# 1 . Set files
shps <- list.files('/media/mnt/Forest_Armonization/SINAP_areas/', pattern='shp')
shps <- list.files('/Volumes/tug76452/Forest_Armonization/SINAP_areas', pattern='shp')
shps <- list.files('/Users/sputnik/Documents/bosque-nobosque/SINAP_areas', pattern='shp')
shps <- map(1:length(shps), function(x) str_sub(shps[x], start=1, end=9))
shps <- unlist(shps)
setwd('/Volumes/tug76452/Forest_Armonization/SINAP_areas')
# st_read
sfs <- map(1:6, function(x) st_read('.', shps[x]))

#3 Load template to rasterize.
#cargar un raster con el crs y la resolucón de los mapas armonizados para rasterizar los 
# vector con la información de los Parques que se van a analizar.  
#es un mapa de colombia, 
temp <- raster('/Users/sputnik/Documents/bosque-nobosque/SINAP_areas/mask_col_0.tif')
#temp2 <- raster('/Users/sputnik/Documents/bosque-nobosque/IDEAMfnf/msk_SMBYC.tif')
#4. Reproject to the crs of the template. 
# Toda la información Nacional está en Magna Sirgas, pero los datos de GLAD están en WGS84. Es más 
# rápido reprojectar los vectors
sfs <- map(1:6, function(x) st_transform(sfs[[x]], crs(temp)))
#5 Add numeric attribute to rasterize. Asigna un valor numérico para cada una de las clases
sfs <- map(1:length(sfs), function(x) mutate(sfs[[x]], type = case_when(NIVEL2 == 'Aguas Continentales' ~ 1,
                                          NIVEL2 == 'Aguas Maritimas' ~ 2, 
                                          NIVEL2 == 'Areas Abiertas, sin o con poca Vegetacion' ~3,
                                          NIVEL2 == 'Areas Agricolas Heterogeneas' ~ 4,
                                          NIVEL2 == 'Areas con Vegetacion Herbacea y/o Arbustiva' ~ 5,
                                          NIVEL2 == 'Areas Humedas Continentales' ~ 6,
                                          NIVEL2 == 'Areas Humedas Costeras' ~ 7,
                                          NIVEL2 == 'Bosques' ~8,
                                          NIVEL2 == 'Cultivos Permanentes' ~9,
                                          NIVEL2 == 'Nubes' ~ 10,
                                          NIVEL2 == 'Pastos'~ 11,
                                          NIVEL2 == 'Zonas Industriales o Comerciales y Redes de Comunicacion' ~ 12,
                                          NIVEL2 == 'Zonas Verdes Artificializadas, no Agricolas' ~ 13)))

#**Nota, se puede convertir Bosques a 1 y todo lo demás a 0. El resultado es el mismo si no se necesita
#*#saber con que clase de no bosque se hace el análisis
# Nota, la mayoría de los atributos son innecesarios. Basta con eliminar esas columnas y 
# Hacer rowmerge para unirlo todo más fácil. ***Pendiente*** 

#Arreglar el atributo "NOMBRE" en 2018, que viene mal de origen 
sfs[[6]] <- sfs[[6]]%>%mutate(NOMBRE = NOM)
####################################################################################
##########################################NOTA##########################################
#test to nest. However this is a list not a tidy object, and btw, the number and names of the 
#attributes is different, as well as the order. This would require some extra work. Let us keep it 
#like this  for the moment.
# Next to fix: learn how to nest the lists
# just had to drop the attributes and keep only the ones of forest no forest and the geom.
####################################################################################
####################################################################################

#Extract Vector with the names of each of the PNN. Extraer un vector con los nombres de los PNN
names. <- unique(sfs[[1]][["NOMBRE"]])
#Ordenar Alfabéticamente
names. <- sort(names.)
#eliminar espacios, sustituir por _
names. <- gsub(" ", "_", names.) # 
#sfs. <- unlist(sfs)

#Split vector by PNN. Dividir por cada una de las areas de estudio.
sfs <- map(sfs, . %>% split(.$NOMBRE))

#load harmonized masked. Cargar Mapas Harmonizados

                                        #load rasters mask 
>>>>>>> ff7dbf6fb3c7419f751e38d238f7af104fa63ae1

 
#Load Years to analyize 
setwd('/Users/sputnik/Documents/bosque-nobosque/rasters_SINAP')
tiffes <- list.files('.', pattern='bin_masked') 
#select the specific years
<<<<<<< HEAD

tiffes <- tiffes[-c(1:6)]
tiffes <- tiffes[c(3,8,13,16,18,19)]
                                        # set vector to name rasters per year.
years <- unlist(map(1:length(tiffes), function(x) str_sub(tiffes[x], start=8, end=15)))


harm <-list()
for(i in 1:length(tiffes)){
  harm[i] <- raster(paste(mskwd,tiffes[i], sep='/'))}
#load mask (fill NAs, i think i have it somewhere but can't recall where)
# crop the template raster
# for some reason future_map s not working on the Mac. Find out why

mem_future <- 5000*1024^2 #this is toset the limit to 5GB
 plan(multisession, workers=6)
 options(future.globals.maxSize= mem <- future)

harm <- map(1:length(harm), function(x) raster::merge(harm[[x]], temp))
binwd <- '/storage/home/TU/tug76452/Forest_Armonization'
setwd(binwd)
map(1:length(harm), function(x) writeRaster(harm[[x]], paste('bin_masked', years[x], sep= '_')))

dir()

#crop and mask for each of the PNN
temp <-map(1:length(sfs1), function(x)  crop(temp, extent(sfs1[[x]]))) 
temp <-map(1:length(sfs1), function(x)  mask(temp[[x]], sfs1[[x]])) 

                                        #what is this

# for each year. Data rasterized (each one is each park)

sfs1 <- map(1:6, function(x) fasterize(sfs1[[x]], temp[[x]], field='type'))
sfs2 <- map(1:6, function(x) fasterize(sfs2[[x]], temp[[x]], field='type'))
sfs3 <- map(1:6, function(x) fasterize(sfs3[[x]], temp[[x]], field='type'))
sfs4 <- map(1:6, function(x) fasterize(sfs4[[x]], temp[[x]], field='type'))
sfs5 <- map(1:6, function(x) fasterize(sfs5[[x]], temp[[x]], field='type'))
sfs6 <- map(1:6, function(x) fasterize(sfs6[[x]], temp[[x]], field='type'))
#harm <- do.call(stack, harm)

sfs. <- map(sfs., . %>% fasterize(.$sfs., ))
sfs.1<-map( 

                                        # split  Harmonized by each one per year. This is the kind of process that i need to nest, because so far I have to cp+v each time,  looks awful and is very inefficient, but anyway.
                                        # SEE, Iit gets really confusing



                                        #convert names list from factor into character. Subsitute " " with "_"
names <-  sub(" ", "_", names)

map(1:length(harm), function(x) writeRaster(harm[[x]],paste('harm_bin', years[x], sep='_'))) 

getwd()

tiffes


                                            
let us solve this the right way. 

each sfs list matches to each harm list. 

harm1 <- map(1:length(temp),function(x) crop(harm[[1]], extent(temp[[x]])))
harm1 <- map(1:length(temp),function(x) mask(harm1[[x]], temp[[x]]))
harm2 <- map(1:length(temp),function(x) crop(harm[[2]], extent(temp[[x]])))
harm2 <- map(1:length(temp),function(x) mask(harm2[[x]], temp[[x]]))
harm3 <- map(1:length(temp),function(x) crop(harm[[3]], extent(temp[[x]])))
harm3 <- map(1:length(temp),function(x) mask(harm3[[x]], temp[[x]]))
harm4 <- map(1:length(temp),function(x) crop(harm[[4]], extent(temp[[x]])))
harm4 <- map(1:length(temp),function(x) mask(harm4[[x]], temp[[x]]))
harm5 <- map(1:length(temp),function(x) crop(harm[[5]], extent(temp[[x]])))
harm5 <- map(1:length(temp),function(x) mask(harm5[[x]], temp[[x]]))
harm6 <- map(1:length(temp),function(x) crop(harm[[6]], extent(temp[[x]])))
harm6 <- map(1:length(temp),function(x) mask(harm6[[x]], temp[[x]]))
map(1:length(harm1), function(x) writeRaster(harm1[[x]],paste('harm1_bin', years[x], sep='_'))) 
map(1:length(harm2), function(x) writeRaster(harm2[[x]],paste('harm2_bin', years[x], sep='_')))
map(1:length(harm3), function(x) writeRaster(harm3[[x]],paste('harm3_bin', years[x], sep='_')))
map(1:length(harm4), function(x) writeRaster(harm4[[x]],paste('harm4_bin', years[x], sep='_')))
map(1:length(harm5), function(x) writeRaster(harm5[[x]],paste('harm5_bin', years[x], sep='_')))
map(1:length(harm6), function(x) writeRaster(harm6[[x]],paste('harm6_bin', years[x], sep='_'))) 


sfs1[[1]]

harm1[[1]]

harm1

[[1]]

map(1:length(temp), function(x) writeRaster(temp[[x]], paste(names[x], 'msk.tif', sep='_')))


plot(temp[[5]])

=======
harm <-list()
for(i in 1:length(tiffes)){
  harm[i] <- raster(tiffes[i])}
#crear vector con los años
years. <- unlist(as.integer(map(1:length(tiffes),function(x) str_sub(tiffes[x],start=12, end=15))))

#Cortar y enmascarar el raster plantilla para rasterizar los polígonos de los PNN que se van a analizar
temp <-map(1:length(sfs), function(x)  crop(temp, extent(sfs[[1]][[x]]))) 
temp <-map(1:length(sfs), function(x)  mask(temp[[x]], sfs[[1]][[x]])) 


# Hacerlo para cada PNN año
# sfs. <- sfs%>%select(NOMBRE)
# %>% group_by(PERIODO)%>%map(1:length(temp), function(x)fasterize(., temp[[x]], field ='type'))
# sfs <- map(sfs, ~map(fasterize))
# I have wasted two days  here trying to find out how to map this.
##########################3
############## Reminder to fix this some day
sfs1 <- map(sfs ~map2(., temp, fasterize(., temp, field= 'type')))
harm. <- map2(harm,temp, ~(.harm, .extent(temp)))
#########################          

#datos PNN rasterizados por lugar y por año. Solución temporal.
sfs1 <- map(1:6, function(x) fasterize(sfs[[1]][[x]], temp[[x]], field='type')) #2002
sfs2 <- map(1:6, function(x) fasterize(sfs[[2]][[x]], temp[[x]], field='type')) #2007
sfs3 <- map(1:6, function(x) fasterize(sfs[[3]][[x]], temp[[x]], field='type')) #2012
sfs4 <- map(1:6, function(x) fasterize(sfs[[4]][[x]], temp[[x]], field='type')) #2015
sfs5 <- map(1:6, function(x) fasterize(sfs[[5]][[x]], temp[[x]], field='type')) #2017
sfs6 <- map(1:6, function(x) fasterize(sfs[[6]][[x]], temp[[x]], field='type')) #2018

#Definir matriz de reclasificación, Todo lo que es no bosque -> 0 , Bosque -> 1.
# Es posible conservar las otras clases de no bosque para analizar la confusión
# con mas detalle. Por ahora solo es bosque/no-bosque. 
m <- c(0.9, 7.1, 0, 7.9, 8.1, 1, 8.9, Inf, 0)
m <- matrix(m, ncol=3, byrow=TRUE)
#Armar listas por lugar (podría ser  por año, hasta seguro es mejor, pero ya lo hice así)
# Si, aarreglar acá. Correr sobre el mismo sfsx cambiando el indice en su lugar. 
# Habría obtenido sfsfx para cada año todos los lugares y no cada lugar todos los años. 
sfsf1 <- (list(sfs1[[1]],sfs2[[1]],sfs3[[1]],sfs4[[1]],sfs5[[1]],sfs6[[1]])) # El Tuparro 
sfsf2 <- (list(sfs1[[2]],sfs2[[2]],sfs3[[2]],sfs4[[2]],sfs5[[2]],sfs6[[2]])) # Los Nevados  
sfsf3 <- (list(sfs1[[3]],sfs2[[3]],sfs3[[3]],sfs4[[3]],sfs5[[3]],sfs6[[3]])) # Sanquianga 
sfsf4 <- (list(sfs1[[4]],sfs2[[4]],sfs3[[4]],sfs4[[4]],sfs5[[4]],sfs6[[4]])) # Serrania de Chiribiquete El tupparo 
sfsf5 <- (list(sfs1[[5]],sfs2[[5]],sfs3[[5]],sfs4[[5]],sfs5[[5]],sfs6[[5]])) # Sierra Nevada de Santa Marta 
sfsf6 <- (list(sfs1[[6]],sfs2[[6]],sfs3[[6]],sfs4[[6]],sfs5[[6]],sfs6[[6]])) # Tayrona  
#Reclasificar
sfsf1 <- map(1:length(sfsf1), function(x) reclassify(sfsf1[[x]], m))
sfsf2 <- map(1:length(sfsf2), function(x) reclassify(sfsf2[[x]], m))
sfsf3 <- map(1:length(sfsf3), function(x) reclassify(sfsf3[[x]], m))
sfsf4 <- map(1:length(sfsf4), function(x) reclassify(sfsf4[[x]], m))
sfsf5 <- map(1:length(sfsf5), function(x) reclassify(sfsf5[[x]], m))
sfsf6 <- map(1:length(sfsf6), function(x) reclassify(sfsf6[[x]], m))

#Cortar/enmascarar hansen armonizado para cada lugar. Otra vez, esta es la case de cosas que tengo 
# que poder loopear.
######################################################################

######################################################################
######################################################################
# Uno a uno por lugar
harm1 <- map(1:length(harm), function(x) crop(harm[[x]], extent(temp[[1]]))) #El Tuparro
harm1 <- map(1:length(harm1),function(x) mask(harm1[[x]], temp[[1]]))
harm2 <- map(1:length(harm), function(x) crop(harm[[x]], extent(temp[[2]]))) #Los Nevados 
harm2 <- map(1:length(harm),function(x) mask(harm2[[x]], temp[[2]]))
harm3 <- map(1:length(harm), function(x) crop(harm[[x]], extent(temp[[3]]))) #Sanquianga
harm3 <- map(1:length(harm),function(x) mask(harm3[[x]], temp[[3]]))
harm4 <- map(1:length(harm), function(x) crop(harm[[x]], extent(temp[[4]]))) #Serrania de Chiribiquete 
harm4 <- map(1:length(harm4),function(x) mask(harm4[[x]], temp[[4]]))
harm5 <- map(1:length(harm), function(x) crop(harm[[x]], extent(temp[[5]]))) #Sierra Nevada de Santa Marta
harm5 <- map(1:length(harm5),function(x) mask(harm5[[x]], temp[[5]]))
harm6 <- map(1:length(harm), function(x) crop(harm[[x]], extent(temp[[6]]))) #Tayrona
harm6 <- map(1:length(harm6),function(x) mask(harm6[[x]], temp[[6]]))

######################################################################
######################################################################
#Reclassify harmonized to the same types of PNN
#This only works to compare pnn with its multiple classes, but not to extract maps, as the classes are not present
#on the second rasters and thus compareraster() cannot get it.  
#set reclass matrix
#  m <- c(7,9,8.1, 1) 
#  m <- matrix(m, ncol=3,byrow=TRUE)
#  
# harm1 <- map(harm1, reclassify, m) #El Tuparro
# harm2 <- map(harm2, reclassify, m) #Los Nevados
# harm3 <- map(harm3, reclassify, m) #Sanquianga
# harm4 <- map(harm4, reclassify, m) #Serrania de Chiribiquete
# harm5 <- map(harm5, reclassify, m) #Sierra Nevada de Santa Marta
# harm6 <- map(harm6, reclassify, m) #Tayrona
######################################################################
######################################################################

#set crosstabm() function from diffeR into map
compdiff <- function(ref,tar, perc){
  cont_t <- crosstabm(ref, tar, percent=perc, population=NULL)
  return(cont_t)}

#Extraer las matrices de contingencia (diffeR) (en # de píxels, si se pone perc=TRUE se obtiene
#en porcentaje)
agg1p <- map(1:length(harm1), function(x) compdiff(harm1[[x]], sfsf1[[x]], perc =  FALSE))
agg2p <- map(1:length(harm1), function(x) compdiff(harm2[[x]], sfsf2[[x]], perc =  FALSE))
agg3p <- map(1:length(harm3), function(x) compdiff(harm3[[x]], sfsf3[[x]], perc =  FALSE))
agg4p <- map(1:length(harm4), function(x) compdiff(harm4[[x]], sfsf4[[x]], perc =  FALSE))
agg5p <- map(1:length(harm5), function(x) compdiff(harm5[[x]], sfsf5[[x]], perc =  FALSE))
agg6p <- map(1:length(harm6), function(x) compdiff(harm6[[x]], sfsf6[[x]], perc =  FALSE))

# Unir todas las tablas de cada lugar, agregar los años.
aggp <- map(1:length(agg1p), function(x) rbind(agg1p[[x]],agg2p[[x]],
                                               agg3p[[x]],agg4p[[x]],agg5p[[x]],agg6p[[x]]))

years <- map(1:length(agg1p), function(x)(c(rep(years.[x], times=12))))

# Agregar la columna con los años 
aggp <- map(1:length(agg1p), function(x) cbind(aggp[[x]], years[[x]]))
# col with names. Thewre is surely a better way to do this.

# Agregar Columna con los nombres (refinar acá, es posible obtener directamente de los nombres)

locs <- c("El_Tuparro","El_Tuparro","Los_Nevados","Los_Nevados","Sanquianga","Sanquianga",
          "Serrania_de Chiribiquete","Serrania_de Chiribiquete","Sierra_Nevada de Santa Marta",
          "Sierra_Nevada de Santa Marta","Tayrona","Tayrona")

aggp <- map(1:length(agg1p), function(x) cbind(aggp[[x]], locs))
# class. es un vector de "bosque"'y "no bosque"
aggp <- map(1:length(agg1p), function(x) cbind(class., aggp[[x]]))

#Unir todas las tablas 
aggp <- do.call(rbind,aggp)
#Asignar nombres a las columnas 
col_names <- c('class', 'no_bosque', 'bosque', 'year', 'pnn')
colnames(aggp) <- col_names
#Convertir a Tibble
aggp <- as_tibble(aggp)
#Salvar
save(aggp, file= 'agg_all.RDAta')
############################################################################################################
############################################################################################################
############################################################################################################
#Crear Mapas de Coincidencia (greenbrown)
 
 compgb <- function(ref,tar,names, years){
   comparedata<- CompareClassification(ref, tar, names = list('GLAD_ARM'=c('No bosque',  'bosque'),'PNN'=c('no bosque', 'bosque')), samplefrac = 1)
     return(comparedata)}


gbr1 <- map(1:length(harm1), function(x) compgb(harm1[[x]], sfsf1[[x]], names= names.[x], years = years.[x])) # El Tuparro
gbr2 <- map(1:length(harm1), function(x) compgb(harm2[[x]], sfsf2[[x]], names= names.[x], years = years.[x])) # Los Nevados
gbr3 <- map(1:length(harm1), function(x) compgb(harm3[[x]], sfsf3[[x]], names= names.[x], years = years.[x])) # Sanquianga
gbr4 <- map(1:length(harm1), function(x) compgb(harm4[[x]], sfsf4[[x]], names= names.[x], years = years.[x])) # Serrania de Chiribiquete
gbr5 <- map(1:length(harm1), function(x) compgb(harm5[[x]], sfsf5[[x]], names= names.[x], years = years.[x])) # Sierra Nevada
gbr6 <- map(1:length(harm1), function(x) compgb(harm6[[x]], sfsf6[[x]], names= names.[x], years = years.[x])) # Tayrona

# setwd('/Users/sputnik/Documents/bosque-nobosque/rasters_SINAP')

map(1:length(gbr1), function(x) writeRaster(gbr1[[x]]$raster, paste(names.[1], years.[x])))
map(1:length(gbr2), function(x) writeRaster(gbr2[[x]]$raster, paste(names.[2], years.[x]), overwrite=TRUE))
map(1:length(gbr3), function(x) writeRaster(gbr3[[x]]$raster, paste(names.[3], years.[x]), overwrite=TRUE))
map(1:length(gbr4), function(x) writeRaster(gbr4[[x]]$raster, paste(names.[4], years.[x]), overwrite=TRUE))
map(1:length(gbr5), function(x) writeRaster(gbr5[[x]]$raster, paste(names.[5], years.[x]), overwrite=TRUE))
map(1:length(gbr6), function(x) writeRaster(gbr6[[x]]$raster, paste(names.[6], years.[x]), overwrite=TRUE))
#save tables from greenbrown. The same but another presentation.
save(gbr1=, file= 'gbr1.RData')
save(gbr2=, file= 'gbr2.RData')
save(gbr3=, file= 'gbr3.RData')
save(gbr4=, file= 'gbr4.RData')
save(gbr5=, file= 'gbr5.RData')
save(gbr6=, file= 'gbr6.RData')

############################################################################################################
############################################################################################################
############################################################################################################
>>>>>>> ff7dbf6fb3c7419f751e38d238f7af104fa63ae1

