select  c.CUS_SHORT_NAME ,c.CUSTOMER_NUMBER, convert(decimal(12,2),COALESCE(ex.Deal_balance,0)+COALESCE(exs.Excess_Exposure,0)) as 'Total Exposure',
exs.Excess_Exposure as Excess_Amount, convert(decimal(12,2),pdo.ARREARS_KES) Loan_ARREARS_KES,
Case 
	when MAX_LOAN_OD_DAYS is null and MAX_EXCESS_DAYS is null then MAX_LOAN_OD_DAYS
	when COALESCE(MAX_LOAN_OD_DAYS,0)>COALESCE(MAX_EXCESS_DAYS,0) then COALESCE(MAX_LOAN_OD_DAYS,0)
	else COALESCE(MAX_EXCESS_DAYS,0)
END as Overall_MAX_DPD,
c.CUSTOMER_BRANCH_NAME ,c.ACCOUNT_OFFICER_NAME ,c.SUB_SEGEMENT_DESC ,c.BUSINESS_SEGMENT_DESC 
from 
dbcba.ke_customer_master c 
LEFT   join  
		(select SUBSTRING(RECID,1,6) as customer_no, sum(Deal_balance) as Deal_balance  from
		stgke.STG_ECB_TOTAL_EXPOSURE 
		WHERE load_date ='2024-10-16'
		group by SUBSTRING(RECID,1,6)) ex
on c.CUSTOMER_NUMBER =ex.customer_no
LEFT JOIN(select CUSTOMER,sum(ARREARS_KES) ARREARS_KES, MAX(OD_DAYS) MAX_LOAN_OD_DAYS
		from
		STGKE.STG_AA_BILL_ARREARS
		where EXTRACTION_DATE =(select max(processing_date) from dbcba.end_of_day )
		GROUP BY CUSTOMER) pdo
ON c.CUSTOMER_NUMBER=pdo.CUSTOMER
left join (select [CUSTOMER NO] ,SUM(EXPOSURE_KES) Excess_Exposure,MAX([EXCESS DAYS]) MAX_EXCESS_DAYS
from
STGKE.STG_AA_DAYS_EXCESS
where EXTRACTION_DATE=(select max(processing_date) from dbcba.end_of_day ) 
GROUP BY [CUSTOMER NO]) exs
ON c.CUSTOMER_NUMBER=exs.[CUSTOMER NO]
where c.EXTRACTION_DATE =(select max(processing_date) from dbcba.end_of_day )
and c.CUSTOMER_NUMBER in
('132702',
'218063',
'239091',
'295765',
'322689',
'325615',
'375712',
'394371',
'416868',
'424472',
'440165',
'450615',
'454511',
'456692',
'463703',
'467051',
'474464',
'500782',
'502385',
'502891',
'506452',
'510444',
'513496',
'517503',
'521649',
'522736',
'528723',
'555534',
'560551',
'576248',
'581909',
'584406',
'589350',
'594793',
'602477',
'608167',
'610384',
'649959',
'656759',
'699592',
'715116',
'728274',
'735667',
'795501',
'805339',
'835851',
'837839',
'838153',
'850914',
'852879',
'861320',
'867048',
'902450',
'848797',
'377491',
'436498',
'737566',
'655576',
'144467',
'454404',
'556648',
'826658',
'562237',
'283680',
'626872',
'666520',
'851861',
'522478',
'153968',
'490913',
'554413',
'601220'
)
order by convert(decimal(12,2),COALESCE(ex.Deal_balance,0)+COALESCE(exs.Excess_Exposure,0)) desc




