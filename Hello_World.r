# This code defines the variable message and assigns it the value "Hello, World!".
message <- "Hello, World!"
# This code prints the value of the variable message to the console.
print(message)

# Question Framed for my data:

# Question 1: Which GP Surgery that has the highest number of patients registered?

# Question 2: What is the area/disctrict with the highest number of registered GP Surgeries?

# Question 3: What sector has the best ratio of GPs to population?

# Question 4: How many surgeries have 10 or more GPs?

library(dplyr)

# Data Sources:

# GP Surgery data-
# https://digital.nhs.uk/services/organisation-data-service/export-data-files/csv-downloads/gp-and-gp-practice-related-data
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

# -----------------------------------------------------------------------------------------------
# POPULATION DATA

# UK population per postcode 2021-
#https://www.beta.ons.gov.uk/aboutus/transparencyandgovernance/freedomofinformationfoi/postcodelevelpopulationdatafromcensus2021
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
    Count_GP_Surgeries = n(), # Count GP surgeries
    Total_Registered_Patients = sum(NUMBER_OF_PATIENTS, na.rm = TRUE),  # Sum patients
    Total_Registered_Practitioners = sum(NUMBER_OF_PRACTITIONERS, na.rm = TRUE),  # Sum practitioners
    .groups = "drop"
  )
# Merge with population data
final_data <- gp_surgery_stats %>%
  left_join(population_postcode, by = c("Postcode_District" = "Postcode.Districts")) %>%
  select(Postcode_District,Count,Total_Registered_Patients,Total_Registered_Practitioners,Count_GP_Surgeries) %>% 
  rename(Population = Count)

# Save the final dataset to a CSV file
write.csv(final_data, "postcode_districts_clean.csv", row.names = FALSE)

# -----------------------------------------------------------------------------------------------
# Postcode Area Calculation
# Load the GP Surgeries Per Postcode data
gp_surgeries_per_postcode <- read.csv("postcode_districts_clean.csv")  # Update file path

# Extract the letter prefix from the Postcode District
combined_data <- gp_surgeries_per_postcode %>%
  mutate(Letter_Area = gsub("[0-9]", "", Postcode_District)) %>%  # Remove numbers from Postcode_District
  group_by(Letter_Area) %>%
  summarise(
    Total_GP_Surgeries = sum(Count_GP_Surgeries, na.rm = TRUE),          # Sum surgeries
    Total_Registered_Patients = sum(Total_Registered_Patients, na.rm = TRUE),  # Sum patients
    Total_Registered_Practitioners = sum(Total_Registered_Practitioners, na.rm = TRUE),  # Sum practitioners
    Population = sum(Population, na.rm = TRUE),  # Sum population
    .groups = "drop"
  )

# Save the final dataset to a new CSV file
write.csv(combined_data, "postcode_area_clean.csv", row.names = FALSE)

# -----------------------------------------------------------------------------------------------
# Calculating desperaty as population recorded not completly accurate

# Load the dataset
gp_surgeries_per_postcode <- read.csv("postcode_area_clean.csv")  # Update file path

# Calculate the sum of Total Registered Patients and Total Population
totals <- gp_surgeries_per_postcode %>%
  summarise(
    Total_Registered_Patients = sum(Total_Registered_Patients, na.rm = TRUE),
    Total_Population = sum(Population, na.rm = TRUE)
  )

# View the results
print(totals)

# -----------------------------------------------------------------------------------------------
# Question 1: 
# Which GP Surgery that has the highest number of patients registered?
