# This code defines the variable message and assigns it the value "Hello, World!".
message <- "Hello, World!"
# This code prints the value of the variable message to the console.
print(message)

# Question Framed for my data:

# Question 1: Which GP Surgery that has the highest number of patients registered?

# Question 2: What is the area/disctrict with the highest number of registered GP Surgeries?

# Question 3: What sector has the best ratio of GPs to population?

# Question 4: How many surgeries have 10 or more GPs?

# Data Sources:

# UK population per postcode 2021-
#https://www.beta.ons.gov.uk/aboutus/transparencyandgovernance/freedomofinformationfoi/postcodelevelpopulationdatafromcensus2021
population_postcode <- read.csv("DataSources/uk-population-postcode-21.csv")

# Patient count at each GP Surgery in the UK December 2021-
# https://digital.nhs.uk/data-and-information/publications/statistical/patients-registered-at-a-gp-practice/december-2021#resources
patients_registered <- read.csv("DataSources/gp-surgery-patient-count-21.csv")

# GP Practitioners data-
# https://digital.nhs.uk/services/organisation-data-service/export-data-files/csv-downloads/gp-and-gp-practice-related-data
gp_practitioner <- read.csv("DataSources/gp-practitioner-data-21.csv")

# GP Surgery data-
# https://digital.nhs.uk/services/organisation-data-service/export-data-files/csv-downloads/gp-and-gp-practice-related-data
gp_surgery <- read.csv("DataSources/gp-surgery-data-21.csv")