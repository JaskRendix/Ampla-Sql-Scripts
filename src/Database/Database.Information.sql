/*
    Database.Information.sql

    Displays database configuration and status information.
*/

SELECT
    name,
    database_id,
    compatibility_level,
    collation_name,
    is_auto_shrink_on,
    recovery_model_desc,
    is_auto_create_stats_on,
    is_auto_update_stats_on,
    is_auto_update_stats_async_on,
    is_fulltext_enabled,
    is_trustworthy_on,
    is_parameterization_forced
FROM sys.databases
ORDER BY
    name;
