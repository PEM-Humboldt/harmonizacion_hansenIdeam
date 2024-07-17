
# Hansen forest  Map Downloader Using the echanges() function from the ecochange R package (Lara et al., 2024)
# for individual polygons using a canopy threshold provided as attribute

#################################################################################################
# 1. PREPARE ENVIRONMENT
#Load Packages
packs <- c('terra', 'raster','purrr', 'landscapemetrics', 'sf','dplyr',
           'rlang', 'rasterDT', 'ecochange', 'here', 'gdalUtilities', 'jsonlite', 'here', 'devtools')
# sapply(packs, install.packages, character.only = TRUE) #Install package if necessary
sapply(packs, require, character.only = TRUE)

load_all()

# create temporary directory to process raster files.
dir.create(here('tempfiledir'))
tempdir=paste(here('tempfiledir'))
rasterOptions(tmpdir=tempdir)
#set directory to store the downloaded data
dir.create(here('downloads'))
output_dir <- here('downloads')
download_path <- here('downloads')


#################################################################################################
# 2. PREPARE INPUT VECTOR DATA
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


 # Set target years
chang_vals <- seq(22,23,1)
n_cores <- 4

#################################################################################################################
#################################################################################################################
# 3. Use iterate the ecochange::echanges function to obtain forests maps with the assigned threshold for each biome
process_sublists(biomat, output_dir, download_path, change_vals = chang_vals, bin_output =FALSE, n_cores=4)

########################################################################################################
########################################################################################################
# 4. Reproject and align the Downloaded data

# Set Directories and paths
dir.create(here('reproj'))
newdir <- here('reproj')
#set reference raster
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

# create list of subdirectories to iterate over
sublist_dirs <- list.dirs(out_dir, full.names = TRUE, recursive = FALSE)

# Initialize a list to sotre the processed rasters.
all_rasters <- list()

# Iterate the postprocessing function over all the sublists

for (sublist_dir in sublist_dirs) {
  message(paste("Processing sublist:", sublist_dir))

  infiles <- file.path(sublist_dir, list.files(sublist_dir, pattern = ".tif"))
  outfiles <- file.path(newdir, basename(infiles))

  # Process each file in the sublist
  system.time({
    Map(post_process, infiles, outfiles, MoreArgs = list(reference_crs = reference_crs, reference_pixel_size = reference_pixel_size, temp_dir = temp_dir, resampling_method = "bilinear"))
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

# Remove names from the list
names(all_rasters) <- NULL

# Now, merge the rasters
final_raster <- do.call(terra::merge, all_rasters)

# Save the final raster
final_output_path <- file.path(here('downloads'), "armonized_22_23.tif")
writeRaster(final_raster, final_output_path, filetype = "GTiff", overwrite = TRUE, datatype = "INT1U")

message("Processing complete.")
