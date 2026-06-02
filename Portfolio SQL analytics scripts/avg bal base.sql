SELECT
    acc.EXTRACTION_DATE AS SNAPSHOT_DATE,
    acc.CUSTOMER AS CUSTOMER_ID,
    avg_bal.Av_Bal_Date,
    avg_bal.CUMULATIVE_BAL_LCY,
    avg_bal.NUM_DAYS

FROM dbcba.KE_Accounts_master acc

INNER JOIN (
    SELECT DISTINCT am.CUSTOMER
    FROM dbcba.KE_Accounts_List am
    INNER JOIN dbcba.KE_Customer_Master cm
        ON cm.CUSTOMER_NUMBER = am.CUSTOMER
    WHERE am.PRODUCT_LINE='LENDING'
      AND am.ARR_STATUS='CURRENT'
      AND cm.BUSINESS_SEGMENT IN ('270','250')
      AND COALESCE(am.ONLINE_ACTUAL_BAL,0) < 0
      AND am.CUSTOMER IS NOT NULL
) fc
    ON acc.CUSTOMER = fc.CUSTOMER

/* ✅ FIX: move date condition into JOIN */
LEFT JOIN STGKE.STG_AVERAGE_BALANCE avg_bal
    ON avg_bal.Account_number = acc.Account_number
   AND avg_bal.Av_Bal_Date <= acc.EXTRACTION_DATE
   AND avg_bal.Av_Bal_Date > DATEADD(MONTH,-6,acc.EXTRACTION_DATE)

WHERE acc.PRODUCT_LINE='ACCOUNTS'
AND acc.EXTRACTION_DATE IN (
    '2025-03-31', '2025-06-30', '2025-09-30', '2025-11-30'
);
