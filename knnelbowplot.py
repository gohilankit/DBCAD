from netCDF4 import Dataset
import numpy as np
from fastdtw import fastdtw
from scipy.spatial.distance import euclidean
import matplotlib.pyplot as plt


neighbourlong=[0,1,1,1,0,-1,-1,-1]
neighbourlat =[-1,-1,0,1,1,1,0,-1]
globalcorepoints=set()
globalnoisepoints=set(range(480))
globalborderpoints=set()
globaldist=[]
Modedict={}
f = Dataset("D:/Git/DBCAD/ALDA_dataset_and_initial_code/air.2m.gauss.2011.nc", "r+", format="NETCDF4")
def testFunc():
  global globaldist
  timewindow=9
  iter=0
  temp=[94]
  for timeIndex in range (4,360,1):
    for iterlong in range(126,158):
      for iterlat in range(20,35):
        currtimeslice = f.variables['air'][timeIndex - timewindow/2  : timeIndex + timewindow/2 + 1, 0, iterlat, iterlong]
        currdist=[]
        for iter in range(8):
           neighbourtimeslice = f.variables['air'][timeIndex - timewindow/2  : timeIndex + timewindow/2 + 1, 0, iterlat +neighbourlat[iter], iterlong+neighbourlong[iter]]
           distance, path = fastdtw(currtimeslice, neighbourtimeslice, dist=euclidean)
           #print distance
           #dist.append((distance,iter))
           currdist.append(distance)

        currdist.sort()
        globaldist+=currdist[0:4]


def main():
  testFunc()
  global globaldist
  #print dist
  globaldist.sort()
  print globaldist
  

  plt.plot(globaldist)
  plt.ylabel("4th neighbour distance")
  plt.show()
  #fig=plt.figure()
  #ax=fig.add_subplot(111)
  #y,x,_=plt.hist(dist,bins=100)
  #for i in range(0,len(y)):
      #if y[i]== y.max():
          #print x[i]
          #break
#
  #fig.savefig("plot.png")
  #nmax=np.max(n)
  #arg_max=None
  #for j,_n in enumerate(n):
      #if _n==max:
          #arg_max=j
          #break

  #print dist[arg_max]


if __name__ == '__main__':
  main()