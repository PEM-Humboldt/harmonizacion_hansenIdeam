#Result extraction and visualization Comparison PNN
library(readr)
load('/Users/sputnik/Documents/bosque-nobosque/rasters_SINAP/agg_all.RDAta')
col_names <- c('class', 'no_bosque', 'bosque', 'year', 'pnn')
colnames(aggp) <- col_names
#1. Get "omission" and "commision" for each class/location/year and add to the table
#2. Find out which metrics work best for this
# 3 Some mutate and other data wrangling operations to fill the gaps (get UA, OA and PA)
# 4 Think about graphs for this.

#Some data manipulation ,conver char into numeric 
aggp <-  as_tibble(aggp%>%transform(no_bosque= as.numeric(no_bosque), bosque=as.numeric(bosque), year=as.numeric(year)))
#add sum rowwise
aggp <- aggp%>%rowwise()%>%mutate(sum_row=sum(no_bosque+bosque))
# add sum to PA
aggp <- aggp%>%mutate(sum_row=sum(no_bosque+bosque))%>%group_by(year, pnn)%>%mutate(colsums_nb=sum(no_bosque))%>%mutate(colsums_b=sum(bosque))
# get  total pixels
aggp <- aggp%>%rowwise()%>%mutate(sum_all=sum(colsums_nb+colsums_b))
# get UA for each class
aggp <- aggp%>%mutate(UAnb=sum(no_bosque/sum_row))%>%mutate(UAb=sum(bosque/sum_row))
# get PA for each class
aggp <- aggp%>%group_by(year, pnn)%>%mutate(PAnb=(no_bosque/colsums_nb))%>%mutate(PAb=(bosque/colsums_b))
#get OA
#Get sum of correctly classified classes   
aggpoa <- aggp%>%filter(class=='no-bosque')
aggpoa <- aggpoa[c(1,2)]
names(aggpoa) <- c('class', 'sum_correct')
aggpoa2 <- aggp%>%filter(class=='bosque')
aggpoa2 <- aggpoa2[3]
names(aggpoa2) <- 'sum_correct'
aggpoa[2] <- (aggpoa[2]+aggpoa2[1])
rm(aggpoa2)
######
aggpp <- aggp%>%filter(class=='no-bosque')%>%cbind(aggpoa[2])
aggp2 <- aggp%>%filter(class=='bosque')
aggp <- as_tibble(merge(aggpp, aggp2, all = T))
rm(aggpp, aggp2)

#GET OA
aggp <- aggp%>%mutate(OA=sum_correct/sum_all)
###### Remove unnecessary values
UAnb for bosquem PAnb for bosque, UAb for no bosque. PAb for no bosque

aggp%>%filter(class=='bosque', UAnb="NA")
df <- aggp %>% mutate(height = replace(height, height == 20, NA))

#Later 

#Overall Agreement (lines)
ggplot(aggp%>%filter(class=='no-bosque'), aes(x=year,y=OA, color=pnn))+#, fill=algorithm))+
  geom_line()+
  #facet_grid(vars(pnn))+
ggtitle('Overall Agreement')

#Overall Agreement (lines/facets)
ggplot(aggp%>%filter(class=='no-bosque'), aes(x=year,y=OA, color=pnn))+#, fill=algorithm))+
  geom_line()+
  facet_grid(vars(pnn))+
  ggtitle('Overall Agreement')

#Overall Agreement (barplot)
ggplot(aggp%>%filter(class=='no-bosque'), aes(x=year,y=OA, color=pnn, fill=pnn))+#, fill=algorithm))+
  geom_bar(stat='identity', position = 'dodge')+
  #facet_grid(vars(pnn))+
  ggtitle('Overall Agreement')


ggplot(aggp%>%filter(class=='bosque')%>%select(c('PAb', 'PAb')), aes(x=year, color=pnn, fill=pnn))+#, fill=algorithm))+
  geom_bar(stat='identity', position = 'dodge')+
  #facet_grid(vars(pnn))+
  ggtitle('Agreement, forest')
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

# # GGplot from here 
aggp%>%filter(pnn=='Serrania_de Chiribiquete')
x <- 5773972+82755
aggp

