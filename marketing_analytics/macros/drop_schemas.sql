
{% macro drop_schemas(dry_run=true, pr_number=none) %}

    {% if target.name != 'ci' %}
        {{ exceptions.raise_compiler_error(
            "Schema cleanup is only permitted for the ci target"
        ) }}
    {% endif %}

    {% if target.database != 'ci_development' %}
        {{ exceptions.raise_compiler_error(
            "Schema cleanup is only permitted in ci_development"
        ) }}
    {% endif %}

    {% if pr_number is none %}
        {{ exceptions.raise_compiler_error(
            "A pull request number is required"
        ) }}
    {% endif %}

    {% set pr = pr_number | string %}
    {% set expected_schema = 'pr_' ~ pr %}

    {% if pr | int <= 0 or (pr | int | string) != pr %}
        {{ exceptions.raise_compiler_error(
            "Invalid pull request number"
        ) }}
    {% endif %}

    {% if target.schema != expected_schema %}
        {{ exceptions.raise_compiler_error(
            "Target schema must exactly match " ~ expected_schema
        ) }}
    {% endif %}

    {{ log(
        "CI schema cleanup: catalog=" ~ target.database
        ~ ", schema=" ~ target.schema
        ~ ", dry_run=" ~ dry_run,
        info=true
    ) }}

    {{ return(adapter.dispatch('drop_schemas', 'marketing_analytics')(dry_run)) }}

{% endmacro %}


{% macro databricks__drop_schemas(dry_run=true) %}

    {% set schema_relation %}
        {{ adapter.quote(target.database) }}.{{ adapter.quote(target.schema) }}
    {% endset %}

    {% set drop_schema_sql %}
        DROP SCHEMA IF EXISTS {{ schema_relation | trim }} CASCADE
    {% endset %}

    {% if dry_run %}
        {{ log(
            "DRY RUN ONLY: " ~ drop_schema_sql | trim,
            info=true
        ) }}
    {% else %}
        {{ log(
            "Executing: " ~ drop_schema_sql | trim,
            info=true
        ) }}

        {% if execute %}
            {% do run_query(drop_schema_sql) %}
        {% endif %}
    {% endif %}

{% endmacro %}
