/*
    Database.ShrinkFiles.sql

    Generates DBCC SHRINKFILE statements for all user databases.

    WARNING:
    Do not use in a production environment unless the impact has been
    reviewed and the operation is required.
*/

SELECT
    CONCAT(
        'USE ',
        QUOTENAME(d.name),
        CHAR(13),
        CHAR(10),
        'DBCC SHRINKFILE (N''',
        mf.name,
        ''', 0, TRUNCATEONLY)',
        CHAR(13),
        CHAR(10),
        CHAR(13),
        CHAR(10)
    ) AS [DBCC SHRINKFILE SQL]
FROM sys.master_files AS mf
INNER JOIN sys.databases AS d
    ON mf.database_id = d.database_id
WHERE
    d.database_id > 4
ORDER BY
    d.name,
    mf.name;
