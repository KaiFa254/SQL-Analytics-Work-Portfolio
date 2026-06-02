---AVERAGE BALANCE TRENDED 12 MONTHS 
WITH RankedDates AS (
    SELECT 
        acc.CUSTOMER,
    	acc.Account_number,
    	avg_bal.Av_Bal_Date,
    	avg_bal.CUMULATIVE_BAL_LCY,
    	avg_bal.NUM_DAYS,
    	ROUND((CUMULATIVE_BAL_LCY/NUM_DAYS),2) AS AVG_BAL,    
        YEAR(Av_Bal_Date) AS year_num,
        MONTH(Av_Bal_Date) AS month_num,
        ROW_NUMBER() OVER (PARTITION BY YEAR(avg_bal.Av_Bal_Date), MONTH(avg_bal.Av_Bal_Date),  acc.CUSTOMER
                           ORDER BY avg_bal.Av_Bal_Date DESC) AS rn
    FROM dbcba.ke_Accounts_master acc 
    LEFT JOIN STGKE.STG_AVERAGE_BALANCE avg_bal
    ON avg_bal.Account_number = acc.Account_number
    LEFT JOIN dbcba.ke_Customer_master cm 
    ON acc.customer = cm.Customer_number 
    AND cm.EXTRACTION_DATE = acc.EXTRACTION_DATE
    
    
    WHERE acc.PRODUCT_LINE IN ('ACCOUNTS')
    AND Av_Bal_Date <= DATEADD(DAY, -(DAY(GETDATE())), CAST(GETDATE() AS DATE))
    AND Av_Bal_Date >= DATEADD(MONTH, -11, DATEADD(DAY, -(DAY(GETDATE())), CAST(GETDATE() AS DATE)))
    --AND Av_Bal_Date BETWEEN '2025-01-01' AND '2025-01-31' --quick validation
    --AND cm.CUSTOMER_NUMBER IN ('114620')
    AND cm.EXTRACTION_DATE = (SELECT MAX(EXTRACTION_DATE) FROM dbcba.ke_Customer_master)
    AND cm.BUSINESS_SEGMENT IN ('250', '270', '260')
    ORDER BY acc.CUSTOMER DESC, avg_bal.Av_Bal_Date DESC
)
,

FilteredMonths AS 
(
   
    SELECT 
    	Av_Bal_Date,
    	CUSTOMER,
    	--Account_number,
    	SUM(CUMULATIVE_BAL_LCY) AS CUMULATIVE_BAL_LCY,
    	--NUM_DAYS,
    	SUM(AVG_BAL) AS AVG_BAL,
    	year_num,
    	month_num	
    
FROM RankedDates

WHERE RankedDates.rn = 1 
GROUP BY CUSTOMER, year_num, month_num, Av_Bal_Date

)
,

PivotedData AS 
(
    SELECT 
        ranked.CUSTOMER, 
        MAX(CASE WHEN month_rank = 1 THEN AVG_BAL END) AS Month_1_Bal,
        MAX(CASE WHEN month_rank = 2 THEN AVG_BAL END) AS Month_2_Bal,
        MAX(CASE WHEN month_rank = 3 THEN AVG_BAL END) AS Month_3_Bal,
        MAX(CASE WHEN month_rank = 4 THEN AVG_BAL END) AS Month_4_Bal,
        MAX(CASE WHEN month_rank = 5 THEN AVG_BAL END) AS Month_5_Bal,
        MAX(CASE WHEN month_rank = 6 THEN AVG_BAL END) AS Month_6_Bal,
        MAX(CASE WHEN month_rank = 7 THEN AVG_BAL END) AS Month_7_Bal,
        MAX(CASE WHEN month_rank = 8 THEN AVG_BAL END) AS Month_8_Bal,
        MAX(CASE WHEN month_rank = 9 THEN AVG_BAL END) AS Month_9_Bal,
        MAX(CASE WHEN month_rank = 10 THEN AVG_BAL END) AS Month_10_Bal,
        MAX(CASE WHEN month_rank = 11 THEN AVG_BAL END) AS Month_11_Bal,
        MAX(CASE WHEN month_rank = 12 THEN AVG_BAL END) AS Month_12_Bal
    FROM (
        SELECT 
            f.CUSTOMER,
            f.AVG_BAL,
            DENSE_RANK() OVER (ORDER BY f.year_num DESC, f.month_num DESC) AS month_rank
        FROM FilteredMonths f
    ) ranked
    GROUP BY ranked.CUSTOMER
)

SELECT 
	PivotedData.CUSTOMER,
	--(Month_1_Bal+Month_2_Bal+Month_3_Bal) AS Q1_Bal_Value,
	--(Month_4_Bal+Month_5_Bal+Month_6_Bal) AS Q2_Bal_Value,
	--(Month_7_Bal+Month_8_Bal+Month_9_Bal) AS Q3_Bal_Value,
	--(Month_10_Bal+Month_11_Bal+Month_12_Bal) AS Q4_Bal_Value,
	
	CASE 
    WHEN COALESCE(Month_2_Bal, 0) = 0 THEN 0
    ELSE ROUND(
        (COALESCE(Month_1_Bal, 0) - COALESCE(Month_2_Bal, 0)) 
        / NULLIF(COALESCE(Month_2_Bal, 0), 0), 2
    )
	END AS M1M2_Bal_Amt_change_pct,

	CASE 
	    WHEN COALESCE(Month_3_Bal, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_2_Bal, 0) - COALESCE(Month_3_Bal, 0)) 
	        / NULLIF(COALESCE(Month_3_Bal, 0), 0), 2
	    )
	END AS M2M3_Bal_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_4_Bal, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_3_Bal, 0) - COALESCE(Month_4_Bal, 0)) 
	        / NULLIF(COALESCE(Month_4_Bal, 0), 0), 2
	    )
	END AS M3M4_Bal_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_5_Bal, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_4_Bal, 0) - COALESCE(Month_5_Bal, 0)) 
	        / NULLIF(COALESCE(Month_5_Bal, 0), 0), 2
	    )
	END AS M4M5_Bal_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_6_Bal, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_5_Bal, 0) - COALESCE(Month_6_Bal, 0)) 
	        / NULLIF(COALESCE(Month_6_Bal, 0), 0), 2
	    )
	END AS M5M6_Bal_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_7_Bal, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_6_Bal, 0) - COALESCE(Month_7_Bal, 0)) 
	        / NULLIF(COALESCE(Month_7_Bal, 0), 0), 2
	    )
	END AS M6M7_Bal_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_8_Bal, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_7_Bal, 0) - COALESCE(Month_8_Bal, 0)) 
	        / NULLIF(COALESCE(Month_8_Bal, 0), 0), 2
	    )
	END AS M7M8_Bal_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_9_Bal, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_8_Bal, 0) - COALESCE(Month_9_Bal, 0)) 
	        / NULLIF(COALESCE(Month_9_Bal, 0), 0), 2
	    )
	END AS M8M9_Bal_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_10_Bal, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_9_Bal, 0) - COALESCE(Month_10_Bal, 0)) 
	        / NULLIF(COALESCE(Month_10_Bal, 0), 0), 2
	    )
	END AS M9M10_Bal_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_11_Bal, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_10_Bal, 0) - COALESCE(Month_11_Bal, 0)) 
	        / NULLIF(COALESCE(Month_11_Bal, 0), 0), 2
	    )
	END AS M10M11_Bal_Amt_change_pct,
	
	CASE 
	    WHEN COALESCE(Month_12_Bal, 0) = 0 THEN 0
	    ELSE ROUND(
	        (COALESCE(Month_11_Bal, 0) - COALESCE(Month_12_Bal, 0)) 
	        / NULLIF(COALESCE(Month_12_Bal, 0), 0), 2
	    )
	END AS M11M12_Bal_Amt_change_pct,
	
	CASE 
	    WHEN (Month_4_Bal + Month_5_Bal + Month_6_Bal) = 0 THEN 0
	    ELSE ROUND(
	        ((Month_1_Bal + Month_2_Bal + Month_3_Bal) - (Month_4_Bal + Month_5_Bal + Month_6_Bal)) 
	        / CAST((Month_4_Bal + Month_5_Bal + Month_6_Bal) AS DECIMAL(18,2)), 2
	    ) 
	END AS Q1Q2_Bal_Amt_change_pct,
	
	CASE 
	    WHEN (Month_7_Bal + Month_8_Bal + Month_9_Bal) = 0 THEN 0
	    ELSE ROUND(
	        ((Month_4_Bal + Month_5_Bal + Month_6_Bal) - (Month_7_Bal + Month_8_Bal + Month_9_Bal)) 
	        / CAST((Month_7_Bal + Month_8_Bal + Month_9_Bal) AS DECIMAL(18,2)), 2
	    ) 
	END AS Q2Q3_Bal_Amt_change_pct,
	
	CASE 
	    WHEN (Month_10_Bal + Month_11_Bal + Month_12_Bal) = 0 THEN 0
	    ELSE ROUND(
	        ((Month_7_Bal + Month_8_Bal + Month_9_Bal) - (Month_10_Bal + Month_11_Bal + Month_12_Bal)) 
	        / CAST((Month_10_Bal + Month_11_Bal + Month_12_Bal) AS DECIMAL(18,2)), 2
	    ) 
	END AS Q3Q4_Bal_Amt_change_pct
	
FROM PivotedData