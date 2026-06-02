-------------------------------------------------------
-- Optimized Loan-Credit Analysis (CTOs)
-- Calculates 6M avg daily credits before/after loan VALUE_DATE
-- Includes CREDIT_CHANGE and % change
-------------------------------------------------------

-- Step 1: Precompute daily credits (CTOs)
WITH CTO_daily AS (
    SELECT 
        tran.ACCOUNT_NUMBER,
        cm.CUSTOMER_NUMBER AS CUSTOMER,
        tran.BOOKING_DATE,
        SUM(tran.AMOUNT_LCY) AS Daily_Credit
    FROM dbcba.KE_ACCOUNT_TRANSACTIONS tran
    INNER JOIN (
        SELECT * 
        FROM dbcba.KE_Customer_Master 
        WHERE EXTRACTION_DATE = (SELECT MAX(processing_date) FROM dbcba.end_of_day)
    ) cm
      ON tran.CUSTOMER_ID = cm.CUSTOMER_NUMBER
    LEFT JOIN (
        SELECT ACCOUNT_NUMBER, CATEGORY_DESC, CATEGORY, PRODUCT_LINE 
        FROM dbcba.KE_Accounts_List 
        WHERE PRODUCT_LINE = 'ACCOUNTS'
    ) al
      ON tran.ACCOUNT_NUMBER = al.ACCOUNT_NUMBER
    WHERE tran.AMOUNT_LCY > 0
      AND txn_code_initiation = 'CUSTOMER'
      AND (tran.CREDIT_CUSTOMER <> tran.DEBIT_CUSTOMER 
           OR tran.CREDIT_CUSTOMER IS NULL OR tran.CREDIT_CUSTOMER = ''
           OR tran.DEBIT_CUSTOMER IS NULL OR tran.DEBIT_CUSTOMER = '')
      AND tran.TRANSACTION_CODE NOT IN ('1085','766','949','945','991','941','433','1006','85','234','859','940','992','947','939','946','944','948','938','1001')
      AND tran.REVERSAL_MARKER <> 'R'
      AND tran.ORDERING_CUST NOT IN ('727119') 
      AND tran.PROFIT_CENTRE_CUST NOT IN ('727119')
      AND tran.DEPARTMENT_CODE NOT IN ('3976')
      AND tran.BOOKING_DATE BETWEEN '2023-01-01' AND '2026-12-31'
    GROUP BY tran.ACCOUNT_NUMBER, cm.CUSTOMER_NUMBER, tran.BOOKING_DATE
),

-- Step 2: Get all lending loans as anchors
lending_loans AS (
    SELECT
        CUSTOMER,
        DATE(VALUE_DATE) AS VALUE_DATE,
        COUNT(ARRANGEMENT_ID) AS LOAN_COUNT,
        SUM(
            CASE 
                WHEN ISNUMERIC(REPLACE(REPAYMENT_AMT, ',', '')) = 1
                THEN CAST(REPLACE(REPAYMENT_AMT, ',', '') AS DECIMAL(18,2))
                ELSE 0
            END
        ) AS EMI
    FROM dbcba.KE_Accounts_List
    WHERE PRODUCT_LINE = 'LENDING'
      AND ARR_STATUS IN ('CURRENT','EXPIRE')
    GROUP BY CUSTOMER, VALUE_DATE
)

-- Step 3: Join loans with daily CTOs and compute 6M averages
SELECT
    ll.CUSTOMER,
    ll.VALUE_DATE,
    ll.LOAN_COUNT,
    ll.EMI,

    -- 6M BEFORE loan
    AVG(CASE 
            WHEN c.BOOKING_DATE >= DATEADD(MONTH,-6,ll.VALUE_DATE)
             AND c.BOOKING_DATE < ll.VALUE_DATE
            THEN c.Daily_Credit
        END) AS AVG_6M_BEFORE_CREDIT,

    -- 6M AFTER loan
    AVG(CASE 
            WHEN c.BOOKING_DATE > ll.VALUE_DATE
             AND c.BOOKING_DATE <= DATEADD(MONTH,6,ll.VALUE_DATE)
            THEN c.Daily_Credit
        END) AS AVG_6M_AFTER_CREDIT,

    -- Change in daily credits
    AVG(CASE 
            WHEN c.BOOKING_DATE > ll.VALUE_DATE
             AND c.BOOKING_DATE <= DATEADD(MONTH,6,ll.VALUE_DATE)
            THEN c.Daily_Credit
        END)
    -
    AVG(CASE 
            WHEN c.BOOKING_DATE >= DATEADD(MONTH,-6,ll.VALUE_DATE)
             AND c.BOOKING_DATE < ll.VALUE_DATE
            THEN c.Daily_Credit
        END) AS CREDIT_CHANGE,

    -- Percentage change
    CASE 
        WHEN AVG(CASE 
                    WHEN c.BOOKING_DATE >= DATEADD(MONTH,-6,ll.VALUE_DATE)
                     AND c.BOOKING_DATE < ll.VALUE_DATE
                    THEN c.Daily_Credit
                 END) = 0
        THEN NULL
        ELSE 
            (AVG(CASE 
                    WHEN c.BOOKING_DATE > ll.VALUE_DATE
                     AND c.BOOKING_DATE <= DATEADD(MONTH,6,ll.VALUE_DATE)
                    THEN c.Daily_Credit
                 END)
             -
             AVG(CASE 
                    WHEN c.BOOKING_DATE >= DATEADD(MONTH,-6,ll.VALUE_DATE)
                     AND c.BOOKING_DATE < ll.VALUE_DATE
                    THEN c.Daily_Credit
                 END)
            )
            /
            AVG(CASE 
                    WHEN c.BOOKING_DATE >= DATEADD(MONTH,-6,ll.VALUE_DATE)
                     AND c.BOOKING_DATE < ll.VALUE_DATE
                    THEN c.Daily_Credit
                 END)
    END AS PCT_CHANGE_CREDIT

FROM lending_loans ll
LEFT JOIN CTO_daily c
       ON c.CUSTOMER = ll.CUSTOMER
      AND c.BOOKING_DATE BETWEEN DATEADD(MONTH,-6,ll.VALUE_DATE) 
                             AND DATEADD(MONTH,6,ll.VALUE_DATE)
WHERE ll.CUSTOMER IN ('256992')  -- optional filter for testing
GROUP BY ll.CUSTOMER, ll.VALUE_DATE, ll.LOAN_COUNT, ll.EMI
ORDER BY ll.CUSTOMER, ll.VALUE_DATE;