
new.data = array(0, dim=c(32,15,36,12))
data.4d = array(0, dim=c(480*36,4))
data.3d = array(0,dim=c(480,3))

index=1
for(k in seq(1,36)){
  name=paste("air.2m.gauss.",k+1978,".nc", sep="")
  id=open.nc(name)
  data=read.nc(id)
  for (i in seq(127,158)){
    for (j in seq(21,35)){
      data.4d[index,]= c(data$lon[i],data$lat[j],k,data$air[i,j,1])
      new.data[i-126,j-20,k,1] = data$air[i,j,1]
      new.data[i-126,j-20,k,2] = data$air[i,j,60]
      new.data[i-126,j-20,k,3] = data$air[i,j,120]
      new.data[i-126,j-20,k,4] = data$air[i,j,180]
      new.data[i-126,j-20,k,5] = data$air[i,j,240]
      new.data[i-126,j-20,k,6] = data$air[i,j,300]
      index=index+1
    }
  }
}
index=1
for (i in seq(127,158)){
  for (j in seq(21,35)){
    data.3d[index,]= c(data$lon[i],data$lat[j],data$air[i,j,1])
    #new.data[i-126,j-20,k,1] = data$air[i,j,1]
    index=index+1
  }
}



plot((1:480),new.data[,,1])

plot(x=NULL,y=NULL,xlim=c(127,158),ylim = c(21,35),xlab = "long",ylab = "lat")
for(i in seq(127,158)){
  for(j in seq(21,35)){
    points(x=i,y=j,col=data$air[i,j,1])
  }
}
myCol <- c("cadetblue1", "cyan3", "cornflowerblue","darkblue", "darkorchid4")
myBreaks <- c(242.730,256.530,274.480,290.005,298.910)
par(mfrow=c(2,3))
for (l in 1:6){
  hm <- heatmap(t(new.data[,,1,l]), scale="none", Rowv=NA, Colv=NA,
                col = heat.colors(256), ## using your colors
                #breaks = myBreaks, ## using your breaks
                dendrogram = "none",  ## to suppress warnings
                margins=c(5,5), cexRow=0.5, cexCol=1.0, key=TRUE, keysize=1.5,
                trace="none")
}



dists=get.knn(data.3d, k=4)
max.two=sapply(1:nrow(dists$nn.dist), function(x) max(dists$nn.dist[x,]))
plot(sort(max.two), main="Elbow Plot", xlab="Indices", ylab="Second Nearest Neighbour distances", type="l")
abline(h=2.35,col="red")
eps=2.35
minPts=5
res <- dbscan(data.3d,eps=eps,minPts = minPts,borderPoints = FALSE)
for(i in 1:length(res$cluster)){
  res$cluster[i]=ifelse(res$cluster[i]!=0,2,0)
}
plot(data.4d[,which(res$cluster==0)], col=res$cluster+1, pch = 20, main=paste("Plot for Epsilon=", eps, ", minPts=", minPts, sep=""),ylab="Air Temperatures (Normalized)", xlab="Number of days, starting from Jan 1, 1979")


noise.data = which(res$cluster==0)
noise.location = c(0,0,0,0)
for(n in noise.data){
  v=c(data$lon[as.integer(n/540)+1+126],data$lat[ifelse(n%%15==0,15,n%%15)+20],new.data[as.integer(n/540)+1,ifelse(n%%15==0,15,n%%15),as.integer(n/480)+1],as.integer(n/480)+1)
  noise.location=rbind(noise.location,v)
}
noise.location=noise.location[2:nrow(noise.location),]
year.one=noise.location[which(noise.location[,4]==36),]
library("maps")
map('state',plot=TRUE, fill=FALSE)
#points(x=year.one[,1]-360,y=year.one[,2],col="red")
points(x=noise.location[,1]-360,y=noise.location[,2],col="red")

install.packages("rworldmap",dependencies = TRUE)
newmap=getMap(resolution="low")


data$air[127,21,1]-data$air[158,35,1]