
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
        Town,
    EmployerName,
    IntRate, 
    FirstApprovalDt AS 'Approval Date',
    RiskStatus,
	CurrentWrkStep,
    custCurrency AS 'Currency',
    AmtApproved
FROM NIC_PB_EXTTABLE  

WHERE RiskStatus = 'Approved' 
   -- AND FirstApprovalDt >= '2025-01-01'
    AND FirstApprovalDt between '2023-01-01' and '2025-12-31'
and  ProductDescription in ('Affordable Housing Mortg(Consumer)',
'Property Purchase Loans',
'EasyBuild(Design & Build)',
'Plot Purchase',
'105OYOH MORTGAGE',
'Equity Release',
'Affordable Housing',
'Equity Release Loan',
'Plot Purchase Loans',
'Construction Loan',
'Construction Mortgage â€“ Consumer',
'Construction Loans',
'Access Mortgage Loans',
'Mortgage Buy Out Loans',
'MORTGAGE.LOAN.KB',
'Buy and Build Construction Loan',
'Market Housing - AHP',
'Mortgage loan',
'Property Purchase Loan',
'Buy and Build Loans',
'Mortgage Loan',
'Plot Purchase Loans',
'Construction Loans',
'Property Purchase Loan')
and WorkItmId ='PB-0000061453-Process'
 

 
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
    ((h.Approvedamount-h.ExistingAmount)/h.cnvrate) as AmtApproved,
    h.uniqueId
 
FROM NIC_BB_EXTTABLE  k join (select g.ProductType,g.Currency,g.InterestRate,g.ExistingAmount,g.ApprovedAmount,g.cnvrate,g.uniqueId,d.WrkItmId
								from NIC_BB_ProductDetails_Grid g inner join NIC_BB_ProductDetails d
								on g.ChildMapping=d.parentMapping
where g.ApprovedAmount > g.ExistingAmount
and g.ProductType  in ('Affordable Housing Mortg(Consumer)',
'Property Purchase Loans',
'EasyBuild(Design & Build)',
'Plot Purchase',
'105OYOH MORTGAGE',
'Equity Release',
'Affordable Housing',
'Equity Release Loan',
'Plot Purchase Loans',
'Construction Loan',
'Construction Mortgage â€“ Consumer',
'Construction Loans',
'Access Mortgage Loans',
'Mortgage Buy Out Loans',
'MORTGAGE.LOAN.KB',
'Buy and Build Construction Loan',
'Market Housing - AHP',
'Mortgage loan',
'Property Purchase Loan',
'Buy and Build Loans',
'Mortgage Loan',
'Plot Purchase Loans',
'Construction Loans',
'Property Purchase Loan')) h on k.WrkItmNo=h.wrkitmid
WHERE RiskStatus = 'Approved'
    --AND FirstApprovalDt >= '2025-01-01'
    AND FirstApprovalDt between '2023-01-01' and '2024-12-31'