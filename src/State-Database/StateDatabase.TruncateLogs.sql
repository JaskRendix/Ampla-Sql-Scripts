/*
    Ampla State-Database cleanup script.

    Preserves the existing cleanup behavior:
    when the oldest Log record is more than four weeks old,
    delete records older than one week before that oldest record.
*/

DECLARE @utcNow       datetime = GETUTCDATE();
DECLARE @weeksOld     int;
DECLARE @countLogs    int;
DECLARE @oldestLog    datetime;

SELECT
    @oldestLog = MIN([Timestamp]),
    @countLogs = COUNT(*)
FROM dbo.Log;

IF @countLogs = 0
BEGIN
    PRINT '*** [Summary] ***';
    PRINT '--- No records have been deleted';
    PRINT '--- Log table is empty';
    RETURN;
END;

SET @weeksOld = DATEDIFF(WEEK, @oldestLog, @utcNow);

IF @weeksOld > 4
BEGIN
    DECLARE @categoryLogDeleted int;
    DECLARE @scenarioDeleted    int;
    DECLARE @logDeleted         int;
    DECLARE @expiresAt          datetime;

    PRINT 'Log table has ' + CAST(@countLogs AS varchar(10)) + ' rows';
    PRINT 'Oldest log record is ' + CAST(@weeksOld AS varchar(10)) + ' weeks old';

    SET @expiresAt = DATEADD(WEEK, -1 * (@weeksOld - 1), @utcNow);

    PRINT 'Deleting log entries - Expiry date (UTC): '
        + CAST(@expiresAt AS varchar(20));

    PRINT '-- Deleting records from CategoryLog';

    DELETE dbo.CategoryLog
    FROM dbo.CategoryLog
    INNER JOIN dbo.Log
        ON dbo.Log.LogId = dbo.CategoryLog.LogId
    WHERE dbo.Log.[Timestamp] < @expiresAt;

    SET @categoryLogDeleted = @@ROWCOUNT;

    PRINT '-- Deleting records from Scenario';

    DELETE dbo.Scenario
    FROM dbo.Scenario
    INNER JOIN dbo.Log
        ON dbo.Log.InstanceId = dbo.Scenario.InstanceId
    WHERE dbo.Log.[Timestamp] < @expiresAt;

    SET @scenarioDeleted = @@ROWCOUNT;

    PRINT '-- Deleting records from Log';

    DELETE dbo.Log
    WHERE dbo.Log.[Timestamp] < @expiresAt;

    SET @logDeleted = @@ROWCOUNT;

    PRINT '*** [Summary] ***';
    PRINT '***  Deleted ' + CAST(@logDeleted AS varchar(10))
        + ' rows from the Log table';
    PRINT '***  Deleted ' + CAST(@categoryLogDeleted AS varchar(10))
        + ' rows from the CategoryLog table';
    PRINT '***  Deleted ' + CAST(@scenarioDeleted AS varchar(10))
        + ' rows from the Scenario table';
END
ELSE
BEGIN
    PRINT '*** [Summary] ***';
    PRINT '--- No records have been deleted';
    PRINT '--- Log table has ' + CAST(@countLogs AS varchar(10)) + ' rows';
    PRINT '--- Oldest record is ' + CAST(@weeksOld AS varchar(10)) + ' weeks old';
END;
