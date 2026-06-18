CREATE VIEW [rpt].[TPGFeeScheduleVariance] AS 
WITH Payments AS (
    SELECT
        TransactionParentSourceID,
        SUM(CASE WHEN TransactionType = 'Adjustment' THEN COALESCE(TransactionAmount, 0) ELSE 0 END) AS TotalAdjustments,
        SUM(CASE WHEN TransactionType IN ('Payment') THEN COALESCE(TransactionAmount, 0) ELSE 0 END) AS TotalPayments,
        SUM(CASE 
            WHEN TransactionType = 'Adjustment' 
                AND TransactionDescription NOT LIKE '%Admin%' 
                AND TransactionDescription NOT LIKE '%SEQUESTRATION WRITE-OFF%'
				AND TransactionDescription NOT LIKE '%Small Balance Adjustment%'
				AND TransactionDescription NOT LIKE '%United HealthCare Adjustment%'
				AND TransactionDescription NOT LIKE '%Commercial Insurance Adjustment%'
				AND TransactionDescription NOT LIKE '%Medicare Adjustment%'
				AND TransactionDescription NOT LIKE '%Tricare Adjustment%'
            THEN TransactionAmount ELSE 0 END) AS TotalAdjustmentsCorrect,
	      SUM(CASE 
        WHEN TransactionType = 'Payment' 
            OR (TransactionType = 'Adjustment' 
                AND (
                    TransactionDescription LIKE '%Small Balance Adjustment%'
                    OR TransactionDescription LIKE '%United HealthCare Adjustment%'
                    OR TransactionDescription LIKE '%Commercial Insurance Adjustment%'
                    OR TransactionDescription LIKE '%Medicare Adjustment%'
                    OR TransactionDescription LIKE '%Tricare Adjustment%'
                )
            )
        THEN COALESCE(TransactionAmount, 0) 
        ELSE 0 
    END) AS TotalPaymentsCorrect,
	p.PayerID

    FROM fact.vPBPaymentsandAdjustmentsCorrected
	  LEFT JOIN [dim].[Payers] p on p.PayerID = TransactionPayerID                                                             
  
    WHERE 1=1 
	  AND TransactionDateOfService >= '2024-01-01'
      AND TransactionType IN ('Payment','Refund','Adjustment')
	  --AND TransactionDatasourceID = '5'
    GROUP BY TransactionParentSourceID,p.PayerID

	--- HERE MAYBE  WE ARE GOING TO NEED SOME ADJUSTMENTS AS PAYMENTS, SO WE CAN BALANCE THE TRANSACTION AND MAP THE ALLOWABLE TO THE FEE SCHEDULE
),

FeeScheduleRates AS (
    SELECT 
        FeeScheduleProcedureCode,
        FeeScheduleID,
        ISNULL(FeeScheduleModifier, '') AS FeeScheduleModifier,
        FeeScheduleFacilityRate AS FacilityRate,
        FeeScheduleNonFacilityRate AS NonFacilityRate,
        FeeScheduleFacilityRateMidLevel AS FacilityRateMidLevel,
        FeeScheduleNonFacilityRateMidLevel AS NonFacilityRateMidLevel,
        FeeScheduleYear
    FROM dim.FeeScheduleRates
 
),

Charges AS (
    SELECT c.*,
        YEAR(c.TransactionDateOfService) AS TransactionYear,
        -- Normalize modifiers
        CASE 
            WHEN c.TransactionModifier1 IN ('53','26','TC') THEN TransactionModifier1
            WHEN c.TransactionModifier2 IN ('53','26','TC') THEN TransactionModifier2
            WHEN c.TransactionModifier3 IN ('53','26','TC') THEN TransactionModifier3
            WHEN c.TransactionModifier4 IN ('53','26','TC') THEN TransactionModifier4
            ELSE ''
        END AS ModifierUsed
    FROM fact.vPBChargeCorrected c
	LEFT JOIN dim.[Practices] prac
		ON prac.PracticeID = c.TransactionPracticeID

    WHERE 1=1
      AND c.TransactionCPTCode IS NOT NULL
      AND c.TransactionDateOfService >= '2024-01-01'
	  --AND c.TransactionDatasourceID = '5'
	  AND c.TransactionCPTCode not in ('BIOTE','NOSHOW')
	  AND prac.PracticeCompany = 'TPG'

)

SELECT
	c.TransactionSourceID,
	c.PatientMRN,
	c.TransactionDateOfService,
	c.TransactionParentSourceID,
	c.TransactionID,
	c.TransactionDateOfPosting,
	c.TransactionDateOfForecastCollection,
	c.TransactionPracticeID,
    c.TransactionBillingProviderID,
    p.PayerID,    
    c.FeeScheduleName,
	f.FeeScheduleRateMultiplier,
    c.TransactionCPTCode,
	c.TransactionCPTDescription,
    c.TransactionModifier1,
    c.TransactionModifier2,
    c.TransactionModifier3,
    c.TransactionModifier4,
    c.MidlevelDiscount,
    c.MultProcModifier,
    c.ModifierDiscount,
	c.TransactionUnits,
	c.UnmodifiedFeeSchedule,
    c.TransactionPlaceOfServiceCode,
    c.TransactionAmount,
    c.TransactionAmount + ISNULL(p.TotalAdjustments, 0) AS SumAllowable,
	c.CalculatedFeeSchedule,
    p.TotalAdjustments,
    p.TotalPayments, -- Here I change the payments for payments correct so we pull the value using the adjustments
	c.TransactionAmount + ISNULL(p.TotalAdjustments, 0)+ISNULL(p.TotalPayments, 0) as TransactionBalance,
	c.CalculatedFeeSchedule - (c.TransactionAmount + ISNULL(p.TotalAdjustments, 0)) as Variance

FROM Charges c
LEFT JOIN Payments p 
  ON p.TransactionParentSourceID = c.TransactionParentSourceID
LEFT JOIN fact.vPBChargeVoids cv 
  ON c.TransactionParentSourceID=cv.TransactionID
LEFT JOIN dim.[FeeSchedules] f 
  ON f.[FeeScheduleName] = c.FeeScheduleName

 WHERE 1=1

AND c.TransactionAmount + ISNULL(p.TotalAdjustments, 0)+ISNULL(p.TotalPayments, 0) = 0
--AND c.TransactionDateOfPosting BETWEEN '2025-03-03' AND '2025-03-07'
AND YEAR(c.TransactionDateOfPosting) >= 2024
AND cv.TransactionID IS NULL
AND ABS(c.TransactionAmount + ISNULL(p.TotalAdjustments, 0) - c.CalculatedFeeSchedule) > 0.02
 --AND c.TransactionAmount + ISNULL(p.TotalAdjustments, 0)+ISNULL(p.TotalPayments, 0) < 2;
AND p.TotalAdjustments is not null
AND  p.TotalAdjustments  <> 0
GO
