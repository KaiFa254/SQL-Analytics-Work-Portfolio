WITH LoansDashboard AS (
    SELECT 
        CAST(cm.EXTRACTION_DATE AS DATE) AS EXTRACTION_DATE,
        cm.CUS_SHORT_NAME,
        am.CUSTOMER,
        am.ARRANGEMENT_ID,
        am.ACCOUNT_NUMBER,
        CASE 
            WHEN stl.PAYOUT_ACCOUNT IS NULL OR stl.PAYOUT_ACCOUNT = '' 
                THEN stl.PAYIN_ACCOUNT 
            ELSE stl.PAYOUT_ACCOUNT 
        END AS SETTLEMENT_ACCOUNT,
        cm.CLASSIFICATION,
        am.CURRENCY,
        am.CATEGORY_DESC,
        am.INTEREST_RATE,
        am.Fixed_Variable_Ind,
        CONVERT(DECIMAL(18,0), am.TERM_AMOUNT) AS DISBURSED_AMT,
        CONVERT(DECIMAL(18,0), ex.Deal_balance) AS EXPOSURE_ACTUAL, 
        CASE 
            WHEN am.CURRENCY = 'KES' 
                THEN CONVERT(DECIMAL(18,0), ex.Deal_balance)
            ELSE CONVERT(DECIMAL(18,0), ex.Deal_balance) * am.EXCHANGE_RATE
        END AS EXPOSURE_KES,
        am.ONLINE_ACTUAL_BAL,
        CONVERT(DECIMAL(18,0), COALESCE(pdo.ARREARS_AMOUNT, 0)) AS ARREARS_KES,
        COALESCE(pdo.Days_In_Arrears, 0) AS OD_DAYS,
        DATE(am.VALUE_DATE) AS VALUE_DATE,
        DATE(am.MATURITY_DATE) AS MATURITY_DATE,
        DATE(am.PAYMENT_START_DATE) AS PAYMENT_START_DATE,
    am.REPAYMENT_AMT AS EMI,
        DATEDIFF(MONTH, CONVERT(DATE, am.VALUE_DATE), CURRENT_TIMESTAMP) AS MOB,
                am.ARR_STATUS AS LOAN_STATUS,
        CASE 
            WHEN cm.BUSINESS_SEGMENT IN ('270','250') THEN 'CONSUMER BANKING'
            WHEN cm.BUSINESS_SEGMENT IN ('200') THEN 'COMMERCIAL & BUSINESS BANKING'
        END AS BUSINESS_UNIT,
        cm.SUB_SEGEMENT_DESC,
        cm.CUSTOMER_BRANCH_NAME,
        cm.CUSTOMER_BRANCH ,
        cm.ACCOUNT_OFFICER_NAME,
        cm.PIN_NUMBER,
        cm.LEGAL_IDNO,
        cm.CUST_MOB_PHONE,
        cm.GENDER,
        cm.DATE_OF_BIRTH,
        cm.EMPLOYMENT_STATUS,
        cm.EMPLOYERS_NAME,
        cm.cm.LEGAL_ID,
        cm.
        
    FROM 
        dbcba.KE_Accounts_List am
    INNER JOIN 
        dbcba.KE_Customer_Master cm 
        ON am.CUSTOMER = cm.CUSTOMER_NUMBER AND cm.EXTRACTION_DATE = (SELECT MAX(processing_date) FROM dbcba.end_of_day)
    LEFT JOIN 
        stgke.STG_ECB_TOTAL_EXPOSURE ex 
        ON am.ACCOUNT_NUMBER = ex.RECID AND ex.LOAD_DATE = (SELECT MAX(processing_date) FROM dbcba.end_of_day)
    LEFT JOIN 
        stgke.STG_AA_ARR_SETTLEMENT stl 
        ON stl.ID_COMP_1 = am.ARRANGEMENT_ID
    LEFT JOIN 
        STGKE.STG_AA_ARREARS pdo 
        ON am.ARRANGEMENT_ID = pdo.ARRANGEMENT_ID AND pdo.EXTRACTION_DATE = (SELECT MAX(processing_date) FROM dbcba.end_of_day)
    WHERE  
        am.PRODUCT_LINE = 'LENDING' 
        and am.ARR_STATUS IN ('CURRENT', 'EXPIRED') 
        AND cm.BUSINESS_SEGMENT IN ('270','250','200')
        --AND cm.CLASSIFICATION <> 'B20' 
        AND am.ONLINE_ACTUAL_BAL <= 0
        and am.ARR_STATUS<>'AUTH'
)
SELECT distinct * 
FROM LoansDashboard
--WHERE 
--VALUE_DATE between '2025-06-01' and '2025-08-31'
--ACCOUNT_NUMBER = '1401460075'
--CUSTOMER in ('660643')



select top 3*
    FROM 
        dbcba.KE_Accounts_List am