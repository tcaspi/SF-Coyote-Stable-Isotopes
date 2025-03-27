########### TERRITORY LOCATIONS MAP ###########
library(tidyverse)
library(sf)
library(ggplot2)
library(ggmap)
library(ggspatial)

# Load location data
locs <- read.csv("Data/territory_covs.csv") %>% 
  filter(group != "Land's End") # remove territory with no whisker samples

# Convert to sf object
locs_sf <- st_as_sf(locs, coords = c("long", "lat"), crs = 4326)

# Transform to UTM for distance-based operations
locs_sf_utm <- st_transform(locs_sf, crs = 32610)  # UTM zone for SF

# Create 1 km buffer for each point
buffers_1km <- st_buffer(locs_sf_utm, dist = 1000)

# Transform back to WGS 84 (latitude/longitude) for mapping
buffers_1km_wgs <- st_transform(buffers_1km, crs = 4326)

# Define the bounding box for the map (San Francisco area)
bbox <- c(left = -122.55, right = -122.35, bottom = 37.68, top = 37.82)

# Get the map
sf_map <- get_stadiamap(bbox, zoom = 14, maptype = "stamen_terrain", scale = 2)

# Create the base ggplot object with the map using ggmap
ggplot() +
  # Add the map 
  annotation_raster(sf_map, xmin = bbox["left"], xmax = bbox["right"], ymin = bbox["bottom"], ymax = bbox["top"]) +
  # Add 1 km buffers
  geom_sf(data = buffers_1km_wgs, fill = "black", color = "black", alpha = 0.1) +
  # Add center points
  geom_sf(data = locs_sf, color="black", size = 3, shape = 16) +
  
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        legend.title = element_blank(),
        legend.position = "none")+
  
  annotation_scale(location = "bl", width_hint = 0.2) + 
  coord_sf(xlim = c(bbox["left"], bbox["right"]), ylim = c(bbox["bottom"], bbox["top"]), expand = FALSE)

# ggsave("Figures/FigureS1.png", dpi=600, height=5, width=5)

##########################################################################

# Inset for California with SF County and Marin County highlighted

library(usmap)

# Define counties to highlight
highlight_counties <- c("San Francisco County")

# Get county-level data for California
county_data <- us_map(regions = "counties") %>%
  filter(full == "California") %>%
  mutate(fill_color = ifelse(county %in% highlight_counties, "#F57E77", "#595959"))

# Plot
ggplot() +
  geom_sf(data = county_data, aes(fill = fill_color), color = NA) +  # Remove county borders
  scale_fill_identity() + 
  theme_void() +
  theme(panel.background = element_rect(fill = "#CCD9E6", color = NA))


