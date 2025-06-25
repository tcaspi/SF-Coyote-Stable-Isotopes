library(tidyverse)
library(ggmap)
library(ggspatial)

### MAP OF SAMPLING LOCATIONS ###

# Load and format prey data
prey <- read.csv("Data/preydata_si.csv")

select.sources <- c("gopher", "skunk", "raccoon", "cat", "rat")

prey <- prey %>% 
  filter(SampleID != "Goph10") %>% 
  filter(species %in% select.sources)

# Identify prey with missing location data
na_counts <- prey %>%
  filter(is.na(lat) | is.na(long)) %>%
  count(species, name = "n_missing")

missing_caption <- paste0(
  "Missing location data: ",
  paste0(na_counts$species, " (", na_counts$n_missing, ")", collapse = ", ")
)

missing_caption

# Make map
bbox <- c(left = -122.52, right = -122.35, bottom = 37.7, top = 37.82)

study_map <- get_stadiamap(bbox, zoom = 14, maptype = "stamen_terrain", scale=2)

prey.map <- ggmap(study_map)+
  geom_jitter(data = prey, aes(x = long, y = lat, color = species), 
             size = 3, alpha=0.7, position=position_jitter(width=.002, height = .002)) +
  scale_color_manual(values=c( "#D81B60","#004D40", "#3E6C92",  "#120961", "grey"),
                     labels=c("Cat", "Gopher", "Raccoon", "Rat", "Skunk"))+
  guides(shape = "none") +
  theme_minimal()+
  theme(axis.text.x = element_text(6),
        axis.text.y = element_text(6),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        legend.title = element_blank(),
        legend.position = "bottom",
        legend.text = element_text(size = 6),  # Make legend text smaller
        legend.key.size = unit(0.2, "cm"),  # Reduce legend key (color box) size
        legend.spacing.y = unit(0.05, "cm"),
        legend.key.height = unit(0.25, "cm"),
        panel.background = element_rect(fill = "white", color = NA),
        plot.background = element_rect(fill = "white", color = NA),   
        legend.background = element_rect(fill = "white", color = NA),
        legend.box.background = element_rect(fill = "white", color = "white"))+
  labs(caption = missing_caption) +
  theme(plot.caption = element_text(size = 6, hjust = 1, face = "italic"))

# ggsave(prey.map, "Figures/prey_map.png", dpi=600, height=5, width=5.7)

### ISOSPACE PLOT OF ALL PREY DATA ### 

# Load fast food data
ff <- read.csv("Data/fastfood_si.csv")

# Load prey data
prey <- read.csv("Data/preydata_si.csv")

# define outliers and sources to keep
remove.sources <- c("Goph10") # sample removed because it was a strong outlier
select.sources <- c("gopher", "fruit", "skunk", "raccoon", "cat", "rat", "wet.food")

# Compute mean and SD for each species
species_stats <- prey %>%
  
  # remove outliers
  filter(!SampleID %in% remove.sources) %>%
  # select target species
  filter(species %in% select.sources) %>% 
  
  # adjust hair back to muscle
  mutate(d13C = if_else(material %in% c("vertebrate hair"), d13C - 1.31, d13C)) %>% 
  
  # select cols
  dplyr::select(c(SampleID, species, d13C, d15N)) %>% 
  
  # rbind chicken data
  rbind(ff %>% filter(species == "ff_chicken")) %>% 
  
  # summarize
  group_by(species) %>%
  summarise(
    Meand13C = round(mean(d13C),2),
    SDd13C = round(sd(d13C),2),
    Meand15N = round(mean(d15N),2),
    SDd15N = round(sd(d15N),2),
    n = n())

# Compute grand mean and pooled SD for "medium.mammal"
medium_mammal_stats <- species_stats %>%
  filter(species %in% c("raccoon", "skunk", "cat")) %>%
  summarise(
    species = "medium.mammal",
    Meand13C = round(mean(Meand13C), 2),  
    Meand15N = round(mean(Meand15N),2),
    
    # Pooled standard deviation formula
    SDd13C = round(sqrt(sum((SDd13C^2 * (n - 1))) / sum(n - 1)),2),
    SDd15N = round(sqrt(sum((SDd15N^2 * (n - 1))) / sum(n - 1)),2),
    n = sum(n))

# Step 3: Combine DFs
source_df <- species_stats %>%
  bind_rows(medium_mammal_stats)

# set TDFs
TDF.C <- 3.97
TDF.N <- 2.76

# Make data frame for plotting with source values corrected by TDF factors
source_df_plotting <- source_df %>% 
  mutate(Meand13C = Meand13C + TDF.C,
         Meand15N = Meand15N + TDF.N)

# Data frame for chicken/pork samples
meat.names <- c("ChkC01", "Pork01")

meat_samples <- prey %>% 
  filter(SampleID %in% meat.names) %>% 
  dplyr::select(SampleID, d13C, d15N) %>% 
  mutate(d13C = d13C + TDF.C,
         d15N = d15N + TDF.N)

# Set colors, line widths, shapes, and label names
cols <- c("ff_chicken" = "#C0362D",
          "wet.food"= "#F57E77",
          "rat"= "#B6CEE2",
          "medium.mammal" = "#284359",
          "skunk"= "#A3B5B3",
          "cat" = "#C1C4D7",
          "raccoon"= "#6A7C8B",
          "gopher"= "#004D40",
          "fruit"= "#59BBAA")

linewidth_vals <- c(
  "raccoon" = 0.2,
  "skunk" = 0.2,
  "cat" = 0.2,
  "gopher" = 0.5,
  "fruit" = 0.5,
  "rat" = 0.5,
  "wet.food" = 0.5,
  "ff_chicken" = 0.5,
  "medium.mammal" = 0.5)

shape_vals <- c(
  "raccoon" = 18,
  "skunk" = 18,
  "cat" = 18,
  "ff_chicken" = 16,
  "wet.food" = 16,
  "rat" = 16,
  "gopher" = 16,
  "fruit" = 16,
  "medium.mammal"= 16)


names <- c("Cat", "Human Food", "Fruit", "Gophers",  "Medium-Sized \nMammals", "Raccoons", "Rats", "Skunks", "Pet Food")

ggplot()+
  geom_errorbar(data=source_df_plotting, mapping=aes(x=Meand13C, y=Meand15N,
                                                     ymax=Meand15N+SDd15N, ymin=Meand15N-SDd15N,
                                                     width=0.3, color=species, linewidth=species,))+
  geom_errorbar(data=source_df_plotting, mapping=aes(x=Meand13C, y=Meand15N,
                                                     xmax=Meand13C+SDd13C, xmin=Meand13C-SDd13C,
                                                     width=0.3, color=species, linewidth=species))+
  geom_point(data=source_df_plotting, mapping=aes(x=Meand13C, y=Meand15N, color=species, shape=species),
             size=3)+
  
  # Meat samples
  geom_point(data=meat_samples, mapping=aes(x=d13C, y=d15N), alpha=0.9, fill="#C0362D", shape=23, color="black")+
  
  # Graphics
  theme_custom()+
  scale_y_continuous(limits=c(4,13), breaks = seq(4, 15, by = 1))+
  scale_x_continuous(limits=c(-25,-11.3), breaks = seq(-25, -10, by=1))+
  xlab(expression(delta^{13}~C)) +
  ylab(expression(delta^{15}~N))+
  theme(legend.position = "bottom", legend.title = element_blank(),
        legend.key.width = unit(0.5, "lines"), legend.key.height = unit(0.5, "lines"),
        legend.text = element_text(size = 6))+
  scale_color_manual(values=cols, labels=names)+
  scale_linewidth_manual(values = linewidth_vals, labels=names)+
  scale_shape_manual(values=shape_vals, labels=names)

# ggsave("Figures/FigureS1.png", dpi=600, height=3.5, width=4)

# MANOVA test to assess significance in difference among skunks, cats, and raccoons
iso_df <- prey %>%
  filter(species %in% c("skunk", "cat", "raccoon")) %>%
  select(species, d13C, d15N)

manova_res <- manova(cbind(d13C, d15N) ~ species, data = iso_df)
summary(manova_res, test = "Pillai")

