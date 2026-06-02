WITH AprraisalStepOwner AS (
    SELECT 
        s.WrkItmID, 
        u.PersonalName + ' ' + u.FamilyName AS ApraisalOwner, 
        RANK() OVER (PARTITION BY s.WrkItmID ORDER BY s.EntryDateTime ASC) AS RankOrder
    FROM nic_pb_statuscomments s
    JOIN pdbuser u ON s.userName = u.UserName
    WHERE s.workStepName IN ('Appraisal', 'Appraisal Manager')
),
CheckerStepOwnerRank AS (
    SELECT 
        s.WrkItmID, 
        u.PersonalName + ' ' + u.FamilyName AS CheckerOwner, 
        RANK() OVER (PARTITION BY s.WrkItmID ORDER BY s.EntryDateTime ASC) AS RankOrder
    FROM nic_pb_statuscomments s
    JOIN pdbuser u ON s.userName = u.UserName
    WHERE s.workStepName IN ('Checker')
)
SELECT 
	a.WrkItmID,  
    c.PersonalName + ' ' + c.FamilyName AS ActionAnalystName,  
    case 
    	when workStepName in ('Checker') then cs.CheckerOwner
    	else aps.ApraisalOwner
    end as ItemOwner,    
    a.EntryDateTime,    
    a.ExitDateTime,    
    a.TAT,    
    a.Decision,
    CASE 
        WHEN a.workStepName IN ('Checker', 'Appraisal', 'Appraisal Manager') 
             AND a.Decision IN ('Discard', 'Decline') THEN 'DECLINED'
        WHEN a.workStepName IN ('Checker', 'Appraisal', 'Appraisal Manager') 
             AND a.Decision IN ('Recommend', 'Send To Business Head', 'Send to Risk Officer', 'STP') THEN 'FORWARDS'
        WHEN a.workStepName IN ('Checker', 'Appraisal', 'Appraisal Manager') 
             AND a.Decision IN ('Documents Pending', 'Send Back', 'Send Back To EDE', 'Send Back To Pending Docs', 'Send to ReScan') THEN 'SEND BACK TO RMS'
        WHEN a.workStepName IN ('Checker', 'Appraisal', 'Appraisal Manager') 
             AND a.Decision IN ('Clarification', 'Forward', 'Send to Risk Officer', 'Exception Raised', 'Refer', '--Select--') THEN 'IN-HOUSE ACTIONS'
        WHEN a.workStepName IN ('Checker', 'Appraisal', 'Appraisal Manager') 
             AND a.Decision IS NULL THEN 'IN-HOUSE ACTIONS'
    END AS [ANALYSIS DECISON],
    a.workStepName,    
    d.Loan_Type,     
    d.AmtApplied,     
    d.AmtApproved,  
    d.RiskStatus,
    CASE 
        WHEN d.RiskStatus = 'Approved' THEN 'Approved'
        WHEN d.RiskStatus = 'Decline' THEN 'Declined'
        WHEN d.RiskStatus IN ('Refer to Risk Director', 'Refer to Risk Manager', '--Select--') THEN 'In Progress'
        WHEN d.RiskStatus IN ('Send Back To AP', 'Send Back To APM', 'Send Back To Business Head', 'Send Back to Pending Docs') THEN 'Send Backs'
        WHEN d.RiskStatus IS NULL THEN 'In Progress'
    END AS [RISK TEAM DECISON],    
    d.custcurrency AS "Currency",      
    a.Comments  
FROM nic_pb_statuscomments a  
JOIN pdbuser c 
    ON a.userName = c.UserName  
JOIN NIC_PB_EXTTABLE d 
    ON a.WrkItmID = d.WorkItmId  
LEFT JOIN CheckerStepOwnerRank cs 
    ON a.WrkItmID = cs.WrkItmID AND cs.RankOrder = 1
LEFT JOIN AprraisalStepOwner aps 
    ON a.WrkItmID = aps.WrkItmID AND aps.RankOrder = 1
WHERE a.workStepName IN ('Checker', 'Appraisal', 'Appraisal Manager')





