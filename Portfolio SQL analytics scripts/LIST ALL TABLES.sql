

--list empty tables
SELECT 
    t.NAME AS TableName,
    s.NAME AS SchemaName
FROM 
    sys.tables t
JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
LEFT JOIN 
    sys.partitions p ON t.object_id = p.object_id
WHERE 
    p.index_id IN (0, 1) -- 0 = heap, 1 = clustered index
GROUP BY 
    t.NAME, s.NAME
HAVING 
    SUM(p.rows) = 0;

---list all tables

SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'

---list all tables
SELECT u.name AS schema_name,
       o.name AS table_name
FROM sysobjects o
JOIN sysusers u ON o.uid = u.uid
WHERE o.type = 'U'
ORDER BY u.name, o.name;




SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    SUM(p.rows) AS RowCount
FROM 
    sys.tables t
INNER JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
INNER JOIN 
    sys.partitions p ON t.object_id = p.object_id
WHERE 
    p.index_id IN (0, 1) -- 0 = heap, 1 = clustered index
GROUP BY 
    s.name, t.name
HAVING 
    SUM(p.rows) > 0
ORDER BY 
    RowCount DESC;


SELECT name AS TableName,
       creator AS Owner
FROM sys.systable
WHERE tabletype = 'BASE'
ORDER BY creator, name;






---all tables 
SELECT 
    u.name AS schema_name,
    o.name AS table_name,
    (SELECT COUNT(*) FROM " + o.name + ") -- dynamic needed normally
FROM sysobjects o
JOIN sysusers u ON o.uid = u.uid
WHERE o.type = 'U';

--with date
SELECT 
    u.name AS schema_name,
    o.name AS table_name,
    o.crdate AS creation_date
FROM sysobjects o
JOIN sysusers u 
    ON o.uid = u.uid
WHERE o.type = 'U'
ORDER BY u.name, o.name;


