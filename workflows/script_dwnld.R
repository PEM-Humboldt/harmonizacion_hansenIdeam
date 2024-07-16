
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
library(gdalUtilities)
library(terra)
library(here)
library(jsonlite)

# Directories and paths
newdir <- here('reproj')
ref <- here("reference", "mask_colombia.tif")
out_dir <- here("downloads")
temp_dir <- here('tmp')

# Ensure the temp directory exists
if (!dir.exists(temp_dir)) {
  dir.create(temp_dir, recursive = TRUE)
}

# Get the CRS and pixel size of the reference raster
reference_info <- gdalUtilities::gdalinfo(ref, json = TRUE)

# Replace "nan" with "null" to make the JSON valid
reference_info <- gsub("nan", "null", reference_info)

# Convert JSON string to R list
reference_info <- fromJSON(reference_info)

# Extract CRS and pixel size
reference_crs <- reference_info$coordinateSystem$wkt
reference_pixel_size <- c(reference_info$geoTransform[2], -reference_info$geoTransform[6])

# Initialize a list to keep track of skipped files
skipped_files <- list()

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

sublist_dirs <- list.dirs(out_dir, full.names = TRUE, recursive = FALSE)

all_rasters <- list()

for (sublist_dir in sublist_dirs) {
  message(paste("Processing sublist:", sublist_dir))

  infiles <- file.path(sublist_dir, list.files(sublist_dir, pattern = ".tif"))
  outfiles <- file.path(newdir, basename(infiles))

  # Process each file in the sublist
  system.time({
    Map(process_raster, infiles, outfiles, MoreArgs = list(reference_crs = reference_crs, reference_pixel_size = reference_pixel_size, temp_dir = temp_dir))
  })

  # Load processed rasters
  processed_files <- file.path(newdir, list.files(newdir, pattern = ".tif"))
  sublist_rasters <- lapply(processed_files, rast)

  # Merge rasters in the current sublist
  sublist_merged <- do.call(terra::merge, sublist_rasters)

  # Store the merged raster of the current sublist
  all_rasters[[sublist_dir]] <- sublist_merged

  # Clean up the newdir for the next sublist processing
  file.remove(processed_files)
}

# Merge all sublist rasters into a final raster
final_raster <- do.call(terra::merge, all_rasters)

# Save the final raster
final_output_path <- file.path(newdir, "final_merged_raster.tif")
writeRaster(final_raster, final_output_path, filetype = "GTiff", overwrite = TRUE, datatype = "INT1U")

message("Processing complete.")

##############################################################
infiles <- file.path(newdir, list.files(newdir, pattern = ".tif"))

arm <- lapply(infiles, rast)
arm2 <- do.call(terra::merge, arm)

writeRaster(arm2, here(out_dir, 'arm_22_23.tif'))
#######################SCRATCH####################################################################################
