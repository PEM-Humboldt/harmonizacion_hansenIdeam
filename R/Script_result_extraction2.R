#extract  threshold for max OA
save(accu_msk, file='accuracy_msk.RData')
save(accu_no_msk, file='accuracy_unmmasked_full.RData')


load("accuracy_unmasked_full.RData")

accu_no_msk
accu_msk
accu_msk <- accu_msk%>%rowwise()%>%mutate(area_corrected=(accuracy*share_class_ref))

accu_no_msk

# Get the overall accuracies corrected 

######################################################################
#Here is whre I extracrt ShareOA_msk and the others
######################################################################  
shareOA_msk <- (accu_msk%>%group_by(biome)%>%filter(type=='OA')%>%slice(which.max(accuracy)))#, n=100))  
pixels <- shareOA_msk%>%select(pixelcount)
pixelscol_msk <- sum(pixels[,2]) 

#extract shares/bioma
shareOA_msk <- shareOA_msk%>%rowwise()%>%mutate(share_area=pixelcount/pixelscol_msk)%>%rowwise()%>%mutate(weighted=share_area*accuracy)
#drop biomes with 0 OA (most of them artifacts because of the small size)
shareOA_msk <- shareOA_msk%>%filter(accuracy!=0)
weightedOA_msk <- sum(shareOA_msk$weighted)
mean_OA_msk <- mean(shareOA_msk$accuracy)

print(shareOA_msk%>%select(-share_class_ref, -share_class_tar, -area_corrected)%>%arrange(desc(accuracy)), n=50)
print(shareOA_no_msk%>%select(-share_class_ref, -share_class_tar, area_corrected)%>%arrange(desc(accuracy)),n=50)

#############################################

shareOA_no_msk <- (accu_no_msk%>%group_by(biome)%>%filter(type=='OA')%>%slice(which.max(accuracy)))#, n=100))  
pixels <- shareOA_no_msk%>%select(pixelcount)
pixelscol_no_msk <- sum(pixels[,2])  

shareOA_no_msk <-  shareOA_no_msk%>%rowwise()%>%mutate(share_area=pixelcount/pixelscol_no_msk)%>%rowwise()%>%mutate(weighted=share_area*accuracy)
shareOA_no_msk <- shareOA_no_msk%>%filter(accuracy!=0)
weightedOA_no_msk <- sum(shareOA_no_msk$weighted)
mean_OA_no_msk <- mean(shareOA_no_msk$accuracy)

#Here are the other shares

##########################
sharePA_msk_nof <- (accu_msk%>%group_by(biome)%>%filter(type=='PA', class=='no forest')%>%slice(which.max(accuracy)))#, n=100))  
sharePA_msk_floss <- (accu_msk%>%group_by(biome)%>%filter(type=='PA', class=='forest loss')%>%slice(which.max(accuracy)))#, n=100))  
sharePA_msk_forest <- (accu_msk%>%group_by(biome)%>%filter(type=='PA', class=='forest')%>%slice(which.max(accuracy)))#, n=100))  
shareUA_msk_nof <- (accu_msk%>%group_by(biome)%>%filter(type=='UA', class=='no forest')%>%slice(which.max(accuracy)))#, n=100))  
shareUA_msk_floss <- (accu_msk%>%group_by(biome)%>%filter(type=='UA', class=='forest loss')%>%slice(which.max(accuracy)))#, n=100))  
shareUA_msk_forest <- (accu_msk%>%group_by(biome)%>%filter(type=='UA', class=='forest')%>%slice(which.max(accuracy)))#, n=100))  

sharePA_no_msk_nof <- (accu_no_msk%>%group_by(biome)%>%filter(type=='PA', class=='no forest')%>%slice(which.max(accuracy)))#, n=100))  
sharePA_no_msk_floss <- (accu_no_msk%>%group_by(biome)%>%filter(type=='PA', class=='forest loss')%>%slice(which.max(accuracy)))#, n=100))  
sharePA_no_msk_forest <- (accu_no_msk%>%group_by(biome)%>%filter(type=='PA', class=='forest')%>%slice(which.max(accuracy)))#, n=100))  
shareUA_no_msk_nof <- (accu_no_msk%>%group_by(biome)%>%filter(type=='UA', class=='no forest')%>%slice(which.max(accuracy)))#, n=100))  
shareUA_no_msk_floss <- (accu_no_msk%>%group_by(biome)%>%filter(type=='UA', class=='forest loss')%>%slice(which.max(accuracy)))#, n=100))  
shareUA_no_msk_forest <- (accu_no_msk%>%group_by(biome)%>%filter(type=='UA', class=='forest')%>%slice(which.max(accuracy)))#, n=100))  
############################ 
#Maybe here I need to extract the share of pixels that belong to the specific class

# yes, indeed, this is what i needed to do
#################3
#Extract Pixerl number per class
pixels_noforest_msk <- sharePA_msk_nof%>%mutate(class_share=(pixelcount*share_class_ref))%>%select(class_share)
pixels_noforest_msk <- sum(pixels_noforest_msk[,2], na.rm=TRUE)

pixels_floss_msk <- sharePA_msk_floss%>%mutate(class_share=(pixelcount*share_class_ref))%>%select(class_share)
pixels_floss_msk <- sum(pixels_floss_msk[,2], na.rm=TRUE)

pixels_forest_msk <- sharePA_msk_forest%>%mutate(class_share=(pixelcount*share_class_ref))%>%select(class_share)
pixels_forest_msk <- sum(pixels_forest_msk[,2], na.rm=TRUE)


#Pixels no mask 
pixels_noforest_no_msk <- sharePA_no_msk_nof%>%mutate(class_share=(pixelcount*share_class_ref))%>%select(class_share)
pixels_noforest_no_msk <- sum(pixels_noforest_no_msk[,2], na.rm=TRUE)

pixels_floss_no_msk <- sharePA_no_msk_floss%>%mutate(class_share=(pixelcount*share_class_ref))%>%select(class_share)
pixels_floss_no_msk <- sum(pixels_floss_no_msk[,2], na.rm=TRUE)

pixels_forest_no_msk <- sharePA_no_msk_forest%>%mutate(class_share=(pixelcount*share_class_ref))%>%select(class_share)
pixels_forest_no_msk <- sum(pixels_forest_no_msk[,2], na.rm=TRUE)

#########################
#Prodcuers Accuracy masked no forest
sharePA_msk_nof <- sharePA_msk_nof%>%rowwise()%>%mutate(share_area=(pixelcount*share_class_ref)/pixels_noforest_msk)%>%rowwise()%>%mutate(weighted=(share_area*accuracy))
PA_nof_weighted <- sum(sharePA_msk_nof$weighted, na.rm=TRUE)
PA_mean_nof <- mean(sharePA_msk_nof$accuracy)
#########################
#Prodcuers Accuracy Masked forest loss
sharePA_msk_floss <- sharePA_msk_floss%>%rowwise()%>%mutate(share_area=(pixelcount*share_class_ref)/pixels_floss_msk)%>%rowwise()%>%mutate(weighted=(share_area*accuracy))
PA_floss_weighted <- sum(sharePA_msk_floss$weighted, na.rm=TRUE)
PA_mean_floss <- mean(sharePA_msk_floss$accuracy)
#########################
#Producers Accuracy Masked forest  
sharePA_msk_forest <- sharePA_msk_forest%>%rowwise()%>%mutate(share_area=(pixelcount*share_class_ref)/pixels_forest_msk)%>%rowwise()%>%mutate(weighted=(share_area*accuracy))
PA_forest_weighted <- sum(sharePA_msk_forest$weighted, na.rm=TRUE)
PA_mean_forest <- mean(sharePA_msk_forest$accuracy)
# I finally got this right. Start here!!!

# Users Accuracy masked 
shareUA_msk_nof <- shareUA_msk_nof%>%rowwise()%>%mutate(share_area=(pixelcount*share_class_ref)/pixels_noforest_msk)%>%rowwise()%>%mutate(weighted=(share_area*accuracy))
UA_nof_weighted <- sum(shareUA_msk_nof$weighted, na.rm=TRUE)
UA_mean_nof <- mean(shareUA_msk_nof$accuracy)
#########################
#Users Accuracy Masked forest loss
shareUA_msk_floss <- shareUA_msk_floss%>%rowwise()%>%mutate(share_area=(pixelcount*share_class_ref)/pixels_floss_msk)%>%rowwise()%>%mutate(weighted=(share_area*accuracy))
UA_floss_weighted <- sum(shareUA_msk_floss$weighted, na.rm=TRUE)
UA_mean_floss <- mean(shareUA_msk_floss$accuracy)
#########################
#Users Accuracy Masked forest  
shareUA_msk_forest <- shareUA_msk_forest%>%rowwise()%>%mutate(share_area=(pixelcount*share_class_ref)/pixels_forest_msk)%>%rowwise()%>%mutate(weighted=(share_area*accuracy))
UA_forest_weighted <- sum(shareUA_msk_forest$weighted, na.rm=TRUE)
UA_mean_forest <- mean(shareUA_msk_forest$accuracy)

#Without Mask 
#Prodcuers Accuracy masked no forest
sharePA_no_msk_nof <- sharePA_no_msk_nof%>%rowwise()%>%mutate(share_area=(pixelcount*share_class_ref)/pixels_noforest_msk)%>%rowwise()%>%mutate(weighted=(share_area*accuracy))
PA_no_msk_nof_weighted <- sum(sharePA_no_msk_nof$weighted, na.rm=TRUE)
PA_mean_no_msk_nof <- mean(sharePA_no_msk_nof$accuracy)
#########################
#Prodcuers Accuracy no Masked forest loss
sharePA_no_msk_floss <- sharePA_no_msk_floss%>%rowwise()%>%mutate(share_area=(pixelcount*share_class_ref)/pixels_floss_msk)%>%rowwise()%>%mutate(weighted=(share_area*accuracy))
PA_no_msk_floss_weighted <- sum(sharePA_no_msk_floss$weighted, na.rm=TRUE)
PA_mean_no_msk_floss <- mean(sharePA_no_msk_floss$accuracy)
#########################
#Producers Accuracy no Masked forest  
sharePA_no_msk_forest <- sharePA_no_msk_forest%>%rowwise()%>%mutate(share_area=(pixelcount*share_class_ref)/pixels_forest_msk)%>%rowwise()%>%mutate(weighted=(share_area*accuracy))
PA_no_msk_forest_weighted <- sum(sharePA_no_msk_forest$weighted, na.rm=TRUE)
PA_no_msk_mean_forest <- mean(sharePA_no_msk_forest$accuracy)
# I finally got this right. Start here!!!

# Users Accuracy no masked 
shareUA_no_msk_nof <- shareUA_no_msk_nof%>%rowwise()%>%mutate(share_area=(pixelcount*share_class_ref)/pixels_noforest_msk)%>%rowwise()%>%mutate(weighted=(share_area*accuracy))
UA_no_msk_nof_weighted <- sum(shareUA_no_msk_nof$weighted, na.rm=TRUE)
UA_no_msk_mean_nof <- mean(shareUA_no_msk_nof$accuracy)
#########################
#Users Accuracy no Masked forest loss
shareUA_no_msk_floss <- shareUA_no_msk_floss%>%rowwise()%>%mutate(share_area=(pixelcount*share_class_ref)/pixels_floss_msk)%>%rowwise()%>%mutate(weighted=(share_area*accuracy))
UA_no_msk_floss_weighted <- sum(shareUA_no_msk_floss$weighted, na.rm=TRUE)
UA_no_msk_mean_floss <- mean(shareUA_no_msk_floss$accuracy)
#########################
#Users Accuracy no Masked forest  
shareUA_no_msk_forest <- shareUA_no_msk_forest%>%rowwise()%>%mutate(share_area=(pixelcount*share_class_ref)/pixels_forest_msk)%>%rowwise()%>%mutate(weighted=(share_area*accuracy))
UA_no_msk_forest_weighted <- sum(shareUA_no_msk_forest$weighted, na.rm=TRUE)
UA_no_msk_mean_forest <- mean(sharePA_no_msk_forest$accuracy)

#########################
# I finally got this right. Start here!!!

results_msk <- c(pixelscol_msk, mean_OA_msk,weightedOA_msk, PA_mean_nof, PA_nof_weighted, UA_mean_nof, UA_nof_weighted, PA_mean_floss, PA_floss_weighted,
                 UA_mean_floss, UA_floss_weighted, PA_mean_forest, PA_forest_weighted, UA_mean_forest, UA_forest_weighted)

results_no_msk <- c(pixelscol_no_msk, mean_OA_no_msk,weightedOA_no_msk, PA_mean_no_msk_nof, PA_no_msk_nof_weighted, UA_no_msk_mean_nof, UA_no_msk_nof_weighted, PA_mean_no_msk_floss, 
                    PA_no_msk_floss_weighted, UA_no_msk_mean_floss, UA_no_msk_floss_weighted, PA_no_msk_mean_forest, PA_no_msk_forest_weighted, 
                    UA_no_msk_mean_forest, UA_no_msk_forest_weighted)
length(results_msk)

results_final <- rbind(results_msk, results_no_msk)
results_final <- as.data.frame(results_final)

namer <- c('Pixel count', 'Mean OA', 'Weighted OA', 'Mean PA stable non forest', 'Weighted PA stable non forest', 'Mean UA stable non forest',
           'Weighted UA stable non forest', 'Mean PA forest loss', 'Weighted PA forest loss', 'Mean UA forest loss', 'Weighted UA forest loss',
           'Mean PA stable forest', 'Weighted PA stable forest', 'Mean UA stable forest', 'Weighted UA stable forest')

namer <- as.data.frame(namer)
length(namer)


results_final <- t(results_final)

## This gives the final results ##
results_final <- cbind(namer, results_final)
results_final <- as_tibble(results_final)


write_csv(results_final, 'results_all.csv')

########################################
########################################
mun <- st_read('/Users/sputnik/Documents/biomas_iavh/final_march/biomas_wgs84.shp')


mun <- st_make_valid(mun)
mun <- mun[-7,]
mun <- left_join(mun, shareOA_no_msk)
mun <- as(mun, 'Spatial')
writeOGR(mun, ".", "biomes_attributes_no_msk", driver="ESRI Shapefile")

mun2 <- left_join(mun2, shareOA_msk)

mun2 <- as(mun, 'Spatial')
mun2

writeOGR(mun2, ".", "biomes_attributes_msk", driver="ESRI Shapefile")



mun$biome[1:10]
mun <- mun%>%select(mun)

attributes$biome[1:10]
test_match <- function(ideam1, ideam2){
  mun$biome==attributes$biome
  
  names <- as.list(mun$biome)
  names <- map(1:length(names), function(x) as.character(names[[x]]))
  namesu <- unlist(names)
  
  mun <- st_make_valid(mun)
  dir()
  
  PA_noforest <- 
    rm(accu_msk_wide)
  <- pivot_wider(accu_msk, names_from = biome, values_from = accuracy)
  
  
  diff_mat_50
  
