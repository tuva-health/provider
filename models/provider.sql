select
      npi
    , entity_type_code
    , case
        when entity_type_code = '1' then 'Individual'
        when entity_type_code = '2' then 'Organization'
        end as entity_type_description
--     , primary_taxonomy_code
--     , primary_taxonomy_description
    , case
        when entity_type_code = '1' then initcap(concat(provider_last_name, ', ', provider_first_name))
        when entity_type_code = '2' then initcap(provider_organization_name)
      end as provider_name
    , initcap(parent_organization_lbn) as parent_organization_name
    , initcap(provider_first_line_business_practice_location_address) as practice_address_line_1
    , initcap(provider_second_line_business_practice_location_address) as practice_address_line_2
    , initcap(provider_business_practice_location_address_city_name) as practice_city
    , provider_business_practice_location_address_state_name as practice_state
    , provider_business_practice_location_address_postal_code as practice_zip_code
from {{ source('nppes', 'npi') }}