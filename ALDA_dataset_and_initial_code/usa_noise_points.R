
new.data = array(0, dim=c(32,15,36))
for(k in seq(1,36)){
  name=paste("air.2m.gauss.",k+1978,".nc", sep="")
  id=open.nc(name)
  data=read.nc(id)
  
  for (i in seq(127,158)){
    for (j in seq(21,35)){
      new.data[i-126,j-20,k] = data$air[i,j,k]
    }
  }
}

plot((1:480),new.data[,,1])

dists=get.knn(new.data, k=4)
max.two=sapply(1:nrow(dists$nn.dist), function(x) max(dists$nn.dist[x,]))
plot(sort(max.two), main="Elbow Plot", xlab="Indices", ylab="Second Nearest Neighbour distances", type="l")
abline(h=0.05,col="red")
eps=0.05
minPts=5
res <- dbscan(new.data,eps=eps,minPts = minPts,borderPoints = FALSE)
for(i in 1:length(res$cluster)){
  res$cluster[i]=ifelse(res$cluster[i]!=0,2,0)
}
plot(new.data, col=res$cluster+1, pch = 20, main=paste("Plot for Epsilon=", eps, ", minPts=", minPts, sep=""),ylab="Air Temperatures (Normalized)", xlab="Number of days, starting from Jan 1, 1979")


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
points(x=year.one[,1]-360,y=year.one[,2],col="red")

install.packages("rworldmap",dependencies = TRUE)
newmap=getMap(resolution="low")


data$air[127,21,1]-data$air[158,35,1]