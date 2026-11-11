/*
    Lists all items in the Ampla project hierarchy together with their type.

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
    items.ID,
    items.FullName,
    items.Depth,
    types.TypeFullName
FROM Item_CTE AS items
INNER JOIN dbo.ItemTypes AS types
    ON items.TypeID = types.ID
ORDER BY
    items.FullName;
