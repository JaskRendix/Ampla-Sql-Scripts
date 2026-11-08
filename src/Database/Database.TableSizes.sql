/*
    Database.TableSizes.sql

    Reports row counts and space usage for user tables.
*/

SELECT
    t.name AS TableName,
    i.name AS IndexName,
    p.rows AS [Rows],
    SUM(a.total_pages) AS TotalPages,
    SUM(a.used_pages) AS UsedPages,
    SUM(a.data_pages) AS DataPages,
    (SUM(a.total_pages) * 8) / 1024 AS TotalSpaceMB,
    (SUM(a.used_pages) * 8) / 1024 AS UsedSpaceMB,
    (SUM(a.data_pages) * 8) / 1024 AS DataSpaceMB
FROM sys.tables AS t
INNER JOIN sys.indexes AS i
    ON t.object_id = i.object_id
INNER JOIN sys.partitions AS p
    ON i.object_id = p.object_id
    AND i.index_id = p.index_id
INNER JOIN sys.allocation_units AS a
    ON p.partition_id = a.container_id
WHERE
    t.name NOT LIKE 'dt%'
    AND i.object_id > 255
    AND i.index_id <= 1
GROUP BY
    t.name,
    i.object_id,
    i.index_id,
    i.name,
    p.rows
ORDER BY
    p.rows DESC,
    OBJECT_NAME(i.object_id);
