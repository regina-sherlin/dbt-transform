{% macro clean_string(column_name, default_value='NULL') %}
    case 
        when upper(trim({{column_name}})) in ('UNKNOWN', 'ERROR','N/A','NA','NULL','NONE','-','') then NULL
        else trim({{column_name}})
    end
{% endmacro %}