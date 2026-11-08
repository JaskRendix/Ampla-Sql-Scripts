/*
Show the details of ThresholdRange values stored in the Calendar table.

Threshold Ranges are stored using these names:
    {ReportingPoint}.Fields.{Field}.ThresholdRange.__UpperThreshold
    {ReportingPoint}.Fields.{Field}.ThresholdRange.__LowerThreshold

Debugging:
- If ThresholdRange does not exist in the Project Configuration as an item fullname,
  its value may not be linked correctly.

Run this query against the AmplaProjectData database.
*/

WITH Thresholds AS
(
    SELECT
        c.ItemName,
        c.ActiveDateTime,
        c.ItemValue,
        CASE
            WHEN c.ItemName LIKE '%.__UpperThreshold' THEN 'Upper'
            ELSE 'Lower'
        END AS [Direction],
        CASE
            WHEN c.ItemName LIKE '%.__UpperThreshold' THEN '__UpperThreshold'
            ELSE '__LowerThreshold'
        END AS [ThresholdSuffix]
    FROM Calendar AS c
    WHERE
        c.ItemName LIKE '%.__UpperThreshold'
        OR c.ItemName LIKE '%.__LowerThreshold'
)
SELECT
    t.ItemName,
    t.ActiveDateTime,
    t.ItemValue,
    LEFT(t.ItemName, CHARINDEX('.Fields.', t.ItemName) - 1) AS [ReportingPoint],
    LEFT(
        t.ItemName,
        LEN(t.ItemName) - LEN('.__UpperThreshold')
    ) AS [ThresholdRange],
    t.[Direction],
    t.[ThresholdSuffix]
FROM Thresholds AS t;
