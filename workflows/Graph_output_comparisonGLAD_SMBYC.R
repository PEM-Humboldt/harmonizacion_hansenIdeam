library(purrr)
library(tidyr)

load(here('results_outputs', 'areas_fin.RData'))

areas_f

#areas_f%>%group_by(year,src)%>%summarise(a_sum=sum(count)

areas_f <- areas_f%>%mutate(area_ha = count*0.09)
areas_f <- areas_f%>%drop_na(value)
areas_f <- areas_f%>%mutate(clase= case_when(value==0 ~'no Bosque',
                                             value==1 ~'Bosque',
                                             value==3 ~'sin información'))


require(scales)

save(areas_f, file= 'areas_f.RData')
jpeg(file='plot2c.jpeg',
width = 16, height=9, units= 'in', res=300) # this exports the ggplots as jpegs,
# and sets the size and resolution. ayou can plot inside Rstudio instead  # by dropping this
# here, i created line graps, but ypu will need to use barplots
ggplot (areas_f%>%filter(value!=3), aes(x = year, y= area_ha, color= interaction(clase,src), group=interaction(value,src)))+
 geom_line(linewidth=1.5)+
geom_point(size=4)+
scale_y_continuous(labels = comma)+
labs (
title = "Bosque/no Bosque 2000-2019",
subtitle = "SMBYC vs GLAD",
x = "Año",
 y = "Total Area (ha)"
 )
#stops graphic device. Necessary for new plots
dev.off()

jpeg(file='plot3c.jpeg',
  width = 16, height=9, units= 'in', res=300)
ggplot (areas_f, aes(x = year, y= area_ha, color= interaction(clase,src), group=interaction(value,src)))+
  geom_line(size=1.5)+
 geom_point(size=4)+
 scale_y_continuous(labels = comma)+
labs (
title = "Bosque/no Bosque 2000-2019",
subtitle = "SMBYC vs GLAD",
x = "Año",
y = "Total Area (ha)"
)
dev.off()

 # Find oout later what this was.
ras_2019 <- raster('/Users/sputnik/Documents/bosque-nobosque/merged_2019a.tif')
 border <- raster('/Users/sputnik/Documents/bosque-nobosque/borders/borderd_biomes_msk.tif')
 merged <- merge(border, ras_2019)
 writeRaster(merged, 'armonized_2019a.tif')
 id_2019 <- raster('/Users/sputnik/Documents/bosque-nobosque/IDEAMfnf/rec SBQ_SMBYC_BQNBQ_V5_2019.tif')
 mskd <- mask(merged, id_2019, filename='diff_2019.tif', maskvalue=1)

# Get forewst loss. (add loss for the whole armonized thing)
 forests <- areas_f%>%filter(clase=='Bosque')

 loss <- forests %>%group_by(src) %>%
   mutate(loss = area_ha - lag(area_ha, default = area_ha[1]))
 loss <- loss%>%mutate(loss_p= loss*-1)

 jpeg(file='plot_forloss.jpeg',
      width = 16, height=9, units= 'in', res=300)
ggplot(loss, aes(x = year, y =loss_p, group= src, color = src, fill =src))+
  geom_bar(stat="identity",position="dodge")+
  scale_y_continuous(labels = comma)+
  labs (
    title = "Forest loss 2000-2019",
    subtitle = "SMBYC vs GLAD",
    x = "Year",
    y = "Total Area (ha)"
  )
dev.off()
