/* -------------------------------------------------------------------
    Determines whether orphaned streams exist in the State database
    and generates SQL statements to remove them.

    Usage:
        Set @configDB to the configuration database.
        Optionally set @stateDB_override to override the derived
        state database name.
---------------------------------------------------------------------- */

DECLARE @configDB sysname = DB_NAME();
-- DECLARE @configDB sysname = N'AmplaProject';

DECLARE @stateDB_override sysname = NULL;

DECLARE @sql nvarchar(MAX);
DECLARE @stateDB sysname;

-- Uncomment to override the default state database.
-- SET @stateDB_override = N'MyStateDatabase';

SET @stateDB = COALESCE(@stateDB_override, @configDB + N'State');

IF NOT EXISTS
(
    SELECT 1
    FROM sys.databases
    WHERE name = @configDB
)
BEGIN
    PRINT '** ERROR - Unable to find Ampla Config Database: [' + @configDB + ']';
    RETURN;
END;

IF NOT EXISTS
(
    SELECT 1
    FROM sys.databases
    WHERE name = @stateDB
)
BEGIN
    PRINT '** ERROR - Unable to find Ampla State Database: [' + @stateDB + ']';
    RETURN;
END;

IF OBJECT_ID(@configDB + '.dbo.Items', 'U') IS NULL
BEGIN
    PRINT '** ERROR - [' + @configDB + '] is not a valid Ampla configuration database.';
    RETURN;
END;

IF OBJECT_ID(@stateDB + '.dbo.SampleStoreSample', 'U') IS NULL
BEGIN
    PRINT '** ERROR - [' + @stateDB + '] is not a valid Ampla state database.';
    RETURN;
END;

SET @sql = N'
SELECT
    streams.StreamId,
    streams.ItemId,
    streams.PropertyName,
    COALESCE(samples.SampleCount, 0) AS SampleCount,
    ' + QUOTENAME(@stateDB) + N'.dbo.udfTicksToDateTime(streams.StartTimeTicks) AS StartTime,
    ' + QUOTENAME(@stateDB) + N'.dbo.udfTicksToDateTime(streams.EndTimeTicks) AS EndTime,
    CASE
        WHEN COALESCE(samples.SampleCount, 0) > 0
        THEN
            ''DELETE FROM ' + QUOTENAME(@stateDB) + N'.dbo.SampleStoreSample WHERE StreamId=''
            + CONVERT(varchar(20), streams.StreamId)
            + CHAR(13)
        ELSE ''''
    END +
    ''DELETE FROM ' + QUOTENAME(@stateDB) + N'.dbo.SampleStoreSampleStream WHERE StreamId=''
    + CONVERT(varchar(20), streams.StreamId)
    AS [Delete SQL]
FROM ' + QUOTENAME(@stateDB) + N'.dbo.SampleStoreSampleStream AS streams
LEFT JOIN
(
    SELECT
        StreamId,
        COUNT(*) AS SampleCount
    FROM ' + QUOTENAME(@stateDB) + N'.dbo.SampleStoreSample
    GROUP BY StreamId
) AS samples
    ON streams.StreamId = samples.StreamId
WHERE NOT EXISTS
(
    SELECT 1
    FROM ' + QUOTENAME(@configDB) + N'.dbo.Items AS items
    WHERE items.Id = streams.ItemId
)
ORDER BY
    samples.SampleCount DESC,
    streams.PropertyName;
';

-- PRINT @sql;
EXEC sys.sp_executesql @sql;
