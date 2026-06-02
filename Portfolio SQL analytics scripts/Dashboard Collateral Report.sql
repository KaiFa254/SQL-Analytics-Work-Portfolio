select TOP 100
c.RECID,substring(c.RECID,1,6) as CUSTOMER_NO,pdo.CUS_SHORT_NAME, aac.AA_AARANGEMENT,ad.SEC_ATTACHED,c.COLLATERAL_TYPE,dt.COLLATERAL_TYPE_DESCRIPTION,c.DESCRIPTION,c.DESCRIPTION_1,c.CURRENCY,c.EXECUTION_VALUE , c.NOMINAL_VALUE,
ad.VEHICLE_MODEL, ad.REG_NUMBER,ad.INSURANCE_TYPE,ad.INSURANCE_AMT,ad.INSUR_EXP_DATE,ad.VAL_EXPIRY_DATE,ad.RATE_EXP_DATE,ad.RENT_EXP_DATE, ad.MARKET_VALUE,ad.FORCE_VALUE,
pdo.BUSINESS_SEGMENT, pdo.SUB_SEGEMENT, pdo.SUB_SEGEMENT_DESC,pdo.ARR_STATUS AS lOAN_STATUS, pdo.CUSTOMER_BRANCH_NAME,pdo.ACCOUNT_OFFICER_NAME ,pdo.CUS_ACC_OFFICER
from
stgke.STG_Collateral c
		INNER JOIN stgke.STG_NIC_CO_ADDL_DETS  ad
		ON c.RECID=ad.RECID
		left join dbcba.collateral_type dt 
		on c.COLLATERAL_TYPE=dt.COLLATERAL_TYPE
inner join
		(select *
		FROM dbcba.KE_Accounts_Master am
INNER JOIN dbcba.KE_Customer_Master cm
		on am.CUSTOMER =cm.CUSTOMER_NUMBER and am.EXTRACTION_DATE=cm.EXTRACTION_DATE
		where cm.EXTRACTION_DATE =(select max(processing_date) from dbcba.end_of_day)
		and am.PRODUCT_LINE ='LENDING' AND am.ARR_STATUS in ('CURRENT','EXPIRED') and cm.BUSINESS_SEGMENT in ('270','250','200')
		and cm.CLASSIFICATION <>'B20') pdo
		on ad.SEC_ATTACHED=pdo.ARRANGEMENT_ID
inner join (SELECT 
       		ID_COMP_1 as AA_AARANGEMENT,
        	UNPIVOTED_COLLAT_ID AS AA__COLLAT_ID
			FROM (
   			 SELECT 
       		 	ID_COMP_1,
        		COLLAT_ID,     
		        COLLAT_ID1,
		        COLLAT_ID2,
		        COLLAT_ID3,
		        COLLAT_ID4,
		        COLLAT_ID5,
		        COLLAT_ID6,
		        COLLAT_ID7,
		        COLLAT_ID8,
		        COLLAT_ID9,
		        COLLAT_ID10
			    FROM STGKE.STG_AA_ARR_OFFICERS
			) AS AA_Collaterals
			UNPIVOT (
			    UNPIVOTED_COLLAT_ID FOR COLLAT_ID_COLUMN IN (
			        COLLAT_ID,    
			        COLLAT_ID1, 
			        COLLAT_ID2, 
			        COLLAT_ID3, 
			        COLLAT_ID4, 
			        COLLAT_ID5,
			        COLLAT_ID6,
			        COLLAT_ID7,
			        COLLAT_ID8,
			        COLLAT_ID9,
			        COLLAT_ID10
			    )
			) AS unpvt
			WHERE UNPIVOTED_COLLAT_ID IS NOT NULL) aac
			on c.RECID=aac.AA__COLLAT_ID
where 
 c.COLLATERAL_TYPE not in ('704','921','702','201','605','551','652','701','703','705','801','355','354','353','351','321','961','941','991')
 