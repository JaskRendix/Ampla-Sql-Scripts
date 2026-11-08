/* -------------------------------------------------------------------
    Determines the age of streams in the State database to assist in
    understanding streams that have stopped updating.

    Generates and executes a query that combines information from the
    configuration and state databases.

    Usage:
        Set @configDB to the configuration database.
        Set @stateDB_override to override the derived state database name.
----------------------------------------------------------------------*/

DECLARE @configDB sysname = N'AmplaProject';
DECLARE @stateDB_override sysname = NULL;

DECLARE @sql nvarchar(MAX);
DECLARE @stateDB sysname;

-- Uncomment to override the default state database.
-- SET @stateDB_override = N'MyStateDatabase';

SET @stateDB = COALESCE(@stateDB_override, @configDB + N'State');

SET @sql = N'
DECLARE @utcNow DATETIME = GETUTCDATE();

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
),
Stream_CTE
(
    StreamId,
    ItemId,
    PropertyName,
    StartTime,
    EndTime
)
AS
(
    SELECT
        StreamId,
        ItemId,
        PropertyName,
        ' + QUOTENAME(@stateDB) + N'.dbo.udfTicksToDateTime(StartTimeTicks) AS StartTime,
        ' + QUOTENAME(@stateDB) + N'.dbo.udfTicksToDateTime(EndTimeTicks) AS EndTime
    FROM ' + QUOTENAME(@stateDB) + N'.dbo.SampleStoreSampleStream
    WHERE StartTimeTicks IS NOT NULL
)

SELECT
    ss.StreamId,
    config.FullName,
    ss.PropertyName,
    DATEDIFF(DAY, ss.EndTime, @utcNow) AS AgeDays,
    DATEDIFF(HOUR, ss.EndTime, @utcNow) AS AgeHours,
    DATEDIFF(MINUTE, ss.EndTime, @utcNow) AS AgeMinutes,
    config.TypeFullName,
    ss.StartTime,
    ss.EndTime
FROM Stream_CTE AS ss
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
    ON config.ID = ss.ItemId
WHERE config.FullName IS NOT NULL
ORDER BY
    ss.EndTime ASC,
    config.FullName DESC,
    ss.PropertyName;
';

EXEC sys.sp_executesql @sql;
