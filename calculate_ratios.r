# Read the CSV file into a dataframe
data <- read.csv("population_by_postcode.csv")

# Calculate the ratio columns
data$Population_to_Practitioners <- data$Population / data$Registered_Practitioners
data$Population_to_Surgeries <- data$Population / data$GP_Surgeries

# Save the updated dataframe to a new CSV file (optional)
write.csv(data, "updated_population_by_postcode.csv", row.names = FALSE)

# View the updated dataframe
print(data)
