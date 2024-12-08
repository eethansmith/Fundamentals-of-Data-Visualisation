library(httr)
library(jsonlite)
library(dplyr)


get_lat_long <- function(postcode) {
  # Construct the API URL
  base_url <- "https://api.postcodes.io/postcodes/"
  full_url <- paste0(base_url, URLencode(postcode))
  
  # Make the API request
  response <- GET(full_url)
  
  # Check if the request was successful
  if (status_code(response) == 200) {
    # Parse the JSON content
    data <- fromJSON(content(response, as = "text", encoding = "UTF-8"))
    lat <- data$result$latitude
    long <- data$result$longitude
    return(c(latitude = lat, longitude = long))
  } else {
    # Return NA if the request fails
    return(c(latitude = NA, longitude = NA))
  }
}

# Read the CSV file
file_path <- "gp_surgery_data.csv"
gp_data <- read.csv(file_path, stringsAsFactors = FALSE)

# Fetch latitude and longitude for each postcode
coordinates <- t(apply(gp_data, 1, function(row) get_lat_long(row["POSTCODE"])))

# Combine the coordinates with the original data
gp_data_with_coords <- cbind(gp_data, coordinates)

# Save the new CSV
output_file <- "gp_surgery_data_with_coords.csv"
write.csv(gp_data_with_coords, output_file, row.names = FALSE)
