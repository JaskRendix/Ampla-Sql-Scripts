/*
    Database.Trustworthy.sql

    Lists SQL CLR modules and reports the database TRUSTWORTHY setting
    and owner. Generates suggested remediation SQL when CLR modules are
    present and the checks indicate a change.

    Review the suggested commands before executing them.
*/

DECLARE @numCLR int = 0;
DECLARE @databaseNameQuoted nvarchar(258) = QUOTENAME(DB_NAME());
DECLARE @saSid varbinary(85) = SUSER_SID(N'sa');

SELECT
    o.name AS object_name,
    a.name AS assembly_name,
    am.assembly_class,
    CONCAT(
        ASSEMBLYPROPERTY(a.name, 'VersionMajor'), '.',
        ASSEMBLYPROPERTY(a.name, 'VersionMinor'), '.',
        ASSEMBLYPROPERTY(a.name, 'VersionBuild'), '.',
        ASSEMBLYPROPERTY(a.name, 'VersionRevision')
    ) AS AssemblyVersion,
    a.permission_set_desc,
    o.type_desc
FROM sys.assembly_modules AS am
INNER JOIN sys.assemblies AS a
    ON a.assembly_id = am.assembly_id
INNER JOIN sys.objects AS o
    ON o.object_id = am.object_id
ORDER BY
    a.name,
    am.assembly_class;

SELECT @numCLR = COUNT(*)
FROM sys.assembly_modules;

SELECT
    d.name,
    'Check TRUSTWORTHY' AS Checking,
    CASE
        WHEN d.is_trustworthy_on = 1 THEN 'TRUSTWORTHY IS ON'
        ELSE 'TRUSTWORTHY IS OFF'
    END AS Result,
    CASE
        WHEN d.is_trustworthy_on = 0 AND @numCLR > 0
            THEN 'ALTER DATABASE ' + @databaseNameQuoted + ' SET TRUSTWORTHY ON'
        ELSE '-- No change to TRUSTWORTHY required'
    END AS SuggestedSql,
    CASE
        WHEN d.is_trustworthy_on = 0 AND @numCLR > 0
            THEN 'CLR modules are present. Review the assembly requirements and security implications before changing the owner.'
        ELSE 'No change to TRUSTWORTHY required by this check.'
    END AS Description
FROM sys.databases AS d
WHERE d.database_id = DB_ID()

UNION ALL

SELECT
    d.name,
    'Check DB Owner' AS Checking,
    CONCAT('Owner: ', COALESCE(SUSER_SNAME(d.owner_sid), '(unknown)')) AS Result,
    CASE
        WHEN d.owner_sid <> @saSid AND @numCLR > 0
            THEN 'ALTER AUTHORIZATION ON DATABASE::'
                 + @databaseNameQuoted
                 + ' TO sa'
        ELSE '-- No change to database owner required'
    END AS SuggestedSql,
    CASE
        WHEN d.owner_sid <> @saSid AND @numCLR > 0
            THEN 'CLR modules are present and the owner is not sa. Review the assembly requirements and security implications before changing the owner.'
        ELSE 'No change to database owner required by this check.'
    END AS Description
FROM sys.databases AS d
WHERE d.database_id = DB_ID();
