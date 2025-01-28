with medicare as (

    select * from {{ source('nppes', 'medicare_specialty_crosswalk') }}

),

nucc as (

    select * from {{ source('nppes', 'nucc_taxonomy') }}

),

/*
    adding row number to deduplicate medicare specialties
    ordering by medicare specialty code in descending order
    to prioritize the most specific specialty
*/
medicare_add_row_num as (

    select
          provider_taxonomy_code
        , provider_taxonomy_description
        , medicare_specialty_code
        , medicare_provider_supplier_type_description
        , row_number() over (
            partition by provider_taxonomy_code
            /* using try_cast since some codes are alphanumeric */
            order by try_cast(medicare_specialty_code as number) desc
        ) as row_num
    from medicare
    where provider_taxonomy_code is not null

),

medicare_dedupe as (

    select
          provider_taxonomy_code
        , medicare_specialty_code
        , medicare_provider_supplier_type_description
    from medicare_add_row_num
    where row_num = 1

),

/*
    joining medicare specialty and nucc taxonomy descriptions

    mapping specialty description logic:
    using cleaned medicare specialty type when available
    otherwise, nucc specialization or classification
*/
joined as (

    select
          nucc.code as taxonomy_code
        , medicare_dedupe.medicare_specialty_code
        , case
            when medicare_dedupe.provider_taxonomy_code is not null
              and medicare_dedupe.medicare_provider_supplier_type_description is not null
              then medicare_dedupe.medicare_provider_supplier_type_description
            else coalesce(nucc.specialization, nucc.classification)
          end as description
    from nucc
         left join medicare_dedupe
         on nucc.code = medicare_dedupe.provider_taxonomy_code

),

clean_description as (

    select 
          taxonomy_code
        , medicare_specialty_code
        , replace(                  
            regexp_replace(                     -- Remove content inside square brackets
                regexp_replace(                 -- Remove content inside parentheses
                    replace(                    -- Replace commas with slashes
                        replace(
                            description,
                            'Physician/', ''),
                        ',', '/'),
                    '\\s*\\([^\\)]*\\)', ''),
                '\\s*\\[[^\\]]*\\]', ''),
            '/ ', '/') AS description
    from joined

)

select * from clean_description
