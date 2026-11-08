DECLARE @lastMinutes int = 60; -- Only look back this many minutes
DECLARE @dateTime datetime = DATEADD(MINUTE, -@lastMinutes, GETDATE());

-- Defaults to the current database.
-- Set to NULL to include all databases, or specify another database name.
DECLARE @dbName sysname = DB_NAME();
-- SET @dbName = N'AmplaProjectState';
-- SET @dbName = NULL;

SELECT
    SUBSTRING(
        q.text,
        (qs.statement_start_offset / 2) + 1,
        (
            (
                CASE qs.statement_end_offset
                    WHEN -1 THEN DATALENGTH(q.text)
                    ELSE qs.statement_end_offset
                END - qs.statement_start_offset
            ) / 2
        ) + 1
    ) AS statement_text,
    DB_NAME(q.dbid) AS [database],
    OBJECT_NAME(q.objectid, q.dbid) AS [objectname],
    qs.execution_count,
    qs.plan_generation_num,
    qs.total_worker_time,
    qs.total_physical_reads,
    qs.total_logical_writes,
    qs.total_logical_reads,
    qs.last_execution_time
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS q
WHERE
    qs.last_execution_time >= @dateTime
    AND (
        @dbName IS NULL
        OR DB_NAME(q.dbid) = @dbName
    )
ORDER BY
    qs.total_logical_reads DESC,
    qs.last_execution_time DESC;
