select top 3*
from 
STGKE.STG_AA_DAYS_EXCESS
where EXTRACTION_DATE =(select max(processing_date) from dbcba.end_of_day)
AND [CUSTOMER NO] ='163796'

select top 3*
from 
STGKE.Days_Excess
where EXCESS_DATE =(select max(processing_date) from dbcba.end_of_day)
AND [CUSTOMER NO] ='856304'


select max(EXTRACTION_DATE) from STGKE.STG_AA_DAYS_EXCESS

select top 3*
from 
STGKE.STG_ECB_TOTAL_EXCESS_EXPOSURE
where RECID ='3664380198'
AND LOAD_DATE =(select max(processing_date) from dbcba.end_of_day)

