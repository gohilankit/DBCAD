library(RNetCDF)
name=paste("air.2m.gauss.",1979,".nc", sep="")
id=open.nc(name)
data=read.nc(id)
year = 1979
files.num=40
for(f in 4:files.num){
  filename=paste("clusters/world.",f,".clusters",sep="")
  clust=read.table(filename, header=F, sep="\n")
  vec.new=rep(-1, 18048)
  clusters=1
  for (k in clust$V1){
    i=(strsplit(as.character(k), ","))[[1]]
    if(length(i)==1){
      vec.new[as.numeric(i)+1]=0
    } else {
      for( j in i){
        vec.new[as.numeric(j)+1]=clusters
      }
      clusters=clusters+1
    }
  }
  
  point.loc = c(0,0,0)
  for(n in 1:18048){
    v=c(data$lon[ifelse(n%%192==0,192,n%%192)],data$lat[as.integer(n/192)+1],vec.new[n])
    point.loc=rbind(point.loc,v)
  }
  point.loc=point.loc[-1,]
  require(rworldmap)
  newmap <- getMap(resolution = "low")
  plot(newmap, asp = 1)
  noise = point.loc[point.loc[,3]==0,]
  points(noise[,1]-180, noise[,2], col = "red", cex = .6)
  title(paste('Day',f,'Year',year,sep=" "))
  dev.copy(png,paste("plots/world_plot",f,".png",sep=""))
  dev.off()
  
}