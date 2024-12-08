library(dplyr)

# Load GP Surgery data
gp_surgery <- read.csv("DataSources/gp-surgery-data-21.csv")

# Extract columns "Organisation_Code" and "Name"
gp_surgery_clean <- gp_surgery %>%
  select(`Organisation_Code`, Name)

# Load GP Practitioners data
gp_practitioner <- read.csv("DataSources/gp-practitioner-data-21.csv")

# Count practitioners by Parent Organisation Code
practitioner_counts <- gp_practitioner %>%
  group_by(Parent_Organisation_Code) %>%
  summarise(Number_of_Practitioners = n(), .groups = "drop")

# Load Patient Count data
patients_registered <- read.csv("DataSources/gp-surgery-patient-count-21.csv")

# Clean and select necessary columns
clean_data <- patients_registered %>%
  select(CODE, POSTCODE, NUMBER_OF_PATIENTS) %>%
  distinct()

# Merge clean data with GP Surgery data
merged_data <- clean_data %>%
  left_join(gp_surgery_clean, by = c("CODE" = "Organisation_Code"))

# Merge practitioner counts into merged data
merged_data <- merged_data %>%
  left_join(practitioner_counts, by = c("CODE" = "Parent_Organisation_Code"))

# Reorder columns and rename `Name` to `NAME`
merged_data <- merged_data %>%
  rename(NAME = Name) %>%
  select(CODE, NAME, POSTCODE, Number_of_Practitioners, NUMBER_OF_PATIENTS) %>%  # Reorder columns
  rename(NUMBER_OF_PRACTITIONERS = Number_of_Practitioners)

# Check structure and content of merged_data
str(merged_data)
head(merged_data)
summary(merged_data)

# Save the final dataset to a CSV file without row names
write.csv(merged_data, "gp_surgery_data.csv", row.names = FALSE)