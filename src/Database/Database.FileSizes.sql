/*
    Database.FileSizes.sql

    Reports database data and log file sizes together with
    available log file space.
*/

SELECT
    filesizes.*,
    [LogFileSize(KB)] - [LogFileUsedSize(KB)] AS [LogFileFreeSize(KB)],
    CASE
        WHEN [LogFileSize(KB)] = 0 THEN NULL
        ELSE
            100.0 *
            ([LogFileSize(KB)] - [LogFileUsedSize(KB)])
            / [LogFileSize(KB)]
    END AS [LogFileFreePercent]
FROM
(
    SELECT
        pc.instance_name AS InstanceName,
        SUM(
            CASE
                WHEN counter_name = 'Data File(s) Size (KB)'
                    THEN cntr_value
                ELSE 0
            END
        ) AS [DataFileSize(KB)],
        SUM(
            CASE
                WHEN counter_name = 'Log File(s) Size (KB)'
                    THEN cntr_value
                ELSE 0
            END
        ) AS [LogFileSize(KB)],
        SUM(
            CASE
                WHEN counter_name = 'Log File(s) Used Size (KB)'
                    THEN cntr_value
                ELSE 0
            END
        ) AS [LogFileUsedSize(KB)]
    FROM
    (
        SELECT
            object_name,
            counter_name,
            instance_name,
            cntr_value
        FROM sys.dm_os_performance_counters
        WHERE object_name LIKE '%SQL%Database%'
            -- Supports default and named instances.
    ) AS pc
    GROUP BY
        pc.instance_name
) AS filesizes
ORDER BY
    [DataFileSize(KB)] DESC,
    InstanceName;
