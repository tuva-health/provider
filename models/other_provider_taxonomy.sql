with source as (

        select
              npi
            , healthcare_provider_taxonomy_code_1
            , healthcare_provider_primary_taxonomy_switch_1
            , healthcare_provider_taxonomy_code_2
            , healthcare_provider_primary_taxonomy_switch_2
            , healthcare_provider_taxonomy_code_3
            , healthcare_provider_primary_taxonomy_switch_3
            , healthcare_provider_taxonomy_code_4
            , healthcare_provider_primary_taxonomy_switch_4
            , healthcare_provider_taxonomy_code_5
            , healthcare_provider_primary_taxonomy_switch_5
            , healthcare_provider_taxonomy_code_6
            , healthcare_provider_primary_taxonomy_switch_6
            , healthcare_provider_taxonomy_code_7
            , healthcare_provider_primary_taxonomy_switch_7
            , healthcare_provider_taxonomy_code_8
            , healthcare_provider_primary_taxonomy_switch_8
            , healthcare_provider_taxonomy_code_9
            , healthcare_provider_primary_taxonomy_switch_9
            , healthcare_provider_taxonomy_code_10
            , healthcare_provider_primary_taxonomy_switch_10
            , healthcare_provider_taxonomy_code_11
            , healthcare_provider_primary_taxonomy_switch_11
            , healthcare_provider_taxonomy_code_12
            , healthcare_provider_primary_taxonomy_switch_12
            , healthcare_provider_taxonomy_code_13
            , healthcare_provider_primary_taxonomy_switch_13
            , healthcare_provider_taxonomy_code_14
            , healthcare_provider_primary_taxonomy_switch_14
            , healthcare_provider_taxonomy_code_15
            , healthcare_provider_primary_taxonomy_switch_15
        from {{ source('nppes', 'npi') }}

),

lookup as (

    select * from {{ source('nppes', 'nucc_taxonomy') }}

),

unpivot as (

    select *
    from source
    /* unpivot taxonomy code */
    unpivot(taxonomy_code for taxonomy_col in (   healthcare_provider_taxonomy_code_1
                                                , healthcare_provider_taxonomy_code_2
                                                , healthcare_provider_taxonomy_code_3
                                                , healthcare_provider_taxonomy_code_4
                                                , healthcare_provider_taxonomy_code_5
                                                , healthcare_provider_taxonomy_code_6
                                                , healthcare_provider_taxonomy_code_7
                                                , healthcare_provider_taxonomy_code_8
                                                , healthcare_provider_taxonomy_code_9
                                                , healthcare_provider_taxonomy_code_10
                                                , healthcare_provider_taxonomy_code_11
                                                , healthcare_provider_taxonomy_code_12
                                                , healthcare_provider_taxonomy_code_13
                                                , healthcare_provider_taxonomy_code_14
                                                , healthcare_provider_taxonomy_code_15
                                              )
    )
    /* unpivot primary indicator for each taxonomy */
    unpivot(taxonomy_switch for switch_col in (   healthcare_provider_primary_taxonomy_switch_1
                                                , healthcare_provider_primary_taxonomy_switch_2
                                                , healthcare_provider_primary_taxonomy_switch_3
                                                , healthcare_provider_primary_taxonomy_switch_4
                                                , healthcare_provider_primary_taxonomy_switch_5
                                                , healthcare_provider_primary_taxonomy_switch_6
                                                , healthcare_provider_primary_taxonomy_switch_7
                                                , healthcare_provider_primary_taxonomy_switch_8
                                                , healthcare_provider_primary_taxonomy_switch_9
                                                , healthcare_provider_primary_taxonomy_switch_10
                                                , healthcare_provider_primary_taxonomy_switch_11
                                                , healthcare_provider_primary_taxonomy_switch_12
                                                , healthcare_provider_primary_taxonomy_switch_13
                                                , healthcare_provider_primary_taxonomy_switch_14
                                                , healthcare_provider_primary_taxonomy_switch_15
                                              )
    )
    /* join each taxonomy with its primary indicator */
    where regexp_replace(taxonomy_col,'[^[:digit:]]','') = regexp_replace(switch_col,'[^[:digit:]]','')

),

/*
    some provider records do not indicate which taxonomy code is primary
    this logic uses row number and the placement of taxonomy codes 1-15 on
    the original nppes record to help determine this
*/
add_primary_row_num as (

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
    from unpivot

),

add_primary_flag as (

    select
          npi
        , taxonomy_code
        , case
            when primary_row_num = 1 then 1
            else 0
          end as primary_flag
    from add_primary_row_num

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
        ) as dedupe_row_num
    from add_primary_flag

),

add_description as (

    select
          dedupe.npi
        , dedupe.taxonomy_code
        , concat_ws(
              '/'
            , lookup.grouping
            , lookup.classification
            , lookup.specialization
          ) as taxonomy_description
        , lookup.grouping taxonomy_grouping
        , lookup.classification taxonomy_classification
        , lookup.specialization taxonomy_specialization
        , dedupe.primary_flag
    from dedupe
         left join lookup
         on dedupe.taxonomy_code = lookup.code
    where dedupe_row_num = 1

)

select * from add_description