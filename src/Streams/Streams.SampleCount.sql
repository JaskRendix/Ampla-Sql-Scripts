/* -------------------------------------------------------------------
    Matches streams in the State database with items in the
    Ampla configuration database.

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

-- Uncomment to override the default State database.
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
WITH Item_CTE
(
    ID,
    FullName,
    TypeID,
    Depth
)
AS
(
    SELECT
        ID,
        CAST(Name AS varchar(MAX)) AS FullName,
        TypeID,
        1 AS Depth
    FROM ' + QUOTENAME(@configDB) + N'.dbo.Items
    WHERE ParentID = ''00000000-0000-0000-0000-000000000000''

    UNION ALL

    SELECT
        item.ID,
        CAST(cte.FullName + ''.'' + item.Name AS varchar(MAX)) AS FullName,
        item.TypeID,
        cte.Depth + 1
    FROM ' + QUOTENAME(@configDB) + N'.dbo.Items AS item
    INNER JOIN Item_CTE AS cte
        ON item.ParentID = cte.ID
)

SELECT
    streams.StreamId,
    config.FullName,
    streams.PropertyName,
    config.TypeFullName,
    samples.SampleCount,
    (
        100.0 * samples.SampleCount
        / NULLIF(summary.TotalCount, 0)
    ) AS Percentage,
    ' + QUOTENAME(@stateDB) + N'.dbo.udfTicksToDateTime(streams.StartTimeTicks) AS StartTime,
    ' + QUOTENAME(@stateDB) + N'.dbo.udfTicksToDateTime(streams.EndTimeTicks) AS EndTime
FROM
(
    SELECT COUNT(*) AS TotalCount
    FROM ' + QUOTENAME(@stateDB) + N'.dbo.SampleStoreSample
) AS summary
CROSS JOIN
    ' + QUOTENAME(@stateDB) + N'.dbo.SampleStoreSampleStream AS streams
LEFT JOIN
(
    SELECT
        StreamId,
        COUNT(*) AS SampleCount
    FROM ' + QUOTENAME(@stateDB) + N'.dbo.SampleStoreSample
    GROUP BY StreamId
) AS samples
    ON streams.StreamId = samples.StreamId
LEFT JOIN
(
    SELECT
        items.ID,
        items.FullName,
        items.Depth,
        types.TypeFullName
    FROM Item_CTE AS items
    INNER JOIN ' + QUOTENAME(@configDB) + N'.dbo.ItemTypes AS types
        ON items.TypeID = types.ID
) AS config
    ON config.ID = streams.ItemId
ORDER BY
    samples.SampleCount DESC,
    config.FullName DESC;
';

-- PRINT @sql;
EXEC sys.sp_executesql @sql;
