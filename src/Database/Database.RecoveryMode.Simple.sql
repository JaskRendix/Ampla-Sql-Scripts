/*
    Database.RecoveryMode.Simple.sql

    Lists databases using FULL recovery mode and generates
    ALTER DATABASE statements to switch them to SIMPLE recovery.

    Review the generated SQL before execution.
*/

SELECT
    name,
    recovery_model_desc,
    CONCAT(
        'ALTER DATABASE ',
        QUOTENAME(name),
        ' SET RECOVERY SIMPLE WITH NO_WAIT'
    ) AS [SQL]
FROM sys.databases
WHERE
    recovery_model_desc = 'FULL'
    AND name NOT IN
    (
        'master',
        'temp_db',
        'model',
        'msdb',
        'ReportServer'
    )
ORDER BY
    name;
