/*
    Database.Assembly.Version.sql

    Lists CLR modules and their associated assembly versions.
*/

SELECT
    o.name AS object_name,
    CONCAT(
        ASSEMBLYPROPERTY(a.name, 'VersionMajor'), '.',
        ASSEMBLYPROPERTY(a.name, 'VersionMinor'), '.',
        ASSEMBLYPROPERTY(a.name, 'VersionBuild'), '.',
        ASSEMBLYPROPERTY(a.name, 'VersionRevision')
    ) AS AssemblyVersion
FROM sys.assembly_modules AS am
INNER JOIN sys.assemblies AS a
    ON a.assembly_id = am.assembly_id
INNER JOIN sys.objects AS o
    ON o.object_id = am.object_id
ORDER BY
    a.name,
    am.assembly_class;
