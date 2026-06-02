
left join dbcba.KE_Accounts_List ac
on pb.LOANACNTNO =ac.ARRANGEMENT_ID and lower(ac.PRODUCT_LINE)='lending'
left join  (select CUSTOMER_NUMBER ,sum(TOTAL_CREDITS) as total_CREDITS  from stgke.STG_SOW_TOTAL_CREDITS
where TXN_YEAR_MONTH ='2024-9'
group by CUSTOMER_NUMBER ) e
on ac.CUSTOMER=e.CUSTOMER_NUMBER
where LOANACNTNO is not null 
and lower(ac.ARR_STATUS) in ('current','expired')
ORDER BY CONTRACT_DATE 



