/*
    Database.CodeSizes.sql

    Reports the approximate size of stored procedures and functions
    by statement count and lines of code.
*/

SELECT
    t.Name,
    SUM(t.StatementCount) AS [Number of Statements],
    SUM(t.LineCount) - 1 AS [Lines of Code],
    t.ObjectType
FROM
(
    SELECT
        o.name AS Name,
        1 AS StatementCount,
        LEN(c.text) - LEN(REPLACE(c.text, CHAR(10), '')) AS LineCount,
        CASE
            WHEN o.xtype = 'P' THEN 'Stored Procedure'
            WHEN o.xtype IN ('FN', 'IF', 'TF') THEN 'Function'
        END AS ObjectType
    FROM sysobjects AS o
    INNER JOIN syscomments AS c
        ON c.id = o.id
    WHERE o.xtype IN ('P', 'FN', 'IF', 'TF')
        AND o.category = 0
        AND o.name NOT IN
        (
            'fn_diagramobjects',
            'sp_alterdiagram',
            'sp_creatediagram',
            'sp_dropdiagram',
            'sp_helpdiagramdefinition',
            'sp_helpdiagrams',
            'sp_renamediagram',
            'sp_upgraddiagrams',
            'sysdiagrams'
        )
) AS t
GROUP BY
    t.Name,
    t.ObjectType
ORDER BY
    t.Name;
