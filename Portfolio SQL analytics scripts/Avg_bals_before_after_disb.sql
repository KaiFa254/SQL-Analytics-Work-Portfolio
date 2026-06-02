------------------------------------------------------
-- Optimized Loan-Deposit Analysis
-- Calculates 6M avg deposit balances before/after loan VALUE_DATE
-- Includes BAL_CHANGE and % change
------------------------------------------------------

-- Step 1: Precompute balances for deposit accounts
WITH balances AS (
    SELECT
        dep.CUSTOMER,
        ab.Account_number,
        ab.Av_Bal_Date,
        ab.CUMULATIVE_BAL_LCY
    FROM dbcba.KE_Accounts_List dep
    JOIN STGKE.STG_AVERAGE_BALANCE ab
      ON ab.Account_number = dep.Account_number
    WHERE dep.PRODUCT_LINE = 'ACCOUNTS'
     -- AND dep.CUSTOMER IN ('1004296')  -- filter your customer list here
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
     -- AND CUSTOMER IN ('1004296')  -- same filter here
    GROUP BY CUSTOMER, VALUE_DATE
)

-- Step 3: Join and compute 6M averages
SELECT
    ll.CUSTOMER,
    ll.VALUE_DATE,
    ll.LOAN_COUNT,
    ll.EMI,

    -- 6M BEFORE loan
    AVG(CASE 
            WHEN b.Av_Bal_Date >= DATEADD(MONTH,-6,ll.VALUE_DATE)
             AND b.Av_Bal_Date < ll.VALUE_DATE
            THEN b.CUMULATIVE_BAL_LCY
        END) AS AVG_6M_BEFORE,

    -- 6M AFTER loan
    AVG(CASE 
            WHEN b.Av_Bal_Date > ll.VALUE_DATE
             AND b.Av_Bal_Date <= DATEADD(MONTH,6,ll.VALUE_DATE)
            THEN b.CUMULATIVE_BAL_LCY
        END) AS AVG_6M_AFTER,

    -- Change in balances
    AVG(CASE 
            WHEN b.Av_Bal_Date > ll.VALUE_DATE
             AND b.Av_Bal_Date <= DATEADD(MONTH,6,ll.VALUE_DATE)
            THEN b.CUMULATIVE_BAL_LCY
        END) 
    -
    AVG(CASE 
            WHEN b.Av_Bal_Date >= DATEADD(MONTH,-6,ll.VALUE_DATE)
             AND b.Av_Bal_Date < ll.VALUE_DATE
            THEN b.CUMULATIVE_BAL_LCY
        END) AS BALANCE_CHANGE,

    -- Percentage change
    CASE 
        WHEN AVG(CASE 
                    WHEN b.Av_Bal_Date >= DATEADD(MONTH,-6,ll.VALUE_DATE)
                     AND b.Av_Bal_Date < ll.VALUE_DATE
                    THEN b.CUMULATIVE_BAL_LCY
                 END) = 0
        THEN NULL
        ELSE 
            (AVG(CASE 
                    WHEN b.Av_Bal_Date > ll.VALUE_DATE
                     AND b.Av_Bal_Date <= DATEADD(MONTH,6,ll.VALUE_DATE)
                    THEN b.CUMULATIVE_BAL_LCY
                 END)
             -
             AVG(CASE 
                    WHEN b.Av_Bal_Date >= DATEADD(MONTH,-6,ll.VALUE_DATE)
                     AND b.Av_Bal_Date < ll.VALUE_DATE
                    THEN b.CUMULATIVE_BAL_LCY
                 END)
            )
            /
            AVG(CASE 
                    WHEN b.Av_Bal_Date >= DATEADD(MONTH,-6,ll.VALUE_DATE)
                     AND b.Av_Bal_Date < ll.VALUE_DATE
                    THEN b.CUMULATIVE_BAL_LCY
                 END)
    END AS PCT_CHANGE

FROM lending_loans ll
LEFT JOIN balances b
       ON b.CUSTOMER = ll.CUSTOMER
      AND b.Av_Bal_Date BETWEEN DATEADD(MONTH,-6,ll.VALUE_DATE) 
                             AND DATEADD(MONTH,6,ll.VALUE_DATE)
where ll.CUSTOMER in ('256992')
GROUP BY
    ll.CUSTOMER, ll.VALUE_DATE, ll.LOAN_COUNT, ll.EMI
ORDER BY
    ll.CUSTOMER, ll.VALUE_DATE;