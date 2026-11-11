/*
    Lists items in hierarchical order using a recursive CTE.

    SortOrder is generated from DisplayOrder and Name to preserve
    project navigation order throughout the hierarchy.
*/

WITH Item_CTE
(
    ID,
    Parent,
    Name,
    FullName,
    TypeID,
    Depth,
    DisplayOrder,
    SortOrder
)
AS
(
    SELECT
        ID,
        CAST('' AS varchar(MAX)) AS Parent,
        Name,
        CAST(Name AS varchar(MAX)) AS FullName,
        TypeID,
        1 AS Depth,
        DisplayOrder,
        CAST
        (
            ROW_NUMBER()
            OVER (ORDER BY DisplayOrder, Name)
            AS varchar(MAX)
        ) AS SortOrder
    FROM dbo.Items
    WHERE ParentID = '00000000-0000-0000-0000-000000000000'

    UNION ALL

    SELECT
        item.ID,
        cte.FullName,
        item.Name,
        CAST(cte.FullName + '.' + item.Name AS varchar(MAX)) AS FullName,
        item.TypeID,
        cte.Depth + 1,
        item.DisplayOrder,
        cte.SortOrder
            + '.'
            + CAST
              (
                  ROW_NUMBER()
                  OVER (ORDER BY item.DisplayOrder, item.Name)
                  AS varchar(MAX)
              )
    FROM dbo.Items AS item
    INNER JOIN Item_CTE AS cte
        ON item.ParentID = cte.ID
)
SELECT
    ID,
    FullName,
    Depth,
    SortOrder
FROM Item_CTE
ORDER BY
    SortOrder;
