---Unpaid items trended 
WITH transactions AS (
SELECT
    BOOKING_DATE,
    CUSTOMER_ID,
    ACCOUNT_NUMBER,
    (CAST(AMOUNT_LCY AS DECIMAL(18,2)) * -1) AS AMOUNT_LCY_1
    --(AMOUNT_LCY_1*-1) AS AMOUNT_LCY_1
FROM
    dbcba.KE_ACCOUNT_TRANSACTIONS
WHERE
    BOOKING_DATE <= DATEADD(DAY, -(DAY(GETDATE())), CAST(GETDATE() AS DATE))  -- Current day of the month --removes the days of incomplete current month
    AND BOOKING_DATE >= DATEADD(MONTH, -12, DATEADD(DAY, -(DAY(GETDATE()) - 1), CAST(GETDATE() AS DATE))) -- One year back, minus current day minus 1
    AND AMOUNT_LCY < 0
    --AND txn_code_initiation = 'CUSTOMER'
    AND (DEBIT_CUSTOMER <> CREDIT_CUSTOMER OR CREDIT_CUSTOMER IS NULL) --Remove inter-account transfers
    AND TRANSACTION_CODE IN ('938', '939', '940', '941', '944', '945', '946', '947', '948', '949', '991', '992','1084',	'1085',	'285',	'561',	'882',	'904',	'905',	'923') --Unpaid items Codes
    AND REVERSAL_MARKER <> 'R'
    --AND CUSTOMER_ID IN ('545179')
--ORDER BY BOOKING_DATE DESC

),
account_transactions AS (
    SELECT
        acc.CUSTOMER,
        acc.Account_number AS ACCOUNT_NUMBER,
        acc.category,
        cto.BOOKING_DATE,
        cto.AMOUNT_LCY_1
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

),

debits AS (
SELECT 
    CUSTOMER,
    --ACCOUNT_NUMBER,
    
    
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -1, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_1_Unpaid],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -2, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_2_Unpaid],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -3, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_3_Unpaid],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -4, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_4_Unpaid],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -5, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_5_Unpaid],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -6, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_6_Unpaid],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -7, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_7_Unpaid],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -8, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_8_Unpaid],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -9, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_9_Unpaid],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -10, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_10_Unpaid],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -11, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_11_Unpaid],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -12, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_12_Unpaid]
    
FROM 
    account_transactions
    
GROUP BY 
    CUSTOMER
    --ACCOUNT_NUMBER
 
),

counts AS (

SELECT 
    CUSTOMER,
    --ACCOUNT_NUMBER,
    
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -1, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_1_Unpaid_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -2, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_2_Unpaid_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -3, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_3_Unpaid_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -4, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_4_Unpaid_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -5, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_5_Unpaid_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -6, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_6_Unpaid_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -7, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_7_Unpaid_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -8, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_8_Unpaid_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -9, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_9_Unpaid_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -10, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_10_Unpaid_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -11, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_11_Unpaid_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -12, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_12_Unpaid_Counts]
    
FROM 
    account_transactions
    
GROUP BY 
    CUSTOMER
   -- ACCOUNT_NUMBER
    --category
),

Q_debits AS 
(

SELECT 
	debits.CUSTOMER,
	(Month_1_Unpaid+Month_2_Unpaid+Month_3_Unpaid) AS QI_Unpaid_Value,
	(Month_4_Unpaid+Month_5_Unpaid+Month_6_Unpaid) AS Q2_Unpaid_Value,
	(Month_7_Unpaid+Month_8_Unpaid+Month_9_Unpaid) AS Q3_Unpaid_Value,
	(Month_10_Unpaid+Month_11_Unpaid+Month_12_Unpaid) AS Q4_Unpaid_Value,
	(Month_1_Unpaid_Counts+Month_2_Unpaid_Counts+Month_3_Unpaid_Counts) AS Q1_Unpaid_Counts,
	(Month_4_Unpaid_Counts+Month_5_Unpaid_Counts+Month_6_Unpaid_Counts) AS Q2_Unpaid_Counts,
	(Month_7_Unpaid_Counts+Month_8_Unpaid_Counts+Month_9_Unpaid_Counts) AS Q3_Unpaid_Counts,
	(Month_10_Unpaid_Counts+Month_11_Unpaid_Counts+Month_12_Unpaid_Counts) AS Q4_Unpaid_Counts,
	
	CASE 
	    WHEN COALESCE(Month_4_Unpaid, 0) + COALESCE(Month_5_Unpaid, 0) + COALESCE(Month_6_Unpaid, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_1_Unpaid, 0) + COALESCE(Month_2_Unpaid, 0) + COALESCE(Month_3_Unpaid, 0) 
	        - (COALESCE(Month_4_Unpaid, 0) + COALESCE(Month_5_Unpaid, 0) + COALESCE(Month_6_Unpaid, 0))) 
	        / NULLIF((COALESCE(Month_4_Unpaid, 0) + COALESCE(Month_5_Unpaid, 0) + COALESCE(Month_6_Unpaid, 0)), 0), 2
	    ) 
	END AS Q1Q2_Unpaid_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_7_Unpaid, 0) + COALESCE(Month_8_Unpaid, 0) + COALESCE(Month_9_Unpaid, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_4_Unpaid, 0) + COALESCE(Month_5_Unpaid, 0) + COALESCE(Month_6_Unpaid, 0) 
	        - (COALESCE(Month_7_Unpaid, 0) + COALESCE(Month_8_Unpaid, 0) + COALESCE(Month_9_Unpaid, 0))) 
	        / NULLIF((COALESCE(Month_7_Unpaid, 0) + COALESCE(Month_8_Unpaid, 0) + COALESCE(Month_9_Unpaid, 0)), 0), 2
	    ) 
	END AS Q2Q3_Unpaid_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_10_Unpaid, 0) + COALESCE(Month_11_Unpaid, 0) + COALESCE(Month_12_Unpaid, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_7_Unpaid, 0) + COALESCE(Month_8_Unpaid, 0) + COALESCE(Month_9_Unpaid, 0) 
	        - (COALESCE(Month_10_Unpaid, 0) + COALESCE(Month_11_Unpaid, 0) + COALESCE(Month_12_Unpaid, 0))) 
	        / NULLIF((COALESCE(Month_10_Unpaid, 0) + COALESCE(Month_11_Unpaid, 0) + COALESCE(Month_12_Unpaid, 0)), 0), 2
	    ) 
	END AS Q3Q4_Unpaid_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_4_Unpaid_Counts, 0) + COALESCE(Month_5_Unpaid_Counts, 0) + COALESCE(Month_6_Unpaid_Counts, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_1_Unpaid_Counts, 0) + COALESCE(Month_2_Unpaid_Counts, 0) + COALESCE(Month_3_Unpaid_Counts, 0) 
	        - (COALESCE(Month_4_Unpaid_Counts, 0) + COALESCE(Month_5_Unpaid_Counts, 0) + COALESCE(Month_6_Unpaid_Counts, 0))) 
	        / NULLIF((COALESCE(Month_4_Unpaid_Counts, 0) + COALESCE(Month_5_Unpaid_Counts, 0) + COALESCE(Month_6_Unpaid_Counts, 0)), 0), 2
	    ) 
	END AS Q1Q2_Unpaid_Cnt_Change_pct,
	
	CASE 
	    WHEN COALESCE(Month_7_Unpaid_Counts, 0) + COALESCE(Month_8_Unpaid_Counts, 0) + COALESCE(Month_9_Unpaid_Counts, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_4_Unpaid_Counts, 0) + COALESCE(Month_5_Unpaid_Counts, 0) + COALESCE(Month_6_Unpaid_Counts, 0) 
	        - (COALESCE(Month_7_Unpaid_Counts, 0) + COALESCE(Month_8_Unpaid_Counts, 0) + COALESCE(Month_9_Unpaid_Counts, 0))) 
	        / NULLIF((COALESCE(Month_7_Unpaid_Counts, 0) + COALESCE(Month_8_Unpaid_Counts, 0) + COALESCE(Month_9_Unpaid_Counts, 0)), 0), 2
	    ) 
	END AS Q2Q3_Unpaid_Cnt_Change_pct,
	
	CASE 
	    WHEN COALESCE(Month_10_Unpaid_Counts, 0) + COALESCE(Month_11_Unpaid_Counts, 0) + COALESCE(Month_12_Unpaid_Counts, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_7_Unpaid_Counts, 0) + COALESCE(Month_8_Unpaid_Counts, 0) + COALESCE(Month_9_Unpaid_Counts, 0) 
	        - (COALESCE(Month_10_Unpaid_Counts, 0) + COALESCE(Month_11_Unpaid_Counts, 0) + COALESCE(Month_12_Unpaid_Counts, 0))) 
	        / NULLIF((COALESCE(Month_10_Unpaid_Counts, 0) + COALESCE(Month_11_Unpaid_Counts, 0) + COALESCE(Month_12_Unpaid_Counts, 0)), 0), 2
	    ) 
	END AS Q3Q4_Unpaid_Cnt_Change_pct,
	
	CASE 
	    WHEN COALESCE(Month_2_Unpaid, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_1_Unpaid, 0) - COALESCE(Month_2_Unpaid, 0)) 
	        / NULLIF(COALESCE(Month_2_Unpaid, 0), 0), 2
	    ) 
	END AS CurrMonthPrevMonth_Unpaid_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_2_Unpaid_Counts, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_1_Unpaid_Counts, 0) - COALESCE(Month_2_Unpaid_Counts, 0)) 
	        / NULLIF(COALESCE(Month_2_Unpaid_Counts, 0), 0), 2
	    ) 
	END AS CurrMonthPrevMonth_Unpaid_Cnt_change_pct

	
FROM debits
LEFT JOIN counts
ON debits.CUSTOMER = counts.CUSTOMER

)

SELECT 
/*
	debits.*,
	CAST(counts.Month_1_Unpaid_Counts AS INT),
	CAST(counts.Month_2_Unpaid_Counts AS INT),
	CAST(counts.Month_3_Unpaid_Counts AS INT),
	CAST(counts.Month_4_Unpaid_Counts AS INT),
	CAST(counts.Month_5_Unpaid_Counts AS INT),
	CAST(counts.Month_6_Unpaid_Counts AS INT),
	CAST(counts.Month_7_Unpaid_Counts AS INT),
	CAST(counts.Month_8_Unpaid_Counts AS INT),
	CAST(counts.Month_9_Unpaid_Counts AS INT),
	CAST(counts.Month_10_Unpaid_Counts AS INT),
	CAST(counts.Month_11_Unpaid_Counts AS INT),
	CAST(counts.Month_12_Unpaid_Counts AS INT),
*/
	debits.CUSTOMER,
	Q_debits.QI_Unpaid_Value,
	Q_debits.Q2_Unpaid_Value,
	Q_debits.Q3_Unpaid_Value,
	Q_debits.Q4_Unpaid_Value,
	Q_debits.Q1_Unpaid_Counts,
	Q_debits.Q2_Unpaid_Counts,
	Q_debits.Q3_Unpaid_Counts,
	Q_debits.Q4_Unpaid_Counts,
	Q_debits.Q1Q2_Unpaid_Amt_change_pct,
	Q_debits.Q2Q3_Unpaid_Amt_change_pct,
	Q_debits.Q3Q4_Unpaid_Amt_change_pct,
	Q_debits.Q1Q2_Unpaid_Cnt_Change_pct,
	Q_debits.Q2Q3_Unpaid_Cnt_Change_pct,
	Q_debits.Q3Q4_Unpaid_Cnt_Change_pct,
	Q_debits.CurrMonthPrevMonth_Unpaid_Amt_change_pct,
	Q_debits.CurrMonthPrevMonth_Unpaid_Cnt_change_pct
	
	
	
	
FROM debits
LEFT JOIN counts
ON debits.CUSTOMER = counts.CUSTOMER
LEFT JOIN Q_debits
ON Q_debits.customer = debits.customer




    
    
    