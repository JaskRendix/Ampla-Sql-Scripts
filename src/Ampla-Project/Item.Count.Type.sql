/*
    Counts Items by ItemType.
*/

SELECT
    it.TypeFullName,
    COALESCE(i.ItemCount, 0) AS ItemCount,
    it.ID AS TypeID
FROM dbo.ItemTypes AS it
LEFT JOIN
(
    SELECT
        i.TypeID,
        COUNT(*) AS ItemCount
    FROM dbo.Items AS i
    GROUP BY
        i.TypeID
) AS i
    ON it.ID = i.TypeID
ORDER BY
    i.ItemCount DESC,
    it.TypeFullName;
