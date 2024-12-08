# Data Description
In the following section, I will detail which data I selected to visualise to provide analysis on this topic. With the following data, I will process, clean, and prepare it for visualisation using R.

## [NHS UK GP Surgery Data](https://digital.nhs.uk/services/organisation-data-service/export-data-files/csv-downloads/gp-and-gp-practice-related-data)
The structure of the NHS provided surgery data included 16,402 entries of surgeries across the whole of the United Kingdom. The columns were extensive and mostly unnecessary for the visualisation process, making the task of cleaning this data essential. The following is an extract of the original data in CSV.

![Screenshot extract from the NHS UK GP Surgery Data](${await FileAttachment("Screenshot 2024-12-06 at 13.20.08.png").url()})

As you can see from these columns, they are mostly irrelevant for the visualisations I plan. Although this data as a whole was far from useless, essential columns included: "Organisation_Code", "Name", and "Postcode".

## [NHS UK Registered Practitioner Data](https://digital.nhs.uk/services/organisation-data-service/export-data-files/csv-downloads/gp-and-gp-practice-related-data)
Utilising the practitioner data was essential to answer the questions I had for healthcare service distribution across England. The data included every employed practitioner for the National Health Service during 2021, which was 118,662 practitioners. Similar to the previous dataset, this was very extensive and included full names, full addresses of practices, and even date of surgery open. All this information was too granular for my visualisation. 

![Screenshot extract of NHS UK Registered Practitioners](${await FileAttachment("Untitled.jpg").url()})

The above extract demonstrates the granular detail provided within the dataset. The value for my project was the column "Organisation Code", this correlated directly to the GP Surgeries in the dataset above, which, after processing would produce a count of the number of registered practitioners at each surgery.

## [NHS England Registered Patient Data](https://digital.nhs.uk/data-and-information/publications/statistical/patients-registered-at-a-gp-practice)
The data provided by NHS England on the number of registered patients at each surgery was more concise. Unlike the practitioner data, the only column with surgery identifiable information was "ONS_CCG_CODE", which with the use of the documentation correlated to the Organisation Code seen previously. As this data only looked at England based surgeries, the number of rows of data is 6,535.

![Screenshot extract of NHS Registered Patient Count](${await FileAttachment("Screenshot 2024-12-06 at 13.59.09.png").url()})

The screenshot above is an extract of the data in the registered patient count. This demonstrates the columns that are within this dataset and highlights the data that is essential and which data is not needed.  

## [Office for National Statistics - UK Distrcit Population Census 2021](https://www.beta.ons.gov.uk/aboutus/transparencyandgovernance/freedomofinformationfoi/postcodelevelpopulationdatafromcensus2021)
In order to get accurate population comparison to the surgeries in postcode areas I needed to use the Office for National Statistics' postcode district population data. This looks at a more granular level of population distribution. In the UK a postcode is identified by area (NG, WD, B, etc.) then narrowing down the area further is the district (NG7, NG8, etc).

![Screenshot National Statistics UK District Population](${await FileAttachment("Screenshot 2024-12-06 at 17.18.00.png").url()})

The screenshot extract above is the Office for National Statistics- Population Census by UK Districts 2021. Unfortunately, I found that this data was limited and lacked essential detail about the districts. So to get more information I had to resort using a secondary dataset for more information on area names. Listing every district in the United Kingdom had a result of 2,302 rows.

## [Wikipedia - UK Postcode Area Names with Area Codes](https://en.wikipedia.org/wiki/List_of_postcode_areas_in_the_United_Kingdom)
Finally, the dataset extracted from the Wikipedia page for UK Postcode Area Names allowed the processing of the full postcode information also providing an obvious choice for how to segment areas in the mapping process used in the data visualisation. 

![Screenshot of Wikipedia Postcode Area data](${await FileAttachment("Screenshot 2024-12-06 at 17.16.48.png").url()})

This data is great for specific questions regarding comparison of areas within the data. A key part of visualising this data will be interaction. By only revealing certain details upon user interaction, the data becomes more valuable and avoids overwhelming the user.

# Data Processing in R
In the following section, I will discuss the process I took to clean and formulate the extensive NHS data in preperation for my visualisation. The language I am using to process the data is R.

With a clear plan, my aim was to produce two CSV files encapsulating all necessary information extracted from the extensive data. My focus was on not processing any data I would later leave unused. With one CSV file to have the statistics on an area basis, looking at population, practitioner count, and registered patients for each. With the second to be looking at all of the surgery data, patient count, practitioners, and address for each location.

## Surgery Data Processing
With the code below we are looking at the initiation of the clean dataset for individual surgeries, this data looks at calculating the total practitioners registered to each surgery by counting the occurrences of Organisation Code within the Practitioner registered GP Surgery column. Also we see the merge of the registered patient count with the clean data set to have all surgery data in one place.
```r 
library(dplyr)

# Load GP Surgery data
gp_surgery <- read.csv("DataSources/uk-gp-surgery-data-21.csv")

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

# Save the final dataset to a CSV file without row names
write.csv(merged_data, "gp_surgery_data.csv", row.names = FALSE)
```

The outcome of the code above, produces the following cleaned data file of gp surgeries across the UK:
![Screenshot extract of processed Surgery data using R](${await FileAttachment("Screenshot 2024-12-06 at 20.51.40.png").url()})

## Surgery Data - Postcode to Longitude and Latitude Co-Ordinates
In order to plot all the NHS GP surgeries using the postcode data I needed to find a way to correlate the location with the map data. With a lot of research I discovered the [postcodes.io API](https://postcodes.io) this allowed me to input the postcodes provided by the NHS data and produce the columns of Longitude and Latitude. Perfectly situated for the visualisation implementation.

```r
library(httr)
library(jsonlite)

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
  } 
}
# Fetch latitude and longitude for each postcode
coordinates <- t(apply(gp_data, 1, function(row) get_lat_long(row["POSTCODE"])))
```

With the R processing above, the attached dataset gp_surgery_data highlights how this looks in a CSV format ready for data visualisation of GP Surgeries.
![Screenshot extract of processed Surgery data using R](${await FileAttachment("Screenshot 2024-12-06 at 20.51.40.png").url()})

## Population by Postcode Data Processing
Now, we are looking at processing the healthcare data on a larger scale. My aim is to produce comprehensive statistics for each postcode area, including the total number of registered practitioners per area, registered patients, and population for postcode locations.

```r
population_postcode <- read.csv("DataSources/uk-population-postcode-21.csv")
gp_surgery <- read.csv("gp_surgery_data.csv") 

# Extract postcode areas (first part of the postcode)
gp_surgery <- gp_surgery %>%
  mutate(Postcode_Areas = sub(" .*", "", POSTCODE))  # Extract first part of POSTCODE

# Group by postcode district to calculate statistics
gp_surgery_stats <- gp_surgery %>%
  group_by(Postcode_Areas) %>%
  summarise(
    GP_Surgeries = n(), # GP surgeries
    Registered_Patients = sum(NUMBER_OF_PATIENTS, na.rm = TRUE),  # Sum patients
    Registered_Practitioners = sum(NUMBER_OF_PRACTITIONERS, na.rm = TRUE),  # Sum practitioners
    .groups = "drop"
  )
```

The data processing snippet above removes the postcode district data and areas with additional name column. Output seen below:
![Screenshot extract of postcode areas with additional name column](${await FileAttachment("Screenshot 2024-12-06 at 22.37.28.png").url()})

This cleaned data is alot more usable for my data visualisation and makes mapping streamlined without the need to process further with JavaScript.

## Population by Postcode Areas - Calculate Ratios
In the following code I wanted to pre-calculate certain metrics to minimise processing needed on the JavaScript side during visualisation. Making the addition of the following two columns for postcode area data ratios, these look at the ratio of Population to Practitioners and the ratio of Population to Surgeries in each area.

```r
# Calculate the ratio columns
data$Population_to_Practitioners <- data$Population / data$Registered_Practitioners
data$Population_to_Surgeries <- data$Population / data$GP_Surgeries
```
In this code we can see the simple calculation of the ratios being processed and then going on to be added to the clean data. The following is the final outcome, an attachment of the population_by_area.csv as defined above displaying the entire dataset ready for use in the visualisation.
![Screenshot extract of postcode areas with additional name column](${await FileAttachment("Screenshot 2024-12-06 at 22.37.28.png").url()})
