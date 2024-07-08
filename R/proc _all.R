' Process each sublist of sf objects to download and save rasters
#'
#' @param biomat A list of sublists of sf objects
#' @param output_dir The directory where the output rasters will be saved
#' @param download_path The path where downloaded rasters will be stored
#' @param n_cores Number of cores for parallel processing
#' @importFrom ecochange echanges
#' @importFrom terra rast
#' @importFrom terra writeRaster
#' @import here
#' @return None
#' @export
process_sublists <- function(biomat, output_dir, download_path, n_cores = 2) {
  # Function to process each sf object and download rasters
  process_raster <- function(sf_obj, output_file) {
    # Download the raster data
    d <- echanges(sf_obj,
                  lyrs = c('treecover2000', 'lossyear'), # initial year and loss year
                  path = download_path, # directory to store downloaded data
                  eco_range = c(sf_obj$threshold, 100), # canopy cover threshold
                  change_vals = seq(22, 23, 1), # years of data (2022 and 2023 with a step of one year)
                  binary_output = FALSE, # if TRUE, produces binary masks of forest/non-forest, otherwise keeps the canopy threshold for each pixel
                  mc.cores = n_cores) # number of cores for parallel processing

    # Debugging: Print structure of d
    # print("Downloaded data structure (d):")
    # print(str(d))

    # Convert each RasterLayer to SpatRaster
    d <- lapply(d, function(x) {
      if (inherits(x, "RasterLayer")) {
        return(terra::rast(x))
      } else {
        stop("Expected a RasterLayer")
      }
    })

    # Debugging: Print structure after conversion
    # print("Structure after conversion to SpatRaster:")
    # print(str(d))

    # Stack the bands
    r <- rast(d)

    # Debugging: Print structure after stacking
    # print("Structure after stacking bands:")
    # print(str(r))

    # Save the stacked raster
    writeRaster(r, paste0(output_file, '.tif'), overwrite = TRUE)
  }

  # Apply the function to each sublist
  for (i in seq_along(biomat)) {
    biomat_r <- biomat[[i]]
    message(paste("Processing sublist", i, "of", length(biomat)))

    # Create output directory for the sublist
    sublist_output_dir <- file.path(output_dir, paste0("sublist_", i))
    if (!dir.exists(sublist_output_dir)) {
      dir.create(sublist_output_dir, recursive = TRUE)
    }

    # Apply the process to each sf object in the sublist
    map(1:length(biomat_r), function(x) {
      sf_obj <- biomat_r[[x]]
      output_file <- file.path(sublist_output_dir, paste0("raster_", x))
      process_raster(sf_obj, output_file)
    })
  }
}
