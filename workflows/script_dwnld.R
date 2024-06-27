
# Hansen forest  Map Downloader Using the echanges() function from the ecochange R package (Lara et al, 2024) 
#  and determining threshold from an attribute table. 

#Load Packages 
packs <- c('terra', 'raster','tidyverse', 'landscapemetrics', 'sf','dplyr',
           'rasterVis','rlang', 'rasterDT', 'ecochange', 'here')

# sapply(packs, install.packages, character.only = TRUE)
sapply(packs, require, character.only = TRUE)

#load Vector Data ROI
           # It uses the attribute table to extract data labeling and parameter definition information (name spatial unit) and splits in the different 
           # objects 
#Define path to stored polygon data
path_biomes <- here('vector_data', 'biomes_thresholds.shp')
#Load the data
masked <- st_read(path_biomes)

#Remove biomes for which the threshold attribute is empty (NA)
masked <- masked%>%subset(!is.na(agreement))

#masked <- as(masked, 'Spatial')
# Split the vector file into a list of multipolygons (one for each biome)
biomat <- masked%>%split(.$biome)


# Function to split a list into n roughly equal parts (deal with memory limitations)
split_list <- function(input_list, n) {
  # Calculate the number of elements in each sublist
  split_size <- ceiling(length(input_list) / n)
  
  # Split the list into sublists
  split(input_list, rep(1:n, each = split_size, length.out = length(input_list)))
}

# Split the list into 5 sublists
biomat <- split_list(biomat, 5)

# Check the lengths of the sublists to ensure even distribution
sapply(biomat, length)
        
# Iterate the echanges over the polygon list. 
def <- lapply(biomat, function(ls){
  lapply(ls,function(sf){
    d <- echanges(sf,
                lyrs = c('treecover2000','lossyear'), # a~no inicial y a~no de perdida
                path = '/media/mnt/harmonizacion_hansenIdeam/downloads', #directprio para domde se almacenan los datos descargados. si se deja getwd() se guardan en el directorio de trabajo
                eco_range = c(sf$threshold,100), # asigna el umbarl de dosel. el valor se lee de l tabla de atributos de cada pol'igono
                change_vals = seq(22,23,1), # los anos de descarga (a partir de 2000. en este caso 2022 y 2023 con pasos de un ano)
                binary_output = FALSE, # si es TRUE, produce mascaras binarias de bosque /no bosque, de lo contrario, deja el valor del umbarl para cada pixel
                mc.cores = 5) # numero de nucleos para correr en paralelo. Solo aplica para sistemas Linux/MacOS
                })
})

#test
sf <- biomat[[1]]

  ti <- echanges(sf,
                lyrs = c('treecover2000','lossyear'), # a~no inicial y a~no de perdida
                path = '/media/mnt/harmonizacion_hansenIdeam/downloads', #directprio para domde se almacenan los datos descargados. si se deja getwd() se guardan en el directorio de trabajo
                eco_range = c(sf$threshlod,100), # asigna el umbarl de dosel. el valor se lee de l tabla de atributos de cada pol'igono
                change_vals = seq(22,23,1), # los anos de descarga (a partir de 2000. en este caso 2022 y 2023 con pasos de un ano)
                binary_output = FALSE, # si es TRUE, produce mascaras binarias de bosque /no bosque, de lo contrario, deja el valor del umbarl para cada pixel
                mc.cores = 5) # numero de nucleos para correr en paralelo. Solo aplica para sistemas Linux/MacOS



# Convertir  los objetos en SpatRasters multibanda 
process_rasters <- function(x) {
  # convert RasterLayer to SpatRaster
  convert_to_spatraster <- function(x) {
    if (inherits(x, "RasterLayer")) {
      return(terra::rast(x))
    } else if (is.list(x)) {
      return(lapply(x, convert_to_spatraster))
    } else {
      return(x)
    }
  }
  # convert list of SpatRaster to multilayer SpatRaster
  convert_to_multilayer <- function(x) {
    if (is.list(x) && all(sapply(x, inherits, "SpatRaster"))) {
      return(terra::rast(x))
    } else if (is.list(x)) {
      return(lapply(x, convert_to_multilayer))
    } else {
      return(x)
    }
  }
  # Convert RasterLayer to SpatRaster
  x <- convert_to_spatraster(x)
  # Convert lists of SpatRaster to multilayer SpatRaster
  x <- convert_to_multilayer(x)
  return(x)
}

#Correr la funcion
def. <- lapply(def, process_rasters)

#Ensamblar el mapa
def. <- do.call(merge, def.)

#establecer ruta
pt <-'/media/mnt/harmonizacion_hansenIdeam/downloads' 
#Exportar capas
writeRaster(def., paste0(pt, '/', '2022_2023', '_arm.tif'))
