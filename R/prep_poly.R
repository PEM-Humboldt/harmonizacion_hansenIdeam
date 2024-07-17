#' Load and preprocess input data
#'
#' @param path_biomes Path to the input shapefile containing the biomes
#' @return A list of sf objects, each representing a polygon
#' @export
load_preprocess_data <- function(path_biomes) {
  masked <- st_read(path_biomes) # Load the input data as an sf object with multiple polygons
  masked <- masked %>% subset(!is.na(agreement)) # Remove biomes for which the threshold attribute is empty (NA)
  biomat <- masked %>% split(.$biome) # Split the vector into a list of individual polygons
  return(biomat)
}
