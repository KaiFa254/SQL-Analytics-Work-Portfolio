select distinct
acc.CUSTOMER,SCHEME_NUMBER,
case when acc.SCHEME_INS_PART <>'' then acc.SCHEME_INS_PART else acc.NIC_SCHEMES end as SCHEME 
from dbcba.ke_accounts_list acc 
left join STGKE.STG_AVERAGE_BALANCE bal on bal.Account_number = acc.Account_number and bal.Av_Bal_Date=(select max(PROCESSING_DATE) PROCESSING_DATE from dbcba.end_of_day)
left join dbcba.ke_Customer_master cm on acc.customer=cm.Customer_number  and cm.EXTRACTION_DATE =bal.Av_Bal_Date
where  
cm.CLASSIFICATION <>'B20'
and acc.PRODUCT_LINE='LENDING'
and acc.category not in ('3114','3765','3113')
and bal.daily_lcy_bal<>0 
--and (acc.NIC_SCHEMES is not null or acc.SCHEME_INS_PART is not null)
and cm.BUSINESS_SEGMENT in ('200','250','270')
and scheme <>'' 

select distinct
acc.CUSTOMER,SCHEME_NUMBER,
case when acc.SCHEME_INS_PART <>'' then acc.SCHEME_INS_PART else acc.NIC_SCHEMES end as SCHEME 
from dbcba.ke_accounts_list acc 
where  scheme <>'' 


