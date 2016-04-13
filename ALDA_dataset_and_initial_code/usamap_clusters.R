name=paste("air.2m.gauss.",1979,".nc", sep="")
id=open.nc(name)
data=read.nc(id)

clust=read.table("4.clusters", header=F, sep="\n")
vec.new=rep(0, 480)
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
for(n in 1:480){
  v=c(data$lon[ifelse(n%%32==0,32,n%%32)+126],data$lat[as.integer(n/32)+1+20],vec.new[n])
  point.loc=rbind(point.loc,v)
}
point.loc=point.loc[-1,]
library("maps")
map('state',plot=TRUE, fill=FALSE)
#points(x=year.one[,1]-360,y=year.one[,2],col="red")
points(x=point.loc[,1]-360,y=point.loc[,2],col=point.loc[,3])




