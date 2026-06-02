SELECT DISTINCT 
    WrkItmno AS 'Work Item ID',
    CustNo, 
    CASE 
        WHEN LOWER(WrkItmno) LIKE '%loan%' THEN 'AF'
        ELSE 'Others'
    END AS "[LOAN TYPE]",
    CsAvgTurnOver AS [Month SOW Kes000],
    SOWProposed,
    ISNULL(CONVERT(VARCHAR, q.IntroductionDateTime, 13), '-') AS "Applicationdate",
    AcctNo,
    LoanType,
    apprdate AS 'Approval Date',
    LoanAccNo,
    Currency,
    q.activityname AS 'Current Queue',
    q.entrydatetime,
    CASE 
        WHEN e.CoporateName IS NULL 
        THEN RTRIM(LTRIM(FName)) + ' ' + RTRIM(LTRIM(MName)) + ' ' + RTRIM(LTRIM(SName)) 
        ELSE e.CoporateName 
    END AS 'Customer Name'
FROM NIC_LOAN_EXTTABLE e 
JOIN queueview q ON e.WrkItmno = q.processinstanceid 
JOIN nic_loan_statuscomments d ON e.wrkitmno = d.workitemid
WHERE 
    LoanType NOT LIKE 'IPF' 
    AND SOWProposed IS NOT NULL 
    AND q.activityname IN 
    (
        'BB Portfolio Validation', 'Manual Disbursement', 'Work Exit1', 
        'Disbursement', 'BB RM Deepening', 'Platinum Banking RM Deepening', 
        'BB Portfolio Deepening', 'PB Portfolio Deepening'
    )
    AND TRY_CONVERT(DATE, e.applicationdate) BETWEEN '2026-04-01' AND '2026-04-30'
ORDER BY e.WrkItmno DESC;






