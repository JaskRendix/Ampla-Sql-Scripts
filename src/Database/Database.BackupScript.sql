/*
    Database.BackupScript.sql

    Generates backup commands for Ampla databases using the current
    date in the backup file name.

    Review the generated commands before execution.
*/

DECLARE @date varchar(10) =
    CONVERT(varchar(10), GETDATE(), 120);

DECLARE @backupDir varchar(100) =
    'C:\Backups\Databases\';

DECLARE @sqlFormat varchar(1000);
DECLARE @sql varchar(MAX);

SET @sqlFormat =
      'BACKUP DATABASE [<<db-name>>] '
    + 'TO DISK = N'''
    + @backupDir
    + @date
    + ' <<db-name>>.bak'' '
    + 'WITH NOFORMAT, INIT, '
    + 'NAME = N''<<db-name>>-Full Backup'', '
    + 'SKIP, NOREWIND, NOUNLOAD, STATS = 10';

SET @sql = REPLACE(
    @sqlFormat,
    '<<db-name>>',
    'AmplaProject'
);

PRINT @sql;
-- EXEC (@sql);

SET @sql = REPLACE(
    @sqlFormat,
    '<<db-name>>',
    'AmplaProjectData'
);

PRINT @sql;
-- EXEC (@sql);

SET @sql = REPLACE(
    @sqlFormat,
    '<<db-name>>',
    'AmplaProjectState'
);

PRINT @sql;
-- EXEC (@sql);

SET @sql = REPLACE(
    @sqlFormat,
    '<<db-name>>',
    'AmplaProjectExtras'
);

PRINT @sql;
-- EXEC (@sql);
GO
