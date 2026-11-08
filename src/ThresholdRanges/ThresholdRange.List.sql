/*
    Lists Threshold Range items from the Ampla Project configuration.

    Threshold Range items are identified by the item type:
        Citect.Ampla.General.Server.ThresholdRange

    Run this query against the AmplaProject database.
*/

WITH ItemHierarchy
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
    FROM Items
    WHERE ParentID = '00000000-0000-0000-0000-000000000000'

    UNION ALL

    SELECT
        item.ID,
        CAST(cte.FullName + '.' + item.Name AS varchar(MAX)),
        item.TypeID,
        cte.Depth + 1
    FROM Items AS item
    INNER JOIN ItemHierarchy AS cte
        ON item.ParentID = cte.ID
)
SELECT
    items.FullName AS ThresholdRange
FROM ItemHierarchy AS items
INNER JOIN ItemTypes AS types
    ON items.TypeID = types.ID
WHERE types.TypeFullName = 'Citect.Ampla.General.Server.ThresholdRange'
ORDER BY
    items.FullName;
