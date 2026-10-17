-- Keep this macro in the project's macros directory.
-- Controls Unity Catalog routing across environments.

{% macro generate_database_name(custom_database_name=none, node=none) -%}

    {# Use custom catalogs in staging and production only #}

    {%- set default_database = target.database -%}

    {%- if custom_database_name is none
        or target.name not in ['production', 'staging'] -%}

        {{ default_database }}

    {%- else -%}

        {{ custom_database_name | trim }}

    {%- endif -%}

{%- endmacro %}