select * -- DISTINCT ACCOUNT_NUMBER,ACCOUNT_TITLE_1,CATEGORY_DESC,AC_OTHER_OFFICER,dt.NAME as [OTHER OFFICER NAME],ACCOUNT_BRANCH_NAME,OPENING_DATE,CURRENCY,ONLINE_ACTUAL_BAL,dm.Cost_Centre_Name,
--dt.AREA,dt.DELIVERY_POINT,dt.EMAIL_ID
from
dbcba.KE_Accounts_Master am
		left join  STGKE.STG_F_DEPT_ACCT_OFFICER dt
		on dt.DEPT_ACCT_OFF_CODE=am.AC_OTHER_OFFICER 
		left join  dbcba.STAFF_DAO_MASTER dm
		on am.AC_OTHER_OFFICER =dm.DAO_Code
	where 
	OPENING_DATE between '2025-01-01' and '2025-12-31'
  	and PRODUCT_LINE='ACCOUNTS'
  	AND am.EXTRACTION_DATE = (select max(processing_date) from dbcba.end_of_day)
  	--AND AC_OTHER_OFFICER IS NOT NULL AND AC_OTHER_OFFICER <>'' AND AC_OTHER_OFFICER <>'NOT USED' AND dt.NAME NOT LIKE '%BRANCH%'
  	--AND dt.NAME NOT LIKE '%HEAD OFFICE%'  	AND dt.NAME NOT LIKE '%GOB RM%' AND dt.NAME NOT LIKE '%VSE RM%' AND dt.NAME NOT LIKE '%CPA - EXTERNAL%' 
  	--AND dt.NAME NOT LIKE '%TEAM%' AND dt.NAME NOT LIKE '%HUMAN RESOURCES%' AND dt.NAME NOT LIKE '%NOT USED%' 
  	and AC_OTHER_OFFICER IN ('3270') -- MONITORING TEAM ('8815','5806','5825','3270','5653','5826')
  	ORDER BY dt.NAME

  
  
  SELECT *
  FROM dbcba.account_officer 
  WHERE  ACC_OFF_CODE in ('2385','2453', '3270','2374' )
  AND VALID_TO >= CURRENT TIMESTAMP
  
 

    
  select *
  FROM STGKE.STG_F_DEPT_ACCT_OFFICER
   where DEPT_ACCT_OFF_CODE in ('2385','2453', '3270','2374' )
   
   
   select * FROM 
   dbcba.STAFF_DAO_MASTER
   where --DAO_Code in ('3270','5506','5825') and
   lower(Staff_Name) like '%obilla%'
   
  
   select ACCOUNT_NUMBER,CUSTOMER,ARRANGEMENT_ID,DSA,DSA_NAME 
   from
dbcba.KE_Accounts_Master am
where AC_OTHER_OFFICER ='5711' and
	OPENING_DATE between '2024-01-01' and '2024-12-31'
	and AC_ACCOUNT_OFFICER
	
	
	

	
	WITH customer_data AS
(
    SELECT
        CUSTOMER,
        BOOKING_DATE,
        
        EXTRACT(YEAR FROM BOOKING_DATE) AS BOOKING_YEAR,
        EXTRACT(MONTH FROM BOOKING_DATE) AS BOOKING_MONTH
        
    FROM customer_list
),

master_data AS
(
    SELECT
        ACCOUNT_NUMBER,
        CUSTOMER,
        ARRANGEMENT_ID,
        DSA,
        DSA_NAME,
        UPLOAD_DATE,
        
        EXTRACT(YEAR FROM UPLOAD_DATE) AS UPLOAD_YEAR,
        EXTRACT(MONTH FROM UPLOAD_DATE) AS UPLOAD_MONTH
        
    FROM dbcba.KE_Accounts_Master
)

SELECT
    c.CUSTOMER,
    c.BOOKING_DATE,
    m.ACCOUNT_NUMBER,
    m.ARRANGEMENT_ID,
    m.DSA,
    m.DSA_NAME,
    m.UPLOAD_DATE

FROM customer_data c

LEFT JOIN master_data m
    ON c.CUSTOMER = m.CUSTOMER
    AND c.BOOKING_YEAR = m.UPLOAD_YEAR
    AND c.BOOKING_MONTH = m.UPLOAD_MONTH
;
   
---------------------------------------------------------

 SELECT
        ACCOUNT_NUMBER,
        CUSTOMER,
        ARRANGEMENT_ID,
        DSA,
        DSA_NAME
            FROM       dbcba.KE_Accounts_List am
            WHERE am.PRODUCT_LINE = 'LENDING'
      AND am.ARR_STATUS IN ('CURRENT', 'EXPIRED')
      AND am.ARR_STATUS NOT IN ('AUTH','UNAUTH','REVERSED')
      AND am.ONLINE_ACTUAL_BAL <= 0

