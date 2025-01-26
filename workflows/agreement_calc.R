


masked <- st_make_valid(masked)

masked_oro <- masked %>%
  filter(str_detect(BIOMA_P, "Orobioma"))

masked_no_oro <- masked %>%
  filter(!str_detect(BIOMA_P, "Orobioma"))

tt <- rast('/Users/sputnik/Library/CloudStorage/OneDrive-TempleUniversity/Research_Sommer_2023/harmonization_23/change10_17IDEam.tif')

tt <- subst(tt, from=c(0,3), to=NA)
th <- rast('/Users/sputnik/Library/CloudStorage/OneDrive-TempleUniversity/Research_Sommer_2023/harmonization_23/ch1017arm_msk.tif')

st_write(masked_oro, here('vector_data', 'biomes_no_oro.shp'))


masked_oro <- st_read('/Users/sputnik/Library/CloudStorage/OneDrive-TempleUniversity/Research Forests/vector_data/orobiomes.shp')

masked_no_oro <- st_read('/Users/sputnik/Library/CloudStorage/OneDrive-TempleUniversity/Research Forests/vector_data/no_orobiomes.shp')

tt_oro <- mask(tt, masked_oro)
tt_no_oro <-  mask(tt, masked_no_oro)
th_oro <- mask(th, masked_oro)
th_no_oro <- mask(th, masked_no_oro)

ag_all <- crosstabm(tt, th, percent = FALSE)
ag_oro <- crosstabm(tt_oro, th_oro, percent = FALSE)
ag_no_oro <- crosstabm(tt_no_oro, th_no_oro, percent = FALSE)
mats <- list(ag_all, ag_oro, ag_no_oro)

weight_matrix <- function(cont_matrix) {
  total_area <- sum(cont_matrix)
  proportional_areas <- rowSums(cont_matrix) / total_area
  weighted_matrix <- sweep(cont_matrix, 1, proportional_areas, "*")
  return(weighted_matrix)
}

weighted_mat <- lapply(mats, weight_matrix)

wm <- do.call(rbind, weighted_mat)

write.csv(wm,here('outs', 'wm.csv'))
write.csv(mats,here('outs', 'mats.csv'))

area_or <- sum(ag_all)
prop_1 <- rowSums(ag_all)/area_or
prop1 <- sweep(ag_all, 1, prop_1, "*")
library(diffeR)
