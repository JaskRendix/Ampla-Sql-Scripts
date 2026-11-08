/*
    Item.Stopped.sql

    Lists items with a StartupMode property together with their item type.

    Run this query against the AmplaProject database.
*/

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
    FROM dbo.Items
    WHERE ParentID = '00000000-0000-0000-0000-000000000000'

    UNION ALL

    SELECT
        item.ID,
        CAST(cte.FullName + '.' + item.Name AS varchar(MAX)) AS FullName,
        item.TypeID,
        cte.Depth + 1 AS Depth
    FROM dbo.Items AS item
    INNER JOIN Item_CTE AS cte
        ON item.ParentID = cte.ID
)
SELECT
    cte.FullName AS [Stopped Items],
    ip.Value AS StartupMode,
    it.TypeFullName
FROM dbo.ItemProperties AS ip
INNER JOIN Item_CTE AS cte
    ON ip.ItemID = cte.ID
INNER JOIN dbo.ItemTypes AS it
    ON cte.TypeID = it.ID
WHERE ip.PropertyName = 'StartupMode'
ORDER BY
    cte.FullName;
