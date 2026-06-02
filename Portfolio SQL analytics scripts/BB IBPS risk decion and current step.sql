SELECT 
    d.WrkItmNo ,
    CASE 
        WHEN d.CorporateName IS NULL OR d.CorporateName = '0' 
            THEN RTRIM(LTRIM(FName)) + ' ' + RTRIM(LTRIM(MName)) + ' ' + RTRIM(LTRIM(SName)) 
        ELSE d.CorporateName 
    END AS [Customer Name], 
 d.ApplicationDate, d.SegmentType,
    -- Product & Amounts
    d.ProductType,
    d.AmtApplied,
    d.Enhanced_Amount,    
    d.CurrentWrkStep,    
    d.RiskStatus,
    CASE 
        WHEN d.RiskStatus IN ('Approved') THEN 'Approved'
        WHEN d.RiskStatus IN ('Decline') THEN 'Declined'
        WHEN d.RiskStatus IN ('Refer to Risk Director', 'Refer to Risk Manager', '--Select--') THEN 'In Progress'
        WHEN d.RiskStatus IN ('Send Back To AP', 'Send Back To APM', 'Send Back To Business Head', 'Send Back to Pending Docs') THEN 'Send Backs'
        WHEN d.RiskStatus IS NULL THEN 'In Progress'
    END AS [RISK DECISION],

    d.CurrentWrkStep

FROM   NIC_BB_EXTTABLE d
--JOIN nic_bb_statuscomments a
 --   ON d.WrkItmNo = a.WrkItmID
--LEFT JOIN NIC_BB_ProductDetails e 
   -- ON e.WrkItmID = d.WrkItmNo 
WHERE 
     --d.CurrentWrkStep IN ('Appraisal', 'Appraisal Manager')
    ApplicationDate >= DATEADD(YEAR, -1, CAST(CURRENT_TIMESTAMP AS DATE))  
  
ORDER BY d.WrkItmNo

--select distinct d.CurrentWrkStep  from  NIC_BB_EXTTABLE d

