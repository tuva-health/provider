with source as (

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
        , taxonomy_description
    from {{ ref('other_provider_taxonomy') }}
    where primary_flag = 1

)

select
      source.npi
    , source.entity_type_code
    , case
        when source.entity_type_code = '1' then 'Individual'
        when source.entity_type_code = '2' then 'Organization'
        end as entity_type_description
    , primary_taxonomy.taxonomy_code as primary_taxonomy_code
    , primary_taxonomy.taxonomy_description as primary_taxonomy_description
    , case
        when source.entity_type_code = '1' then initcap(concat(source.provider_last_name, ', ', source.provider_first_name))
        when source.entity_type_code = '2' then initcap(source.provider_organization_name)
      end as provider_name
    , initcap(source.parent_organization_lbn) as parent_organization_name
    , initcap(source.provider_first_line_business_practice_location_address) as practice_address_line_1
    , initcap(source.provider_second_line_business_practice_location_address) as practice_address_line_2
    , initcap(source.provider_business_practice_location_address_city_name) as practice_city
    , source.provider_business_practice_location_address_state_name as practice_state
    , source.provider_business_practice_location_address_postal_code as practice_zip_code
from source
     left join primary_taxonomy
     on source.npi = primary_taxonomy.npi
