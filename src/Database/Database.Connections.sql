/*
    Database.Connections.sql

    Lists connection counts grouped by database, host,
    application, and login.
*/

SELECT
    DB_NAME(dbid) AS DatabaseName,
    RTRIM(hostname) AS HostName,
    RTRIM(program_name) AS ProgramName,
    COUNT(*) AS NumberOfConnections,
    RTRIM(loginame) AS LoginName
FROM sys.sysprocesses
WHERE dbid > 0
GROUP BY
    dbid,
    loginame,
    hostname,
    program_name
ORDER BY
    DatabaseName,
    NumberOfConnections DESC;
