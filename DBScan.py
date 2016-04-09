from netCDF4 import Dataset
from fastdtw import fastdtw
import numpy as np
from scipy.spatial.distance import euclidean
from scipy.sparse import csr_matrix
from igraph import *


#latitutdes index range: 0 to 93
#longitudes index range: 0 to 191
#126 to 157 USA longitude
#20 to 34 USA latitude

neighbourlong=[0,1,1,1,0,-1,-1,-1]
neighbourlat =[-1,-1,0,1,1,1,0,-1]
globalcorepoints=set()
globalnoisepoints=set()
globalborderpoints=set()
g = Graph()
g.add_vertices(480)
f = Dataset('ALDA_dataset_and_initial_code/air.2m.gauss.1979.nc', 'r+', format="NETCDF4")



def setupGraph():
  g = Graph()
  g.add_vertices(480)


  return g

def isCorePoint(minPts, epsDist, currlong, currlat, minlong, minlat, rangelong, rangelat, timeindex, timewindow):

  # for i in range(num_files):
  #   f = netcdf.netcdf_file('air.2m.gauss.' + str(i+1979) + '.nc', 'r')
  #   print(f.air)
  countwithineps=1    #count self. hence 1

  #currtimeslice = []
  #for iter in range(-1*timewindow/2+1, timewindow/2+1):
    ## [-4, -3, -2, -1, 0, 1, 2, 3, 4]
    #currtimeslice.append(f.variables['air'][timeindex + iter][0][currlat][currlong])

  currtimeslice = f.variables['air'][timeindex - timewindow/2 : timeindex + timewindow/2+1, 0, currlat, currlong]
  smallDTWDict={}     #key is index of neighbourlong and neighbourlat
  for iter in range(8):
    #checking neighbours of current, using neighbourlong and neighbourlat
    #neighbourtimeslice=[]
    #for iter2 in range(-1*timewindow/2+1, timewindow/2+1):
    # neighbourtimeslice.append(f.variables['air'][timeindex + iter2][0][currlat+iter][currlong+iter])
    neighbourtimeslice = f.variables['air'][timeindex - timewindow/2 : timeindex + timewindow/2+1, 0, currlat+neighbourlat[iter], currlong+neighbourlong[iter]]
    distance, path = fastdtw(currtimeslice, neighbourtimeslice, dist=euclidean)
    #print ("iter: ", iter)
    #print ("distance:", distance)
    smallDTWDict[iter]=distance
    if distance < epsDist:
      countwithineps+=1

  if countwithineps >= minPts:
    globalcorepoints.add((currlat - minlat)*rangelong + (currlong - minlong))

    for iter in range(8):
      #Add edge to points which are within epsDist. use smallDTWDict
      if smallDTWDict[iter] < epsDist:
        if (currlat - minlat)*rangelong + (currlong - minlong) < 0:
          print ("currlat:" , currlat)
          print ("currlong:" , currlong)
        g.add_edge((currlat - minlat)*rangelong + (currlong - minlong), (currlat+neighbourlat[iter] - minlat)*rangelong + (currlong+neighbourlong[iter] - minlong))


def DBSCAN(minPts, epsDist, timeindex, timewindow):
  #in our case the points of USA are well within the index range of f. currently not writing a border handling case

  for iterlong in range(126,158):
    for iterlat in range(20,35):
      isCorePoint(minPts, epsDist, iterlong, iterlat, 126, 20, 32, 15, timeindex, timewindow)


def main():
  
  #g= setupGraph()
  #using global variable for now
  
  DBSCAN(5, 100, 4, 9)
  print globalcorepoints
  print g


if __name__ == '__main__':
  main()
