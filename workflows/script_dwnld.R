
# Hansen forest  Map Downloader Using the echanges() function from the ecochange R package (Lara et al., 2024)
# for individual polygons using a canopy threshold provided as attribute
                                        #Load Packages
packs <- c('terra', 'raster','purrr', 'landscapemetrics', 'sf','dplyr',
           'rlang', 'rasterDT', 'ecochange', 'here', 'gdalUtilities', 'jsonlite')

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

# Function to split a list into n equal parts (deals with memory limitations distributing the work load into smaller sets)
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

                                        # Iterate over each subset (pending to fix)
n <- 8
biomat_r <- biomat[[n]]

system.time(#def <- lapply(biomat, function(ls){
def1 <- lapply(biomat_r,function(sf){
    d <- echanges(sf,
                lyrs = c('treecover2000','lossyear'), # a~no inicial y a~no de perdida
                path = here('downloads'),
                eco_range = c(sf$threshold,100), # asigna el umbral de dosel. el valor se lee de l tabla de atributos de cada pol'igono
                change_vals = seq(00,02,1), # los anos de descarga (a partir de 2000. en este caso 2022 y 2023 con pasos de un ano)
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
map(1:length(def1), function(x) writeRaster(def1[[x]], paste0(out_dir, '/',n, '_', x,'.tif')))
#################################################################

# Create directory to store the aligned rasters
#dir.create(here('reproj'))
newdir <- here('reproj')

#Define the paths
## Set reference template to align
ref <- here("reference", "mask_colombia.tif")
## set path to downloaded  files
infiles <- file.path(out_dir, list.files(out_dir, pattern = ".tif"))
## set paths for output files
outfiles <- file.path(newdir, basename(infiles))

#create temp dir.
temp_dir <- here('tmp')

# Ensure the directory exists
if (!dir.exists(temp_dir)) {
  dir.create(temp_dir, recursive = TRUE)
}

# Get the CRS of the reference raster
reference_info <- gdalUtilities::gdalinfo(ref, json = TRUE)
# Replace invalid 'nan' with 'null' in the JSON string
reference_info <- gsub("\\bnan\\b", "null", reference_info)
reference_info <- fromJSON(reference_info)
reference_crs <- reference_info$coordinateSystem$wkt
# Extract pixel size from reference raster
reference_pixel_size <- c(reference_info$geoTransform[2], -reference_info$geoTransform[6])

                                        # Initialize a list to keep track of skipped files
skipped_files <- list()

# Function to postprocess rasters
process_raster <- function(input_file, output_file, reference_crs, reference_pixel_size, temp_dir) {
  temp_file <- tempfile(tmpdir = temp_dir, fileext = ".tif")
  # Change data type and compress
  gdalUtilities::gdal_translate(src_dataset = input_file, dst_dataset = temp_file, of = "GTiff",
                                co = c("COMPRESS=LZW", "TILED=YES", "PIXELTYPE=SIGNEDBYTE"))
  temp_aligned_file <- tempfile(tmpdir = temp_dir, fileext = ".tif")
  # Reproject and align
  gdalUtilities::gdalwarp(srcfile = temp_file, dstfile = temp_aligned_file, t_srs = reference_crs,
                          tr = reference_pixel_size, r = "near", tap = TRUE, overwrite = TRUE)
  # Trim the raster
  r <- rast(temp_aligned_file)
  if (all(is.na(values(r)))) {
      message(paste("Skipping raster with only NAs:", input_file))
      skipped_files <<- c(skipped_files, input_file)
      unlink(temp_file)
      unlink(temp_aligned_file)
      return(NULL)
        }
  r <- rast(temp_aligned_file)
  r_trimmed <- trim(r)
  temp_trimmed_file <- tempfile(tmpdir = temp_dir, fileext = ".tif")
  writeRaster(r_trimmed, temp_trimmed_file, filetype = "GTiff", overwrite = TRUE, datatype = "INT1U")
  gdalUtilities::gdal_translate(src_dataset = temp_trimmed_file, dst_dataset = output_file, of = "GTiff",
                                                                 co = c("COMPRESS=LZW", "TILED=YES"))
  # Clean up temporary files
  unlink(temp_file)
  unlink(temp_aligned_file)
  unlink(temp_trimmed_file)
}

# Apply the function to all input files
system.time({
  Map(process_raster, infiles, outfiles, MoreArgs = list(reference_crs = reference_crs, reference_pixel_size = reference_pixel_size, temp_dir = temp_dir))
})

##############################################################
infiles <- file.path(newdir, list.files(newdir, pattern = ".tif"))

arm <- lapply(infiles, rast)
arm2 <- do.call(terra::merge, arm)

writeRaster(arm2, here(out_dir, 'arm_22_23.tif'))
#######################SCRATCH####################################################################################
