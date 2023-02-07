{% test single_primary_taxonomy(model, column_name) %}

with validation as (

    select
          {{ column_name }} as npi
        , primary_flag
    from {{ model }}
    where primary_flag = 1

),

validation_errors as (

    select
          npi
        , primary_flag
    from validation
    group by npi, primary_flag
    having count(*) > 1

)

select *
from validation_errors

{% endtest %}