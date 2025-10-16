with taxonomy_unpivot as (

    select * from {{ ref('taxonomy_unpivot') }}

),

specialty_mapping as (

    select * from {{ ref('specialty_mapping') }}

),

/*
    some provider records do not indicate which taxonomy code is primary
    this logic uses row number and the placement of taxonomy codes 1-15 on
    the original nppes record to help determine this
*/
add_row_num as (

    select
          npi
        , taxonomy_code
        , row_number() over (
             partition by npi
             order by
                   case
                       when taxonomy_switch = 'Y' then 1
                       when taxonomy_switch = 'X' then 2
                       when taxonomy_switch = 'N' then 3
                   end
                 , taxonomy_col
         ) as primary_row_num
    from taxonomy_unpivot

),

add_primary_flag as (

    select
          npi
        , taxonomy_code
        , case
            when primary_row_num = 1 then 1
            else 0
          end as primary_flag
    from add_row_num

),

/* remove duplicates and prioritize ones with the primary flag */
dedupe as (

    select
          npi
        , taxonomy_code
        , primary_flag
        , row_number() over (
            partition by npi, taxonomy_code
            order by primary_flag desc
        ) as row_num
    from add_primary_flag

),

add_description as (

    select
          dedupe.npi
        , dedupe.taxonomy_code
        , specialty_mapping.medicare_specialty_code
        , specialty_mapping.description
        , dedupe.primary_flag
    from dedupe
         left join specialty_mapping
         on dedupe.taxonomy_code = specialty_mapping.taxonomy_code
    where dedupe.row_num = 1

)

select * from add_description