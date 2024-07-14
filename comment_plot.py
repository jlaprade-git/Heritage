import pandas as pd
import folium
from folium.plugins import HeatMap

# Load the data
file_path = r'c:\temp\heritage\ip_with_comment_counts.csv'
data = pd.read_csv(file_path, dtype={'Latitude': 'float64', 'Longitude': 'float64', 'Comment_Count': 'float64'})

# Ensure that Latitude and Longitude are numeric
data['Latitude'] = pd.to_numeric(data['Latitude'], errors='coerce')
data['Longitude'] = pd.to_numeric(data['Longitude'], errors='coerce')
data['Comment_Count'] = pd.to_numeric(data['Comment_Count'], errors='coerce')

# Drop any rows with NaN values that may have resulted from conversion errors
data.dropna(subset=['Latitude', 'Longitude', 'Comment_Count'], inplace=True)

# Create a base map
base_map = folium.Map(location=[data['Latitude'].mean(), data['Longitude'].mean()], zoom_start=3)

# Create a heatmap layer
heat_data = [[row['Latitude'], row['Longitude'], row['Comment_Count']] for index, row in data.iterrows()]
HeatMap(heat_data, radius=15, max_zoom=13).add_to(base_map)

# Save the map as an HTML file
output_file = r'c:\temp\heritage\comment_count_heatmap.html'
base_map.save(output_file)

# Print the path to the HTML file
print(f"Heatmap saved as {output_file}")
