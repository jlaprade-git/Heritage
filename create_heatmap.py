import pandas as pd
import folium
from folium.plugins import HeatMap

# path/enc
file_path = 'C:/temp/geolocated_ips - Copy.csv'
encoding = 'utf-16'

#read
data = pd.read_csv(file_path, encoding=encoding)

#init a new a map
m = folium.Map(location=[0, 0], zoom_start=2)

#dataprep
heat_data = [[row['Latitude'], row['Longitude']] for index, row in data.iterrows()]

#insert data to the map
HeatMap(heat_data).add_to(m)

# export html
m.save('C:/temp/ip_heatmap.html')


