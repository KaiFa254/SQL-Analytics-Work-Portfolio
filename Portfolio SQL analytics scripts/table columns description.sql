 SELECT 
    c.column_name,
    d.domain_name AS data_type,        -- VARCHAR, DECIMAL, etc.
    c.width,
    c.scale,
    CASE c."nulls" 
         WHEN 'Y' THEN 'YES' 
         WHEN 'N' THEN 'NO' 
         ELSE c."nulls" 
    END AS is_nullable,
    c."default" AS default_value
FROM 
    sys.syscolumn c
JOIN 
    sys.systable t ON c.table_id = t.table_id
JOIN 
    sys.sysdomain d ON c.domain_id = d.domain_id
WHERE 
    UPPER(t.table_name) = 'KE_ACCOUNTS_LIST'
    AND t.creator = USER_ID('DBCBA')
    and c.column_name like '%REPAYMENT_AMT%'
ORDER BY 
    c.column_id;