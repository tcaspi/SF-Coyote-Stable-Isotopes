########### SAMPLE COLLECTION MAP ###########
library(tidyverse)
library(ggmap)
library(ggspatial)


## Prep Location Data

# Load SI data from all runs
data1 <- read.csv("Data/pilot_and_20231003.csv")
data2 <- read.csv("Data/20240102_data.csv")
data3 <- read.csv("Data/20240910_data.csv")

# Bind data frames
all.data <- rbind(data1, data2, data3) %>% 
  arrange(SampleID)

# Load metadata and select relevant columns
metadata <- read.csv("Data/whisker_metadata.csv") %>% 
  select(c(whisker, urban, site, dead, lat, long))

# Join SI data to metadata
joined <- left_join(all.data, metadata, by="whisker")

# Load genotype and individual ID data
ids <- read.csv("Data/individual_ids.csv")

# Define duplicates to remove
dups.to.remove <- c("S22-0889-A", "S21-3433-2", "S22-0870", "S21-1080")

# Clean data
data_clean <- joined %>% 
  
  # Remove samples with no returned isotope data (n=2)
  filter(!is.na(C_raw)) %>% 
  
  # Remove samples with incomplete lipid extraction
  mutate(C.N_ratio = C_total/N_total, .after=N_total) %>% 
  filter(C.N_ratio < 3.2) %>% 
  
  # Add whisker segment count
  group_by(whisker) %>% 
  add_count(name="count") %>% 
  relocate(count, .after=whisker) %>%
  
  # Remove unnecessary duplicates
  filter(!whisker %in% dups.to.remove) %>% 
  
  # Add column of segment numbers
  mutate(seg_num = row_number(), .after="SampleID") %>% 
  
  # Add genotype data
  left_join(ids, by = "individual")

# Create data frame for plotting
data_inds <- data_clean %>% 
  distinct(whisker, sex, dead, urban, site, lat, long) 

table(data_inds$dead) # investigate sample counts per category

# Rename categories for map
locs <- data_inds %>% 
  mutate(dead.cat = case_when(
    dead == "euthanized" ~ "Euthanized: Aggression",
    dead == "live cap" ~ "Live Capture",
    dead == "roadkill" ~ "Deceased",
    dead == "sick.euth" ~ "Euthanized: Other",
    dead == "sick.release" ~ "Live Capture",
    dead == "unknown" ~ "Deceased",
    TRUE ~ "Other" 
  ))

table(locs$dead.cat) # check that names are correct

# Make Study Site Map
register_google(key = "YOUR KEY HERE")
register_stadiamaps("YOUR KEY HERE", write = TRUE)

bbox <- c(left = -122.6, right = -122.35, bottom = 37.68, top = 37.88)

get_stadiamap(bbox, zoom = 14, maptype = "stamen_terrain", scale=2) %>% ggmap()+
  geom_point(data = locs, aes(x = long, y = lat, color = dead.cat), 
             size = 2, alpha=0.7, position=position_jitter(width=.002, height = .002)) +
  scale_color_manual(values=c( "black", "#f54242", "#1f50cc", "#004D40"),
                     labels=c("Deceased", "Euthanized: Aggression", "Euthanized: Other", "Live Capture"))+
  guides(shape = "none") +
  theme_minimal()+
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        legend.title = element_blank(),
        legend.position = c(0.148, 0.12),
        legend.background = element_rect(fill = "white", color = "black", linewidth = 0.5), 
        legend.box.background = element_rect(fill = "white", color = "black"),
        legend.text = element_text(size = 6),  # Make legend text smaller
        legend.key.size = unit(0.2, "cm"),  # Reduce legend key (color box) size
        legend.spacing.y = unit(0.05, "cm"),
        legend.key.height = unit(0.25, "cm"))+
  
  annotation_scale(location = "bl", width_hint = 0.2) + 
  coord_sf(crs = 4326)

# ggsave("Figures/Figure1.png", dpi=600, height=5, width=5)

##########################################################################

# Inset for California with SF County and Marin County highlighted

library(usmap)

# Define counties to highlight
highlight_counties <- c("San Francisco County", "Marin County")

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


