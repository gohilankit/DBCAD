from netCDF4 import Dataset
from fastdtw import fastdtw
import numpy as np
from scipy.sparse import csr_matrix
from igraph import *


#latitutdes index range: 0 to 93
#longitudes index range: 0 to 191
#126 to 157 USA longitude
#20 to 34 USA latitude

neighbourlong=[0,1,1,1,0,-1,-1,-1]
neighbourlat =[-1,-1,0,1,1,1,0,-1]
globalcorepoints=set()
g = Graph()
g.add_vertices(480)


def main():
  
	#g= setupGraph()

  f = Dataset('ALDA_dataset_and_initial_code/air.2m.gauss.1979.nc', 'r+', format="NETCDF4")
  print len(f.variables['air'].dimensions)



##DTW function to calculate distance with neighbor

def setupGraph():
	g = Graph()
	g.add_vertices(480)


	return g

def isCorePoint(minPts, epsDist, currlong, currlat, minlong, minlat, timeindex, timewindow):

  # for i in range(num_files):
  #   f = netcdf.netcdf_file('air.2m.gauss.' + str(i+1979) + '.nc', 'r')
  #   print(f.air)
  countwithineps=1    #count self. hence 1

  #currtimeslice = []
  #for iter in range(-1*timewindow/2+1, timewindow/2+1):
  	## [-4, -3, -2, -1, 0, 1, 2, 3, 4]
  	#currtimeslice.append(f.variables['air'][timeindex + iter][0][currlat][currlong])

  currtimeslice = f.variables['air'][timeindex - timewindow/2 : timeindex + timewindow/2+1, 0, currlat, currlong]

  for iter in range(8):
  	#checking neighbours of current, using neighbourlong and neighbourlat
  	#neighbourtimeslice=[]
  	#for iter2 in range(-1*timewindow/2+1, timewindow/2+1):
  	#	neighbourtimeslice.append(f.variables['air'][timeindex + iter2][0][currlat+iter][currlong+iter])
  	neighbourtimeslice = f.variables['air'][timeindex - timewindow/2 : timeindex + timewindow/2+1, 0, currlat+neighbourlat[iter], currlong+neighbourlong[iter]

  	distance, path = fastdtw(currtimeslice, neighbourtimeslice, dist=euclidean)
  	if distance < epsDist:
  		countwithineps+=1

  if countwithineps >= minPts:
  	currlat - minlat
  	currlong - minlong
  	globalcorepoints.add((currlat - minlat)*32 + (currlong - minlong))

  for iter in range(8):
  	g.add_edge((currlat - minlat)*32 + (currlong - minlong), (currlat+neighbourlat[iter] - minlat)*32 + (currlong+neighbourlong[iter] - minlong))

def DBSCAN(minPts, epsDist, timeindex):
	


if __name__ == '__main__':
  main()
