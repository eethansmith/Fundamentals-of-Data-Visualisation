# Read the CSV file into a dataframe
data <- read.csv("postcode_area_with_names.csv")

# Calculate the ratio columns
data$Population_to_Practitioners <- data$Population / data$Registered_Practitioners
data$Population_to_Surgeries <- data$Population / data$GP_Surgeries

# Reorder the columns
data <- data[, c("Postcode_Area", "Area_Name", "Population", 
                 "Registered_Patients", "Registered_Practitioners", 
                 "GP_Surgeries", "Population_to_Surgeries", 
                 "Population_to_Practitioners")]

# Save the updated dataframe to a new CSV file
write.csv(data, "population_by_postcode_ratios.csv", row.names = FALSE)

