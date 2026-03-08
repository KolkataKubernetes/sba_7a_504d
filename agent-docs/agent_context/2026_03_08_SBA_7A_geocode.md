# Geocoding the Combined SBA 7A Data
- I'd like to geocode SBA 7(A) data, and return both a precise lat/long of the address and the 11 digit census tract associated with each address.
- We want both geographic features (lat long, census tract ID) to be saved for both borrower and lender addresses.

## Goals and Objectives
- The goal is to build a script that ingests the combined SBA 7(A) dataframe that was combined in the R script @1_code/1_0_ingest/SBA_7A_combine.R and uses the US Census Geocoder API to identify (a) the Lat Long associated with each borrower/lender address, (b) The 11 digit census tract associated with each borrower/lender address
- The 11 digit census tract should be appended as a feature to SBA7A_combined.rds, saved as "borrower_census_tract". We don't need the bank censsu tract information.
- The borrower lat and long should be similarly appended, and be saved in columns:
  - borrower_lat
  - borrower_long
  - bank_lat
  - bank_long
- Data should be saved as SBA7A_combined_geocoded.rds

## Data Sources
- @2_processed_data/SBA7A_combined.rds
- The US Census Geocoder API 
## Tasks to be completed
- Load SBA7A_combined.rds
- Build and populate a "complete address" column for each of the bank (address_bank)and borrower (address_borrower), which will be deleted before we re-save.
  - For bank, follow the following paste regime:
    - BankStreet + BorrCity + BankState + BankZip. Note that you'll need to unabbreviate BankState unless the Census docs say otherwise.
  - For borrower, follow the following paste regime:
    - BorrStreet + BorrCity + BorrState + BorrZip. Similarly, you may need to unabbreviate Borrower unless the Census docs say otherwise.
  - Complete address example: 2214 BANDYWOOD DR, NASHVILLE, Tennessee, 37215
- For each of address_bank, address_borrower, invoke the US Census Geocode API and return:
  - borrower_lat
  - borrower_long
  - bank_lat
  - bank_long
  - borrower_census_tract

## Target outputs
- Output should be saved in @2_processed_data/SBA7A_combined_geocoded.rds, which does not yet exist.


## General Guidance
- US Census Geocoder documentation can be found here: https://geocoding.geo.census.gov/geocoder/Geocoding_Services_API.html#_Toc220929672
- I value transparency and well commented code. I also prefer the use of tidyverse packages when writing code.
- The census tract ID should be 11 digits.
- Validation should include a check of how many successful address matches occured, seperately for borrower and banker.
- I have included a Census API Key in 0_inputs, stored in Markdown form.
