 
# Hansen forest  Map Downloader Using the echanges() function from the ecochange R package (Lara et al., 2024) 
# for individual polygons using a canopy threshold provided as attribute

                                        #Load Packages 
packs <- c('terra', 'raster','purrr', 'landscapemetrics', 'sf','dplyr',
           'rlang', 'rasterDT', 'ecochange', 'here', 'gdalUtilities')

# sapply(packs, install.packages, character.only = TRUE) #Install package if necessary
sapply(packs, require, character.only = TRUE)

                                        #Define paths
# input polygons
path_biomes <- here('vector_data', 'biomes_thresholds.shp')
# Set output directory
out_dir <- here('downloads')

                                        #Load input data
masked <- st_read(path_biomes)
#Remove biomes for which the threshold attribute is empty (NA)
masked <- masked%>%subset(!is.na(agreement))
#Split the vector into a list of individual polygons
biomat <- masked%>%split(.$biome)

# Function to split a list into n equal parts (deals with memory limitations distributing the work load in multiple subsets)
split_list <- function(input_list, n) {
  # Calculate the number of elements in each sublist
  split_size <- ceiling(length(input_list) / n)  
  # Split the list into sublists
  split(input_list, rep(1:n, each = split_size, length.out = length(input_list)))
}

                                        # Split the list into 5 sublists
biomat <- split_list(biomat, 15)
# Check Number of polyons/subset
sapply(biomat, length)


                                        # Iterate the ecochange::echanges() over the polygon list. 
                                        # Iterate over each subset (pending to fix) 
n <- 15
biomat_r <- biomat[[n]]

system.time(#def <- lapply(biomat, function(ls){
def1 <- lapply(biomat_r,function(sf){
    d <- echanges(sf,
                lyrs = c('treecover2000','lossyear'), # a~no inicial y a~no de perdida
                # path = '/media/mnt/harmonizacion_hansenIdeam/downloads', #directorio para domde se almacenan los datos descargados. si se deja getwd() se guardan en el directorio de trabajo
                path = '/storage/home/TU/tug76452/harmonizacion_hansenIdeam/downloads',
                eco_range = c(sf$threshold,100), # asigna el umbral de dosel. el valor se lee de l tabla de atributos de cada pol'igono
                change_vals = seq(22,23,1), # los anos de descarga (a partir de 2000. en este caso 2022 y 2023 con pasos de un ano)
                binary_output = FALSE, # si es TRUE, produce mascaras binarias de bosque /no bosque, de lo contrario, deja el valor del umbarl para cada pixel
                mc.cores = 2) # numero de nucleos para correr en paralelo. Solo aplica para sistemas Linux/MacOS
  })
)

# convert RasterLayer to SpatRaster
  convert_to_spatraster <- function(x){
    if (inherits(x, "RasterLayer")) {
      return(terra::rast(x))
    } else if (is.list(x)) {
      return(lapply(x, convert_to_spatraster))
    } else {
      return(x)
    }
  }

system.time(def1 <- lapply(def1,function(ls){
    lapply(ls,convert_to_spatraster)
    }))

# Stack the bands
def1 <- lapply(def1, function(ls){
    r <- rast(ls)
    })


#WriteRasters
map(1:length(def1), function(x) writeRaster(def1[[x]], paste0(out_dir, '/',n, '_', x,'.tif')))#, progress=TRUE) 
#################################################################

# I know why it crashes, because of the different CRS. Need to reproject/align first.
## set target crs:
cr.  <- "+proj=tmerc +lat_0=4.596200416666666 +lon_0=-74.07750791666666 +k=1 +x_0=1000000 +y_0=1000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"  

#set list of files to reproject
infiles <- file.path(out_dir, list.files(out_dir, pattern = ".tif"))
#create folder to store the new rasters 
dir.create(here('reproj'))
newdir <- here('reproj')
# set list of output paths
outfiles <- file.path(newdir, list.files)




def <- do.call(terra::merge, def)



def.<- reduce(def_c, terra::merge)



def1

writeRaster(def., '/storage/home/TU/tug76452/harmonizacion_hansenIdeam/downloads/armonized_2223.tif')

###########################################################################################################
def_c[1]

pt <-'/media/mnt/harmonizacion_hansenIdeam/downloads' 
map(1:length(def_c), function(x) writeRaster(def_c[[x]], paste0(pt, '/', x, '_test.tif')))

lapply(def_c, function(sr){
  writeRaster()
})

#test
sf <- biomat[[1]]

  ti <- echanges(sf,
                lyrs = c('treecover2000','lossyear'), # a~no inicial y a~no de perdida
                path = '/media/mnt/harmonizacion_hansenIdeam/downloads', #directorio para domde se almacenan los datos descargados. si se deja getwd() se guardan en el directorio de trabajo
                eco_range = c(sf$threshlod,100), # asigna el umbral de dosel. el valor se lee de l tabla de atributos de cada pol'igono
                change_vals = seq(22,23,1), # los anos de descarga (a partir de 2000. en este caso 2022 y 2023 con pasos de un ano)
                binary_output = FALSE, # si es TRUE, produce mascaras binarias de bosque /no bosque, de lo contrario, deja el valor del umbarl para cada pixel
                mc.cores = 5) # numero de nucleos para correr en paralelo. Solo aplica para sistemas Linux/MacOS


def. <- lapply(def, process_rasters)



def_c <- unlist(def_c, recursive = FALSE)


def_c

#Ensamblar el mapa
def. <- do.call(terra::mosaic, def_c)

#establecer ruta
pt <-'/media/mnt/harmonizacion_hansenIdeam/downloads' 

#Exportar capas
writeRaster(def., paste0(pt, '/', '2022_2023', '_arm.tif'))

