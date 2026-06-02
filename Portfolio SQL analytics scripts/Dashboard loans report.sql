WITH mx_dt AS (
    SELECT MAX(LOAD_DATE) AS max_load_date
    FROM dbcba.AA_SCHEDULES
),

last_installment AS (
    SELECT
        ARRANGEMENT,
        SCHEDULE_DATE AS LAST_INSTALLMENT_DATE,
        TOTAL_DUE AS LAST_INSTALLMENT_EMI
    FROM (
        SELECT
            aa_sch.ARRANGEMENT,
            aa_sch.SCHEDULE_DATE,
            aa_sch.TOTAL_DUE,
            ROW_NUMBER() OVER (
                PARTITION BY aa_sch.ARRANGEMENT
                ORDER BY aa_sch.SCHEDULE_DATE DESC
            ) AS rn
        FROM dbcba.AA_SCHEDULES aa_sch
        INNER JOIN mx_dt
            ON mx_dt.max_load_date = aa_sch.LOAD_DATE
    ) x
    WHERE rn = 1
),

LoansDashboard AS (
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
        am.CATEGORY,
        am.CATEGORY_DESC,
        am.ACCOUNT_TITLE_1,
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
     li.LAST_INSTALLMENT_DATE,
     li.LAST_INSTALLMENT_EMI,
     --Compute EMI Difference
     (CAST(li.LAST_INSTALLMENT_EMI AS FLOAT)
 - CAST(am.REPAYMENT_AMT AS FLOAT)) AS EMI_DIFF,
 ---Percentage Change (VERY IMPORTANT)
 CASE 
    WHEN CAST(am.REPAYMENT_AMT AS FLOAT) = 0 THEN NULL
    ELSE 
        ( (CAST(li.LAST_INSTALLMENT_EMI AS FLOAT)
          - CAST(am.REPAYMENT_AMT AS FLOAT))
        / CAST(am.REPAYMENT_AMT AS FLOAT) ) * 100
END AS EMI_PCT_CHANGE,

------Create BLOAT BUCKETS (your requirement)
CASE 
    WHEN 
        ( (CAST(li.LAST_INSTALLMENT_EMI AS FLOAT)
          - CAST(am.REPAYMENT_AMT AS FLOAT))
        / NULLIF(CAST(am.REPAYMENT_AMT AS FLOAT),0) ) * 100 <= 10
    THEN 'NOT BLOATED (<=10%)'

    WHEN 
        ( (CAST(li.LAST_INSTALLMENT_EMI AS FLOAT)
          - CAST(am.REPAYMENT_AMT AS FLOAT))
        / NULLIF(CAST(am.REPAYMENT_AMT AS FLOAT),0) ) * 100 BETWEEN 11 AND 30
    THEN 'LOW BLOAT (11-30%)'

    WHEN 
        ( (CAST(li.LAST_INSTALLMENT_EMI AS FLOAT)
          - CAST(am.REPAYMENT_AMT AS FLOAT))
        / NULLIF(CAST(am.REPAYMENT_AMT AS FLOAT),0) ) * 100 BETWEEN 31 AND 50
    THEN 'MEDIUM BLOAT (31-50%)'

    WHEN 
        ( (CAST(li.LAST_INSTALLMENT_EMI AS FLOAT)
          - CAST(am.REPAYMENT_AMT AS FLOAT))
        / NULLIF(CAST(am.REPAYMENT_AMT AS FLOAT),0) ) * 100 > 50
    THEN 'HIGH BLOAT (>50%)'
END AS EMI_BLOAT_BUCKET,
     
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
        cm.LEGAL_ID,
        cm.CONTACT_DATE,
        cm.CUST_TYPE,
        
    FROM 
        dbcba.KE_Accounts_List am
    INNER JOIN 
        dbcba.KE_Customer_Master cm 
        ON am.CUSTOMER = cm.CUSTOMER_NUMBER AND cm.EXTRACTION_DATE = (select max(EXTRACTION_DATE) from  dbcba.KE_Customer_Master)
    LEFT JOIN 
        stgke.STG_ECB_TOTAL_EXPOSURE ex 
        ON am.ACCOUNT_NUMBER = ex.RECID AND ex.LOAD_DATE = (select max(EXTRACTION_DATE) from  dbcba.KE_Customer_Master)
    LEFT JOIN 
        stgke.STG_AA_ARR_SETTLEMENT stl 
        ON stl.ID_COMP_1 = am.ARRANGEMENT_ID
    LEFT JOIN 
        STGKE.STG_AA_ARREARS pdo 
        ON am.ARRANGEMENT_ID = pdo.ARRANGEMENT_ID AND pdo.EXTRACTION_DATE = (select max(EXTRACTION_DATE) from  dbcba.KE_Customer_Master)
     ----last installment--
          LEFT JOIN last_installment li
        ON am.ARRANGEMENT_ID = li.ARRANGEMENT
    WHERE  
        am.PRODUCT_LINE = 'LENDING' 
       and am.ARR_STATUS IN ('CURRENT', 'EXPIRED') 
      --   and am.ARR_STATUS not IN ('CURRENT', 'EXPIRED') ----paid off
        AND cm.BUSINESS_SEGMENT IN ('270','250','200') 
        --AND cm.CLASSIFICATION <> 'B20' 
        AND am.ONLINE_ACTUAL_BAL <= 0
        and am.ARR_STATUS not in ('AUTH','UNAUTH','REVERSED')
)
SELECT distinct *
--SELECT distinct VALUE_DATE, sum(DISBURSED_AMT)
--select  CUSTOMER , sum(CONVERT(DECIMAL(18,0), EMI))
FROM LoansDashboard
WHERE CUSTOMER ='282045'
AND CATEGORY ='3765' 
--AND DISBURSED_AMT>1000000
--ORDER BY DISBURSED_AMT DESC
--AND CLASSIFICATION NOT IN ('A1','A2','A3','A5','B9')
--VALUE_DATE between '2025-06-01' and '2025-08-31'
--ACCOUNT_NUMBER = '1401460075'

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT CRR,[CUSTOMER NO] AS CUSTOMER,[ACCOUNT NUMBER] AS ACCOUNT,CURRENCY,[EXCESS DAYS] AS OD_DAYS, SUB_SEGEMENT_DESC AS CATEGORY_NAME,'' AS CATEGORY_ID, 
Arrears_Acual_Amount AS ARREARS_ACTUAL, EXPOSURE_KES,'' AS [EARLY INDICATORS], 'Excess' AS [LOAN TYPE] , '' AS EMPLOYER 
FROM 
STGKE.STG_AA_DAYS_EXCESS
WHERE EXTRACTION_DATE = (select max(EXTRACTION_DATE) from  STGKE.STG_AA_DAYS_EXCESS)
and [EXCESS DAYS]>0 and CRR not in ('B20')
AND [CUSTOMER NO] ='586863'
AND (
    LIM_EXPIRY_DATE < CURRENT DATE
    OR LIM_EXPIRY_DATE IS NULL
)


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select trim(CUSTOMER_NO) as CUSTOMER_NO   ,sum(EXPOSURE_KES) as Total_Exxposure
from DBCBA.COMBINED_MASTER_LOAN_LISTING
where REPORT_DATE = (select max(REPORT_DATE) from  DBCBA.COMBINED_MASTER_LOAN_LISTING)
and CUSTOMER_NO is not null and CUSTOMER_NO <> '' and  CUSTOMER_NO  <>'(blank)'
group by CUSTOMER_NO

select top 3*
from DBCBA.COMBINED_MASTER_LOAN_LISTING

---------------------------------------------------------------------------------------


WITH DIGITAL_CUSTOMERS AS
(
    SELECT DISTINCT CUSTOMER
    FROM dbcba.KE_Accounts_List
    WHERE PRODUCT_LINE = 'LENDING'
      AND ARR_STATUS IN ('CURRENT', 'EXPIRED')
      AND ONLINE_ACTUAL_BAL <= 0
      AND ARR_STATUS NOT IN ('AUTH', 'UNAUTH', 'REVERSED')
)

SELECT 
    am.CUSTOMER,

    CASE 
        WHEN dc.CUSTOMER IS NOT NULL THEN 'YES'
        ELSE 'NO'
    END AS "WITH DIGITAL?"

FROM dbcba.KE_Accounts_List am

LEFT JOIN DIGITAL_CUSTOMERS dc
    ON am.CUSTOMER = dc.CUSTOMER;




