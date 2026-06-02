WITH LoansSnapshot AS (
    SELECT 
        CAST(am.EXTRACTION_DATE AS DATE) AS SNAPSHOT_DATE,
        cm.CUSTOMER_NUMBER AS CUSTOMER_ID,
        am.ARRANGEMENT_ID AS LOAN_ID,
        am.ACCOUNT_NUMBER,
          cm.CLASSIFICATION,
        am.CURRENCY,
        am.ACCOUNT_TITLE_1,
       
        am.Fixed_Variable_Ind,
        
        -- Exposure
        CONVERT(DECIMAL(18,0), am.TERM_AMOUNT) AS DISBURSED_AMT,
        CONVERT(DECIMAL(18,0), ex.Deal_balance) AS EXPOSURE_ACTUAL, 
        
        CASE 
            WHEN am.CURRENCY = 'KES' 
                THEN CONVERT(DECIMAL(18,0), ex.Deal_balance)
            ELSE CONVERT(DECIMAL(18,0), ex.Deal_balance) * am.EXCHANGE_RATE
        END AS EXPOSURE_KES,
        
        -- Installment
        am.REPAYMENT_AMT AS EMI,
        am.INTEREST_RATE,
        
        -- Arrears
        COALESCE(pdo.ARREARS_AMOUNT, 0) AS ARREARS_KES,
        COALESCE(pdo.Days_In_Arrears, 0) AS DPD,
        
        -- Tenure
        DATEDIFF(MONTH, CONVERT(DATE, am.VALUE_DATE), '2025-11-30') AS MOB,
        DATEDIFF(MONTH, '2025-11-30', am.MATURITY_DATE) AS TENURE_REMAINING,
        
        -- Status
        am.ARR_STATUS AS LOAN_STATUS,
        am.CATEGORY,
        am.CATEGORY_DESC,
        
        -- Customer
        cm.DATE_OF_BIRTH,
        cm.GENDER,
        cm.EMPLOYMENT_STATUS,
        cm.BUSINESS_SEGMENT,
        case 
	when cm.BUSINESS_SEGMENT in ('270','250') then 'CONSUMER BANKING'
	when cm.BUSINESS_SEGMENT in ('200') then 'COMMERCIAL & BUSINESS BANKING'
	else 'OTHERS'
end as BUSINESS_UNIT

    FROM dbcba.KE_Accounts_Master am
    
    INNER JOIN dbcba.KE_Customer_Master cm 
        ON am.CUSTOMER = cm.CUSTOMER_NUMBER 
        AND cm.EXTRACTION_DATE = '2025-11-30'
        
    LEFT JOIN stgke.STG_ECB_TOTAL_EXPOSURE ex 
        ON am.ACCOUNT_NUMBER = ex.RECID 
        AND ex.LOAD_DATE = '2025-11-30'
        
    LEFT JOIN STGKE.STG_AA_ARREARS pdo 
        ON am.ARRANGEMENT_ID = pdo.ARRANGEMENT_ID 
        AND pdo.EXTRACTION_DATE = '2025-11-30'

    WHERE  
        am.EXTRACTION_DATE = '2025-11-30'
        AND am.PRODUCT_LINE = 'LENDING'
        AND am.ARR_STATUS IN ('CURRENT')
        AND cm.BUSINESS_SEGMENT IN ('270','250','200') 
        AND am.ONLINE_ACTUAL_BAL <= 0
        and am.ARR_STATUS<>'AUTH'
        AND COALESCE(pdo.Days_In_Arrears, 0) = 0   -- IMPORTANT: No arrears at snapshot
        
),

--SELECT *
--FROM LoansSnapshot;
OutcomeWindow AS (
    SELECT
        ARRANGEMENT_ID,
        MAX(Days_In_Arrears) AS MAX_DPD_90D
    FROM STGKE.STG_AA_ARREARS
    WHERE EXTRACTION_DATE > '2025-11-30'
      AND EXTRACTION_DATE <= '2026-02-28'
    GROUP BY ARRANGEMENT_ID
)

SELECT 
    b.*,
    CASE 
        WHEN o.MAX_DPD_90D >= 20 THEN 1
        ELSE 0
    END AS TARGET_DEFAULT_90D
FROM LoansSnapshot b
LEFT JOIN OutcomeWindow o
    ON b.LOAN_ID = o.ARRANGEMENT_ID


    
    select top 3* FROM dbcba.KE_Accounts_Master