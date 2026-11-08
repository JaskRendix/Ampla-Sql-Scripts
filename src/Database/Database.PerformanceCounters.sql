/*
    Database.PerformanceCounters.sql

    Lists SQL Server performance counters and their meanings.
*/

SELECT
    object_name,
    counter_name,
    instance_name,
    cntr_value,
    CASE cntr_type
        WHEN 65792 THEN 'Absolute Meaning'
        WHEN 65536 THEN 'Absolute Meaning'
        WHEN 272696576 THEN 'Per Second counter and is cumulative in nature'
        WHEN 1073874176 THEN 'Bulk counter. Divide by the corresponding base counter to obtain the correct value'
        WHEN 537003264 THEN 'Bulk counter. Divide by the corresponding base counter to obtain the correct value'
    END AS counter_comments
FROM sys.dm_os_performance_counters
WHERE cntr_type NOT IN (1073939712)
ORDER BY
    object_name,
    counter_name,
    instance_name;
