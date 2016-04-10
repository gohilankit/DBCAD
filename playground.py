from netCDF4 import Dataset
from fastdtw import fastdtw
import numpy as np
from scipy.spatial.distance import euclidean
from scipy.sparse import csr_matrix
from igraph import *

neighbourlong=[0,1,1,1,0,-1,-1,-1]
neighbourlat =[-1,-1,0,1,1,1,0,-1]
globalcorepoints=set()
globalnoisepoints=set(range(480))
globalborderpoints=set()
g = Graph(directed=True)
g.add_vertices(480)
f = Dataset('ALDA_dataset_and_initial_code/air.2m.gauss.2011.nc', 'r+', format="NETCDF4")
currlat = 28
currlong = 150
timeindex = 4
timewindow = 7

currtimeslice = f.variables['air'][timeindex - timewindow/2 : timeindex + timewindow/2+1, 0, currlat, currlong]
print ("current:",currtimeslice)

smallDTWDict={}     #key is index of neighbourlong and neighbourlat
for iter in range(8):
  neighbourtimeslice = f.variables['air'][timeindex - timewindow/2 : timeindex + timewindow/2+1, 0, currlat+neighbourlat[iter], currlong+neighbourlong[iter]]
  print ("iter:", iter)
  print currtimeslice
  print neighbourtimeslice
  distance, path = fastdtw(currtimeslice, neighbourtimeslice, dist=euclidean)
  print distance
  print path
  print "---------------"
  #print ("iter: ", iter)
  #print ("distance:", distance)
