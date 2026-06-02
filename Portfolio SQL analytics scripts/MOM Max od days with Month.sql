WITH ODS AS (
    SELECT 
        EXTRACTION_DATE, 
        CAST(MONTH(EXTRACTION_DATE) AS VARCHAR) || '-' || CAST(YEAR(EXTRACTION_DATE) AS VARCHAR) AS Month_year,
        CUSTOMER, 
        ARREARS_KES, 
        OD_DAYS
    FROM 
        SVUPHSIQDBPR.STGKE.STG_AA_BILL_ARREARS A
    WHERE A.EXTRACTION_DATE BETWEEN '2024-04-01' AND '2025-06-18'
),
FilteredODS AS (
    -- Only include March to June 2025 months for MaxODS
    SELECT *
    FROM ODS
    WHERE Month_year IN ('4-2025', '5-2025', '6-2025')
),
MaxODS AS (
    SELECT 
        CUSTOMER, 
        Month_year, 
        OD_DAYS,
        ROW_NUMBER() OVER (PARTITION BY CUSTOMER ORDER BY OD_DAYS DESC) AS rn
    FROM FilteredODS
)

SELECT
    o.CUSTOMER,
    MAX(CASE WHEN o.Month_year = '4-2025' THEN o.OD_DAYS ELSE 0 END) AS Max_OD_Days_Apr_2025,
    MAX(CASE WHEN o.Month_year = '5-2025' THEN o.OD_DAYS ELSE 0 END) AS Max_OD_Days_May_2025,
    MAX(CASE WHEN o.Month_year = '6-2025' THEN o.OD_DAYS ELSE 0 END) AS Max_OD_Days_Jun_2025,

    CASE 
        WHEN 
            MAX(CASE WHEN o.Month_year = '4-2025' THEN o.OD_DAYS ELSE 0 END) > 1 OR
            MAX(CASE WHEN o.Month_year = '5-2025' THEN o.OD_DAYS ELSE 0 END) > 1 OR
            MAX(CASE WHEN o.Month_year = '6-2025' THEN o.OD_DAYS ELSE 0 END) > 1 
        THEN 'Yes'
        ELSE 'No'
    END AS Any_Month_Above_1DPD,

    m.Month_year AS Month_With_Max_OD_Days,
    m.OD_DAYS AS Max_OD_Days_Overall

FROM FilteredODS o
LEFT JOIN MaxODS m ON o.CUSTOMER = m.CUSTOMER AND m.rn = 1
GROUP BY o.CUSTOMER, m.Month_year, m.OD_DAYS;
