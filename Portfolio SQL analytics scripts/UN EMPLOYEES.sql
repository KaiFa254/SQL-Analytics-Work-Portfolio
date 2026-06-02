   
   
  
   SELECT EmployerName,
       EmploymentType,
       Scheme_Sponsor,
       SchemeName,
       SchemeIns,
       Scheme_Type,
       SchemeNumber,
       *
FROM NIC_PB_EXTTABLE
WHERE
      LOWER(EmployerName) LIKE '%united nation%'
   OR LOWER(EmployerName) LIKE 'un %'
   OR LOWER(EmployerName) LIKE '% un %'

   -- ECOSOC & UN Commissions
   OR LOWER(EmployerName) LIKE '%ecosoc%'
   OR LOWER(EmployerName) LIKE '%economic and social%'
   OR LOWER(EmployerName) LIKE '%economic commission%'
   OR LOWER(EmployerName) LIKE '%latin america%'
   OR LOWER(EmployerName) LIKE '%caribbean%'
   OR LOWER(EmployerName) LIKE '%asia and the pacific%'
   OR LOWER(EmployerName) LIKE '%western asia%'

   -- UN Offices & Funds
   OR LOWER(EmployerName) LIKE '%peacebuilding%'
   OR LOWER(EmployerName) LIKE '%human settlements%'
   OR LOWER(EmployerName) LIKE '%population fund%'
   OR LOWER(EmployerName) LIKE '%un university%'
   OR LOWER(EmployerName) LIKE '%children in armed conflict%'
   OR LOWER(EmployerName) LIKE '%sexual violence in conflict%'
   OR LOWER(EmployerName) LIKE '%violence against children%'
   OR LOWER(EmployerName) LIKE '%gender equality%'
   OR LOWER(EmployerName) LIKE '%climate change%'
   OR LOWER(EmployerName) LIKE '%unfccc%'
   OR LOWER(EmployerName) LIKE '%trade and development%'
   OR LOWER(EmployerName) LIKE '%international trade centre%'
   
   
   -- UN Nairobi / Kenya Presence (OTHERS)
   OR LOWER(EmployerName) LIKE '%unep%'
   OR LOWER(EmployerName) LIKE '%un environment%'
   OR LOWER(EmployerName) LIKE '%un habitat%'
   OR LOWER(EmployerName) LIKE '%un-habitat%'
   OR LOWER(EmployerName) LIKE '%unon%'
   OR LOWER(EmployerName) LIKE '%un office at nairobi%'
   OR LOWER(EmployerName) LIKE '%department of global communications%'
   OR LOWER(EmployerName) LIKE '%department of safety and security%'
   OR LOWER(EmployerName) LIKE '%undss%'

   -- UN Funds & Programmes in Kenya
   OR LOWER(EmployerName) LIKE '%undp%'
   OR LOWER(EmployerName) LIKE '%un development programme%'
   OR LOWER(EmployerName) LIKE '%unicef%'
   OR LOWER(EmployerName) LIKE '%un children%'
   OR LOWER(EmployerName) LIKE '%unfpa%'
   OR LOWER(EmployerName) LIKE '%un women%'
   OR LOWER(EmployerName) LIKE '%wfp%'
   OR LOWER(EmployerName) LIKE '%world food programme%'
   OR LOWER(EmployerName) LIKE '%unhcr%'
   OR LOWER(EmployerName) LIKE '%refugees%'
   OR LOWER(EmployerName) LIKE '%unodc%'
   OR LOWER(EmployerName) LIKE '%un office on drugs and crime%'
   OR LOWER(EmployerName) LIKE '%unaids%'
   OR LOWER(EmployerName) LIKE '%unops%'
   OR LOWER(EmployerName) LIKE '%unv%'
   OR LOWER(EmployerName) LIKE '%un volunteers%'

   -- Specialized Agencies (Kenya / Regional)
   OR LOWER(EmployerName) LIKE 'who'
   OR LOWER(EmployerName) LIKE '%world health organization%'
   OR LOWER(EmployerName) LIKE '%fao%'
   OR LOWER(EmployerName) LIKE '%food and agriculture%'

   OR LOWER(EmployerName) LIKE '%international labour organization%'
   OR LOWER(EmployerName) LIKE '%unesco%'
   OR LOWER(EmployerName) LIKE '%education scientific%'
   OR LOWER(EmployerName) LIKE '%icao%'
   OR LOWER(EmployerName) LIKE '%civil aviation%'
   OR LOWER(EmployerName) LIKE '%iom%'
   OR LOWER(EmployerName) LIKE '%international organization for migration%'

   -- Humanitarian, Peace & Coordination
   
   OR LOWER(EmployerName) LIKE '%humanitarian affairs%'
   OR LOWER(EmployerName) LIKE '%peacebuilding%'
   OR LOWER(EmployerName) LIKE '%mine action%'
   OR LOWER(EmployerName) LIKE '%political and peacebuilding%'

   -- Training, Research & System Support
   OR LOWER(EmployerName) LIKE '%unitar%'
   OR LOWER(EmployerName) LIKE '%training and research%'
   OR LOWER(EmployerName) LIKE '%system staff college%'
   OR LOWER(EmployerName) LIKE '%chief executives board%'
