toffs <- list.files('.', 'cas')
tt <- rast('def00_21m.tif')

time(tt, tstep='years') <- 2000+0:21

writeRaster(tt, filename='def00_21f.tif', overwrite=TRUE)
map(1:nlyr(tt), function(x) writeRaster(tt[[x]], filename=toffs[x], overwrite=TRUE))

band_metadata <- data.frame(band = 1:nlyr(tt), date = c("2000/01/01","2001/01/01","2002/01/01","2003/01/01","2004/01/01","2005/01/01",
                                                           "2006/01/01","2007/01/01","2008/01/01","2009/01/01","2010/01/01","2011/01/01",
                                                           "2012/01/01","2013/01/01","2014/01/01","2015/01/01","2016/01/01", "2017/01/01",
                                                           "2018/01/01","2019/01/01","2020/01/01","2021/01/01"))
write.table(band_metadata, "band_dates.txt", sep = "=", col.names = FALSE, row.names = FALSE, quote = FALSE)
