SELECT
    Identifier, CUSTOMERNO, ACCOUNTNO, NetIncome, OnUsEMI,
    CurrentBalanceAmount, Debit_Turnover, TotalAssets, MOBILE_TOTAL,
    PASTDUEAMOUNT, MAXARREARS, CURRENTINARREARS, NONPERFORMING, Gender,
    SavingAcctDepositCount, Age, CustomerTenure, FirstName, MiddleName,
    IDNO, Email, DOB, SURNAME, EmployerStrength, PhoneNumber, CUSTOMERNAMES,
    EMPLOYER_CATEGORY, Netinaccount,
    CAST(New_Customer_Flag AS VARCHAR(10)) AS NEW_Cust_Flag,
    Customer_Creation_Date, LOAD_DATE, [LIMIT], Propdrstocr, AvgInpayments, ELMA_Mobile_Number
FROM dbcba.LFA_data_source
