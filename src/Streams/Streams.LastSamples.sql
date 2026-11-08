/* -------------------------------------------------------------------
    Lists streams, last sample values, sample counts, and stream metadata
    by combining information from the Ampla configuration and state databases.

    Usage:
        Set @configDB to the configuration database.
        Set @stateDB_override to override the derived state database name.
---------------------------------------------------------------------- */

DECLARE @configDB sysname = N'AmplaProject';
DECLARE @stateDB_override sysname = NULL;

DECLARE @sql nvarchar(MAX);
DECLARE @stateDB sysname;

-- Uncomment to override the default state database.
-- SET @stateDB_override = N'MyStateDatabase';

SET @stateDB = COALESCE(@stateDB_override, @configDB + N'State');

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
),
SampleStats_CTE
(
    StreamId,
    LastSampleId,
    SampleCount
)
AS
(
    SELECT
        StreamId,
        MAX(SampleId) AS LastSampleId,
        COUNT(*) AS SampleCount
    FROM ' + QUOTENAME(@stateDB) + N'.dbo.SampleStoreSample
    GROUP BY StreamId
),
Samples_CTE
(
    SampleId,
    Value,
    QualityName,
    TimestampUtc
)
AS
(
    SELECT
         ss.SampleId,
         ss.Value,
         ssq.Value AS QualityName,
         ' + QUOTENAME(@stateDB) + N'.dbo.udfTicksToDateTime(ss.TimestampTicks) AS TimestampUtc
    FROM ' + QUOTENAME(@stateDB) + N'.dbo.SampleStoreSample AS ss
    INNER JOIN ' + QUOTENAME(@stateDB) + N'.dbo.SampleStoreQuality AS ssq
        ON ss.Quality = ssq.Code
),
Streams_CTE
(
    StreamId,
    ItemId,
    PropertyName,
    SampleType,
    EndTimeUtc
)
AS
(
    SELECT
        s.StreamId,
        s.ItemId,
        s.PropertyName,
        sst.Value
            + CASE
                  WHEN s.DuplicatesAllowed = 1
                      THEN '' (Duplicates)''
                  ELSE ''''
              END AS SampleType,
        ' + QUOTENAME(@stateDB) + N'.dbo.udfTicksToDateTime(s.EndTimeTicks) AS EndTimeUtc
    FROM ' + QUOTENAME(@stateDB) + N'.dbo.SampleStoreSampleStream AS s
    INNER JOIN ' + QUOTENAME(@stateDB) + N'.dbo.SampleStoreSampleTypeCode AS sst
        ON s.SampleTypeCode = sst.Code
)

SELECT
    items.FullName,
    s.PropertyName AS [Stream],
    s.SampleType,
    s.EndTimeUtc,
    COALESCE(ssts.SampleCount, 0) AS SampleCount,
    ss.Value AS [LastSample.Value],
    ss.TimestampUtc AS [LastSample.TimestampUtc],
    ss.QualityName AS [LastSample.Quality]
FROM Streams_CTE AS s
INNER JOIN Item_CTE AS items
    ON items.ID = s.ItemId
LEFT JOIN SampleStats_CTE AS ssts
    ON s.StreamId = ssts.StreamId
LEFT JOIN Samples_CTE AS ss
    ON ss.SampleId = ssts.LastSampleId
ORDER BY
    items.FullName;
';

-- PRINT @sql;
EXEC sys.sp_executesql @sql;
