
                WITH mx_dt AS (
                    SELECT
                        MAX(LOAD_DATE) max_load_date
                    FROM dbcba.AA_SCHEDULES
                )
                SELECT
                    aa_sch.*
                FROM dbcba.AA_SCHEDULES aa_sch
                INNER JOIN mx_dt
                    ON (mx_dt.max_load_date = aa_sch.LOAD_DATE)
                      where ARRANGEMENT ='AA252699NT59'
                ORDER BY aa_sch.ARRANGEMENT, aa_sch.SCHEDULE_DATE DESC
                
                                             ;
 ------LAST INSTALLMENT SCRIPT--------------------------------------------                                            
                                             
     WITH mx_dt AS (
    SELECT MAX(LOAD_DATE) AS max_load_date
    FROM dbcba.AA_SCHEDULES
),
ranked AS (
    SELECT
        aa_sch.*,
        ROW_NUMBER() OVER (
            PARTITION BY aa_sch.ARRANGEMENT
            ORDER BY aa_sch.SCHEDULE_DATE DESC
        ) AS rn
    FROM dbcba.AA_SCHEDULES aa_sch
    INNER JOIN mx_dt
        ON mx_dt.max_load_date = aa_sch.LOAD_DATE
)
SELECT *
FROM ranked
WHERE rn = 1
AND ARRANGEMENT = 'AA252699NT59'
;
----------------------------------------------------------------------------------------------            
                    
          
            