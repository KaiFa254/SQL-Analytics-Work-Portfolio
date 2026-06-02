
-------------------------------------------------------------------------------
-- PB MORTGAGES --  
SELECT DISTINCT  
    WorkItmId,
    DsaCode,
    IntroducerName,
    Branch,
    SegmentType,
    customerNumber AS 'Customer No.',
    CONCAT(FName, ' ', MName, ' ', SName) AS 'Customer Name',
    Loan_Type,
    ProductDescription,
    Scheme_Sponsor,
    EmployerName,
    IntRate,
    FirstApprovalDt AS 'Approval Date',
    RiskStatus,
    CurrentWrkStep,
    custCurrency AS 'Currency',
    AmtApproved
 
FROM NIC_PB_EXTTABLE  
 
WHERE RiskStatus = 'Approved'
    AND FirstApprovalDt >= '2025-01-01'
    
 
UNION  
 
-- BB MORTGAGES --  
SELECT  
    k.WrkItmNo AS WorkItmId,
   -- k.IntroducerName,
    k.DsaCode,
    --k.IntroducerName,
    k.Branch,
    k.SegmentType,
    k.CustNo AS 'Customer No.',  
    k.CorporateName AS 'Customer Name',
    k.ApplicationType AS Loan_Type,
    h.ProductType AS ProductDescription,
    k.SchemeName AS Scheme_Sponsor,
    k.EmployerName,
    h.InterestRate as IntRate,
    k.FirstApprovalDt AS 'Approval Date',
    k.RiskStatus,
    k.CurrentWrkStep,
    h.Currency AS 'Currency',
    ((h.Approvedamount-h.ExistingAmount)/h.cnvrate) as AmtApproved

FROM NIC_BB_EXTTABLE  k join (select g.ProductType,g.Currency,g.InterestRate,g.ExistingAmount,g.ApprovedAmount,g.cnvrate,d.WrkItmId
								from NIC_BB_ProductDetails_Grid g inner join NIC_BB_ProductDetails d
								on g.ChildMapping=d.parentMapping
where g.ApprovedAmount > g.ExistingAmount
) h on k.WrkItmNo=h.wrkitmid

WHERE RiskStatus = 'Approved'
    AND FirstApprovalDt >= '2025-01-01'
 