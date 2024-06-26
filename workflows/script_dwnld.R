
# Hansen forest  Map Downloader Using Ecochange and determining threshold from an attribute table. 

setwd("~/Documents/biomas_iavh/Final_results_Codename_Abril") #keep in mind for the documentation, remove after)
#setwd('/Users/sputnik/Documents/biomas_iavh/Biomas IAvH')
packs <- c('terra', 'raster','parallel', 'R.utils', 'rvest','xml2','tidyverse', 'landscapemetrics', 'sf','dplyr','httr','getPass',
           'rasterVis','rlang', 'rasterDT', 'ecochange', 'here')

# sapply(packs, install.packages, character.only = TRUE)
sapply(packs, require, character.only = TRUE)

#load Vector Data ROI
           # It uses the attribute table to extract data labeling and parameter definition information (name spatial unit) and splits in the different 
           # objects 

path_biomes <- here('vector_data', 'biomes_attributes_msk.shp')

masked <- st_read(path_biomes)

#here, you need to filter and select the biome you need. You can filter sf objects with tidyverse)
masked <- masked%>%subset(!is.na(accurcy))
labels <- (masked$biome)

#masked <- as(masked, 'Spatial')
# split mun into list of independent polygons. You don't need it 
#biomat <- masked%>%split(.$biome)

biomat <- masked%>%split(.$biome)
           #Run individual example (documentation R)


def <- lapply(biomat, function(sf){
  d <- echanges(sf,
                lyrs = c('treecover2000','lossyear'),
                path = '/media/mnt/harmonizacion_hansenIdeam/downloads',
                eco_range = c(sf$threshld,100),
                change_vals = seq(22,23,1),
                mc.cores = 4) 
                })
pt <-'/media/mnt/harmonizacion_hansenIdeam/downloads' 

map(1:length(def), function(x) writeRaster(def[[x]], paste0(pt, '/', x, '_arm.tif')))





suppressWarnings(
  def <- echanges(test,   # polígono 
                  lyrs = c('treecover2000','lossyear'),      # nombres de las capas
                  path = getwd(),      # directorio de trabajo, en caso de que no desees trabajar en el directorio temporal
                  eco_range = c(test$thrshld,100),      # Umbral de treecover2000
                  change_vals = seq(21,22,1),      # en este caso, los años de pérdida, 
                  mc.cores = 9)     # número de núcleos, solo funciona en sistema linux
)

#suppressWarnings(
  def <- map(1:10, function(x) echanges(biomat[[x]],   # polígono 
                  lyrs = c('treecover2000','lossyear'),
                  eco = 'treecover2000',
                  change = 'lossyear',      # nombres de las capas
                  path = getwd(),      # directorio de trabajo, en caso de que no desees trabajar en el directorio temporal
                  eco_range = c(biomat[[x]]$thrshld,100),      # Umbral de treecover2000
                  change_vals = seq(0,21,1),      # en este caso, los años de pérdida, 
                  mc.cores = 7))     # número de núcleos, solo funciona en sistema linux





