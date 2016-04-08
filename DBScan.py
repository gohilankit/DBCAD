from scipy.io import netcdf
from netCDF4 import Dataset


def main():
  num_files = 36;


  f = Dataset('air.2m.gauss.1979.nc', 'r+', format="NETCDF4")
  print len(f.variables['air'].dimensions)


  # for i in range(num_files):
  #   f = netcdf.netcdf_file('air.2m.gauss.' + str(i+1979) + '.nc', 'r')
  #   print(f.air)


if __name__ == '__main__':
  main()
