CREATE VIEW [rpt].[vUSPI_DIM_payor] AS
SELECT 
    5 AS company_code,  -- Company code
    NULL AS facility_code,                                        -- Placeholder for facility code
    p1.PayerName AS payor_name,                                   -- Payer name
    NULL AS payor_type,                                           -- Placeholder for payor type
    pp.PayerPlanName AS payor_plan,                               -- Payer plan name
    pp.PayerPlanSourceID AS payor_plan_code,                                      -- Placeholder for payor plan code
    pp.PayerPlanContractNumber AS contract_code,                  -- Contract code
    NULL AS contract_flag,                                        -- Placeholder for contract flag
    NULL AS contract_type,                                        -- Placeholder for contract type
    'EPIC' AS source_system,                                      -- Source system identifier
    p1.PayerSourceID AS payor_code,                               -- Payer code
    fc.financial_class_code AS financial_class_code,                           
    CASE 
        WHEN p1.PayerSourceID = 0 THEN 1 
        ELSE 0 
    END AS self_pay_ind,  
    GETDATE() AS create_date,                                     -- Current date/time for ETL
    GETDATE() AS update_date,                                          -- Placeholder for update date
    p1.PayerSourceID AS source_payor_code,                -- Source payor code
    NULL AS field_1,                                              -- Placeholder for field_1
    NULL AS field_2,                                              -- Placeholder for field_2
    NULL AS field_3,                                              -- Placeholder for field_3
    NULL AS field_4                                               -- Placeholder for field_4
FROM 
    [HPIDW].[dim].[PayerPlans] pp
LEFT JOIN 
    [HPIDW].[dim].[Payers] p1 
    ON pp.PayerID = p1.PayerID

LEFT JOIN 
	HPIDW.rpt.vUSPI_DIM_financial_class fc
	ON fc.financial_class_code = p1.PayerCategoryID
WHERE 
    pp.PayerPlanDataSourceID = 5;
GO
