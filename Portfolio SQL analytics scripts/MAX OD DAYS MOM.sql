WITH RankedData AS (
    SELECT 
        A.EXTRACTION_DATE, 
        STRING(DATENAME(MONTH, A.EXTRACTION_DATE), '-', YEAR(A.EXTRACTION_DATE)) AS Month_Year,
        A.CUSTOMER,
        A.ARREARS_KES,
        A.OD_DAYS,
        ROW_NUMBER() OVER (PARTITION BY YEAR(A.EXTRACTION_DATE), MONTH(A.EXTRACTION_DATE) ORDER BY A.OD_DAYS DESC) AS RowNum
    FROM SVUPHSIQDBPR.STGKE.STG_AA_BILL_ARREARS A
    WHERE  A.EXTRACTION_DATE BETWEEN '2024-12-01' AND '2025-05-31'
    and A.CUSTOMER='593982'
)
SELECT 
     CUSTOMER,
    CASE 
    	WHEN Month_Year='December-2024' then OD_DAYS
    END as December_2024_MAX_OD_DAYS,
     CASE 
    	WHEN Month_Year='January-2024' then OD_DAYS
    END as January_2024_MAX_OD_DAYS,
     CASE 
    	WHEN Month_Year='February-2024' then OD_DAYS
    END as February_2024_MAX_OD_DAYS,
     CASE 
    	WHEN Month_Year='March-2024' then OD_DAYS
    END as March_2024_MAX_OD_DAYS,
     CASE 
    	WHEN Month_Year='April-2024' then OD_DAYS
    END as April_2024_MAX_OD_DAYS,
     CASE 
    	WHEN Month_Year='May-2024' then OD_DAYS
    END as May_2024_MAX_OD_DAYS,
    CASE 
    	WHEN Month_Year='December-2024' then ARREARS_KES
    END as December_2024_ARREARS_KES              
FROM RankedData
WHERE RowNum = 1
ORDER BY EXTRACTION_DATE ASC;




