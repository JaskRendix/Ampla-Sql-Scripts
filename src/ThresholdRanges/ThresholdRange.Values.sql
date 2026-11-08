/*
    Outputs Calendar values for a reporting point.

    Threshold ranges are stored using names such as:
        {ReportingPoint}.Fields.{Field}.ThresholdRange.__UpperThreshold
        {ReportingPoint}.Fields.{Field}.ThresholdRange.__LowerThreshold

    Run this query against the AmplaProjectData database.
*/

DECLARE @ReportingPoint nvarchar(200) =
    N'Enterprise.Site.Area.Production';

SELECT
    c.ItemName,
    c.ActiveDateTime,
    c.ItemValue
FROM Calendar AS c
WHERE c.ItemName LIKE @ReportingPoint + N'.Fields.%'
ORDER BY
    c.ItemName,
    c.ActiveDateTime;
