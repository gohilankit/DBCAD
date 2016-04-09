library(RNetCDF)
library(FNN)
library(dbscan)
install.packages("dtw")
library(dtw)

df=data.frame(1:480, 1:480)
names(df)=c("Lon", "Lat")

name=paste("air.2m.gauss.",1979,".nc", sep="")
id=open.nc(name)
first.year=read.nc(id)

for (i in seq(127,158)){
  df$Lon[(15*(i-127)+1):(15*(i-126))]=first.year$lon[i];
  for (j in seq(21,35)){
    df$Lat[(15*(i-127))+(j-20)]=first.year$lat[j];
    df$Temp.ts[(15*(i-127))+(j-20)] <- lapply(1:480, function(x) first.year$air[i,j,1])
  }
}
for(k in seq(2,36)){
  name=paste("air.2m.gauss.",1978+k,".nc", sep="")
  id=open.nc(name)
  data.year=read.nc(id)
  for (i in seq(127,158)){
    for (j in seq(21,35)){
      df$Temp.ts[[(15*(i-127))+(j-20)]] <- c(df$Temp.ts[[(15*(i-127))+(j-20)]],data.year$air[i,j,1])
    }
  }
}

sim.vector = 0
for(x in seq(1,32)){
  for(y in seq(1,15)){
    for(i in seq(-1,1)){
      for(j in seq(-1,1)){
        if(i==0 && j==0){
          next
        }
        if(((15*(x+i-1))+(y+j)) %in% (1:480)){
          sim.vector=c(sim.vector,dtw(x=as.matrix(df[15*(x-1)+y,]$Temp.ts[[1]]),y=df[(15*(x+i-1))+(y+j),]$Temp.ts[[1]])$distance)
        }
      }
    }
  }
}
sim.vector=sim.vector[-1]

par("mar")
par(mar=c(2,2,2,0.1))
hist(sim.vector)

sim.new=sim.vector[which(sim.vector<=500)]

hist(sim.new,breaks=100)

eps=145