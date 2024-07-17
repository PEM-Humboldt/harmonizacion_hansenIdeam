#' Post-process a raster file
#'
#' This function post-processes a raster file by changing the data type, compressing, reprojecting, aligning, and trimming it.
#'
#' @param input_file Character. The path to the input raster file.
#' @param output_file Character. The path where the processed raster file will be saved.
#' @param reference_crs Character. The target coordinate reference system (CRS) in Well-Known Text (WKT) format.
#' @param reference_pixel_size Numeric vector of length 2. The target pixel size (resolution) in the x and y directions.
#' @param temp_dir Character. The path to the directory where temporary files will be stored.
#' @param resampling_method Character. The resampling method to use for reprojecting and aligning the raster. Options are "near", "bilinear", "cubic", "cubicspline", "lanczos", "average", "mode", "max", "min", "med", "q1", "q3". Default is "near".
#'
#' @details
#' This function performs the following steps:
#' \itemize{
#'   \item Changes the data type of the raster and compresses it.
#'   \item Reprojects and aligns the raster to the specified CRS and pixel size.
#'   \item Trims the raster to remove outer rows and columns that are all NA values.
#' }
#' Temporary files are created during the process and deleted upon completion. If the raster contains only NA values after trimming, it is skipped and not processed further.
#'
#' @importFrom gdalUtilities gdal_translate gdalwarp
#' @importFrom terra rast values trim writeRaster
#' @importFrom utils unlink tempfile
#'
#' @return NULL. The function is called for its side effect of saving the processed raster to the specified output file.
#' @export
#' @author Jeronimo Rodriguez-Escobar <jeronimo.rescobar@gmail.com>
#' @examples
#' \dontrun{
#' post_process(
#'   input_file = "path/to/input.tif",
#'   output_file = "path/to/output.tif",
#'   reference_crs = "EPSG:4326",
#'   reference_pixel_size = c(0.00025, 0.00025),
#'   temp_dir = "path/to/temp",
#'   resampling_method = "bilinear"
#' )
#' }
post_process <- function(input_file, output_file, reference_crs, reference_pixel_size, temp_dir, resampling_method = "near") {
  temp_file <- tempfile(tmpdir = temp_dir, fileext = ".tif")

  # Change data type and compress
  gdalUtilities::gdal_translate(src_dataset = input_file, dst_dataset = temp_file, of = "GTiff",
                                co = c("COMPRESS=LZW", "TILED=YES", "PIXELTYPE=SIGNEDBYTE"))

  temp_aligned_file <- tempfile(tmpdir = temp_dir, fileext = ".tif")

  # Reproject and align
  gdalUtilities::gdalwarp(srcfile = temp_file, dstfile = temp_aligned_file, t_srs = reference_crs,
                          tr = reference_pixel_size, r = resampling_method, tap = TRUE, overwrite = TRUE)

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
