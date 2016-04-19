#install.packages("FNN")
#setwd("D:/Git/DBCAD/ALDA_dataset_and_initial_code")
library(RNetCDF)
library(FNN)
library(dbscan)
library(gtools)
library(maps)
#rm(data.years)
#Approach 1: Naive approach
anomalies=list()
datanetcdf=list()
for(i in seq(1,36)){
  name=paste("air.2m.gauss.",i+1978,".nc", sep="")
  id=open.nc(name)
  data=read.nc(id)
  datanetcdf[[i]]=data
  close.nc(id)
}
for (k in seq(127,158)){
  for (j in seq(21,35)){
    print(paste("k=",k))
    print(paste("j=",j))
    data.years=(rep(0,365))
    for(i in seq (1,36)){
      #name=paste("air.2m.gauss.",i+1978,".nc", sep="")
      #id=open.nc(name)
      #data=read.nc(id)
      data=datanetcdf[[i]]
      #data.years[i]=data$air[1,1,]
      data.years =c(data.years,data$air[k,j,])
      #close.nc(id)
    } 
    data.years<- data.years[366:length(data.years)]
    #plot(data.years, pch = 20, main="Daily Air temperatures (Jan 1, 1979- Dec 31, 2014)",ylab="Air Temperatures", xlab="Number of days, starting from Jan 1, 1979")
    dat=cbind(1:length(data.years), data.years)	
    #dists=get.knn(dat, k=2)
    #max.two=sapply(1:nrow(dists$nn.dist), function(x) max(dists$nn.dist[x,]))
    #plot(sort(max.two), main="Elbow Plot", xlab="Indices", ylab="Second Nearest Neighbour distances", type="l")
    #max= as.vector(dists$nn.dist)
    #plot(sort(max), main="Elbow Plot", xlab="Indices", ylab="Second Nearest Neighbour distances", type="l")
    
    
    eps=5
    minPts=3
    res <- dbscan(as.matrix(dat),eps=eps,minPts = minPts,borderPoints = FALSE)
    for(i in 1:length(res$cluster)){
      #res$cluster[i]=ifelse(res$cluster[i]!=0,ifelse(res$cluster[i]!=127,2,1), 0)
      res$cluster[i]=ifelse(res$cluster[i]!=0,2,0)
    }
   # plot(dat, col=res$cluster+1, pch = 20, main=paste("Plot for Epsilon=", eps, ", minPts=", minPts, sep=""),ylab="Air Temperatures (Normalized)", xlab="Number of days, starting from Jan 1, 1979")
    anomaliestime= which(res$cluster == 0)
    currlocationindex=(j - 21)*32 + (k - 127)+1
    for (i in anomaliestime){
      if (invalid(anomalies[i])){
        anomalies[i]=c(currlocationindex)
      } else {
        anomalies[[i]]=c(anomalies[[i]],currlocationindex)
      }
    }
  }
}
save(anomalies,file='anomalies.RData')
dev.off()
library("maps")
for(i in seq(1,13149)){
  point.loc = c(0,0)
  map('state',plot=TRUE, fill=FALSE)
  if(!invalid(anomalies[[i]])){
    for(j in anomalies[[i]]){
      v=c(data$lon[ifelse(j%%32==0,32,j%%32)+126],data$lat[as.integer(j/32)+1+20])
      point.loc=rbind(point.loc,v)
    }
  }
  if(!class(point.loc)=="numeric"){
    point.loc=point.loc[-1,]
  
  
  
  #points(x=point.loc[,1]-360,y=point.loc[,2],col=point.loc[,3]+1,pch="*")
  #noise = point.loc[point.loc[,3]==0,1:2]
  #print(f)
  #print(nrow(noise))
    if(!is.null(nrow(point.loc))){
      points(x=point.loc[,1]-360,y=point.loc[,2],col="red")
    }
  }
  title(paste('Day',i,sep=" "))
  dev.copy(png,paste("usa_all_Location/usa_plot",i,".png",sep=""))
  dev.off()  
}