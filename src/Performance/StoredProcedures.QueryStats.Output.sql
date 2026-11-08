DECLARE @lastMinutes int = 60;
DECLARE @dateTime datetime = DATEADD(MINUTE, -@lastMinutes, GETDATE());

-- Optional database filter. Leave NULL to include all databases.
DECLARE @dbName sysname = NULL;
-- SET @dbName = N'AmplaProjectState';

SELECT
    CONCAT(
        '---------------------------------', CHAR(13), CHAR(10),
        ' -- Database: ', COALESCE(DB_NAME(q.dbid), '<none>'), CHAR(13), CHAR(10),
        ' -- Object: ', COALESCE(OBJECT_NAME(q.objectid, q.dbid), '<none>'), CHAR(13), CHAR(10),
        ' -- Execution Count: ', CONVERT(varchar(30), qs.execution_count), CHAR(13), CHAR(10),
        ' -- Plan Generation: ', CONVERT(varchar(30), qs.plan_generation_num), CHAR(13), CHAR(10),
        ' -- Total Worker time: ', CONVERT(varchar(30), qs.total_worker_time), CHAR(13), CHAR(10),
        ' -- Total Physical Reads : ', CONVERT(varchar(30), qs.total_physical_reads), CHAR(13), CHAR(10),
        ' -- Total Logical Reads  : ', CONVERT(varchar(30), qs.total_logical_reads), CHAR(13), CHAR(10),
        ' -- Total Logical Writes : ', CONVERT(varchar(30), qs.total_logical_writes), CHAR(13), CHAR(10),
        ' -- Last Executed: ', CONVERT(varchar(23), qs.last_execution_time, 121), CHAR(13), CHAR(10),
        '---------------------------------', CHAR(13), CHAR(10),
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
        ),
        CHAR(13), CHAR(10), CHAR(13), CHAR(10)
    ) AS statement_text
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
