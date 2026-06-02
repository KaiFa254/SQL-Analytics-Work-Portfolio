
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
    and  (ProductDescription in ('Affordable Housing Mortg(Consumer)',
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
'Property Purchase Loan','Mortgage','Plot Purchase Loans','Property Purchase Loan') 
or lower(ProductDescription) like '%mortgage%' or lower(ProductDescription) like '%build%'
or lower(ProductDescription) like '%house%' or lower(ProductDescription) like '%plot%'
or lower(ProductDescription) like '%construction%' or lower(ProductDescription) like '%equity release%')
 
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
    h.Approvedamount as AmtApproved
 
FROM NIC_BB_EXTTABLE  k join (select g.ProductType,g.Currency,g.InterestRate,g.ApprovedAmount,d.WrkItmId
								from NIC_BB_ProductDetails_Grid g inner join NIC_BB_ProductDetails d
								on g.ChildMapping=d.parentMapping
where lower(g.ProductType) like '%equty%')
h on k.WrkItmNo=h.wrkitmid
WHERE RiskStatus = 'Approved'
    AND FirstApprovalDt >= '2025-01-01'


(g.ProductType  in ('Affordable Housing Mortg(Consumer)',
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
'Property Purchase Loan','Mortgage','Plot Purchase Loans','Property Purchase Loan')
or lower(g.ProductType) like '%mortgage%' or lower(g.ProductType) like '%build%'
or lower(g.ProductType) like '%house%' or lower(g.ProductType) like '%plot%'
or lower(g.ProductType) like '%construction%' or lower(g.ProductType) like '%equity release%')) h on k.WrkItmNo=h.wrkitmid
WHERE RiskStatus = 'Approved'
    AND FirstApprovalDt >= '2025-01-01'

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

    SELECT TOP 3 * --DISTINCT Scheme_Type ,Scheme_Sponsor ,SchemeIns ,SchemeName 
    FROM NIC_PB_EXTTABLE 
    
    SELECT TOP 3 * -- DISTINCT SegmentType
    FROM NIC_BB_EXTTABLE

