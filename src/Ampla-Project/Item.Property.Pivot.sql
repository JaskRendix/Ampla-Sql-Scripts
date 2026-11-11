/*
    Generates dynamic property PIVOT queries for each Item Type.

    The generated SQL returns item names together with their configured
    properties pivoted into columns.
*/

SELECT
    cols.TypeFullName,
    cols.NumProperties,

    'SELECT '
    + 'i.Name, pvt.* '
    + 'FROM dbo.Items AS i '
    + 'INNER JOIN ( '
    + 'SELECT ItemID, ' + cols.[Columns] + ' FROM '
    + '( '
    + 'SELECT '
    + 'ItemID, '
    + 'PropertyName, '
    + 'CAST(Value AS NVARCHAR(MAX)) AS [prop.Value] '
    + 'FROM dbo.ItemProperties '
    + ') AS x '
    + 'PIVOT ( '
    + 'MAX([prop.Value]) FOR PropertyName IN ('
    + cols.[Columns]
    + ') '
    + ') AS firstValue '
    + ') AS pvt '
    + 'ON pvt.ItemID = i.ID '
    + 'WHERE i.TypeID = '''
    + CAST(cols.TypeID AS NVARCHAR(36))
    + ''''
    AS [SQL],

    cols.TypeID

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

ORDER BY
    cols.TypeFullName;
