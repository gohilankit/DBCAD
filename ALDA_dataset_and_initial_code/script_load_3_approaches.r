#library(spatstat)
library(RNetCDF)
#library(FNN)
library(dbscan)
data.years=(rep(0,365))
#rm(data.years)
#Approach 1: Naive approach
for(i in seq(1,36)){
  name=paste("air.2m.gauss.",i+1978,".nc", sep="")
  id=open.nc(name)
  data=read.nc(id)
  #data.years[i]=data$air[1,1,]
  data.years <- c(data.years, data$air[151,29,])
}
data.years <- data.years[366:length(data.years)]
plot(data.years, pch = 20, main="Daily Air temperatures (Jan 1, 1979- Dec 31, 2014)",ylab="Air Temperatures", xlab="Number of days, starting from Jan 1, 1979")

dat=cbind(1:length(data.years), data.years)	
dists=get.knn(dat, k=2)
max.two=sapply(1:nrow(dists$nn.dist), function(x) max(dists$nn.dist[x,]))
plot(sort(max.two), main="Elbow Plot", xlab="Indices", ylab="Second Nearest Neighbour distances", type="l")
eps=5
minPts=3
res <- dbscan(as.matrix(dat),eps=eps,minPts = minPts,borderPoints = FALSE)
for(i in 1:length(res$cluster)){
   res$cluster[i]=ifelse(res$cluster[i]!=0,ifelse(res$cluster[i]!=127,2,1), 0)
 }
plot(dat, col=res$cluster+1, pch = 20, main=paste("Plot for Epsilon=", eps, ", minPts=", minPts, sep=""),ylab="Air Temperatures (Normalized)", xlab="Number of days, starting from Jan 1, 1979")

  #Paper approach

for(i in seq(1,36)){
  name=paste("air.2m.gauss.",i+1978,".nc", sep="")
  id=open.nc(name)
  data=read.nc(id)
  monthsData=split(data$air[151,29,], ceiling(seq_along(data$air[29,41,])/31))
  means = lapply(1:12, function(x) mean(monthsData[[x]]))
  sd = lapply(1:12, function(x) sd(monthsData[[x]]))
  newair = 0
  for(x in 1:12){
    for(dates in monthsData[[x]]){
      newair = c(newair, (as.numeric(dates)-means[[x]])/sd[[x]])
    }
  }
  newair = newair[2:length(newair)]
  data.years <- c(data.years, newair)
}
data.years <- data.years[366:length(data.years)]


#timeseries
# tsdata <- ts(data.years, freq=365)
# #plot(stl(tsdata, s.window="periodic", t.window=15))
# plot(decompose(tsdata,type="additive"))
# splitdecompose <- decompose(tsdata,type="additive")
# sum(is.na(splitdecompose$random))
# sum(is.na(data.years))
# random.wo.na=splitdecompose$random[!is.na(splitdecompose$random)]
# plot(random.wo.na)

#find epsilon
dists=get.knn(data.years, k=2)
max.fourth=sapply(1:nrow(dists$nn.dist), function(x) max(dists$nn.dist[x,]))
plot(sort(max.fourth), main="Elbow Plot", xlab="Indices", ylab="Fourth Nearest Neighbour distances",xlim=c(0, 15000), type="l")
plot(sort(max.fourth[max.fourth<0.004]), main="Elbow Plot", xlab="Indices", ylab="Fourth Nearest Neighbour distances", type="l")

#DBSCAN
eps=0.002
minPts=3
res <- dbscan(as.matrix(data.years),eps=eps,minPts = minPts,borderPoints = FALSE)
#res <- dbscan(as.matrix(dat),eps=eps,minPts = minPts,borderPoints = FALSE)
for(i in 1:length(res$cluster)){
  res$cluster[i]=ifelse(res$cluster[i]!=0,2,0)
}
plot(data.years, col=res$cluster+1, pch = 20, main=paste("Plot for Epsilon=", eps, ", minPts=", minPts, sep=""),ylab="Air Temperatures (Normalized)", xlab="Number of days, starting from Jan 1, 1979")
legend("bottomright", c("All identified clusters", "Noise/Border points"), col=c(3,1), pch=20)


#dev.off()
#par(mfrow=c(3,3))
#28, 39
#for(i in seq(0:2)){
#  for(j in seq(0:2)){
#    plot(data$air[28+i,39+j,], main=paste("28+",i,", 39+", j, sep=""))
#  }
#}
#plot(data$air[29,41,], main="29,41")



#Third Approach:
data.years=(rep(0,365))
for(i in seq(1,36)){
  name=paste("air.2m.gauss.",i+1978,".nc", sep="")
  id=open.nc(name)
  data=read.nc(id)
  #data.years[i]=data$air[1,1,]
  data.years <- c(data.years, data$air[151,29,])
}
data.years <- data.years[366:length(data.years)]
tsdata <- ts(data.years, freq=365)
plot(decompose(tsdata,type="additive"))
splitdecompose <- decompose(tsdata,type="additive")
sum(is.na(splitdecompose$random))
random=splitdecompose$trend+splitdecompose$random
random.wo.na=random[!is.na(random)]
plot(random.wo.na, main="Deseasonalized Average Daily Temperatues plotted as time series", xlab="No. of years string from 1979", ylab="Air Temperatures", pch=20)
dat=cbind(1:length(random.wo.na), random.wo.na)
max.two=sapply(1:nrow(dists$nn.dist), function(x) max(dists$nn.dist[x,]))
plot(sort(max.two), main="Elbow Plot", xlab="Indices", ylab="Second Nearest Neighbour distances", type="l")
eps=6
minPts=3
res <- dbscan(as.matrix(dat),eps=eps,minPts = minPts,borderPoints = FALSE)
# for(i in 1:length(res$cluster)){
#   res$cluster[i]=ifelse(res$cluster[i]!=0,2,0)
# }
# for(i in 1:length(res$cluster)){
#   res$cluster[i]=ifelse(res$cluster[i]!=0,ifelse(res$cluster[i]!=127,2,1), 0)
# }
plot(dat, col=res$cluster+1, pch = 20, main=paste("Plot for Epsilon=", eps, ", minPts=", minPts, sep=""),ylab="Air Temperatures", xlab="Number of days, starting from Jan 1, 1979")
legend("bottomright", c("All identified clusters", "Noise/Border points"), col=c(3,1), pch=20)



dev.off()
par(mfrow=c(3,3))
#28, 39
for(j in seq(0:2)){
  for(i in seq(0:2)){
    plot(data$air[149+i,27+j,], main=paste("lat= ",  round(data$lat[27+j],3),", lon= ", data$lon[149+i]-360, sep=""), ylab="Air temperatures", pch=20)
  }
}
#plot(data$air[151,29,], main="151,29")