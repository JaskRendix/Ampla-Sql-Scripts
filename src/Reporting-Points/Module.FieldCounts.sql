/*
  Module.FieldCounts.sql
  Gets a record count for each field, showing Inactive, Active and Total values.
*/

SELECT
     counts.Module
    ,rp.ItemFullName AS ReportingPoint
    ,f.Name AS [FieldName]
    ,(counts.TotalRecords - counts.ActiveRecords) AS [InactiveRecords]
    ,counts.ActiveRecords
    ,counts.TotalRecords
    ,CAST(
        100.0 * counts.ActiveRecords /
        NULLIF(counts.TotalRecords, 0)
        AS NUMERIC(5, 2)
     ) AS [Active Percent]
    /* ,rp.ReportingPointId */
FROM (
    SELECT
         FieldId
        ,'Production' AS Module
        ,SUM(CAST(IsActive AS INT)) AS ActiveRecords
        ,COUNT(1) AS TotalRecords
    FROM dbo.ProductionDataField
    GROUP BY FieldId

    UNION ALL

    SELECT
         FieldId
        ,'Downtime' AS Module
        ,SUM(CAST(IsActive AS INT)) AS ActiveRecords
        ,COUNT(1) AS TotalRecords
    FROM dbo.DowntimeDataField
    GROUP BY FieldId

    /* Include the Energy module in V4.2
    UNION ALL

    SELECT
         FieldId
        ,'Energy' AS Module
        ,SUM(CAST(IsActive AS INT)) AS ActiveRecords
        ,COUNT(1) AS TotalRecords
    FROM dbo.EnergyDataField
    GROUP BY FieldId
    */

    UNION ALL

    SELECT
         FieldId
        ,'Quality' AS Module
        ,SUM(CAST(IsActive AS INT)) AS ActiveRecords
        ,COUNT(1) AS TotalRecords
    FROM dbo.QualityDataField
    GROUP BY FieldId

    UNION ALL

    SELECT
         FieldId
        ,'Metrics' AS Module
        ,SUM(CAST(IsActive AS INT)) AS ActiveRecords
        ,COUNT(1) AS TotalRecords
    FROM dbo.MetricsDataField
    GROUP BY FieldId

    UNION ALL

    SELECT
         FieldId
        ,'Maintenance' AS Module
        ,SUM(CAST(IsActive AS INT)) AS ActiveRecords
        ,COUNT(1) AS TotalRecords
    FROM dbo.MaintenanceDataField
    GROUP BY FieldId

    UNION ALL

    SELECT
         FieldId
        ,'Knowledge' AS Module
        ,SUM(CAST(IsActive AS INT)) AS ActiveRecords
        ,COUNT(1) AS TotalRecords
    FROM dbo.KnowledgeDataField
    GROUP BY FieldId

    UNION ALL

    SELECT
         FieldId
        ,'Planning' AS Module
        ,SUM(CAST(IsActive AS INT)) AS ActiveRecords
        ,COUNT(1) AS TotalRecords
    FROM dbo.PlanningDataField
    GROUP BY FieldId

    UNION ALL

    SELECT
         FieldId
        ,'Recipe' AS Module
        ,SUM(CAST(IsActive AS INT)) AS ActiveRecords
        ,COUNT(1) AS TotalRecords
    FROM dbo.RecipeDataField
    GROUP BY FieldId
) AS counts
INNER JOIN dbo.Field AS f
    ON f.FieldId = counts.FieldId
INNER JOIN dbo.ReportingPoint AS rp
    ON f.ReportingPointId = rp.ReportingPointId
ORDER BY
     counts.TotalRecords DESC
    ,rp.ItemFullName
    ,f.Name
    ,counts.Module;
