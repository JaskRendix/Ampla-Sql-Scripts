/*
    Database.ReferencedObjects.sql

    Lists SQL object dependencies and the referenced objects
    used by database objects.
*/

SELECT
    src.object_id AS [Object.Id],
    src.name AS [Object.Name],
    src.type_desc AS [Object.Type],
    COALESCE(
        COL_NAME(dep.referencing_id, dep.referencing_minor_id),
        '(n/a)'
    ) AS [Object.Column],
    ref.object_id AS [Referenced.Id],
    ref.name AS [Referenced.Name],
    ref.type_desc AS [Referenced.Type],
    dep.*
FROM sys.sql_expression_dependencies AS dep
LEFT JOIN sys.objects AS src
    ON dep.referencing_id = src.object_id
LEFT JOIN sys.objects AS ref
    ON dep.referenced_id = ref.object_id
ORDER BY
    src.name,
    ref.name;
