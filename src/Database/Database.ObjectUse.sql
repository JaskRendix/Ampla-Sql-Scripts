/*
    Database.ObjectUse.sql

    Reports database objects referenced by other SQL objects and
    shows where those references occur.
*/

SELECT DISTINCT
    src.name AS [Source Name],
    src.type_desc AS [Source Type],
    ref.name AS [Found In],
    ref.type_desc AS [Found In Type],
    mod.definition AS [SQL Definition],
    CHARINDEX(src.name, mod.definition) AS [SQL Position]
FROM sys.objects AS src
INNER JOIN sys.sql_expression_dependencies AS dep
    ON src.object_id = dep.referenced_id
INNER JOIN sys.objects AS ref
    ON dep.referencing_id = ref.object_id
INNER JOIN sys.sql_modules AS mod
    ON ref.object_id = mod.object_id
ORDER BY
    ref.name,
    [SQL Position];
