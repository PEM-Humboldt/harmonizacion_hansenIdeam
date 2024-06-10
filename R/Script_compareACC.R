#July 18 2022
#This can be improved by manipulatinb the table after rbinding, not before!!!! Way easier 
rm(list=ls())
load('/Users/sputnik/Documents/biomas_iavh/selected_areas/accut_f.RData')

# just checking

setwd('/Users/sputnik/Documents/biomas_iavh/final_march')

dir()

#load cont tables no mask
mat <- list.files('.', 'ag_hansen_')
mat <- list(mat[2:14], mat[1])
mat <- unlist(mat)
mats <- list()

for(i in  1:length(mat)){
  mats[i] <- load(mat[i])
}


#load cont tables masked 
mat <- list.files('.', 'ag_id_ha')

for(i in  1:length(mat)){
  mats[i] <- load(mat[i])
}


#remove Nechi. (only for the masked, the unmasked already has it removed)
####################################################
# diff_mat_20 <- diff_mat_20[-7]
# diff_mat_30 <- diff_mat_30[-7]
# diff_mat_40 <- diff_mat_40[-7]
# diff_mat_50 <- diff_mat_50[-7]
# diff_mat_55 <- diff_mat_55[-7]
# diff_mat_60 <- diff_mat_60[-7]
# diff_mat_65 <- diff_mat_65[-7]
# diff_mat_70 <- diff_mat_70[-7]
# diff_mat_75 <- diff_mat_75[-7]
# diff_mat_80 <- diff_mat_80[-7]
# diff_mat_85 <- diff_mat_85[-7]
# diff_mat_85 <- diff_mat_85[-7]
# diff_mat_90 <- diff_mat_90[-7]
# diff_mat_95 <- diff_mat_95[-7]
# diff_mat_100 <- diff_mat_100[-7]
################################################

# Fix the stupid problem with Cauca Medio! It is only mnecessary for the masked. Why? We will never know.
# who i am lying to, at some moment i will have to come back to this shit and figure out how to solve it
#################################################################
masker <- raster('/Users/sputnik/Documents/biomas_iavh/final_march/ag_id_msk_Orobioma Subandino Cauca medio.tif')

m <- c(-Inf, 0, NA, 0, Inf, 1)
m <- matrix(m, ncol=3, byrow=TRUE)
masker <- reclassify(masker, m)
plot(masker)
# 
 hansen <- stack('/Users/sputnik/Documents/biomas_iavh/final_march/han_ag1017_Orobioma Subandino Cauca medio.tif')
# 
 hansen <- mask(hansen,masker)
# writeRaster(hansen, 'ag_ha_msk_Orobioma Subandino Cauca mediox', format='GTiff')

#Somehow, add Cauca Medio (maldita sea perdí toda la tarde por este hijueputa problema)

# comparer2 <- function(ideam1,ideam2, perc){
#   test1 <- crosstabm(ideam1, ideam2, percent=perc, population=NULL)
#   # differences <-  diffTable(test1, digits = 2, analysis = 'error')
#   return(test1)}
# 
# perc=FALSE
# 
# mem_future <- 1000*1024^2 #this is toset the limit to 1GB
# plan(multisession, workers=12)
# options(future.globals.maxSize= mem_future)
# cauca <- future_map(1:nlayers(hansen), function(x) comparer2(ideam, hansen[[x]], perc=FALSE))
# 
# 
# # create the names of the last thing. Fucking stupid problem, a wholo afternoon just because of this shit (again)
# namesv <- c(rep('Orobioma Subandino Cauca medio', times=14))
# 
# names(cauca) <- namesv
# save(cauca, file='cauca_medio_sq.RData')

#####################################################################################


namesv <- names(diff_mat_50)
#fuckthis fucking shit again. Why does this guy not get it!!! It is obvious. But no, I have to go fuck myself (again)
 
accuracies <- function(diff_mat, t, biome){
  test <- diff_mat
  pixel_count <- sum(rowSums(test))
  # i need to do this because in some cases the square contingency matrix is not 4x4, because there can be missing classes
  # in most cases it is the forest gain that is missing (if Ideam does not have forest gain, but it can also happen with 
  # other classes and/or with more than one class, up to empty matrices. I should create a script that adds the missing
  # rows and column full with zeros and generates the required 4x4 matrices. However, because of reasons, this will 
  # need some effort, as in some cases the order of the columns and rows is changed and it would produce wrong results
  # as this is something that can be solved, but would require time to figure out, and the cases where it happens are 
  # mostly (obviously) small spatial units, i will just bypass them and put zeros in the results and deal with it latter)
  if(nrow(test)<=3){
     output1 <- c(0,0,0,0,0,0,0)
     output1 <- as.data.frame(output1)
      type <- as.data.frame(c('UA','UA','UA','PA','PA','PA','OA'))
      biome <- as.data.frame(c(rep(biome, times=7)))
      class <- as.data.frame(c('no forest', 'forest loss', 'forest','no forest', 'forest loss', 'forest', 'overall'))
      threshold <- as.data.frame(c(rep(t, times=7)))
      pix <- as.data.frame(c(rep(pixel_count, times=7)))
      output1 <- cbind(output1, type, biome, class, threshold, pix)
      colnames(output1) <- c('accuracy', 'type','biome','class', 'threshold', 'pixelcount')
   }
  else{
    UA1 <- test[,1]/rowSums(test)
    UA1 <- UA1[1]
    upixels1 <- sum(test[1,])/pixel_count
    UA2 <- test[,2]/rowSums(test)
    UA2 <- UA2[2]
    upixels2 <- sum(test[2,])/pixel_count
    UA4 <- test[,4]/rowSums(test)
    UA4 <- UA4[4]
    upixels4 <- sum(test[4,])/pixel_count
    PA1 <- test[1,]/colSums(test)
    PA1 <- PA1[1]
    ppixels1 <- sum(test[,1])/pixel_count
    PA2 <- test[2,]/colSums(test)
    PA2 <- PA2[2]
    ppixels2 <- sum(test[,2])/pixel_count
        PA4 <- test[4,]/colSums(test)
    PA4 <- PA4[4]
    ppixels4 <- sum(test[4,])/pixel_count
    OA <- sum(diag(test))/sum(colSums(test))
    output1 <- c(UA1,UA2, UA4,PA1,PA2,PA4,OA)
    output1 <- as.data.frame(output1)
    type <- as.data.frame(c('UA','UA','UA','PA','PA','PA','OA'))
    biome <- as.data.frame(c(rep(biome, times=7)))
    class <- as.data.frame(c('no forest', 'forest loss', 'forest','no forest', 'forest loss', 'forest', 'overall'))
    threshold <- as.data.frame(c(rep(t, times=7)))
    pix <- as.data.frame(c(upixels1, upixels2, upixels4, ppixels1, ppixels2, ppixels4, pixel_count))
    output1 <- cbind(output1, type, biome, class, threshold, pix)
    colnames(output1) <- c('accuracy', 'type','biome','class', 'threshold', 'pixelcount')}
  return(output1)}

#Had to do thios to insert stupid cauca medio 
########################################################
load('cauca_medio_sq.RData')

 namesc <- 'Orobioma Subandino Cauca medio'
# cauca1 <- accuracies(cauca[[1]], t=20, biome = namesc)
# cauca2 <- accuracies(cauca[[2]], t=30, biome = namesc)
# cauca3 <- accuracies(cauca[[3]], t=40, biome = namesc)
# cauca4 <- accuracies(cauca[[4]], t=50, biome = namesc)
# cauca5 <- accuracies(cauca[[5]], t=55, biome = namesc)
# cauca6 <- accuracies(cauca[[6]], t=60, biome = namesc)
# cauca7 <- accuracies(cauca[[7]], t=65, biome = namesc)
# cauca8 <- accuracies(cauca[[8]], t=70, biome = namesc)
# cauca9 <- accuracies(cauca[[9]], t=75, biome = namesc)
# cauca10 <- accuracies(cauca[[10]], t=80, biome = namesc)
# cauca11 <- accuracies(cauca[[11]], t=85, biome = namesc)
# cauca12 <- accuracies(cauca[[12]], t=90, biome = namesc)
# cauca13 <- accuracies(cauca[[13]], t=95, biome = namesc)
# cauca14 <- accuracies(cauca[[14]], t=100, biome = namesc)


accu <- map(1:length(diff_mat_20), function(x) accuracies(diff_mat_20[[x]], t=20, biome=namesv[x]))
accu <- do.call(rbind, accu)
accu <- as.data.frame(accu)
accu_20 <- accu
accu <- map(1:length(diff_mat_20), function(x) accuracies(diff_mat_30[[x]], t=30, biome=namesv[x]))
accu <- do.call(rbind, accu)
accu <- as.data.frame(accu)
accu_30 <- accu
accu <- map(1:length(diff_mat_20), function(x) accuracies(diff_mat_40[[x]], t=40, biome=namesv[x]))
accu <- do.call(rbind, accu)
accu <- as.data.frame(accu)
accu_40 <- accu
accu <- map(1:length(diff_mat_20), function(x) accuracies(diff_mat_50[[x]], t=50, biome=namesv[x]))
accu <- do.call(rbind, accu)
accu <- as.data.frame(accu)
accu_50 <- accu
accu <- map(1:length(diff_mat_20), function(x) accuracies(diff_mat_55[[x]], t=55, biome=namesv[x]))
accu <- do.call(rbind, accu)
accu <- as.data.frame(accu)
accu_55 <- accu
accu <- map(1:length(diff_mat_20), function(x) accuracies(diff_mat_60[[x]], t=60, biome=namesv[x]))
accu <- do.call(rbind, accu)
accu <- as.data.frame(accu)
accu_60 <- accu
accu <- map(1:length(diff_mat_20), function(x) accuracies(diff_mat_65[[x]], t=65, biome=namesv[x]))
accu <- do.call(rbind, accu)
accu <- as.data.frame(accu)
accu_65 <- accu
accu <- map(1:length(diff_mat_20), function(x) accuracies(diff_mat_70[[x]], t=70, biome=namesv[x]))
accu <- do.call(rbind, accu)
accu <- as.data.frame(accu)
accu_70 <- accu
accu <- map(1:length(diff_mat_20), function(x) accuracies(diff_mat_75[[x]], t=75, biome=namesv[x]))
accu <- do.call(rbind, accu)
accu <- as.data.frame(accu)
accu_75<- accu
accu <- map(1:length(diff_mat_20), function(x) accuracies(diff_mat_80[[x]], t=80, biome=namesv[x]))
accu <- do.call(rbind, accu)
accu <- as.data.frame(accu)
accu_80 <- accu
accu <- map(1:length(diff_mat_20), function(x) accuracies(diff_mat_85[[x]], t=85, biome=namesv[x]))
accu <- do.call(rbind, accu)
accu <- as.data.frame(accu)
accu_85 <- accu
accu <- map(1:length(diff_mat_20), function(x) accuracies(diff_mat_90[[x]], t=90, biome=namesv[x]))
accu <- do.call(rbind, accu)
accu <- as.data.frame(accu)
accu_90 <- accu
accu <- map(1:length(diff_mat_20), function(x) accuracies(diff_mat_95[[x]], t=95, biome=namesv[x]))
accu <- do.call(rbind, accu)
accu <- as.data.frame(accu)
accu_95 <- accu
accu <- map(1:length(diff_mat_20), function(x) accuracies(diff_mat_100[[x]], t=100, biome=namesv[x]))
accu <- do.call(rbind, accu)
accu <- as.data.frame(accu)
accu_100 <- accu
##################################################

# 
# accu_20 <- rbind(accu_20, cauca1)
# accu_30 <- rbind(accu_30, cauca2)
# accu_40 <- rbind(accu_40, cauca3)
# accu_50 <- rbind(accu_50, cauca4)
# accu_55 <- rbind(accu_55, cauca5)
# accu_60 <- rbind(accu_60, cauca6)
# accu_65 <- rbind(accu_65, cauca7)
# accu_70 <- rbind(accu_70, cauca8)
# accu_75 <- rbind(accu_75, cauca9)
# accu_80 <- rbind(accu_80, cauca10)
# accu_85 <- rbind(accu_85, cauca11)
# accu_90 <- rbind(accu_90, cauca12)
# accu_95 <- rbind(accu_95, cauca13)
# accu_100 <- rbind(accu_100, cauca14)
##################################################


accu_msk<- rbind(accu_20,accu_30, accu_40, accu_50, accu_55, accu_60, accu_65,accu_70, accu_75,accu_80, accu_85,
                 accu_90, accu_95,accu_100)
accu_msk <- as_tibble(accu_msk)
save(accu_msk, file='accuracy_masked_1.RData')


accu_no_msk<- rbind(accu_20,accu_30, accu_40, accu_50, accu_55, accu_60, accu_65,accu_70, accu_75,accu_80, accu_85, 
                 accu_90, accu_95,accu_100)
accu_no_msk <- as_tibble(accu_no_msk)
save(accu_no_msk, file='accuracy_unmasked_1.RData')

dir()
######################################
#load data

load('accuracy_masked_1.RData')
load("accuracy_unmasked_1.RData")



accu_msk <- as_tibble(accu_msk)
accu_no_msk <- as_tibble(accu_no_msk)
print(accu_msk, n=20)
print(accu_no_msk, n=20)

accu_msk%>%filter(type=='OA')%>%top_n(50,accuracy)%>%group_by(biome)

accu_msk%>%group_by(biome)%>%filter(type=='UA')%>%slice(which.max(accuracy))

accu_msk%>%filter(biome=='Halobioma Alta Guajira')%>%filter(type=='OA')




ggplot(accu_msk, aes(x=pixelcount,y=accuracy, color=type))+#, fill=algorithm))+
  geom_point()+
  facet_grid(vars(threshold))
  ggtitle('Accuracies no-change')

pdf(file='test1.pdf',
    width = 16, height=9)
ggplot(accu_msk, aes(x=pixelcount, y=accuracy, color=interaction(threshold, type), shape=type, group=interaction(type,threshold,biome)))+
  geom_point()+
  facet_wrap(vars(threshold))+
  geom_smooth(method='lm', alpha=0.1, size=0.5)+
  ylim(0,1)+
  scale_x_continuous(labels = scales::percent_format(scale = 100))+
  labs(x='no-Change (share)')
dev.off()


pdf(file='acc_no_ch.pdf',
    width = 16, height=9)
ggplot(accu_msk, aes(x=algorithm,y=accuracy, color=user))+#, fill=algorithm))+
  geom_boxplot()+
  facet_grid(vars(location),vars(type))+
  ggtitle('Accuracies no-change')
dev.off()

#Boxplot change
pdf(file='acc_ch.pdf',
    width = 16, height=9)
ggplot(accu_ch, aes(x=algorithm,y=accuracy, color=user))+#, fill=algorithm))+
  geom_boxplot()+
  facet_grid(vars(location),vars(type))+
  ggtitle('Accuracies change')
dev.off()

#Acc/Area no change
pdf(file='acc_no_ch_area.pdf',
    width = 16, height=9)
ggplot(accu_no_ch, aes(x=pixels, y=accuracy, color=interaction(user, algorithm), shape=user, group=interaction(type,user,algorithm)))+
  geom_point()+
  facet_grid(vars(location),vars(type))+
  geom_smooth( method='lm', alpha=0.1, size=0.5)+
  ylim(0,1)+
  scale_x_continuous(labels = scales::percent_format(scale = 100))+
  labs(x='no-Change (share)')
dev.off()

#Acc/Area  change
pdf(file='acc_ch_area.pdf',
    width = 16, height=9)
ggplot(accu_ch, aes(x=pixels, y=accuracy, color=interaction(user, algorithm), shape=user, group=interaction(type,user,algorithm)))+
  geom_point()+
  facet_grid(vars(location),vars(type))+
  geom_smooth( method='lm', alpha=0.1, size=0.5)+
  ylim(0,1)+
  scale_x_continuous(labels = scales::percent_format(scale = 100))+
  labs(x='Change (share)')
dev.off()
