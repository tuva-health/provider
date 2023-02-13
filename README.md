[![Apache License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![dbt logo and version](https://img.shields.io/static/v1?logo=dbt&label=dbt-version&message=1.3.x&color=orange)

# Provider

## 🧰 What does this project do?

The Tuva Provider project combines and transforms messy public provider datasets into usable data.
This project contains the transformations we use to create the clean datasets for users of the Tuva Project. 
We have made this project public to share our methodology and code. 

You can easily load the cleaned provider data into your data warehouse by using [Tuva Terminology package](https://github.com/tuva-health/terminology).

## 🔌 Database Support

- Snowflake

## ✅ How to get started

### Pre-requisites
1. You have [dbt](https://www.getdbt.com/) installed and configured (i.e. connected to your data warehouse). If you have not installed dbt, [here](https://docs.getdbt.com/dbt-cli/installation) are instructions for doing so.
2. You have created a database for the output of this project to be written in your data warehouse.
3. You have downloaded the source data and loaded it into your data warehouse.
   * NPI Data from [NPPES](https://download.cms.gov/nppes/NPI_Files.html)
   * Provider Taxonomy from [NUCC](https://nucc.org/index.php/code-sets-mainmenu-41/provider-taxonomy-mainmenu-40/csv-mainmenu-57)
   * Medicare Specialty Crosswalk from [CMS](https://data.cms.gov/provider-characteristics/medicare-provider-supplier-enrollment/medicare-provider-and-supplier-taxonomy-crosswalk)

### Getting Started
Complete the following steps to configure the project to run in your environment.

1. [Clone](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) this repo to your local machine or environment.
2. Update the `dbt_project.yml` file:
   1. Add the dbt profile connected to your data warehouse.
   2. Update the variable `provider_database` to use the new database you created for this project.
3. Update the `models/_sources.yml` file:
   1. Update the database where your source data has been loaded.
   2. Update the schema where your source data has been loaded.
   3. If the source tables are named differently then you can add the table [identifier](https://docs.getdbt.com/reference/resource-properties/identifier) property. 
4. Run `dbt build` to run the entire project with the built-in sample data.

## 🙋🏻‍♀️ **How is this project maintained and can I contribute?**

### Project Maintenance

The Tuva Project team maintaining this project **only** maintains the latest version of the project. 
We highly recommend you stay consistent with the latest version.

### Contributions

Have an opinion on the mappings? Notice any bugs when installing and running the project?
If so, we highly encourage and welcome feedback!  While we work on a formal process in Github, we can be easily reached on our Slack community.

## 🤝 Community

Join our growing community of healthcare data practitioners on [Slack](https://join.slack.com/t/thetuvaproject/shared_invite/zt-16iz61187-G522Mc2WGA2mHF57e0il0Q)!
