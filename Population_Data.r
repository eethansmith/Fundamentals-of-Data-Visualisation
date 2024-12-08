library(dplyr)

population_postcode <- read.csv("DataSources/uk-population-postcode-21.csv")

# Load GP Surgery data
gp_surgery <- read.csv("gp_surgery_data.csv")  # Update with your file path

# Extract postcode districts (first part of the postcode)
gp_surgery <- gp_surgery %>%
  mutate(Postcode_District = sub(" .*", "", POSTCODE))  # Extract first part of POSTCODE

# Group by postcode district to calculate statistics
gp_surgery_stats <- gp_surgery %>%
  group_by(Postcode_District) %>%
  summarise(
    GP_Surgeries = n(), # GP surgeries
    Registered_Patients = sum(NUMBER_OF_PATIENTS, na.rm = TRUE),  # Sum patients
    Registered_Practitioners = sum(NUMBER_OF_PRACTITIONERS, na.rm = TRUE),  # Sum practitioners
    .groups = "drop"
  )
# Merge with population data
final_data <- gp_surgery_stats %>%
  left_join(population_postcode, by = c("Postcode_District" = "Postcode.Districts")) %>%
  select(Postcode_District,Count,Registered_Patients,Registered_Practitioners,GP_Surgeries) %>% 
  rename(Population = Count)

# Save the final dataset to a CSV file
write.csv(final_data, "postcode_districts_clean.csv", row.names = FALSE)
#--------------------------------------------------------------------------------

# Load the main dataset
postcode_data <- read.csv("postcode_area_clean.csv", stringsAsFactors = FALSE)

# Load the reference dataset containing full area names
reference_data <- read.csv("DataSources/postcode_areas.csv", stringsAsFactors = FALSE)  # Update file path

# Join the datasets to match Postcode_Area with Primary_Area
# Ensure the column names match between the two datasets
postcode_data <- postcode_data %>%
  left_join(reference_data, by = c("Postcode_Area" = "Postcode_Area")) %>%
  mutate(Area_Name = Primary_Area)  # Add the Area_Name column

# Remove unnecessary columns if needed (e.g., Primary_Area, Extra_Info, Details from reference_data)
postcode_data <- postcode_data %>% select(-Primary_Area, -Extra_Info, -Details)

# Save the updated dataframe to a new CSV
write.csv(postcode_data, "postcode_area_with_names.csv", row.names = FALSE)

print("Updated dataset saved as 'postcode_area_with_names.csv'.")