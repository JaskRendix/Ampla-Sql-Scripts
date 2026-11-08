/*
    DataRepository.Field.InfinityNaN.sql

    Detect Infinity and NaN values in the DataRepository
    and generate UPDATE statements to set them to NULL.
*/

SELECT
    modules.Module,
    modules.FieldCount AS InvalidFieldCount,
    CONCAT(
        CASE WHEN modules.FieldCount = 0 THEN '-- ' ELSE '' END,
        'UPDATE dbo.',
        modules.Module,
        'DataField SET DataValue = NULL ',
        'WHERE DataValue IN (N''NaN'', N''Infinity'')'
    ) AS UpdateSQL
FROM
(
    SELECT 'Downtime' AS Module, COUNT(*) AS FieldCount
    FROM dbo.DowntimeDataField
    WHERE DataValue IN (N'NaN', N'Infinity')

    UNION ALL

    SELECT 'Energy', COUNT(*)
    FROM dbo.EnergyDataField
    WHERE DataValue IN (N'NaN', N'Infinity')

    UNION ALL

    SELECT 'Knowledge', COUNT(*)
    FROM dbo.KnowledgeDataField
    WHERE DataValue IN (N'NaN', N'Infinity')

    UNION ALL

    SELECT 'Metrics', COUNT(*)
    FROM dbo.MetricsDataField
    WHERE DataValue IN (N'NaN', N'Infinity')

    UNION ALL

    SELECT 'Lot', COUNT(*)
    FROM dbo.LotDataField
    WHERE DataValue IN (N'NaN', N'Infinity')

    UNION ALL

    SELECT 'Planning', COUNT(*)
    FROM dbo.PlanningDataField
    WHERE DataValue IN (N'NaN', N'Infinity')

    UNION ALL

    SELECT 'Production', COUNT(*)
    FROM dbo.ProductionDataField
    WHERE DataValue IN (N'NaN', N'Infinity')

    UNION ALL

    -- NOTE:
    -- Original script references ProductionDataField for Quality.
    -- Verify against the target Ampla schema before changing.
    SELECT 'Quality', COUNT(*)
    FROM dbo.ProductionDataField
    WHERE DataValue IN (N'NaN', N'Infinity')

    UNION ALL

    SELECT 'Recipe', COUNT(*)
    FROM dbo.RecipeDataField
    WHERE DataValue IN (N'NaN', N'Infinity')
) AS modules
ORDER BY
    modules.FieldCount DESC,
    modules.Module;
