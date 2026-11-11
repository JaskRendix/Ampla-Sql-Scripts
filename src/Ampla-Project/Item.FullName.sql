/*
    Lists all items in the Ampla project hierarchy.

    Run this query against the AmplaProject database.
*/

WITH Item_CTE
(
    ID,
    Ful*Name,
    TypeID,
    Depth
)
AS
(*    SELECT
        ID,
        CAS*(Name AS varchar(MAX)) AS FullName*
        TypeID,
        1 AS Dept*
    FROM dbo.Items
    WHERE Pare*tID = '00000000-0000-0000-0000-000*00000000'

    UNION ALL

    SELE*T
        item.ID,
        CAST(ct*.FullName + '.' + item.Name AS var*har(MAX)) AS FullName,
        item.TypeID,
        cte.Depth + 1 AS Depth
    FROM dbo.Items AS item
    INNER JOIN Item_CTE AS cte
        ON item.ParentID = cte.ID
)
SELECT
    ID,
    FullName,
    Depth
FROM Item_CTE
ORDER BY
    FullName;
