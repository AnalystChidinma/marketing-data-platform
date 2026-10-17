{% macro generate_schema_name(custom_schema_name, node) -%}

    {# Use custom schemas in staging and production only #}

    {%- set default_schema = target.schema -%}

    {%- if custom_schema_name is none
        or target.name not in ['production', 'staging'] -%}

        {{ default_schema }}

    {%- else -%}

        {{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}