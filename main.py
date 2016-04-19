from netCDF4 import Dataset
from fastdtw import fastdtw
import numpy as np
from scipy.spatial.distance import euclidean
from scipy.sparse import csr_matrix
from igraph import *
from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter


#latitutdes index range: 0 to 93
#longitudes index range: 0 to 191
#126 to 157 USA longitude
#20 to 34 USA latitude

neighbourlong=[0,1,1,1,0,-1,-1,-1]
neighbourlat =[-1,-1,0,1,1,1,0,-1]
globalcorepoints=set()
globalnoisepoints=set(range(480))
globalborderpoints=set()
g = Graph(directed=True)
filename="ALDA_dataset_and_initial_code/air.2m.gauss."
f = Dataset(filename+str(1979)+".nc", "r+", format="NETCDF4")


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
    if (currlat - minlat)*rangelong + (currlong - minlong) in globalnoisepoints:
      globalnoisepoints.remove((currlat - minlat)*rangelong + (currlong - minlong))

    for iter in range(8):
      #Add edge to points which are within epsDist. use smallDTWDict
      if smallDTWDict[iter] < epsDist:
        #Consider neighbors for spatially bordered point but don't add them to the graph
        if currlat+neighbourlat[iter] in range(minlat, minlat+rangelat) and currlong+neighbourlong[iter] in range(minlong,minlong+rangelong):
          g.add_edge((currlat - minlat)*rangelong + (currlong - minlong), (currlat+neighbourlat[iter] - minlat)*rangelong + (currlong+neighbourlong[iter] - minlong))
          if (currlat+neighbourlat[iter] - minlat)*rangelong + (currlong+neighbourlong[iter] - minlong) in globalnoisepoints:
            globalnoisepoints.remove((currlat+neighbourlat[iter] - minlat)*rangelong + (currlong+neighbourlong[iter] - minlong))


def DBSCAN(minPts, epsDist, timeindex, timewindow, minlong, minlat, rangelong, rangelat):
  #in our case the points of USA are well within the index range of f. currently not writing a border handling case

  for iterlong in range(minlong,minlong+rangelong):
    for iterlat in range(minlat,minlat+rangelat):
      isCorePoint(minPts, epsDist, iterlong, iterlat, minlong, minlat, rangelong, rangelat, timeindex, timewindow)


def main():

  #g= setupGraph()
  #using global variable for now
  parser = ArgumentParser("DBSCAN", formatter_class=ArgumentDefaultsHelpFormatter, conflict_handler='resolve')
  parser.add_argument('--minPts', default=3, type=int, help='minPts for DBSCAN algorithm')
  parser.add_argument('--epsDist', default=15, type=float, help='epsDist for DBSCAN. Enter float')
  #parser.add_argument('--timeindex', type=int, help='Timeindex')
  parser.add_argument('--timewindow', default=9, type=int, help='')
  parser.add_argument('--country', default=1, type=int, help='1 for USA, 2 for World')

  args = parser.parse_args()
  if args.country == 1:
    minlong=126
    minlat=20
    rangelong=32
    rangelat=15
    g.add_vertices(480)
  elif args.country==2:
    minlong=1
    minlat=1
    rangelong=190
    rangelat=92 
    g.add_vertices(92*190)
    
    
  timeindices= range(4, 40)
  #timeindices=[4]  
  for timeindex in timeindices:
    DBSCAN(args.minPts, args.epsDist, timeindex, args.timewindow,minlong, minlat, rangelong, rangelat)
    clusteredg = g.clusters(mode=WEAK)
    if args.country==1:
      file = open("./clusters/usa."+str(timeindex)+".clusters", 'w')
    else:
      file = open("./clusters/world."+str(timeindex)+".clusters", 'w')
    for cluster in clusteredg:
      file.write(",".join(str(idx) for idx in cluster))
      file.write("\n")
    file.close()

if __name__ == '__main__':
  main()
