SELECT 
    tran.ACCOUNT_NUMBER, cm.CUSTOMER_NUMBER , CM.CUS_SHORT_NAME,
         SUM(tran.AMOUNT_LCY) AS 'PREVIOUS MONTH SOW'
FROM 
    dbcba.KE_ACCOUNT_TRANSACTIONS AS tran
    inner join dbcba.KE_Customer_Master cm
    on tran.CUSTOMER_ID = cm.CUSTOMER_NUMBER and cm.EXTRACTION_DATE = (select max(processing_date) from dbcba.end_of_day)
WHERE 
   tran.AMOUNT_LCY > 0 
    AND txn_code_initiation ='CUSTOMER' 
 and (tran.CREDIT_CUSTOMER <> tran.DEBIT_CUSTOMER 
     OR (tran.CREDIT_CUSTOMER IS NULL OR tran.CREDIT_CUSTOMER = '')
     OR (tran.DEBIT_CUSTOMER IS NULL OR tran.DEBIT_CUSTOMER = ''))
 and (tran.CUSTOMER_ID <> tran.DEBIT_CUSTOMER 
    OR (tran.CUSTOMER_ID IS NULL OR tran.CUSTOMER_ID = '')
    OR (tran.DEBIT_CUSTOMER IS NULL OR tran.DEBIT_CUSTOMER = ''))
      AND tran.TRANSACTION_CODE NOT IN ('1085', '766', '949', '945', '991', '941', '433', '1006', '85', 
   '234', '859', '940', '992', '947', '939', '946', '944', '948', '938', '1001')
    and tran.REVERSAL_MARKER<>'R'
    AND tran.BOOKING_DATE BETWEEN  
    DATEADD(DAY, 1 - DAY(CURRENT DATE), DATEADD(MONTH, -1, CURRENT DATE))  
    AND DATEADD(DAY, -1, DATEADD(MONTH, 0, DATEADD(DAY, 1 - DAY(CURRENT DATE), CURRENT DATE)))

GROUP BY 
    tran.ACCOUNT_NUMBER, 
     cm.CUSTOMER_NUMBER,
     cm.CUS_SHORT_NAME
     
     

  
         