[![Apache License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![dbt logo and version](https://img.shields.io/static/v1?logo=dbt&label=dbt-version&message=1.3.x&color=orange)

# Provider

## 🧰 What does this project do?

The Tuva Provider project combines and transforms messy public provider datasets into usable data.
This project contains the transformations we use to create the clean datasets for users of the Tuva Project. 
We have made this project public to share our methodology and code. 

You can easily load the cleaned provider data into your data warehouse by using the terminology seeds from [The Tuva Project package](https://github.com/tuva-health/the_tuva_project).

Source data dependencies:

| Data Set                                              | Updated by Source                | Source                                                                                         |
|-------------------------------------------------------|----------------------------------|------------------------------------------------------------------------------------------------|
| NPPES Data Dissemination                              | Monthly                          | https://download.cms.gov/nppes/NPI_Files.html                                                  |
| NUCC Health Care Provider Taxonomy                    | Semi-annually (January and July) | https://nucc.org/index.php/code-sets-mainmenu-41/provider-taxonomy-mainmenu-40/csv-mainmenu-57 |
| CMS Medicare Provider and Supplier Taxonomy Crosswalk | Annually                         | https://data.cms.gov/provider-characteristics/medicare-provider-supplier-enrollment/medicare-provider-and-supplier-taxonomy-crosswalk |


## 🔌 Database Support

- Snowflake

## ✅ How to get started

### Pre-requisites
1. You have [dbt](https://www.getdbt.com/) installed and configured (i.e. connected to your data warehouse). If you have not installed dbt, [here](https://docs.getdbt.com/dbt-cli/installation) are instructions for doing so.
2. You have created a database for the output of this project to be written in your data warehouse.
3. You have downloaded the source data and loaded it into a staging table your data warehouse.
   * NPPES NPI Data *(Note: source data comes zipped with many files, only the "npidata_pfile....csv" and "othername_pfile....csv" are required.*)
   * NUCC Health Care Provider Taxonomy
   * CMS Medicare Provider and Supplier Taxonomy Crosswalk

### Getting Started
Complete the following steps to configure the project to run in your environment.

1. [Clone](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) this repo to your local machine or environment.
2. Update the `dbt_project.yml` file:
   1. Add the dbt profile connected to your data warehouse.
   2. Update the variable `provider_database` to use the new database you created for this project, default is "nppes"..
3. Update the `models/_sources.yml` file:
   1. Update the database where your source data has been loaded, default is "nppes".
   2. Update the schema where your source data has been loaded, default is "raw_data".
   3. If the source tables are named differently then you can add the table [identifier](https://docs.getdbt.com/reference/resource-properties/identifier) property. 
4. Run `dbt build`.
5. For Tuva Terminology seeds, we export this data as CSV and then load it to the Tuva Public Resources bucket in Amazon S3.
   Here are some SQL examples for exporting the data from Snowflake:
   1. Standard Provider seed export:
      ```sql
      copy into --YOUR_S3_URL.../provider.csv
        from NPPES.CLAIMS_DATA_MODEL.PROVIDER
      file_format =  (type = csv field_optionally_enclosed_by = '"')
      storage_integration = --YOUR_INTEGRATION
      overwrite = true;
      ```
   2. Compressed Provider seed export:
      ```sql
      copy into --YOUR_S3_URL.../provider_compressed.csv.gz
        from NPPES.CLAIMS_DATA_MODEL.PROVIDER
      file_format = (
          type = csv
          field_optionally_enclosed_by = '"'
          compression = gzip
      )
      header = true
      max_file_size = 4900000000
      overwrite = true
      single = true
      storage_integration = --YOUR_INTEGRATION
      ```
   3. Standard Other Provider Taxonomy seed export:
      ```sql
      copy into --YOUR_S3_URL.../other_provider_taxonomy.csv
        from NPPES.CLAIMS_DATA_MODEL.OTHER_PROVIDER_TAXONOMY
      file_format =  (type = csv field_optionally_enclosed_by = '"')
      storage_integration = --YOUR_INTEGRATION
      overwrite = true;
      ```
   4. Compressed Other Provider Taxonomy seed export:
      ```sql
      copy into --YOUR_S3_URL.../other_provider_taxonomy_compressed.csv.gz
        from NPPES.CLAIMS_DATA_MODEL.PROVIDER
      file_format = (
          type = csv
          field_optionally_enclosed_by = '"'
          compression = gzip
      )
      header = true
      max_file_size = 4900000000
      overwrite = true
      single = true
      storage_integration = --YOUR_INTEGRATION
      ```

## 🙋🏻‍♀️ **How is this project maintained and can I contribute?**

### Project Maintenance

The Tuva Project team maintaining this project **only** maintains the latest version of the project. 
We highly recommend you stay consistent with the latest version.

### Contributions

Have an opinion on the mappings? Notice any bugs when installing and running the project?
If so, we highly encourage and welcome feedback!  While we work on a formal process in Github, we can be easily reached on our Slack community.

## 🤝 Community

Join our growing community of healthcare data practitioners on [Slack](https://join.slack.com/t/thetuvaproject/shared_invite/zt-16iz61187-G522Mc2WGA2mHF57e0il0Q)!
