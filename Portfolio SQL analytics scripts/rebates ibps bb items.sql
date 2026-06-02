select a.WrkItmNo,
a.CustNo,
k.ProductType,
k.ProposedLimit,
a.Branch,
a.DsaCode as [Account Officer Code], AppraisalStatus, 
k.InterestRate,
k.RebateRate,
k.APMRate as [Concessional Rate], 
a.ApplicationDate, 
k.Currency
from nic_bb_exttable a 
join NIC_BB_ProductDetails c on a.WrkItmNo=c.WrkItmId 
join NIC_BB_ProductDetails_Grid k on c.parentMapping=k.ChildMapping 
where k.RebateRate is not null
and ApplicationDate between  '2025-01-01' and '2025-12-01'