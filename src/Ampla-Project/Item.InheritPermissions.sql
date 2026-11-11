/*
    Item.InheritPermissions.sql

    Lists items that explicitly define the InheritPermissions property.

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
    i.ID,
    i.FullName,
    i.Depth,
    ip.Value AS InheritPermissions
FROM Item_CTE AS i
INNER JOIN dbo.ItemProperties AS ip
    ON i.ID = ip.ItemID
WHERE ip.PropertyName = 'InheritPermissions'
ORDER BY
    i.FullName,
    i.Depth;
