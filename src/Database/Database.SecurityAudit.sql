/*
    Database.SecurityAudit.sql

    Source:
    https://stackoverflow.com/questions/7048839/sql-server-query-to-find-all-permissions-access-for-all-users-in-a-database

    Security Audit Report

    1) List all access provisioned directly to SQL users,
       Windows users, and Windows groups.

    2) List all access provisioned through database roles
       and application roles.

    3) List all access provisioned to the public role.

    Columns Returned:

    UserType
        SQL User, Windows User, or Windows Group.

    DatabaseUserName
        Database principal name.

    LoginName
        SQL login or Windows/Active Directory account.

    Role
        Database role name, if applicable.

    PermissionType
        Permission granted to the principal or role.

    PermissionState
        Permission state such as GRANT or DENY.

    ObjectType
        Type of object receiving the permission.

    Schema
        Schema containing the object.

    ObjectName
        Object receiving the permission.

    ColumnName
        Column receiving the permission, if applicable.
*/

-- 1) Permissions granted directly to users/groups
SELECT
    CASE princ.[type]
        WHEN 'S' THEN 'SQL User'
        WHEN 'U' THEN 'Windows User'
        WHEN 'G' THEN 'Windows Group'
    END AS UserType,

    princ.[name] AS DatabaseUserName,
    ulogin.[name] AS LoginName,

    NULL AS [Role],

    perm.[permission_name] AS PermissionType,
    perm.[state_desc] AS PermissionState,

    CASE perm.[class]
        WHEN 1 THEN obj.[type_desc]
        ELSE perm.[class_desc]
    END AS ObjectType,

    objschem.[name] AS [Schema],

    CASE perm.[class]
        WHEN 3 THEN permschem.[name]
        WHEN 4 THEN imp.[name]
        ELSE OBJECT_NAME(perm.[major_id])
    END AS ObjectName,

    col.[name] AS ColumnName
FROM sys.database_principals AS princ
LEFT JOIN sys.server_principals AS ulogin
    ON ulogin.[sid] = princ.[sid]
LEFT JOIN sys.database_permissions AS perm
    ON perm.[grantee_principal_id] = princ.[principal_id]
LEFT JOIN sys.schemas AS permschem
    ON permschem.[schema_id] = perm.[major_id]
LEFT JOIN sys.objects AS obj
    ON obj.[object_id] = perm.[major_id]
LEFT JOIN sys.schemas AS objschem
    ON objschem.[schema_id] = obj.[schema_id]
LEFT JOIN sys.columns AS col
    ON col.[object_id] = perm.[major_id]
    AND col.[column_id] = perm.[minor_id]
LEFT JOIN sys.database_principals AS imp
    ON imp.[principal_id] = perm.[major_id]
WHERE
    princ.[type] IN ('S', 'U', 'G')
    AND princ.[name] NOT IN ('sys', 'INFORMATION_SCHEMA')

UNION ALL

-- 2) Permissions inherited through roles
SELECT
    CASE membprinc.[type]
        WHEN 'S' THEN 'SQL User'
        WHEN 'U' THEN 'Windows User'
        WHEN 'G' THEN 'Windows Group'
    END AS UserType,

    membprinc.[name] AS DatabaseUserName,
    ulogin.[name] AS LoginName,

    roleprinc.[name] AS [Role],

    perm.[permission_name] AS PermissionType,
    perm.[state_desc] AS PermissionState,

    CASE perm.[class]
        WHEN 1 THEN obj.[type_desc]
        ELSE perm.[class_desc]
    END AS ObjectType,

    objschem.[name] AS [Schema],

    CASE perm.[class]
        WHEN 3 THEN permschem.[name]
        WHEN 4 THEN imp.[name]
        ELSE OBJECT_NAME(perm.[major_id])
    END AS ObjectName,

    col.[name] AS ColumnName
FROM sys.database_role_members AS members
INNER JOIN sys.database_principals AS roleprinc
    ON roleprinc.[principal_id] = members.[role_principal_id]
INNER JOIN sys.database_principals AS membprinc
    ON membprinc.[principal_id] = members.[member_principal_id]
LEFT JOIN sys.server_principals AS ulogin
    ON ulogin.[sid] = membprinc.[sid]
LEFT JOIN sys.database_permissions AS perm
    ON perm.[grantee_principal_id] = roleprinc.[principal_id]
LEFT JOIN sys.schemas AS permschem
    ON permschem.[schema_id] = perm.[major_id]
LEFT JOIN sys.objects AS obj
    ON obj.[object_id] = perm.[major_id]
LEFT JOIN sys.schemas AS objschem
    ON objschem.[schema_id] = obj.[schema_id]
LEFT JOIN sys.columns AS col
    ON col.[object_id] = perm.[major_id]
    AND col.[column_id] = perm.[minor_id]
LEFT JOIN sys.database_principals AS imp
    ON imp.[principal_id] = perm.[major_id]
WHERE
    membprinc.[type] IN ('S', 'U', 'G')
    AND membprinc.[name] NOT IN ('sys', 'INFORMATION_SCHEMA')

UNION ALL

-- 3) Permissions granted to the public role
SELECT
    '{All Users}' AS UserType,
    '{All Users}' AS DatabaseUserName,
    '{All Users}' AS LoginName,

    roleprinc.[name] AS [Role],

    perm.[permission_name] AS PermissionType,
    perm.[state_desc] AS PermissionState,

    CASE perm.[class]
        WHEN 1 THEN obj.[type_desc]
        ELSE perm.[class_desc]
    END AS ObjectType,

    objschem.[name] AS [Schema],

    CASE perm.[class]
        WHEN 3 THEN permschem.[name]
        WHEN 4 THEN imp.[name]
        ELSE OBJECT_NAME(perm.[major_id])
    END AS ObjectName,

    col.[name] AS ColumnName
FROM sys.database_principals AS roleprinc
LEFT JOIN sys.database_permissions AS perm
    ON perm.[grantee_principal_id] = roleprinc.[principal_id]
LEFT JOIN sys.schemas AS permschem
    ON permschem.[schema_id] = perm.[major_id]
INNER JOIN sys.objects AS obj
    ON obj.[object_id] = perm.[major_id]
LEFT JOIN sys.schemas AS objschem
    ON objschem.[schema_id] = obj.[schema_id]
LEFT JOIN sys.columns AS col
    ON col.[object_id] = perm.[major_id]
    AND col.[column_id] = perm.[minor_id]
LEFT JOIN sys.database_principals AS imp
    ON imp.[principal_id] = perm.[major_id]
WHERE
    roleprinc.[type] = 'R'
    AND roleprinc.[name] = 'public'
    AND obj.[is_ms_shipped] = 0

ORDER BY
    UserType,
    DatabaseUserName,
    LoginName,
    [Role],
    [Schema],
    ObjectName,
    ColumnName,
    PermissionType,
    PermissionState,
    ObjectType;
