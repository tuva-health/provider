![dbt logo and version](https://img.shields.io/static/v1?logo=dbt&label=dbt-version&message=1.3.x&color=orange)

# Generate Provider Data

## What does this project do?

This is an internal dbt project for generating the provider datasets.

## Pre-requisites
  * The monthly NPI Data file has been downloaded/unzipped from [CMS](https://download.cms.gov/nppes/NPI_Files.html)
    and loaded into the NPPES database in Snowflake.
  * The semi-annual Taxonomy file has been downloaded from [NUCC](https://nucc.org/index.php/code-sets-mainmenu-41/provider-taxonomy-mainmenu-40/csv-mainmenu-57) 
    and loaded into the NPPES database in Snowflake.
  * The annual Medicare Specialty Crosswalk has been downloaded from [CMS](https://data.cms.gov/provider-characteristics/medicare-provider-supplier-enrollment/medicare-provider-and-supplier-taxonomy-crosswalk)
    and loaded into the NPPES database in Snowflake.

*See _sources.yml for expected locations of source data.*

## Steps to Refresh the Data in Snowflake
1. Clone this repo.
2. Update the `dbt_project.yml` file:
   1. Add the dbt profile connected to the Tuva Snowflake data warehouse. 
      *(This project is only intended to be ran in our development data warehouse Snowflake.)*
   2. Update the variable `provider_database` to run this in your own dev database; otherwise, leave the default.
3. Run `dbt build` to run the entire project in Snowflake.
