with npi_source as (

    select
          npi
        , entity_type_code
        , provider_last_name
        , provider_first_name
        , provider_organization_name
        , parent_organization_lbn
        , provider_first_line_business_practice_location_address
        , provider_second_line_business_practice_location_address
        , provider_business_practice_location_address_city_name
        , provider_business_practice_location_address_state_name
        , provider_business_practice_location_address_postal_code
    from {{ source('nppes', 'npi') }}

),

primary_taxonomy as (

    select
          npi
        , taxonomy_code
        , description
    from {{ ref('other_provider_taxonomy') }}
    where primary_flag = 1

)

select
      npi_source.npi
    , npi_source.entity_type_code
    , case
        when npi_source.entity_type_code = '1' then 'Individual'
        when npi_source.entity_type_code = '2' then 'Organization'
        end as entity_type_description
    , primary_taxonomy.taxonomy_code as primary_taxonomy_code
    , primary_taxonomy.description as primary_specialty_description
    , case
        when npi_source.entity_type_code = '1' then initcap(concat(npi_source.provider_last_name, ', ', npi_source.provider_first_name))
        when npi_source.entity_type_code = '2' then initcap(npi_source.provider_organization_name)
      end as provider_name
    , initcap(npi_source.parent_organization_lbn) as parent_organization_name
    , initcap(npi_source.provider_first_line_business_practice_location_address) as practice_address_line_1
    , initcap(npi_source.provider_second_line_business_practice_location_address) as practice_address_line_2
    , initcap(npi_source.provider_business_practice_location_address_city_name) as practice_city
    , npi_source.provider_business_practice_location_address_state_name as practice_state
    , npi_source.provider_business_practice_location_address_postal_code as practice_zip_code
from npi_source
     left join primary_taxonomy
     on npi_source.npi = primary_taxonomy.npi