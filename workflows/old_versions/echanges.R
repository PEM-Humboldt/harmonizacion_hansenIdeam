# Hansen forest  Map Downloader Using Ecochange and determining threshold from an attribute table. 


setwd('/Users/sputnik/Library/CloudStorage/OneDrive-TempleUniversity/Research Forests/outputs_armonization_data/Vector_data_biomes')

packs <- c('terra','parallel', 'R.utils', 'rvest','xml2','tidyverse', 'landscapemetrics', 'sf','dplyr','httr','getPass','gdalUtilities', 'viridis',
           'rasterVis','rlang', 'ecochange')
#sapply(packs, install.packages, character.only = TRUE)
sapply(packs, require, character.only = TRUE)

#load Vector Datsa ROI
           # It uses the attribute table to extract data labeling and parameter defiition information (name spatial unit) and splits in the different 
           # objects 
masked <- st_read('biomes_attributes_msk.shp')
labels <- (masked$biome)
# check if i need it!
masked <- as(masked, 'Spatial')
# split mun into list of independent polygons  
biomat <- masked%>%split(.$biome)

#Run individual example (documentation R)
test<- biomat[[353]]
      
suppressWarnings(
  def <- echanges(test,   # polígono 
                  lyrs = c('treecover2000','lossyear'),      # nombres de las capas
                  path = getwd(),      # directorio de trabajo, en caso de que no desees trabajar en el directorio temporal
                  eco_range = c(test$thrshld,100),      # Umbral de treecover2000
                  change_vals = seq(0,18,1),      # en este caso, los años de pérdida, 
                  mc.cores = 9)     # número de núcleos, solo funciona en sistema linux
)

tt <- stack(def)

writeRaster(tt, 'test_ec1_10.tif')
tt <- map(1:length(def), function(x) do.call(stack, def[[x]]))

