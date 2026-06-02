WITH SnapshotDates AS (

    SELECT DISTINCT
        EXTRACTION_DATE AS SNAPSHOT_DATE
    FROM dbcba.KE_Accounts_Master
    WHERE EXTRACTION_DATE IN (
        '2025-06-30','2025-07-31','2025-08-31',
        '2025-09-30','2025-10-31','2025-11-30'
    )
),

FilteredCustomers AS (

    SELECT
        am.CUSTOMER AS CUSTOMER_ID
    FROM dbcba.KE_Accounts_List am
    JOIN dbcba.KE_Customer_Master cm
        ON cm.CUSTOMER_NUMBER = am.CUSTOMER
    WHERE am.PRODUCT_LINE = 'LENDING'
      AND am.ARR_STATUS = 'CURRENT'
      AND cm.BUSINESS_SEGMENT IN ('270','250')
      AND COALESCE(am.ONLINE_ACTUAL_BAL,0) < 0
      AND am.CUSTOMER IS NOT NULL
),

-- Precompute Base Balances with Month Offset
BaseBalances AS (

    SELECT
        s.SNAPSHOT_DATE,
        acc.CUSTOMER AS CUSTOMER_ID,
        avg_bal.Account_number,
        avg_bal.Av_Bal_Date,
        CAST(avg_bal.CUMULATIVE_BAL_LCY AS DECIMAL(18,2)) AS AMOUNT_LCY,
        avg_bal.NUM_DAYS,
        DATEDIFF(MONTH, avg_bal.Av_Bal_Date, s.SNAPSHOT_DATE) AS MonthOffset
    FROM SnapshotDates s
    JOIN dbcba.KE_Accounts_master acc
        ON acc.EXTRACTION_DATE = s.SNAPSHOT_DATE
    JOIN FilteredCustomers fc
        ON acc.CUSTOMER = fc.CUSTOMER_ID
    LEFT JOIN STGKE.STG_AVERAGE_BALANCE avg_bal
        ON avg_bal.Account_number = acc.Account_number
       AND avg_bal.Av_Bal_Date <= s.SNAPSHOT_DATE
       AND avg_bal.Av_Bal_Date > DATEADD(MONTH,-12,s.SNAPSHOT_DATE)
    WHERE acc.PRODUCT_LINE = 'ACCOUNTS'
),

-- Aggregate Monthly Balances Efficiently
Monthly AS (

    SELECT
        SNAPSHOT_DATE,
        CUSTOMER_ID,

        SUM(CASE WHEN MonthOffset=0  THEN AMOUNT_LCY ELSE 0 END) AS M1,
        SUM(CASE WHEN MonthOffset=1  THEN AMOUNT_LCY ELSE 0 END) AS M2,
        SUM(CASE WHEN MonthOffset=2  THEN AMOUNT_LCY ELSE 0 END) AS M3,
        SUM(CASE WHEN MonthOffset=3  THEN AMOUNT_LCY ELSE 0 END) AS M4,
        SUM(CASE WHEN MonthOffset=4  THEN AMOUNT_LCY ELSE 0 END) AS M5,
        SUM(CASE WHEN MonthOffset=5  THEN AMOUNT_LCY ELSE 0 END) AS M6,
        SUM(CASE WHEN MonthOffset=6  THEN AMOUNT_LCY ELSE 0 END) AS M7,
        SUM(CASE WHEN MonthOffset=7  THEN AMOUNT_LCY ELSE 0 END) AS M8,
        SUM(CASE WHEN MonthOffset=8  THEN AMOUNT_LCY ELSE 0 END) AS M9,
        SUM(CASE WHEN MonthOffset=9  THEN AMOUNT_LCY ELSE 0 END) AS M10,
        SUM(CASE WHEN MonthOffset=10 THEN AMOUNT_LCY ELSE 0 END) AS M11,
        SUM(CASE WHEN MonthOffset=11 THEN AMOUNT_LCY ELSE 0 END) AS M12

    FROM BaseBalances
    GROUP BY SNAPSHOT_DATE, CUSTOMER_ID
),

-- Month-to-Month and Quarter-to-Quarter Trends
TrendedFeatures AS (

    SELECT
        CUSTOMER_ID,
        SNAPSHOT_DATE,

        ROUND(CASE WHEN M2=0  THEN NULL ELSE (M1-M2)/NULLIF(M2,0)  END,2) AS M1M2_Change,
        ROUND(CASE WHEN M3=0  THEN NULL ELSE (M2-M3)/NULLIF(M3,0)  END,2) AS M2M3_Change,
        ROUND(CASE WHEN M4=0  THEN NULL ELSE (M3-M4)/NULLIF(M4,0)  END,2) AS M3M4_Change,
        ROUND(CASE WHEN M5=0  THEN NULL ELSE (M4-M5)/NULLIF(M5,0)  END,2) AS M4M5_Change,
        ROUND(CASE WHEN M6=0  THEN NULL ELSE (M5-M6)/NULLIF(M6,0)  END,2) AS M5M6_Change,
        ROUND(CASE WHEN M7=0  THEN NULL ELSE (M6-M7)/NULLIF(M7,0)  END,2) AS M6M7_Change,
        ROUND(CASE WHEN M8=0  THEN NULL ELSE (M7-M8)/NULLIF(M8,0)  END,2) AS M7M8_Change,
        ROUND(CASE WHEN M9=0  THEN NULL ELSE (M8-M9)/NULLIF(M9,0)  END,2) AS M8M9_Change,
        ROUND(CASE WHEN M10=0 THEN NULL ELSE (M9-M10)/NULLIF(M10,0) END,2) AS M9M10_Change,
        ROUND(CASE WHEN M11=0 THEN NULL ELSE (M10-M11)/NULLIF(M11,0) END,2) AS M10M11_Change,
        ROUND(CASE WHEN M12=0 THEN NULL ELSE (M11-M12)/NULLIF(M12,0) END,2) AS M11M12_Change,

        ROUND(
            CASE WHEN (M4+M5+M6)=0 THEN NULL
                 ELSE ((M1+M2+M3)-(M4+M5+M6))/NULLIF((M4+M5+M6),0)
            END,2
        ) AS Q1Q2_Change,

        ROUND(
            CASE WHEN (M7+M8+M9)=0 THEN NULL
                 ELSE ((M4+M5+M6)-(M7+M8+M9))/NULLIF((M7+M8+M9),0)
            END,2
        ) AS Q2Q3_Change,

        ROUND(
            CASE WHEN (M10+M11+M12)=0 THEN NULL
                 ELSE ((M7+M8+M9)-(M10+M11+M12))/NULLIF((M10+M11+M12),0)
            END,2
        ) AS Q3Q4_Change

    FROM Monthly
),

-- Precompute Snapshot 12M Average
SnapshotAvg AS (

    SELECT
        s.SNAPSHOT_DATE,
        acc.CUSTOMER AS CUSTOMER_ID,
        ROUND(
            SUM(avg_bal.CUMULATIVE_BAL_LCY) /
            NULLIF(SUM(avg_bal.NUM_DAYS),0)
        ,2) AS AVG_BAL_12M
    FROM SnapshotDates s
    JOIN dbcba.KE_Accounts_master acc
        ON acc.EXTRACTION_DATE = s.SNAPSHOT_DATE
    LEFT JOIN STGKE.STG_AVERAGE_BALANCE avg_bal
        ON avg_bal.Account_number = acc.Account_number
       AND avg_bal.Av_Bal_Date <= s.SNAPSHOT_DATE
       AND avg_bal.Av_Bal_Date > DATEADD(MONTH,-12,s.SNAPSHOT_DATE)
    WHERE acc.PRODUCT_LINE = 'ACCOUNTS'
    GROUP BY s.SNAPSHOT_DATE, acc.CUSTOMER
)

-- Final Output
SELECT
    s.CUSTOMER_ID,
    s.SNAPSHOT_DATE,
    s.AVG_BAL_12M,

    t.M1M2_Change,
    t.M2M3_Change,
    t.M3M4_Change,
    t.M4M5_Change,
    t.M5M6_Change,
    t.M6M7_Change,
    t.M7M8_Change,
    t.M8M9_Change,
    t.M9M10_Change,
    t.M10M11_Change,
    t.M11M12_Change,

    t.Q1Q2_Change,
    t.Q2Q3_Change,
    t.Q3Q4_Change

FROM SnapshotAvg s
LEFT JOIN TrendedFeatures t
    ON s.CUSTOMER_ID = t.CUSTOMER_ID
   AND s.SNAPSHOT_DATE = t.SNAPSHOT_DATE

ORDER BY s.SNAPSHOT_DATE, s.CUSTOMER_ID;
