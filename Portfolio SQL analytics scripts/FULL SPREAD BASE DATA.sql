/* =========================================================
   1️⃣ SNAPSHOT DATES
========================================================= */
WITH SnapshotDates AS (
    SELECT DISTINCT EXTRACTION_DATE AS SNAPSHOT_DATE 
    FROM dbcba.KE_Accounts_Master
    WHERE EXTRACTION_DATE IN (
        '2025-06-30', '2025-07-31', '2025-08-31', 
        '2025-09-30', '2025-10-31', '2025-11-30'
    )
),

/* =========================================================
   2️⃣ BASE LOAN SNAPSHOT
========================================================= */
LoansSnapshot AS (
    SELECT 
        s.SNAPSHOT_DATE,
        cm.CUSTOMER_NUMBER AS CUSTOMER_ID,
        am.ARRANGEMENT_ID AS LOAN_ID,
        am.ACCOUNT_NUMBER,
        cm.CLASSIFICATION,
        am.CURRENCY,
        am.ACCOUNT_TITLE_1,
        am.Fixed_Variable_Ind,
        CONVERT(DECIMAL(18,0), am.TERM_AMOUNT) AS DISBURSED_AMT,
        CONVERT(DECIMAL(18,0), COALESCE(ex.Deal_balance,0)) AS EXPOSURE_ACTUAL,
        CASE 
            WHEN am.CURRENCY = 'KES' THEN CONVERT(DECIMAL(18,0), COALESCE(ex.Deal_balance,0))
            ELSE CONVERT(DECIMAL(18,0), COALESCE(ex.Deal_balance,0)) * am.EXCHANGE_RATE
        END AS EXPOSURE_KES,
        am.REPAYMENT_AMT AS EMI,
        am.INTEREST_RATE,
        COALESCE(pdo.ARREARS_AMOUNT,0) AS ARREARS_KES,
        COALESCE(pdo.Days_In_Arrears,0) AS DPD,
        DATEDIFF(MONTH, am.VALUE_DATE, s.SNAPSHOT_DATE) AS MOB,
        DATEDIFF(MONTH, s.SNAPSHOT_DATE, am.MATURITY_DATE) AS TENURE_REMAINING,
        am.ARR_STATUS AS LOAN_STATUS,
        am.CATEGORY,
        am.CATEGORY_DESC,
        cm.DATE_OF_BIRTH,
        cm.GENDER,
        cm.EMPLOYMENT_STATUS,
        cm.BUSINESS_SEGMENT
    FROM SnapshotDates s
    INNER JOIN dbcba.KE_Accounts_Master am
        ON am.EXTRACTION_DATE = s.SNAPSHOT_DATE
    INNER JOIN dbcba.KE_Customer_Master cm
        ON am.CUSTOMER = cm.CUSTOMER_NUMBER
        AND cm.EXTRACTION_DATE = s.SNAPSHOT_DATE
    LEFT JOIN stgke.STG_ECB_TOTAL_EXPOSURE ex
        ON am.ACCOUNT_NUMBER = ex.RECID
        AND ex.LOAD_DATE = s.SNAPSHOT_DATE
    LEFT JOIN STGKE.STG_AA_ARREARS pdo
        ON am.ARRANGEMENT_ID = pdo.ARRANGEMENT_ID
        AND pdo.EXTRACTION_DATE = s.SNAPSHOT_DATE
    WHERE am.PRODUCT_LINE = 'LENDING'
        AND am.ARR_STATUS = 'CURRENT'
        AND cm.BUSINESS_SEGMENT IN ('270','250')
        AND COALESCE(am.ONLINE_ACTUAL_BAL,0) < 0
        AND COALESCE(pdo.Days_In_Arrears,0) = 0
),

/* =========================================================
   3️⃣ TARGET 90D DEFAULT
========================================================= */
OutcomeWindow AS (
    SELECT
        s.SNAPSHOT_DATE,
        a.ARRANGEMENT_ID AS LOAN_ID,
        MAX(a.Days_In_Arrears) AS MAX_DPD_90D
    FROM SnapshotDates s
    INNER JOIN STGKE.STG_AA_ARREARS a
        ON a.EXTRACTION_DATE > s.SNAPSHOT_DATE
        AND a.EXTRACTION_DATE <= DATEADD(DAY,90,s.SNAPSHOT_DATE)
    GROUP BY s.SNAPSHOT_DATE, a.ARRANGEMENT_ID
),

/* =========================================================
   4️⃣ DTO FEATURES
========================================================= */
DTO_Base AS (
    SELECT
        s.SNAPSHOT_DATE,
        t.CUSTOMER_ID,
        DATEDIFF(MONTH,t.BOOKING_DATE,s.SNAPSHOT_DATE) AS Month_Diff,
        ABS(t.AMOUNT_LCY) AS AMOUNT_LCY
    FROM SnapshotDates s
    INNER JOIN dbcba.KE_ACCOUNT_TRANSACTIONS t
        ON t.BOOKING_DATE > DATEADD(MONTH,-12,s.SNAPSHOT_DATE)
        AND t.BOOKING_DATE <= s.SNAPSHOT_DATE
    WHERE t.AMOUNT_LCY < 0
        AND t.REVERSAL_MARKER <> 'R'
),
DTO_Trend AS (
    SELECT
        SNAPSHOT_DATE,
        CUSTOMER_ID,
        SUM(CASE WHEN Month_Diff BETWEEN 0 AND 2 THEN AMOUNT_LCY END) AS DTO_3M,
        SUM(CASE WHEN Month_Diff BETWEEN 0 AND 5 THEN AMOUNT_LCY END) AS DTO_6M,
        SUM(CASE WHEN Month_Diff BETWEEN 0 AND 11 THEN AMOUNT_LCY END) AS DTO_12M
    FROM DTO_Base
    GROUP BY SNAPSHOT_DATE, CUSTOMER_ID
),

/* =========================================================
   5️⃣ INCOME (CTO)
========================================================= */
Income_12M AS (
    SELECT
        s.SNAPSHOT_DATE,
        t.CUSTOMER_ID,
        AVG(t.AMOUNT_LCY) AS AVG_INCOME_12M
    FROM SnapshotDates s
    INNER JOIN dbcba.KE_ACCOUNT_TRANSACTIONS t
        ON t.BOOKING_DATE > DATEADD(MONTH,-12,s.SNAPSHOT_DATE)
        AND t.BOOKING_DATE <= s.SNAPSHOT_DATE
    WHERE t.AMOUNT_LCY > 0
        AND t.REVERSAL_MARKER <> 'R'
    GROUP BY s.SNAPSHOT_DATE, t.CUSTOMER_ID
),

/* =========================================================
   6️⃣ FID & Max DPD & Credit Card
========================================================= */
FID_Aggregated AS (
    SELECT
        s.SNAPSHOT_DATE,
        a.customer_number AS CUSTOMER_ID,
        COUNT(DISTINCT a.ACCOUNT_NUMBER) AS NO_OF_ACCOUNTS_FID
    FROM SnapshotDates s
    INNER JOIN STGKE.STG_AA_ARREARS a
        ON a.EXTRACTION_DATE <= s.SNAPSHOT_DATE
    INNER JOIN DBCBA.KE_ACCOUNTS_LIST b
        ON a.ACCOUNT_NUMBER = b.ACCOUNT_NUMBER
    WHERE a.Days_In_Arrears BETWEEN 1 AND 30
        AND DATEDIFF(DAY,b.ARR_START_DATE,a.ARREARS_DATE) BETWEEN 1 AND 30
    GROUP BY s.SNAPSHOT_DATE, a.customer_number
),
Max_DPD AS (
    SELECT
        s.SNAPSHOT_DATE,
        a.CUSTOMER AS CUSTOMER_ID,
        MAX(a.OD_DAYS) AS MAX_LOAN_DPD_60D
    FROM SnapshotDates s
    INNER JOIN STGKE.STG_AA_BILL_ARREARS a
        ON a.EXTRACTION_DATE > DATEADD(DAY,-60,s.SNAPSHOT_DATE)
        AND a.EXTRACTION_DATE <= s.SNAPSHOT_DATE
    GROUP BY s.SNAPSHOT_DATE, a.CUSTOMER
),
CreditCard_Flag AS (
    SELECT
        s.SNAPSHOT_DATE,
        al.CUSTOMER AS CUSTOMER_ID,
        1 AS HAS_CREDIT_CARD
    FROM SnapshotDates s
    INNER JOIN STGKE.STG_DEBIT_CREDIT_CARD cd
        ON cd.EXTRACT_DATE = s.SNAPSHOT_DATE
        AND cd.CARD_TYPE = 'CREDIT'
        AND cd.CARD_STATUS = 'ACTIVE'
    INNER JOIN dbcba.KE_Accounts_List al
        ON cd.BANKACCOUNT = al.ACCOUNT_NUMBER
),

/* =========================================================
   7️⃣ UNPAID ITEMS TRENDED
========================================================= */
transactions AS (
    SELECT
        BOOKING_DATE,
        CUSTOMER_ID,
        ACCOUNT_NUMBER,
        (CAST(AMOUNT_LCY AS DECIMAL(18,2)) * -1) AS AMOUNT_LCY_1
    FROM dbcba.KE_ACCOUNT_TRANSACTIONS
    WHERE BOOKING_DATE <= DATEADD(DAY, -(DAY(GETDATE())), CAST(GETDATE() AS DATE))
      AND BOOKING_DATE >= DATEADD(MONTH, -12, DATEADD(DAY, -(DAY(GETDATE()) - 1), CAST(GETDATE() AS DATE)))
      AND AMOUNT_LCY < 0
      AND (DEBIT_CUSTOMER <> CREDIT_CUSTOMER OR CREDIT_CUSTOMER IS NULL)
      AND TRANSACTION_CODE IN ('938','939','940','941','944','945','946','947','948','949','991','992','1084','1085','285','561','882','904','905','923')
      AND REVERSAL_MARKER <> 'R'
),
account_transactions AS (
    SELECT
        acc.CUSTOMER,
        acc.Account_number AS ACCOUNT_NUMBER,
        acc.category,
        cto.BOOKING_DATE,
        cto.AMOUNT_LCY_1
    FROM dbcba.ke_Accounts_master acc
    LEFT JOIN transactions cto
        ON cto.ACCOUNT_NUMBER = acc.Account_number
),
debits AS (
    SELECT 
        CUSTOMER,
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
    FROM account_transactions
    GROUP BY CUSTOMER
),

/* =========================================================
   8️⃣ CRB DATA
========================================================= */
crb_data AS (
    SELECT 
        CAST(CAST(CLIENTID AS INT) AS VARCHAR) AS CLIENTID,
        NATIONALID,
        PASSPORTNO,
        NUMBEROF_ACCOUNTS,
        OPENACCOUNT,
        PERFORMING,
        NONPERFORMING,
        CLOSED,
        CURRENTINARREARS,
        ARREARS0DAYS,
        MAXARREARS,
        MAXARREARSLAST12MONTHS,
        MAXARREARSLAST3MONTHS,
        PRINCIPALAMOUNT,
        SCHEDULEDPAYMENTAMT,
        CREDITAPPLICATIONSDONE,
        CURRENTBALANCEAMOUNT,
        SUBSCRIBERCURRENTBALANCEAMOUNT,
        PASTDUEAMOUNT,
        NUMBEROFENQUIRIES,
        ENQUIRIES30DAYS,
        ENQUIRIES90DAYS,
        SCORE AS CRB_TU_SCORE,
        MOBILE_TOTAL,
        MOBILE_PERFORMING,
        MOBILE_NONPERFORMING,
        MOBILE_PRINCIPALAMOUNT
    FROM dbcba.LEND_FOR_ALL_CRB_DATA
    WHERE [YEAR] = 2025
      AND QUARTER = 'Q1'
),

/* =========================================================
   9️⃣ AVERAGE BALANCE TRENDED
========================================================= */
AvgBal_12M AS (
    SELECT 
        acc.CUSTOMER,
        ROUND(SUM(avg_bal.CUMULATIVE_BAL_LCY)/SUM(avg_bal.NUM_DAYS),2) AS AVG_BAL_12M
    FROM dbcba.ke_Accounts_master acc
    LEFT JOIN STGKE.STG_AVERAGE_BALANCE avg_bal
        ON avg_bal.Account_number = acc.Account_number
    WHERE acc.PRODUCT_LINE IN ('ACCOUNTS')
      AND avg_bal.Av_Bal_Date <= DATEADD(DAY, -(DAY(GETDATE())), CAST(GETDATE() AS DATE))
      AND avg_bal.Av_Bal_Date >= DATEADD(MONTH, -11, DATEADD(DAY, -(DAY(GETDATE())), CAST(GETDATE() AS DATE)))
    GROUP BY acc.CUSTOMER
)

/* =========================================================
   🔥 FINAL MERGED DATASET
========================================================= */
SELECT TOP 3
    b.*,
    CASE WHEN o.MAX_DPD_90D >= 20 THEN 1 ELSE 0 END AS TARGET_DEFAULT_90D,
    COALESCE(dto.DTO_3M,0) AS DTO_3M,
    COALESCE(dto.DTO_6M,0) AS DTO_6M,
    COALESCE(dto.DTO_12M,0) AS DTO_12M,
    COALESCE(inc.AVG_INCOME_12M,0) AS AVG_INCOME_12M,
    CASE 
        WHEN COALESCE(inc.AVG_INCOME_12M,0) = 0 THEN 0
        ELSE b.EXPOSURE_KES / inc.AVG_INCOME_12M
    END AS LOAN_INCOME_RATIO,
    COALESCE(fid.NO_OF_ACCOUNTS_FID,0) AS NO_OF_ACCOUNTS_FID,
    COALESCE(maxdpd.MAX_LOAN_DPD_60D,0) AS MAX_LOAN_DPD_60D,
    CASE WHEN cc.HAS_CREDIT_CARD = 1 THEN 1 ELSE 0 END AS HAS_CREDIT_CARD,
    
    -- Unpaid Items
    debits.Month_1_Unpaid, debits.Month_2_Unpaid, debits.Month_3_Unpaid, debits.Month_4_Unpaid,
    debits.Month_5_Unpaid, debits.Month_6_Unpaid, debits.Month_7_Unpaid, debits.Month_8_Unpaid,
    debits.Month_9_Unpaid, debits.Month_10_Unpaid, debits.Month_11_Unpaid, debits.Month_12_Unpaid,
    
    -- CRB
    crb.NUMBEROF_ACCOUNTS AS TU_NUMBEROF_ACCOUNTS,
    crb.PERFORMING AS TU_PERFORMING,
    crb.NONPERFORMING AS TU_NONPERFORMING,
    crb.CURRENTINARREARS AS TU_CURRENTINARREARS,
    crb.CRB_TU_SCORE AS CRB_TU_SCORE,
    
    -- PPC
    ppc.PPC,
    
    -- Avg Balance
    ab12.AVG_BAL_12M

FROM LoansSnapshot b
LEFT JOIN OutcomeWindow o
    ON b.LOAN_ID = o.LOAN_ID
    AND b.SNAPSHOT_DATE = o.SNAPSHOT_DATE
LEFT JOIN DTO_Trend dto
    ON b.SNAPSHOT_DATE = dto.SNAPSHOT_DATE
    AND b.CUSTOMER_ID = dto.CUSTOMER_ID
LEFT JOIN Income_12M inc
    ON b.SNAPSHOT_DATE = inc.SNAPSHOT_DATE
    AND b.CUSTOMER_ID = inc.CUSTOMER_ID
LEFT JOIN FID_Aggregated fid
    ON b.SNAPSHOT_DATE = fid.SNAPSHOT_DATE
    AND b.CUSTOMER_ID = fid.CUSTOMER_ID
LEFT JOIN Max_DPD maxdpd
    ON b.SNAPSHOT_DATE = maxdpd.SNAPSHOT_DATE
    AND b.CUSTOMER_ID = maxdpd.CUSTOMER_ID
LEFT JOIN CreditCard_Flag cc
    ON b.SNAPSHOT_DATE = cc.SNAPSHOT_DATE
    AND b.CUSTOMER_ID = cc.CUSTOMER_ID
LEFT JOIN debits
    ON b.CUSTOMER_ID = debits.CUSTOMER
LEFT JOIN crb_data crb
    ON b.CUSTOMER_ID = crb.CLIENTID
LEFT JOIN dbcba.RETAIL_PPC ppc
    ON b.CUSTOMER_ID = ppc.CUSTOMER
LEFT JOIN AvgBal_12M ab12
    ON b.CUSTOMER_ID = ab12.CUSTOMER;
