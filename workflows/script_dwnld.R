
# Hansen forest  Map Downloader Using the echanges() function from the ecochange R package (Lara et al., 2024)
# for individual polygons using a canopy threshold provided as attribute
#Load Packages
packs <- c('terra', 'raster','purrr', 'landscapemetrics', 'sf','dplyr',
           'rlang', 'rasterDT', 'ecochange', 'here', 'gdalUtilities', 'jsonlite', 'here')

# sapply(packs, install.packages, character.only = TRUE) #Install package if necessary
sapply(packs, require, character.only = TRUE)


# create temporary directory for raster files.
dir.create(here('tempfiledir'))
tempdir=paste(here('tempfiledir'))
rasterOptions(tmpdir=tempdir)


#Define paths
# input polygons
path_biomes <- here('vector_data', 'biomes_thresholds.shp')
# Set output directory
out_dir <- dir.create(here('downloads'))

#Load input data
masked <- st_read(path_biomes)
#Remove biomes for which the threshold attribute is empty (NA)
masked <- masked%>%subset(!is.na(agreement))
#Split the vector into a list of individual polygons
biomat <- masked%>%split(.$biome)

# Split the list into n sublists
biomat <- split_list(biomat, 30)

# Check the number of polygons in each sublist
sapply(biomat, length)

# Example parameters
chang_vals <- seq(22,23,1)
output_dir <- here('downloads')
download_path <- here('downloads')
n_cores <- 4


process_sublists(biomat, output_dir, download_path, n_cores)


########################################################################################################


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
