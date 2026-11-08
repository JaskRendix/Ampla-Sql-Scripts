/*
    Item.TraceLevel.sql

    Lists items with a TraceLevel greater than 1.

    Run this query against the AmplaProject database.
*/

WITH Item_CTE
(
    ID,
    FullName,
    TypeID,
    Depth,
    TraceLevel
)
AS
(
    SELECT
        ID,
        CAST(Name AS varchar(MAX)) AS FullName,
        TypeID,
        1 AS Depth,
        TraceLevel
    FROM dbo.Items
    WHERE ParentID = '00000000-0000-0000-0000-000000000000'

    UNION ALL

    SELECT
        item.ID,
        CAST(cte.FullName + '.' + item.Name AS varchar(MAX)) AS FullName,
        item.TypeID,
        cte.Depth + 1 AS Depth,
        item.TraceLevel
    FROM dbo.Items AS item
    INNER JOIN Item_CTE AS cte
        ON item.ParentID = cte.ID
)
SELECT
    cte.FullName,
    cte.TraceLevel
FROM Item_CTE AS cte
WHERE cte.TraceLevel > 1
ORDER BY
    cte.FullName;
