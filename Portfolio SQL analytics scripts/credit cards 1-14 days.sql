	select distinct CUSTOMERNAME,
vas.CARDNUMBER,
vas.CARD_ACCOUNT_NUMBER,
vas.BANKACCOUNT,
al.ONLINE_ACTUAL_BAL,
vas.PRODUCT_NAME,
vas.PRODUCT_TYPE,
CASE 
	WHEN vas.CURRENCY = 'Kenyan Shilling' then 'KES'
	WHEN vas.CURRENCY = 'Tanzanian Shilling' then 'TZS'
	WHEN vas.CURRENCY = 'US Dollar' then 'USD'
	WHEN vas.CURRENCY = 'Ugandan Shilling' then 'UGX'
END CURRENCY,
vas.CREDITLIMIT,
vas.BALANCE,
vas.ACCT_STATUS,
vas.BANKDDENABLED,
vas.MINAMOUNT,
vas.OVERDUEAMOUNT_ACCT,
vas.OVERDUECYCLES,
vas.OVERDUEDAYS,
vas.MOBILE_TELEPHONE_NUMBER,
vas.LOCATION_COUNTRY,
vas.EMAIL_ADDRESS,
vas.ACCOUNT_PRODUCT_TYPE,
vas.INSTALMENT_DUE_DATE,
vas.CURRENCY_OF_FACILITY,
vas.ACCOUNT_STATUS,
vas.DATE_OF_LATEST_PAYMENT,
vas.LAST_PAYMENT_AMOUNT,
vas.CUSTOMER_NO,
vas.EXTRACTION_DATE,
vas.BANKDDPERCENTAGE,
vas.MINPAYPERCENTAGE,
cm.ACCOUNT_OFFICER_NAME,
    CASE 
        WHEN cm.CUSTOMER_BRANCH_NAME IS NULL OR cm.CUSTOMER_BRANCH_NAME = '' 
            THEN al.ACCOUNT_BRANCH_NAME
        ELSE cm.CUSTOMER_BRANCH_NAME
    END AS CUSTOMER_BRANCH,
 CASE 
            WHEN cm.BUSINESS_SEGMENT IN ('270','250') THEN 'CONSUMER BANKING'
            WHEN cm.BUSINESS_SEGMENT IN ('200') THEN 'COMMERCIAL & BUSINESS BANKING'
        END AS BUSINESS_UNIT,
cm.SUB_SEGEMENT_DESC
from stgke.STG_OVERDUE_VAS vas
							left JOIN dbcba.KE_Accounts_List al
						    ON vas.BANKACCOUNT = al.ACCOUNT_NUMBER
							left JOIN (select * from dbcba.KE_Customer_Master where EXTRACTION_DATE = (SELECT MAX(processing_date) FROM dbcba.end_of_day)) cm 
						    ON al.CUSTOMER = cm.CUSTOMER_NUMBER
where --vas.OVERDUEDAYS between 1 and 14
vas.EXTRACTION_DATE = (select max(EXTRACTION_DATE) from stgke.STG_OVERDUE_VAS)
AND cm.BUSINESS_SEGMENT NOT IN ('260')
AND vas.PRODUCT_NAME NOT IN (
            'TZ USD PERSONAL credit GOLD',
            'TZS Personal Gold credit card',
            'Uganda Shillings Personal Gold Credit Card',
            'Uganda USD Visa Gold Credit',
            'Uganda business Credit',
            'TZ USD Business Gold credit',
            'TZS Business Gold Credit Card',
            'TZ Person Classic credit card',
            'Uganda Visa Classic Credit',
            'Uganda USD Business Credit',
            'TZ USD BUSSINESS credit SILVER'
        )
and vas.CARD_ACCOUNT_NUMBER not in ('3454JKJDF')
order by CREDITLIMIT DESC

--BRANCH

	select distinct CUSTOMERNAME,
vas.CARDNUMBER,
vas.CARD_ACCOUNT_NUMBER,
vas.BANKACCOUNT,
    CASE 
        WHEN cm.CUSTOMER_BRANCH_NAME IS NULL OR cm.CUSTOMER_BRANCH_NAME = '' 
            THEN al.ACCOUNT_BRANCH_NAME
        ELSE cm.CUSTOMER_BRANCH_NAME
    END AS CUSTOMER_BRANCH,
 CASE 
            WHEN cm.BUSINESS_SEGMENT IN ('270','250') THEN 'CONSUMER BANKING'
            WHEN cm.BUSINESS_SEGMENT IN ('200') THEN 'COMMERCIAL & BUSINESS BANKING'
        END AS BUSINESS_UNIT,
cm.SUB_SEGEMENT_DESC
from stgke.STG_OVERDUE_VAS vas
							left JOIN dbcba.KE_Accounts_List al
						    ON vas.BANKACCOUNT = al.ACCOUNT_NUMBER
							left JOIN (select * from dbcba.KE_Customer_Master where EXTRACTION_DATE = (SELECT MAX(processing_date) FROM dbcba.end_of_day)) cm 
						    ON al.CUSTOMER = cm.CUSTOMER_NUMBER
where --vas.OVERDUEDAYS between 1 and 14
vas.EXTRACTION_DATE = (select max(EXTRACTION_DATE) from stgke.STG_OVERDUE_VAS)
AND cm.BUSINESS_SEGMENT NOT IN ('260')

