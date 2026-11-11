/*
    Generates dynamic PIVOT queries for Item Types that have configurable
    properties, allowing item property values to be viewed in a tabular format.
*/

SELECT
    cols.TypeFullName,
    cols.NumProperties,
    COALESCE(ic.ItemCount, 0) AS NumItems,

    '/*--- CTE ---*/ '
    + 'WITH Item_CTE(ID, FullName, Parent, Name, TypeID, Depth) '
    + 'AS ( '
    + 'SELECT ID, CAST(Name AS VARCHAR(MAX)) AS FullName, '
    + 'CAST('''' AS VARCHAR(MAX)) AS Parent, '
    + 'Name, TypeID, 1 AS Depth '
    + 'FROM Items '
    + 'WHERE ParentID = ''00000000-0000-0000-0000-000000000000'' '
    + 'UNION ALL '
    + 'SELECT item.ID, '
    + 'CAST(cte.FullName + ''.'' + item.Name AS VARCHAR(MAX)) AS FullName, '
    + 'cte.FullName AS Parent, '
    + 'item.Name, '
    + 'item.TypeID, '
    + 'cte.Depth + 1 AS Depth '
    + 'FROM Items AS item '
    + 'INNER JOIN Item_CTE AS cte '
    + 'ON item.ParentID = cte.ID '
    + ') '

    + '/*------------*/ '
    + '/*---SELECT---*/ '
    + '/*------------*/ '

    + 'SELECT '
    + 'items.FullName, '
    + 'items.Name, '
    + cols.[Columns]

    + ' FROM Item_CTE items '

    + 'LEFT JOIN ( '
    + 'SELECT ItemID, ' + cols.[Columns]
    + ' FROM ( '
    + 'SELECT '
    + 'ItemID, '
    + 'PropertyName, '
    + 'CAST(Value AS NVARCHAR(MAX)) AS [prop.Value] '
    + 'FROM ItemProperties '
    + ') x '
    + 'PIVOT ( '
    + 'MAX([prop.Value]) '
    + 'FOR PropertyName IN ('
    + cols.[Columns]
    + ') '
    + ') AS firstValue '
    + ') pvt '
    + 'ON pvt.ItemID = items.ID '

    + 'WHERE items.TypeID = '''
    + CAST(cols.TypeID AS NVARCHAR(36))
    + ''' '

    + '/*---------------*/ '
    + '/*---ORDER BY ---*/ '
    + '/*---------------*/ '

    + 'ORDER BY items.FullName, items.Name'
    AS [Pivot-Data-SQL]

FROM
(
    SELECT
        it.TypeFullName,
        it.ID AS TypeID,

        (
            SELECT COUNT(*)
            FROM dbo.PropertyDescriptors AS pd
            WHERE
                pd.Name NOT LIKE '%.Overridden'
                AND pd.BehaviorName = 'Config'
                AND pd.DeclaringTypeID = it.ID
        ) AS NumProperties,

        COALESCE
        (
            STUFF
            (
                (
                    SELECT
                        ',' + QUOTENAME(pd.Name)
                    FROM dbo.PropertyDescriptors AS pd
                    WHERE
                        pd.Name NOT LIKE '%.Overridden'
                        AND pd.BehaviorName = 'Config'
                        AND pd.DeclaringTypeID = it.ID
                    GROUP BY
                        pd.Name
                    ORDER BY
                        pd.Name
                    FOR XML PATH(''), TYPE
                ).value('.', 'NVARCHAR(MAX)')
            ,1,1,'')
        ,'') AS [Columns]

    FROM dbo.ItemTypes AS it
) AS cols

LEFT JOIN
(
    SELECT
        TypeID,
        COUNT(*) AS ItemCount
    FROM dbo.Items
    GROUP BY
        TypeID
) AS ic
    ON cols.TypeID = ic.TypeID

WHERE cols.NumProperties > 0

ORDER BY
    cols.TypeFullName;
