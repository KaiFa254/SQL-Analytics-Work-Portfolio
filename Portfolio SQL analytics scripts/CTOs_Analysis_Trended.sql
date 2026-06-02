WITH transactions AS (
SELECT
    BOOKING_DATE,
    CUSTOMER_ID,
    ACCOUNT_NUMBER,
    AMOUNT_LCY

FROM
    dbcba.KE_ACCOUNT_TRANSACTIONS
WHERE
    BOOKING_DATE <= DATEADD(DAY, -(DAY(GETDATE())), CAST(GETDATE() AS DATE))  -- Current day of the month --removes the days of incomplete current month
    AND BOOKING_DATE >= DATEADD(MONTH, -12, DATEADD(DAY, -(DAY(GETDATE()) - 1), CAST(GETDATE() AS DATE))) -- One year back, minus current day minus 1
	--BOOKING_DATE BETWEEN '2025-01-01' AND '2025-01-31'
    AND AMOUNT_LCY > 0
    --AND txn_code_initiation = 'CUSTOMER'
    AND (DEBIT_CUSTOMER <> CREDIT_CUSTOMER OR DEBIT_CUSTOMER IS NULL) --Remove inter-account transfers
    AND TRANSACTION_CODE NOT IN ('1001', '944', '945''1085','766','949','945','991','941','433','1006',
    '85','234','859','940','992','947','939','946','944','948','938','1001', '967') --Remove loan disbursements, unpaid cheques
    AND SYSTEM_ID NOT IN ('AA') -- Remove credits from Fixed Deposits and any other AA module txns
    AND REVERSAL_MARKER <> 'R'
    --AND CUSTOMER_ID IN ('100001')
ORDER BY BOOKING_DATE DESC

),
account_transactions AS (
    SELECT
        acc.CUSTOMER,
        cm.CUS_NAME_1,
        cm.CUSTOMER_BRANCH_NAME,
        cm.CUS_ACC_OFFICER,
        cm.ACCOUNT_OFFICER_NAME,
        cm.BUSINESS_SEGMENT_DESC,
        cm.SUB_SEGEMENT_DESC,
        acc.Account_number AS ACCOUNT_NUMBER,
        acc.category,
        cto.BOOKING_DATE,
        cto.AMOUNT_LCY
        --COALESCE(cm.DATE_OF_BIRTH, cm.DATE_OF_BIRTHS, cm.BIRTH_INCORP_DATE) AS DOB --Pick the first non-null in that order

    FROM
        dbcba.ke_Accounts_master acc
    LEFT JOIN dbcba.ke_Customer_master cm 
        ON acc.customer = cm.Customer_number 
        AND cm.EXTRACTION_DATE = acc.EXTRACTION_DATE
    LEFT JOIN transactions cto
        ON cto.ACCOUNT_NUMBER = acc.Account_number
    WHERE
        (acc.PRODUCT_LINE = 'ACCOUNTS' OR acc.PRODUCT_LINE IS NULL)
        AND cm.EXTRACTION_DATE = (SELECT MAX(EXTRACTION_DATE) FROM dbcba.ke_Customer_master)
        AND cm.BUSINESS_SEGMENT IN ('250', '270')

),

credits AS (
SELECT 
    CUSTOMER,
    CUS_NAME_1,
	CUSTOMER_BRANCH_NAME,
	CUS_ACC_OFFICER,
	ACCOUNT_OFFICER_NAME,
	BUSINESS_SEGMENT_DESC,
	SUB_SEGEMENT_DESC,
	
    --ACCOUNT_NUMBER,
    
    
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -1, GETDATE())) THEN AMOUNT_LCY ELSE 0 END) AS [Month_1_CTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -2, GETDATE())) THEN AMOUNT_LCY ELSE 0 END) AS [Month_2_CTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -3, GETDATE())) THEN AMOUNT_LCY ELSE 0 END) AS [Month_3_CTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -4, GETDATE())) THEN AMOUNT_LCY ELSE 0 END) AS [Month_4_CTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -5, GETDATE())) THEN AMOUNT_LCY ELSE 0 END) AS [Month_5_CTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -6, GETDATE())) THEN AMOUNT_LCY ELSE 0 END) AS [Month_6_CTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -7, GETDATE())) THEN AMOUNT_LCY ELSE 0 END) AS [Month_7_CTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -8, GETDATE())) THEN AMOUNT_LCY ELSE 0 END) AS [Month_8_CTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -9, GETDATE())) THEN AMOUNT_LCY ELSE 0 END) AS [Month_9_CTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -10, GETDATE())) THEN AMOUNT_LCY ELSE 0 END) AS [Month_10_CTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -11, GETDATE())) THEN AMOUNT_LCY ELSE 0 END) AS [Month_11_CTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -12, GETDATE())) THEN AMOUNT_LCY ELSE 0 END) AS [Month_12_CTO]

    
FROM 
    account_transactions
    
GROUP BY 
    CUSTOMER,
    CUS_NAME_1,
	CUSTOMER_BRANCH_NAME,
	CUS_ACC_OFFICER,
	ACCOUNT_OFFICER_NAME,
	BUSINESS_SEGMENT_DESC,
	SUB_SEGEMENT_DESC
 
),

counts AS (

SELECT 
    CUSTOMER,
    --ACCOUNT_NUMBER,
    
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -1, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_1_CTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -2, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_2_CTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -3, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_3_CTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -4, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_4_CTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -5, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_5_CTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -6, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_6_CTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -7, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_7_CTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -8, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_8_CTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -9, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_9_CTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -10, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_10_CTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -11, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_11_CTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -12, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_12_CTO_Counts]
    
FROM 
    account_transactions
    
GROUP BY 
    CUSTOMER
   -- ACCOUNT_NUMBER
    --category
),

Q_credits AS 
(

SELECT 
	credits.CUSTOMER,
	(Month_1_CTO+Month_2_CTO+Month_3_CTO) AS Q1_CTO_Value,
	(Month_4_CTO+Month_5_CTO+Month_6_CTO) AS Q2_CTO_Value,
	(Month_7_CTO+Month_8_CTO+Month_9_CTO) AS Q3_CTO_Value,
	(Month_10_CTO+Month_11_CTO+Month_12_CTO) AS Q4_CTO_Value,
	(Month_1_CTO_Counts+Month_2_CTO_Counts+Month_3_CTO_Counts) AS Q1_CTO_Counts,
	(Month_4_CTO_Counts+Month_5_CTO_Counts+Month_6_CTO_Counts) AS Q2_CTO_Counts,
	(Month_7_CTO_Counts+Month_8_CTO_Counts+Month_9_CTO_Counts) AS Q3_CTO_Counts,
	(Month_10_CTO_Counts+Month_11_CTO_Counts+Month_12_CTO_Counts) AS Q4_CTO_Counts,
	
	CASE 
    WHEN COALESCE(Month_2_CTO, 0) = 0 THEN 0
    ELSE ROUND(
        (COALESCE(Month_1_CTO, 0) - COALESCE(Month_2_CTO, 0)) 
        / NULLIF(COALESCE(Month_2_CTO, 0), 0), 2
    )
	END AS M1M2_CTO_Amt_change_pct,

	CASE 
	    WHEN COALESCE(Month_3_CTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_2_CTO, 0) - COALESCE(Month_3_CTO, 0)) 
	        / NULLIF(COALESCE(Month_3_CTO, 0), 0), 2
	    )
	END AS M2M3_CTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_4_CTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_3_CTO, 0) - COALESCE(Month_4_CTO, 0)) 
	        / NULLIF(COALESCE(Month_4_CTO, 0), 0), 2
	    )
	END AS M3M4_CTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_5_CTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_4_CTO, 0) - COALESCE(Month_5_CTO, 0)) 
	        / NULLIF(COALESCE(Month_5_CTO, 0), 0), 2
	    )
	END AS M4M5_CTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_6_CTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_5_CTO, 0) - COALESCE(Month_6_CTO, 0)) 
	        / NULLIF(COALESCE(Month_6_CTO, 0), 0), 2
	    )
	END AS M5M6_CTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_7_CTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_6_CTO, 0) - COALESCE(Month_7_CTO, 0)) 
	        / NULLIF(COALESCE(Month_7_CTO, 0), 0), 2
	    )
	END AS M6M7_CTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_8_CTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_7_CTO, 0) - COALESCE(Month_8_CTO, 0)) 
	        / NULLIF(COALESCE(Month_8_CTO, 0), 0), 2
	    )
	END AS M7M8_CTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_9_CTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_8_CTO, 0) - COALESCE(Month_9_CTO, 0)) 
	        / NULLIF(COALESCE(Month_9_CTO, 0), 0), 2
	    )
	END AS M8M9_CTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_10_CTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_9_CTO, 0) - COALESCE(Month_10_CTO, 0)) 
	        / NULLIF(COALESCE(Month_10_CTO, 0), 0), 2
	    )
	END AS M9M10_CTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_11_CTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_10_CTO, 0) - COALESCE(Month_11_CTO, 0)) 
	        / NULLIF(COALESCE(Month_11_CTO, 0), 0), 2
	    )
	END AS M10M11_CTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_12_CTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_11_CTO, 0) - COALESCE(Month_12_CTO, 0)) 
	        / NULLIF(COALESCE(Month_12_CTO, 0), 0), 2
	    )
	END AS M11M12_CTO_Amt_change_pct,
	
	CASE 
	    WHEN (Month_4_CTO + Month_5_CTO + Month_6_CTO) = 0 THEN 0
	    ELSE ROUND(
	        ((Month_1_CTO + Month_2_CTO + Month_3_CTO) - (Month_4_CTO + Month_5_CTO + Month_6_CTO)) 
	        / CAST((Month_4_CTO + Month_5_CTO + Month_6_CTO) AS DECIMAL(18,2)), 2
	    ) 
	END AS Q1Q2_CTO_Amt_change_pct,
	
	CASE 
	    WHEN (Month_7_CTO + Month_8_CTO + Month_9_CTO) = 0 THEN 0
	    ELSE ROUND(
	        ((Month_4_CTO + Month_5_CTO + Month_6_CTO) - (Month_7_CTO + Month_8_CTO + Month_9_CTO)) 
	        / CAST((Month_7_CTO + Month_8_CTO + Month_9_CTO) AS DECIMAL(18,2)), 2
	    ) 
	END AS Q2Q3_CTO_Amt_change_pct,
	
	CASE 
	    WHEN (Month_10_CTO + Month_11_CTO + Month_12_CTO) = 0 THEN 0
	    ELSE ROUND(
	        ((Month_7_CTO + Month_8_CTO + Month_9_CTO) - (Month_10_CTO + Month_11_CTO + Month_12_CTO)) 
	        / CAST((Month_10_CTO + Month_11_CTO + Month_12_CTO) AS DECIMAL(18,2)), 2
	    ) 
	END AS Q3Q4_CTO_Amt_change_pct,
	
	CASE 
	    WHEN (Month_4_CTO_Counts + Month_5_CTO_Counts + Month_6_CTO_Counts) = 0 THEN 0
	    ELSE ROUND(
	        ((Month_1_CTO_Counts + Month_2_CTO_Counts + Month_3_CTO_Counts) - (Month_4_CTO_Counts + Month_5_CTO_Counts + Month_6_CTO_Counts)) 
	        / CAST((Month_4_CTO_Counts + Month_5_CTO_Counts + Month_6_CTO_Counts) AS DECIMAL(18,2)), 2
	    ) 
	END AS Q1Q2_CTO_Cnt_Change_pct,
	
	CASE 
	    WHEN (Month_7_CTO_Counts + Month_8_CTO_Counts + Month_9_CTO_Counts) = 0 THEN 0
	    ELSE ROUND(
	        ((Month_4_CTO_Counts + Month_5_CTO_Counts + Month_6_CTO_Counts) - (Month_7_CTO_Counts + Month_8_CTO_Counts + Month_9_CTO_Counts)) 
	        / CAST((Month_7_CTO_Counts + Month_8_CTO_Counts + Month_9_CTO_Counts) AS DECIMAL(18,2)), 2
	    ) 
	END AS Q2Q3_CTO_Cnt_Change_pct,
	
	CASE 
	    WHEN (Month_10_CTO_Counts + Month_11_CTO_Counts + Month_12_CTO_Counts) = 0 THEN 0
	    ELSE ROUND(
	        ((Month_7_CTO_Counts + Month_8_CTO_Counts + Month_9_CTO_Counts) - (Month_10_CTO_Counts + Month_11_CTO_Counts + Month_12_CTO_Counts)) 
	        / CAST((Month_10_CTO_Counts + Month_11_CTO_Counts + Month_12_CTO_Counts) AS DECIMAL(18,2)), 2
	    ) 
	END AS Q3Q4_CTO_Cnt_Change_pct
	
	/*
	CASE 
    WHEN (Month_2_CTO) = 0 THEN 0
    ELSE ROUND(
        ((Month_1_CTO) - (Month_2_CTO)) 
        / CAST((Month_2_CTO) AS DECIMAL(18,2)), 2
    ) 
	END AS CurrMonthPrevMonth_CTO_Amt_change_pct,
	
	CASE 
    WHEN (Month_2_CTO_Counts) = 0 THEN 0
    ELSE ROUND(
        ((Month_1_CTO_Counts) - (Month_2_CTO_Counts)) 
        / CAST((Month_2_CTO_Counts) AS DECIMAL(18,2)), 2
    ) 
	END AS CurrMonthPrevMonth_CTO_Cnt_change_pct
	*/
	
FROM credits
LEFT JOIN counts
ON credits.CUSTOMER = counts.CUSTOMER

)

SELECT 

/*
	credits.*,
	CAST(counts.Month_1_CTO_Counts AS INT),
	CAST(counts.Month_2_CTO_Counts AS INT),
	CAST(counts.Month_3_CTO_Counts AS INT),
	CAST(counts.Month_4_CTO_Counts AS INT),
	CAST(counts.Month_5_CTO_Counts AS INT),
	CAST(counts.Month_6_CTO_Counts AS INT),
	CAST(counts.Month_7_CTO_Counts AS INT),
	CAST(counts.Month_8_CTO_Counts AS INT),
	CAST(counts.Month_9_CTO_Counts AS INT),
	CAST(counts.Month_10_CTO_Counts AS INT),
	CAST(counts.Month_11_CTO_Counts AS INT),
	CAST(counts.Month_12_CTO_Counts AS INT),

	
	Q_credits.Q1_CTO_Value,
	Q_credits.Q2_CTO_Value,
	Q_credits.Q3_CTO_Value,
	Q_credits.Q4_CTO_Value,
	Q_credits.Q1_CTO_Counts,
	Q_credits.Q2_CTO_Counts,
	Q_credits.Q3_CTO_Counts,
	Q_credits.Q4_CTO_Counts,
*/	
	credits.CUSTOMER,
	
	Q_credits.M1M2_CTO_Amt_change_pct,
	Q_credits.M2M3_CTO_Amt_change_pct,
	Q_credits.M3M4_CTO_Amt_change_pct,
	Q_credits.M4M5_CTO_Amt_change_pct,
	Q_credits.M5M6_CTO_Amt_change_pct,
	Q_credits.M6M7_CTO_Amt_change_pct,
	Q_credits.M7M8_CTO_Amt_change_pct,
	Q_credits.M8M9_CTO_Amt_change_pct,
	Q_credits.M9M10_CTO_Amt_change_pct,
	Q_credits.M10M11_CTO_Amt_change_pct,
	Q_credits.M11M12_CTO_Amt_change_pct,
	
	Q_credits.Q1Q2_CTO_Amt_change_pct,
	Q_credits.Q2Q3_CTO_Amt_change_pct,
	Q_credits.Q3Q4_CTO_Amt_change_pct,
	Q_credits.Q1Q2_CTO_Cnt_Change_pct,
	Q_credits.Q2Q3_CTO_Cnt_Change_pct,
	Q_credits.Q3Q4_CTO_Cnt_Change_pct
	--Q_credits.CurrMonthPrevMonth_CTO_Amt_change_pct,
	--Q_credits.CurrMonthPrevMonth_CTO_Cnt_change_pct
	
FROM credits
LEFT JOIN counts
ON credits.CUSTOMER = counts.CUSTOMER
LEFT JOIN Q_credits
ON Q_credits.customer = credits.customer