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

unpivot as (

    select *
    from source
    /* unpivot taxonomy code */
    unpivot(taxonomy_code for taxonomy in (   healthcare_provider_taxonomy_code_1
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
    unpivot(primary_flag for switch in (   healthcare_provider_primary_taxonomy_switch_1
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
    where regexp_replace(taxonomy,'[^[:digit:]]','') = regexp_replace(switch,'[^[:digit:]]','')

)

select
      npi
    , taxonomy_code
    , case
        when primary_flag = 'Y' then 1
        else 0
      end as primary_flag
from unpivot