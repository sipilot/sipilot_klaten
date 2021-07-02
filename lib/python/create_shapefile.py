import sys
import shutil
import pandas as pd
import geopandas as gpd

file_name = sys.argv[1].rstrip('\n')

# set dataframe
df = pd.read_csv('./lib/python/{}.csv'.format(file_name))

# Obtain ESRI WKT
ESRI_WKT = 'PROJCS["DGN95_Indonesia_TM_3_zone_49_1",GEOGCS["GCS_DGN95",DATUM["D_Datum_Geodesi_Nasional_1995",SPHEROID["WGS_1984",6378137,298.257223563]],PRIMEM["Greenwich",0],UNIT["Degree",0.017453292519943295]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",109.5],PARAMETER["scale_factor",0.9999],PARAMETER["false_easting",200000],PARAMETER["false_northing",1500000],UNIT["Meter",1]]'
crs = {'init': 'epsg:4326'}

# create geopandas GeoDataFrame using pandas Data Frame
gdf = gpd.GeoDataFrame(df, geometry=gpd.points_from_xy(df['Longitude'], df['Lattitude']), crs=crs)

# convert tm3
gdf_tm3 = gdf.to_crs(epsg=23835)

print(gdf_tm3)

# save he file as ESRI Shapefile
gdf_tm3.to_file(filename = '{}.shp'.format(file_name), driver='ESRI Shapefile')
