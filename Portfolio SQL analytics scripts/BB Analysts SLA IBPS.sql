SELECT     
    c.PersonalName + ' ' + c.FamilyName AS AnalystName,  
    a.EntryDateTime,    
    a.ExitDateTime,    
    a.TAT,    
    a.Decision,  
    case 
    	when a.workstepname IN( 'Checker','Appraisal', 'Appraisal Manager') and a.Decision in ('Discard','Decline') then 'DECLINED'
    	when a.workstepname IN( 'Checker','Appraisal', 'Appraisal Manager') and a.Decision in ('Recommend','Send To Business Head','Send to Risk Officer','STP') then 'FORWARDS'
		when a.workstepname IN( 'Checker','Appraisal', 'Appraisal Manager') and a.Decision in ('Documents Pending','Send Back','Send Back To EDE','Send Back To Pending Docs','Send to ReScan') then 'SEND BACK TO RMS'
		when a.workstepname IN( 'Checker','Appraisal', 'Appraisal Manager') and a.Decision in ('Clarification','Forward','Send to Risk Officer','Exception Raised','Refer','--Select--') then 'IN-HOUSE  ACTIONS'
		when a.workstepname IN( 'Checker','Appraisal', 'Appraisal Manager') and a.Decision IS NULL then 'IN-HOUSE  ACTIONS'
    end  AS [ANALYSIS DECISON],
    d.AmtApplied,    
    e.TotalApprovedAmount AS "Apprvd amount",    
    d.AmtRecommended,   
    d.Enhanced_Amount,    
    a.workStepName,    
    a.WrkItmID,    
    d.RiskStatus ,
    case 
    	when RiskStatus in ('Approved') then 'Approved'
    	when RiskStatus in ('Decline') then 'Declined'
    	when RiskStatus in ('Refer to Risk Director','Refer to Risk Manager','--Select--') then 'In Progress'
    	when RiskStatus in ('Send Back To AP','Send Back To APM','Send Back To Business Head','Send Back to Pending Docs') then 'Send Backs'
    	when RiskStatus is null then 'In Progress'
    end AS [RISK TEAM DECISON],   
    d.CurrentWrkStep,    
    a.Remarks  
FROM nic_bb_statuscomments a  
JOIN pdbuser c 
    ON a.userName = c.UserName  
JOIN NIC_BB_EXTTABLE d 
    ON a.WrkItmID = d.WrkItmNo  
LEFT JOIN NIC_BB_ProductDetails e 
    ON e.wrkitmID = d.WrkItmNo  
WHERE a.workStepName IN ('Appraisal', 'Appraisal Manager')
