#install.packages("ncdf")
#setwd("D:/Git/DBCAD/ALDA_dataset_and_initial_code")
library(RNetCDF)
library(FNN)
library(dbscan)
#rm(data.years)
#Approach 1: Naive approach
count=0
for (k in seq(127,158)){
  
  for (j in seq(21,35)){
    data.years=(rep(0,365))
    for(i in seq (1,35)){
      name=paste("air.2m.gauss.",i+1978,".nc", sep="")
      id=open.nc(name)
      data=read.nc(id)
      
      #data.years[i]=data$air[1,1,]
      data.years =c(data.years,data$air[k,j,])
      close.nc(id)
      
    } 
    data.years<- data.years[366:length(data.years)]
    #plot(data.years, pch = 20, main="Daily Air temperatures (Jan 1, 1979- Dec 31, 2014)",ylab="Air Temperatures", xlab="Number of days, starting from Jan 1, 1979")
    dat=cbind(1:length(data.years), data.years)	
    dists=get.knn(dat, k=2)
    max.two=sapply(1:nrow(dists$nn.dist), function(x) max(dists$nn.dist[x,]))
    plot(sort(max.two), main="Elbow Plot", xlab="Indices", ylab="Second Nearest Neighbour distances", type="l")
    
    count=count+1
    dev.copy(png,paste("elbowPlots/",count,".png",sep=""))
  
    dev.off()
    graphics.off()  
    #eps=6
    #minPts=3
    #res <- dbscan(as.matrix(dat),eps=eps,minPts = minPts,borderPoints = FALSE)
    #for(i in 1:length(res$cluster)){
     # res$cluster[i]=ifelse(res$cluster[i]!=0,ifelse(res$cluster[i]!=127,2,1), 0)
    #}
    #plot(dat, col=res$cluster+1, pch = 20, main=paste("Plot for Epsilon=", eps, ", minPts=", minPts, sep=""),ylab="Air Temperatures (Normalized)", xlab="Number of days, starting from Jan 1, 1979")
    
  }
  
}
 

