/*
  Module.RecordCounts.sql
  Gets a record count for each reporting point in the database.
*/

DECLARE @utcNow DATETIME = GETUTCDATE();

SELECT
     counts.Module
    ,rp.ItemFullName AS ReportingPoint
    ,counts.RecordCount
    ,counts.FirstRecord
    ,counts.LastRecord
    ,DATEDIFF(WEEK, counts.LastRecord, @utcNow) AS WeeksAgo
    ,DATEDIFF(MONTH, counts.LastRecord, @utcNow) AS MonthsAgo
FROM (
    SELECT
         ReportingPointId
        ,'Production' AS Module
        ,COUNT(1) AS RecordCount
        ,MIN(SampleDateTime) AS FirstRecord
        ,MAX(SampleDateTime) AS LastRecord
    FROM dbo.ProductionDataSet
    GROUP BY ReportingPointId

    UNION ALL

    SELECT
         ReportingPointId
        ,'Downtime' AS Module
        ,COUNT(1) AS RecordCount
        ,MIN(StartDateTime) AS FirstRecord
        ,MAX(StartDateTime) AS LastRecord
    FROM dbo.DowntimeDataSet
    GROUP BY ReportingPointId

    /* Include the Energy module
    UNION ALL

    SELECT
         ReportingPointId
        ,'Energy' AS Module
        ,COUNT(1) AS RecordCount
        ,MIN(StartDateTime) AS FirstRecord
        ,MAX(StartDateTime) AS LastRecord
    FROM dbo.EnergyDataSet
    GROUP BY ReportingPointId
    */

    UNION ALL

    SELECT
         ReportingPointId
        ,'Quality' AS Module
        ,COUNT(1) AS RecordCount
        ,MIN(SampleDateTime) AS FirstRecord
        ,MAX(SampleDateTime) AS LastRecord
    FROM dbo.QualityDataSet
    GROUP BY ReportingPointId

    UNION ALL

    SELECT
         ReportingPointId
        ,'Metrics' AS Module
        ,COUNT(1) AS RecordCount
        ,MIN(StartDateTime) AS FirstRecord
        ,MAX(StartDateTime) AS LastRecord
    FROM dbo.MetricsDataSet
    GROUP BY ReportingPointId

    UNION ALL

    SELECT
         ReportingPointId
        ,'Maintenance' AS Module
        ,COUNT(1) AS RecordCount
        ,MIN(SampleDateTime) AS FirstRecord
        ,MAX(SampleDateTime) AS LastRecord
    FROM dbo.MaintenanceDataSet
    GROUP BY ReportingPointId

    UNION ALL

    /* Some Ampla versions use SampleDateTime and others use StartDateTime. */
    SELECT
         ReportingPointId
        ,'Knowledge' AS Module
        ,COUNT(1) AS RecordCount
        ,MIN(SampleDateTime) AS FirstRecord
        ,MAX(SampleDateTime) AS LastRecord
        -- For versions using StartDateTime, use it instead:
        -- ,MIN(StartDateTime) AS FirstRecord
        -- ,MAX(StartDateTime) AS LastRecord
    FROM dbo.KnowledgeDataSet
    GROUP BY ReportingPointId

    UNION ALL

    SELECT
         ReportingPointId
        ,'Planning' AS Module
        ,COUNT(1) AS RecordCount
        ,MIN(PlannedStartDateTime) AS FirstRecord
        ,MAX(PlannedStartDateTime) AS LastRecord
    FROM dbo.PlanningDataSet
    GROUP BY ReportingPointId

    UNION ALL

    SELECT
         ReportingPointId
        ,'Recipe' AS Module
        ,COUNT(1) AS RecordCount
        ,MIN(StateChangedDateTime) AS FirstRecord
        ,MAX(StateChangedDateTime) AS LastRecord
    FROM dbo.RecipeDataSet
    GROUP BY ReportingPointId
) AS counts
INNER JOIN dbo.ReportingPoint AS rp
    ON rp.ReportingPointId = counts.ReportingPointId
ORDER BY
     counts.RecordCount DESC
    ,rp.ItemFullName
    ,counts.Module;
