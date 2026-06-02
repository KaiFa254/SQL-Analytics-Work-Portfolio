---DTO_Analysis Trended
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
    AND TRANSACTION_CODE NOT IN ('433', '234', '938', '939', '940', '941', '991', '992') --Remove unpaid items and bank charges
    AND REVERSAL_MARKER <> 'R'
    --AND CUSTOMER_ID IN ('545179')
--ORDER BY BOOKING_DATE DESC

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
        cto.AMOUNT_LCY_1

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

debits AS (
SELECT 
    CUSTOMER,
    CUS_NAME_1,
	CUSTOMER_BRANCH_NAME,
	CUS_ACC_OFFICER,
	ACCOUNT_OFFICER_NAME,
	BUSINESS_SEGMENT_DESC,
	SUB_SEGEMENT_DESC,
    --ACCOUNT_NUMBER,
    
    
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -1, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_1_DTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -2, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_2_DTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -3, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_3_DTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -4, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_4_DTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -5, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_5_DTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -6, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_6_DTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -7, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_7_DTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -8, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_8_DTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -9, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_9_DTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -10, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_10_DTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -11, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_11_DTO],
    SUM(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -12, GETDATE())) THEN AMOUNT_LCY_1 ELSE 0 END) AS [Month_12_DTO]
    
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
    
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -1, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_1_DTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -2, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_2_DTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -3, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_3_DTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -4, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_4_DTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -5, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_5_DTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -6, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_6_DTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -7, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_7_DTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -8, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_8_DTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -9, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_9_DTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -10, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_10_DTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -11, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_11_DTO_Counts],
    COUNT(CASE WHEN DATENAME(MONTH, BOOKING_DATE) = DATENAME(MONTH, DATEADD(MONTH, -12, GETDATE())) THEN CUSTOMER ELSE NULL END) AS [Month_12_DTO_Counts]
    
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
	(Month_1_DTO+Month_2_DTO+Month_3_DTO) AS Q1_DTO_Value,
	(Month_4_DTO+Month_5_DTO+Month_6_DTO) AS Q2_DTO_Value,
	(Month_7_DTO+Month_8_DTO+Month_9_DTO) AS Q3_DTO_Value,
	(Month_10_DTO+Month_11_DTO+Month_12_DTO) AS Q4_DTO_Value,
	(Month_1_DTO_Counts+Month_2_DTO_Counts+Month_3_DTO_Counts) AS Q1_DTO_Counts,
	(Month_4_DTO_Counts+Month_5_DTO_Counts+Month_6_DTO_Counts) AS Q2_DTO_Counts,
	(Month_7_DTO_Counts+Month_8_DTO_Counts+Month_9_DTO_Counts) AS Q3_DTO_Counts,
	(Month_10_DTO_Counts+Month_11_DTO_Counts+Month_12_DTO_Counts) AS Q4_DTO_Counts,
	
	CASE 
	    WHEN COALESCE(Month_2_DTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_1_DTO, 0) - COALESCE(Month_2_DTO, 0)) 
	        / NULLIF(COALESCE(Month_2_DTO, 0), 0), 2
	    )
	END AS M1M2_DTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_3_DTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_2_DTO, 0) - COALESCE(Month_3_DTO, 0)) 
	        / NULLIF(COALESCE(Month_3_DTO, 0), 0), 2
	    )
	END AS M2M3_DTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_4_DTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_3_DTO, 0) - COALESCE(Month_4_DTO, 0)) 
	        / NULLIF(COALESCE(Month_4_DTO, 0), 0), 2
	    )
	END AS M3M4_DTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_5_DTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_4_DTO, 0) - COALESCE(Month_5_DTO, 0)) 
	        / NULLIF(COALESCE(Month_5_DTO, 0), 0), 2
	    )
	END AS M4M5_DTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_6_DTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_5_DTO, 0) - COALESCE(Month_6_DTO, 0)) 
	        / NULLIF(COALESCE(Month_6_DTO, 0), 0), 2
	    )
	END AS M5M6_DTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_7_DTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_6_DTO, 0) - COALESCE(Month_7_DTO, 0)) 
	        / NULLIF(COALESCE(Month_7_DTO, 0), 0), 2
	    )
	END AS M6M7_DTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_8_DTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_7_DTO, 0) - COALESCE(Month_8_DTO, 0)) 
	        / NULLIF(COALESCE(Month_8_DTO, 0), 0), 2
	    )
	END AS M7M8_DTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_9_DTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_8_DTO, 0) - COALESCE(Month_9_DTO, 0)) 
	        / NULLIF(COALESCE(Month_9_DTO, 0), 0), 2
	    )
	END AS M8M9_DTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_10_DTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_9_DTO, 0) - COALESCE(Month_10_DTO, 0)) 
	        / NULLIF(COALESCE(Month_10_DTO, 0), 0), 2
	    )
	END AS M9M10_DTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_11_DTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_10_DTO, 0) - COALESCE(Month_11_DTO, 0)) 
	        / NULLIF(COALESCE(Month_11_DTO, 0), 0), 2
	    )
	END AS M10M11_DTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_12_DTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_11_DTO, 0) - COALESCE(Month_12_DTO, 0)) 
	        / NULLIF(COALESCE(Month_12_DTO, 0), 0), 2
	    )
	END AS M11M12_DTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_4_DTO, 0) + COALESCE(Month_5_DTO, 0) + COALESCE(Month_6_DTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_1_DTO, 0) + COALESCE(Month_2_DTO, 0) + COALESCE(Month_3_DTO, 0) 
	        - (COALESCE(Month_4_DTO, 0) + COALESCE(Month_5_DTO, 0) + COALESCE(Month_6_DTO, 0))) 
	        / NULLIF((COALESCE(Month_4_DTO, 0) + COALESCE(Month_5_DTO, 0) + COALESCE(Month_6_DTO, 0)), 0), 2
	    ) 
	END AS Q1Q2_DTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_7_DTO, 0) + COALESCE(Month_8_DTO, 0) + COALESCE(Month_9_DTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_4_DTO, 0) + COALESCE(Month_5_DTO, 0) + COALESCE(Month_6_DTO, 0) 
	        - (COALESCE(Month_7_DTO, 0) + COALESCE(Month_8_DTO, 0) + COALESCE(Month_9_DTO, 0))) 
	        / NULLIF((COALESCE(Month_7_DTO, 0) + COALESCE(Month_8_DTO, 0) + COALESCE(Month_9_DTO, 0)), 0), 2
	    ) 
	END AS Q2Q3_DTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_10_DTO, 0) + COALESCE(Month_11_DTO, 0) + COALESCE(Month_12_DTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_7_DTO, 0) + COALESCE(Month_8_DTO, 0) + COALESCE(Month_9_DTO, 0) 
	        - (COALESCE(Month_10_DTO, 0) + COALESCE(Month_11_DTO, 0) + COALESCE(Month_12_DTO, 0))) 
	        / NULLIF((COALESCE(Month_10_DTO, 0) + COALESCE(Month_11_DTO, 0) + COALESCE(Month_12_DTO, 0)), 0), 2
	    ) 
	END AS Q3Q4_DTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_4_DTO_Counts, 0) + COALESCE(Month_5_DTO_Counts, 0) + COALESCE(Month_6_DTO_Counts, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_1_DTO_Counts, 0) + COALESCE(Month_2_DTO_Counts, 0) + COALESCE(Month_3_DTO_Counts, 0) 
	        - (COALESCE(Month_4_DTO_Counts, 0) + COALESCE(Month_5_DTO_Counts, 0) + COALESCE(Month_6_DTO_Counts, 0))) 
	        / NULLIF((COALESCE(Month_4_DTO_Counts, 0) + COALESCE(Month_5_DTO_Counts, 0) + COALESCE(Month_6_DTO_Counts, 0)), 0), 2
	    ) 
	END AS Q1Q2_DTO_Cnt_Change_pct,
	
	CASE 
	    WHEN COALESCE(Month_7_DTO_Counts, 0) + COALESCE(Month_8_DTO_Counts, 0) + COALESCE(Month_9_DTO_Counts, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_4_DTO_Counts, 0) + COALESCE(Month_5_DTO_Counts, 0) + COALESCE(Month_6_DTO_Counts, 0) 
	        - (COALESCE(Month_7_DTO_Counts, 0) + COALESCE(Month_8_DTO_Counts, 0) + COALESCE(Month_9_DTO_Counts, 0))) 
	        / NULLIF((COALESCE(Month_7_DTO_Counts, 0) + COALESCE(Month_8_DTO_Counts, 0) + COALESCE(Month_9_DTO_Counts, 0)), 0), 2
	    ) 
	END AS Q2Q3_DTO_Cnt_Change_pct,
	
	CASE 
	    WHEN COALESCE(Month_10_DTO_Counts, 0) + COALESCE(Month_11_DTO_Counts, 0) + COALESCE(Month_12_DTO_Counts, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_7_DTO_Counts, 0) + COALESCE(Month_8_DTO_Counts, 0) + COALESCE(Month_9_DTO_Counts, 0) 
	        - (COALESCE(Month_10_DTO_Counts, 0) + COALESCE(Month_11_DTO_Counts, 0) + COALESCE(Month_12_DTO_Counts, 0))) 
	        / NULLIF((COALESCE(Month_10_DTO_Counts, 0) + COALESCE(Month_11_DTO_Counts, 0) + COALESCE(Month_12_DTO_Counts, 0)), 0), 2
	    ) 
	END AS Q3Q4_DTO_Cnt_Change_pct
	/*
	CASE 
	    WHEN COALESCE(Month_2_DTO, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_1_DTO, 0) - COALESCE(Month_2_DTO, 0)) 
	        / NULLIF(COALESCE(Month_2_DTO, 0), 0), 2
	    ) 
	END AS CurrMonthPrevMonth_DTO_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_2_DTO_Counts, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_1_DTO_Counts, 0) - COALESCE(Month_2_DTO_Counts, 0)) 
	        / NULLIF(COALESCE(Month_2_DTO_Counts, 0), 0), 2
	    ) 
	END AS CurrMonthPrevMonth_DTO_Cnt_change_pct
	*/


	
FROM debits
LEFT JOIN counts
ON debits.CUSTOMER = counts.CUSTOMER

)

SELECT 
	/*
	debits.*,
	CAST(counts.Month_1_DTO_Counts AS INT),
	CAST(counts.Month_2_DTO_Counts AS INT),
	CAST(counts.Month_3_DTO_Counts AS INT),
	CAST(counts.Month_4_DTO_Counts AS INT),
	CAST(counts.Month_5_DTO_Counts AS INT),
	CAST(counts.Month_6_DTO_Counts AS INT),
	CAST(counts.Month_7_DTO_Counts AS INT),
	CAST(counts.Month_8_DTO_Counts AS INT),
	CAST(counts.Month_9_DTO_Counts AS INT),
	CAST(counts.Month_10_DTO_Counts AS INT),
	CAST(counts.Month_11_DTO_Counts AS INT),
	CAST(counts.Month_12_DTO_Counts AS INT),

	Q_debits.Q1_DTO_Value,
	Q_debits.Q2_DTO_Value,
	Q_debits.Q3_DTO_Value,
	Q_debits.Q4_DTO_Value,
	Q_debits.Q1_DTO_Counts,
	Q_debits.Q2_DTO_Counts,
	Q_debits.Q3_DTO_Counts,
	Q_debits.Q4_DTO_Counts,
	*/

	debits.CUSTOMER,
	Q_debits.M1M2_DTO_Amt_change_pct,
	Q_debits.M2M3_DTO_Amt_change_pct,
	Q_debits.M3M4_DTO_Amt_change_pct,
	Q_debits.M4M5_DTO_Amt_change_pct,
	Q_debits.M5M6_DTO_Amt_change_pct,
	Q_debits.M6M7_DTO_Amt_change_pct,
	Q_debits.M7M8_DTO_Amt_change_pct,
	Q_debits.M8M9_DTO_Amt_change_pct,
	Q_debits.M9M10_DTO_Amt_change_pct,
	Q_debits.M10M11_DTO_Amt_change_pct,
	Q_debits.M11M12_DTO_Amt_change_pct,	
	
	Q_debits.Q1Q2_DTO_Amt_change_pct,
	Q_debits.Q2Q3_DTO_Amt_change_pct,
	Q_debits.Q3Q4_DTO_Amt_change_pct,
	Q_debits.Q1Q2_DTO_Cnt_Change_pct,
	Q_debits.Q2Q3_DTO_Cnt_Change_pct,
	Q_debits.Q3Q4_DTO_Cnt_Change_pct
	--Q_debits.CurrMonthPrevMonth_DTO_Amt_change_pct,
	--Q_debits.CurrMonthPrevMonth_DTO_Cnt_change_pct
	
FROM debits
LEFT JOIN counts
ON debits.CUSTOMER = counts.CUSTOMER
LEFT JOIN Q_debits
ON Q_debits.customer = debits.customer
and Q_debits.customer=