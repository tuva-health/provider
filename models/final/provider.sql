with npi_source as (

    select
          npi
        , entity_type_code
        , provider_last_name
        , provider_first_name
        , provider_credential_text
        , provider_organization_name
        , parent_organization_lbn
        , provider_first_line_business_practice_location_address
        , provider_second_line_business_practice_location_address
        , provider_business_practice_location_address_city_name
        , provider_business_practice_location_address_state_name
        , provider_business_practice_location_address_postal_code
        , provider_business_mailing_address_telephone_number
        , provider_business_practice_location_address_telephone_number
        , authorized_official_telephone_number
        , last_update_date
        , npi_deactivation_date
    from {{ source('nppes', 'npi') }}

)

, npi_othername as (

    select
          npi
        , provider_other_organization_name
        , provider_other_organization_name_type_code
        , case /* According to CMS NPPES Data Dissemination - Code Values pdf; these descriptions aren't available in the file used */
            when provider_other_organization_name_type_code = '1' then 'Former Name'
            when provider_other_organization_name_type_code = '2' then 'Professional Name'
            when provider_other_organization_name_type_code = '3' then 'Doing Business As'
            when provider_other_organization_name_type_code = '4' then 'Former Legal Business Name'
            when provider_other_organization_name_type_code = '5' then 'Other Name'
            else null
          end as provider_other_organization_name_type_description
    from {{ source('nppes', 'npi_othername') }}

)

, npi_othername_dedup as (

    select
          npi
        , provider_other_organization_name
        , provider_other_organization_name_type_code
        , provider_other_organization_name_type_description
    from npi_othername
    qualify
        row_number() over (
            partition by npi
            order by provider_other_organization_name_type_code
        ) = 1

)

, npi_expanded as (

    select
          npi_source.npi
        , npi_source.entity_type_code
        , npi_source.provider_last_name
        , npi_source.provider_first_name
        , npi_source.provider_credential_text
        , npi_source.provider_organization_name
        , npi_othername_dedup.provider_other_organization_name
        , npi_othername_dedup.provider_other_organization_name_type_code
        , npi_othername_dedup.provider_other_organization_name_type_description
        , npi_source.parent_organization_lbn
        , npi_source.provider_first_line_business_practice_location_address
        , npi_source.provider_second_line_business_practice_location_address
        , npi_source.provider_business_practice_location_address_city_name
        , npi_source.provider_business_practice_location_address_state_name
        , npi_source.provider_business_practice_location_address_postal_code
        , npi_source.provider_business_mailing_address_telephone_number
        , npi_source.provider_business_practice_location_address_telephone_number
        , npi_source.authorized_official_telephone_number
        , npi_source.last_update_date
        , npi_source.npi_deactivation_date
    from npi_source
    left join npi_othername_dedup
        on npi_source.npi = npi_othername_dedup.npi

)

, primary_taxonomy as (

    select
          npi
        , taxonomy_code
        , description
    from {{ ref('other_provider_taxonomy') }}
    where primary_flag = 1

)

select
      npi_expanded.npi
    , npi_expanded.entity_type_code
    , case
        when npi_expanded.entity_type_code = '1' then 'Individual'
        when npi_expanded.entity_type_code = '2' then 'Organization'
        end as entity_type_description
    , primary_taxonomy.taxonomy_code as primary_taxonomy_code
    , primary_taxonomy.description as primary_specialty_description
    , initcap(npi_expanded.provider_first_name) as provider_first_name
    , initcap(npi_expanded.provider_last_name) as provider_last_name
    , npi_expanded.provider_credential_text as provider_credential
    , initcap(npi_expanded.provider_organization_name) as provider_organization_name
    , initcap(npi_expanded.provider_other_organization_name) as provider_other_organization_name
    , npi_expanded.provider_other_organization_name_type_code as provider_other_organization_name_type_code
    , npi_expanded.provider_other_organization_name_type_description as provider_other_organization_name_type_description
    , initcap(npi_expanded.parent_organization_lbn) as parent_organization_name
    , initcap(npi_expanded.provider_first_line_business_practice_location_address) as practice_address_line_1
    , initcap(npi_expanded.provider_second_line_business_practice_location_address) as practice_address_line_2
    , initcap(npi_expanded.provider_business_practice_location_address_city_name) as practice_city
    , npi_expanded.provider_business_practice_location_address_state_name as practice_state
    , npi_expanded.provider_business_practice_location_address_postal_code as practice_zip_code
    , npi_expanded.provider_business_mailing_address_telephone_number as mailing_telephone_number
    , npi_expanded.provider_business_practice_location_address_telephone_number as location_telephone_number
    , npi_expanded.authorized_official_telephone_number as official_telephone_number
    , cast(last_update_date as date) as last_updated
    , cast(npi_deactivation_date as date) as deactivation_date
    , case
        when npi_deactivation_date is not null then 1
        else 0
      end as deactivation_flag
from npi_expanded
     left join primary_taxonomy
     on npi_expanded.npi = primary_taxonomy.npi
