SELECT 
DATENAME(month, 
        CAST(SUBSTRING(Report_Date, 5, 4) || '-' ||  -- YYYY
             SUBSTRING(Report_Date, 3, 2) || '-' ||  -- MM
             SUBSTRING(Report_Date, 1, 2)            -- DD
        AS DATE)
    ) || ' ' || SUBSTRING(Report_Date, 5, 4) AS Month,
CUSTOMER_NO,	
LINE_CONTRACT,	
BRANCH_NAME,	
CUSTOMER_NAME as [CUSTOMER NAME],	
[BUSINESS UNIT],	
PRODUCT_LINE as [PRODUCT LINE],	
MOVEMENT,	
ARM	,
[NET HELD], 
[NET HELD]/1000 as [NET HELD '000']
FROM
dbcba.Customer_Provision
WHERE lower([BUSINESS UNIT]) not like '%corporate%' and [BUSINESS UNIT] <> '(blank)' and [BUSINESS UNIT] is not null
--and CUSTOMER_NO = '175916' AND Report_Date = (SELECT MAX(Report_Date) FROM dbcba.Customer_Provision)
order by Report_Date desc
------------------------------------------------------------------------------------------------------------------------------------

--CURRENT BY BISINESS UNIT
select [BUSINESS UNIT] ,sum ([NET HELD])
FROM
dbcba.Customer_Provision
WHERE lower([BUSINESS UNIT]) not like '%corporate%' and [BUSINESS UNIT] <> '(blank)' and [BUSINESS UNIT] is not null
and Report_Date = (SELECT MAX(Report_Date) FROM dbcba.Customer_Provision)
GROUP BY [BUSINESS UNIT] 

----------------------------------------------------------------------------

-- TREND
-------------------------------------------------------------------------------
SELECT  
    DATENAME(month, dt) || ' ' || CAST(YEAR(dt) AS VARCHAR) AS Month,
     CUSTOMER_NO,
     BRANCH_NAME,
    [BUSINESS UNIT],
   LINE_CONTRACT,	
    PRODUCT_LINE,
    SUM([NET HELD]) AS [NET PROVISION HELD]
FROM (
    SELECT *,
        CAST(
            SUBSTRING(CAST(TRIM(Report_Date) AS VARCHAR(8)), 5, 4) || '-' ||--yyyy
            SUBSTRING(CAST(TRIM(Report_Date) AS VARCHAR(8)), 3, 2) || '-' ||--mm
            SUBSTRING(CAST(TRIM(Report_Date) AS VARCHAR(8)), 1, 2)          --dd
        AS DATE
        ) AS dt
    FROM dbcba.Customer_Provision
) t
WHERE 
    dt IS NOT NULL
    AND LOWER(TRIM([BUSINESS UNIT])) NOT LIKE '%corporate%' 
    AND TRIM([BUSINESS UNIT]) <> '(blank)' 
    AND TRIM([BUSINESS UNIT]) IS NOT NULL 
    AND [NET HELD] IS NOT NULL
GROUP BY 
    DATENAME(month, dt),
    YEAR(dt),
         CUSTOMER_NO,
         LINE_CONTRACT,	
     BRANCH_NAME,
    [BUSINESS UNIT],
    PRODUCT_LINE

--------------------------------------------------------------------------------------------------------------

    select distinct Report_Date --top 3*

     FROM dbcba.Customer_Provision
     
     
     SELECT DISTINCT MOVEMENT
FROM dbcba.Customer_Provision


SELECT Report_Date, [BUSINESS UNIT]
FROM dbcba.Customer_Provision
WHERE (
    LOWER([BUSINESS UNIT]) LIKE '%consumer%'
    OR LOWER([BUSINESS UNIT]) LIKE '%sme%'
)


SELECT 
    [BUSINESS UNIT],
    COUNT(*) AS CNT,
    SUM([NET HELD]) AS TOTAL_NET_HELD
FROM dbcba.Customer_Provision
WHERE LOWER([BUSINESS UNIT]) LIKE '%consumer%'
   OR LOWER([BUSINESS UNIT]) LIKE '%sme%'
GROUP BY [BUSINESS UNIT]