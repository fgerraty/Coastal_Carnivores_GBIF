##########################################################################
# Coastal Carnivores Project #############################################
# Author: Frankie Gerraty (frankiegerraty@gmail.com; fgerraty@ucsc.edu) ##
##########################################################################
# Script 01: Import and Process Data #####################################
#-------------------------------------------------------------------------


#######################################
# PART 1: Read in GSHHG shapefile #####
#######################################

# Define the path to the shapefile. Note that we are using f (full resolution) and level 1 (all coasts except antarctica). Be sure to check to make sure your file path is the same as mine, listed below, or adjust the code accordingly. 
shapefile_path <- "data/shapefile/GSHHS_shp/f/GSHHS_f_L1.shp" 

# Read the shapefile
gshhg <- st_read(shapefile_path)

#Repair the shapefile
shoreline <- st_make_valid(gshhg)


#sf_use_s2(TRUE)  # Disable s2 processing

# Convert to a projected CRS (Web Mercator, EPSG:3857)
shoreline_proj <- st_transform(shoreline, crs = 3857)

# Apply the buffer in meters
shoreline_buffer_proj <- st_buffer(shoreline_proj, dist = 10)

# Convert back to WGS 84
shoreline_buffer <- st_transform(shoreline_buffer_proj, crs = 4326)



#######################################
# PART 2: Import GBIF Data ############
#######################################

# Search for the taxonomic key of Carnivora
carnivora_key <- name_backbone(name = "Carnivora")$usageKey
print(carnivora_key)  # It is 732


# Download occurrence data for Carnivora. Note this is just for testing. Use occ_download for final version. 
carnivora_data <- occ_search(
  hasCoordinate=TRUE,
  taxonKey = carnivora_key,
  limit = 10000  # Number of records to download (testing)
  )


# Extract relevant columns
carnivora_df <- carnivora_data$data %>%
  select(scientificName, species, acceptedScientificName, decimalLatitude, decimalLongitude, country, eventDate) #Look more at these later!


# Convert to sf object
carnivora_sf <- st_as_sf(carnivora_df, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)

# Convert GBIF points to a projected CRS (same as shoreline)
carnivora_proj <- st_transform(carnivora_sf, crs = 3857)

# Perform the spatial join using a projected CRS
carnivora_near_shore <- st_join(carnivora_proj, shoreline_buffer_proj, join = st_intersects) #%>% 
  filter(!is.na(level)) 

# Convert back to WGS 84 if needed
carnivora_near_shore <- st_transform(carnivora_near_shore, crs = 4326)





#Filter for records on shoreline ######




# Spatial join to filter GBIF points within 10m of the shoreline
carnivora_near_shore <- st_join(carnivora_sf, shoreline_buffer, join = st_intersects)

# Remove NA values (i.e., keep only points within the buffer)
carnivora_near_shore <- carnivora_near_shore %>% filter(!is.na(level))  # 'level' is a column from GSHHG

# View result
print(carnivora_near_shore)


#Note: Filter didn't work, need to mess around with l8r

ggplot() +
 # geom_sf(data = shoreline, color = "blue") +
  geom_sf(data = carnivora_near_shore, aes(color = species), alpha = 0.7) +
  theme_minimal()+
  theme(legend.position = "none")
