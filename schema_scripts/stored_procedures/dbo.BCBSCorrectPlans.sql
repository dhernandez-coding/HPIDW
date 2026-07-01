-- =============================================
-- Author:		<Author,Diego Hernandez>
-- ALTER PROCEDURE28/2025>
-- Description:	<StoreProcedure for mapping the correct BCB>

-- =============================================
--EXEC [dbo].[BCBSCorrectPlans]
CREATE   PROCEDURE [dbo].[BCBSCorrectPlans] AS
BEGIN
SET NOCOUNT ON;

TRUNCATE TABLE rpt.BCBSCorrected
  
 -- Create the temp working table

-- Cleanup previous data
IF OBJECT_ID('tempdb..#TempRateCalculation') IS NOT NULL DROP TABLE #TempRateCalculation;


CREATE TABLE #TempRateCalculation (
    TransactionBillingProviderID NVARCHAR(300),
    TransactionPracticeID NVARCHAR(300),
    TransactionSourceID NVARCHAR(100),
    PatientMRN NVARCHAR(50),
    TransactionParentSourceID NVARCHAR(100),
    TransactionID NVARCHAR(100),
    TransactionDateOfPosting DATETIME,
    TransactionDateOfService DATETIME,
    TransactionPaymentLagPost INT,
    TransactionDateOfForecastCollection DATETIME,
    FeeScheduleName NVARCHAR(100),
    TransactionCPTCode NVARCHAR(50),
    TransactionModifier1 NVARCHAR(10),
    TransactionModifier2 NVARCHAR(10),
    TransactionModifier3 NVARCHAR(10),
    TransactionModifier4 NVARCHAR(10),
    MidlevelDiscount DECIMAL(18,2),
    MultProcModifier DECIMAL(18,2),
    ModifierDiscount DECIMAL(18,2),
    TransactionPlaceOfServiceCode NVARCHAR(10),
    TransactionUnits INT,
    TransactionAmount DECIMAL(18,2),
    SumAllowable DECIMAL(18,2),
    SumAdjustments DECIMAL(18,2),
    SumPayments DECIMAL(18,2),
	TransactionBalance DECIMAL(18,2),

    BlueCrossChoiceRateCalc DECIMAL(18,2),
    BlueCrossAdvantageRateCalc DECIMAL(18,2),
    BlueCrossPreferredRateCalc DECIMAL(18,2),
    BlueCrossTraditionalRateCalc DECIMAL(18,2),

    BlueChoiceFacilityRate DECIMAL(18,2),
    BlueChoiceNoFacilityRate DECIMAL(18,2),
    BlueChoiceFacilityRateMidLevel DECIMAL(18,2),
    BlueChoiceNonFacilityRateMidLevel DECIMAL(18,2),

    BlueAdvantageFacilityRate DECIMAL(18,2),
    BlueAdvantageNoFacilityRate DECIMAL(18,2),
    BlueAdvantageFacilityRateMidLevel DECIMAL(18,2),
    BlueAdvantageNonFacilityRateMidLevel DECIMAL(18,2),

    BluePreferredFacilityRate DECIMAL(18,2),
    BluePreferredNoFacilityRate DECIMAL(18,2),
    BluePreferredFacilityRateMidLevel DECIMAL(18,2),
    BluePreferredNonFacilityRateMidLevel DECIMAL(18,2),

    BlueTraditionalFacilityRate DECIMAL(18,2),
    BlueTraditionalNoFacilityRate DECIMAL(18,2),
    BlueTraditionalFacilityRateMidLevel DECIMAL(18,2),
    BlueTraditionalNonFacilityRateMidLevel DECIMAL(18,2),
	CorrectPlan NVARCHAR(100),
	Error NVARCHAR(100)
);


;WITH Payments AS (
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
    END) AS TotalPaymentsCorrect

    FROM fact.vPBPaymentsandAdjustments
	  LEFT JOIN [dim].[Payers] p on p.PayerID = TransactionPayerID                                                             
  
    WHERE 1=1 
	  AND TransactionDateOfService >= '2024-01-01'
      AND TransactionType IN ('Payment','Refund','Adjustment')
	  AND p.PayerGroupID = '0~2'
	  --AND TransactionDatasourceID = '5'
    GROUP BY TransactionParentSourceID

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
    WHERE FeeScheduleID IN (
        '0~BlueCrossChoice', 
        '0~BlueCrossAdvantage', 
        '0~BlueCrossPreferred', 
        '0~BlueCrossTraditional'
    )
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
    FROM fact.vPBCharges c
	LEFT JOIN dim.[vPractices] prac
		ON prac.PracticeID = c.TransactionPracticeID

    WHERE c.FeeScheduleName IN ('BlueTraditional','BlueAdvantage','BlueChoice','BluePreferred')
      AND c.TransactionCPTCode IS NOT NULL
      AND c.TransactionDateOfService >= '2024-01-01'
	  --AND c.TransactionDatasourceID = '5'
	  AND c.TransactionCPTCode not in ('BIOTE','NOSHOW')
	  AND prac.PracticeCompany = 'TPG'

)
INSERT INTO #TempRateCalculation
SELECT
    c.TransactionBillingProviderID,
    c.TransactionPracticeID,
    c.TransactionSourceID,
    c.PatientMRN,
    c.TransactionParentSourceID,
    c.TransactionID,
    c.TransactionDateOfPosting,
    c.TransactionDateOfService,
    c.TransactionPaymentLagPost,
    c.TransactionDateOfForecastCollection,
    c.FeeScheduleName,
    c.TransactionCPTCode,
    c.TransactionModifier1,
    c.TransactionModifier2,
    c.TransactionModifier3,
    c.TransactionModifier4,
    c.MidlevelDiscount,
    c.MultProcModifier,
    c.ModifierDiscount,
    c.TransactionPlaceOfServiceCode,
    c.TransactionUnits,	
    c.TransactionAmount,
    c.TransactionAmount + ISNULL(p.TotalAdjustmentsCorrect, 0) AS SumAllowable,
    p.TotalAdjustments,
    p.TotalPaymentsCorrect, -- Here I change the payments for payments correct so we pull the value using the adjustments
	c.TransactionAmount + ISNULL(p.TotalAdjustments, 0)+ISNULL(p.TotalPayments, 0) as TransactionBalance,

    -- BlueCrossChoice
c.TransactionUnits * ISNULL(CONVERT(DECIMAL(18,2), c.MultProcModifier), 1) * ISNULL(c.ModifierDiscount, 1.0) *
    CASE 
        WHEN c.TransactionPlaceOfServiceCode IN ('21','22') AND c.MidlevelDiscount = 1 THEN f_choice.FacilityRate
        WHEN c.TransactionPlaceOfServiceCode IN ('21','22') AND c.MidlevelDiscount = 0.85   THEN ISNULL(f_choice.FacilityRateMidLevel, f_choice.FacilityRate)
        WHEN c.TransactionPlaceOfServiceCode NOT IN ('21','22') AND c.MidlevelDiscount = 0.85   THEN ISNULL(f_choice.NonFacilityRateMidLevel, f_choice.NonFacilityRate)
        ELSE f_choice.NonFacilityRate    END AS BlueCrossChoiceRateCalc,

-- BlueCrossAdvantage
c.TransactionUnits * ISNULL(CONVERT(DECIMAL(18,2), c.MultProcModifier), 1) * ISNULL(c.ModifierDiscount, 1.0) *
    CASE 
        WHEN c.TransactionPlaceOfServiceCode IN ('21','22') AND c.MidlevelDiscount = 1 THEN f_adv.FacilityRate
        WHEN c.TransactionPlaceOfServiceCode IN ('21','22') AND c.MidlevelDiscount = 0.85   THEN ISNULL(f_adv.FacilityRateMidLevel, f_adv.FacilityRate)
        WHEN c.TransactionPlaceOfServiceCode NOT IN ('21','22') AND c.MidlevelDiscount = 0.85   THEN ISNULL(f_adv.NonFacilityRateMidLevel, f_adv.NonFacilityRate)
        ELSE f_adv.NonFacilityRate    END AS BlueCrossAdvantageRateCalc,

-- BlueCrossPreferred
c.TransactionUnits * ISNULL(CONVERT(DECIMAL(18,2), c.MultProcModifier), 1) * ISNULL(c.ModifierDiscount, 1.0) *
    CASE 
        WHEN c.TransactionPlaceOfServiceCode IN ('21','22') AND c.MidlevelDiscount = 1 THEN f_pref.FacilityRate
        WHEN c.TransactionPlaceOfServiceCode IN ('21','22') AND c.MidlevelDiscount = 0.85   THEN ISNULL(f_pref.FacilityRateMidLevel, f_pref.FacilityRate)
        WHEN c.TransactionPlaceOfServiceCode NOT IN ('21','22') AND c.MidlevelDiscount = 0.85   THEN ISNULL(f_pref.NonFacilityRateMidLevel, f_pref.NonFacilityRate)
        ELSE f_pref.NonFacilityRate    END AS BlueCrossPreferredRateCalc,

-- BlueCrossTraditional
c.TransactionUnits * ISNULL(CONVERT(DECIMAL(18,2), c.MultProcModifier), 1) * ISNULL(c.ModifierDiscount, 1.0) *
    CASE 
        WHEN c.TransactionPlaceOfServiceCode IN ('21','22') AND c.MidlevelDiscount = 1 THEN f_trad.FacilityRate
        WHEN c.TransactionPlaceOfServiceCode IN ('21','22') AND c.MidlevelDiscount = 0.85   THEN ISNULL(f_trad.FacilityRateMidLevel, f_trad.FacilityRate)
        WHEN c.TransactionPlaceOfServiceCode NOT IN ('21','22') AND c.MidlevelDiscount = 0.85   THEN ISNULL(f_trad.NonFacilityRateMidLevel, f_trad.NonFacilityRate)
        ELSE f_trad.NonFacilityRate    END AS BlueCrossTraditionalRateCalc,

    -- Raw Rates for reference
		f_choice.FacilityRate as BlueChoiceFacilityRate,
		f_choice.NonFacilityRate as BlueChoiceNoFacilityRate,
		f_choice.FacilityRateMidLevel as BlueChoiceFacilityRateMidLevel,
		f_choice.NonFacilityRateMidLevel as BlueChoiceNonFacilityRateMidLevel,
        f_adv.FacilityRate as BlueAdvantageFacilityRate, 
		f_adv.NonFacilityRate as BlueAdvantageNoFacilityRate,
		f_adv.FacilityRateMidLevel as BlueAdvantageFacilityRateMidLevel,
		f_adv.NonFacilityRateMidLevel as BlueAdvantageNonFacilityRateMidLevel,
        f_pref.FacilityRate as BluePreferredFacilityRate, 
		f_pref.NonFacilityRate as BluePreferredNoFacilityRate,
		f_pref.FacilityRateMidLevel as BluePreferredFacilityRateMidLevel,
		f_pref.NonFacilityRateMidLevel as BluePreferredNonFacilityRateMidLevel,
        f_trad.FacilityRate as BlueTraditionalFacilityRate, 
		f_trad.NonFacilityRate as BlueTraditionalNoFacilityRate,
		f_trad.FacilityRateMidLevel as BlueTraditionalFacilityRateMidLevel,
		f_trad.NonFacilityRateMidLevel as BlueTraditionalNonFacilityRateMidLevel,
		NULL as CorrectPlan,
		NULL as Error


FROM Charges c
LEFT JOIN Payments p 
  ON p.TransactionParentSourceID = c.TransactionParentSourceID

LEFT JOIN FeeScheduleRates f_choice 
    ON f_choice.FeeScheduleProcedureCode = c.TransactionCPTCode
   AND f_choice.FeeScheduleID = '0~BlueCrossChoice'
   AND f_choice.FeeScheduleYear = c.TransactionYear
   AND f_choice.FeeScheduleModifier = c.ModifierUsed

LEFT JOIN FeeScheduleRates f_adv 
    ON f_adv.FeeScheduleProcedureCode = c.TransactionCPTCode
   AND f_adv.FeeScheduleID = '0~BlueCrossAdvantage'
   AND f_adv.FeeScheduleYear = c.TransactionYear
   AND f_adv.FeeScheduleModifier = c.ModifierUsed

LEFT JOIN FeeScheduleRates f_pref 
    ON f_pref.FeeScheduleProcedureCode = c.TransactionCPTCode
   AND f_pref.FeeScheduleID = '0~BlueCrossPreferred'
   AND f_pref.FeeScheduleYear = c.TransactionYear
   AND f_pref.FeeScheduleModifier = c.ModifierUsed

LEFT JOIN FeeScheduleRates f_trad 
    ON f_trad.FeeScheduleProcedureCode = c.TransactionCPTCode
   AND f_trad.FeeScheduleID = '0~BlueCrossTraditional'
   AND f_trad.FeeScheduleYear = c.TransactionYear
   AND f_trad.FeeScheduleModifier = c.ModifierUsed

 WHERE 1=1
 AND c.FeeScheduleName IN ('BlueTraditional','BlueAdvantage','BlueChoice','BluePreferred')
 AND YEAR(c.TransactionDateOfService) >= 2024;
 --AND c.TransactionParentSourceID not in ( select TransactionID FROM [HPIDW].[fact].[vPBChargeVoids])


UPDATE t
SET 
    t.CorrectPlan = 
        CASE 
            WHEN SumAllowable = BlueCrossChoiceRateCalc 
              AND SumAllowable = BlueCrossAdvantageRateCalc 
              AND SumAllowable = BlueCrossPreferredRateCalc 
              AND SumAllowable = BlueCrossTraditionalRateCalc THEN FeeScheduleName
            WHEN BlueChoiceFacilityRate IS NULL THEN 'No FeeSchedule'
            WHEN SumAllowable BETWEEN BlueCrossChoiceRateCalc - 0.1 AND BlueCrossChoiceRateCalc + 0.1 THEN 'BlueChoice'
            WHEN SumAllowable BETWEEN BlueCrossAdvantageRateCalc - 0.1 AND BlueCrossAdvantageRateCalc + 0.1 THEN 'BlueAdvantage'
            WHEN SumAllowable BETWEEN BlueCrossPreferredRateCalc - 0.1 AND BlueCrossPreferredRateCalc + 0.1 THEN 'BluePreferred'
            WHEN SumAllowable BETWEEN BlueCrossTraditionalRateCalc - 0.1 AND BlueCrossTraditionalRateCalc + 0.1 THEN 'BlueTraditional'
            ELSE 'Other Problem' 
        END
FROM #TempRateCalculation t;

UPDATE t
SET 
    t.Error = 
        CASE
			WHEN CorrectPlan <> 'Other Problem' THEN 'CorrectPlan'
            WHEN SumAllowable BETWEEN BlueChoiceFacilityRateMidLevel - 0.1 AND BlueChoiceFacilityRateMidLevel + 0.1 THEN 'BlueChoiceFacilityRateMidLevel'
            WHEN SumAllowable BETWEEN BlueChoiceNonFacilityRateMidLevel - 0.1 AND BlueChoiceNonFacilityRateMidLevel + 0.1 THEN 'BlueChoiceNonFacilityRateMidLevel'
            WHEN SumAllowable BETWEEN BluePreferredFacilityRateMidLevel - 0.1 AND BluePreferredFacilityRateMidLevel + 0.1 THEN 'BluePreferredFacilityRateMidLevel'
            WHEN SumAllowable BETWEEN BluePreferredNonFacilityRateMidLevel - 0.1 AND BluePreferredNonFacilityRateMidLevel + 0.1 THEN 'BluePreferredNonFacilityRateMidLevel'
			WHEN SumAllowable BETWEEN BlueAdvantageFacilityRateMidLevel - 0.1 AND BlueAdvantageFacilityRateMidLevel + 0.1 THEN 'BlueAdvantageFacilityRateMidLevel'
			WHEN SumAllowable BETWEEN BlueAdvantageNonFacilityRateMidLevel - 0.1 AND BlueAdvantageNonFacilityRateMidLevel + 0.1 THEN 'BlueAdvantageNonFacilityRateMidLevel'
			WHEN SumAllowable BETWEEN BlueTraditionalFacilityRateMidLevel - 0.1 AND BlueTraditionalFacilityRateMidLevel + 0.1 THEN 'BlueTraditionalFacilityRateMidLevel'
			WHEN SumAllowable BETWEEN BlueTraditionalNonFacilityRateMidLevel - 0.1 AND BlueTraditionalNonFacilityRateMidLevel + 0.1 THEN 'BlueTraditionalNonFacilityRateMidLevel'

            ELSE 'Other Problem' 
        END
FROM #TempRateCalculation t;

    INSERT INTO rpt.BCBSCorrected
    SELECT * FROM #TempRateCalculation t 
	WHERE 1=1
	AND t.TransactionBalance = 0;
END;
--------------------------------OLD QUERY BEST PERFORMANCE ---------------------------------------------------------------------------------------------------/
----    -- Prevent extra result sets from interfering
--    SET NOCOUNT ON;

  

---- Drop temp table if it already exists
--IF OBJECT_ID('tempdb..#TempTable') IS NOT NULL
--    DROP TABLE #TempTable;
--TRUNCATE TABLE rpt.BCBSCorrected
---- Create the temp table
--CREATE TABLE #TempTable (

--	TransactionBillingProviderID NVARCHAR(300),
--	TransactionPracticeID NVARCHAR(300),
--    TransactionSourceID NVARCHAR(100),
--    PatientMRN NVARCHAR(50),
--    TransactionParentSourceID NVARCHAR(100),
--    TransactionID NVARCHAR(100),
--    TransactionDateOfPosting DATETIME,
--    TransactionDateOfService DATETIME,
--    TransactionPaymentLagPost INT,
--    TransactionDateOfForecastCollection DATETIME,
--    FeeScheduleName NVARCHAR(100),
--    TransactionCPTCode NVARCHAR(50),
--    TransactionModifier1 NVARCHAR(10),
--    TransactionModifier2 NVARCHAR(10),
--    TransactionModifier3 NVARCHAR(10),
--    TransactionModifier4 NVARCHAR(10),
--    MidlevelDiscount DECIMAL(18,2),
--    MultProcModifier DECIMAL(18,2),
--    ModifierDiscount DECIMAL(18,2),
--    TransactionPlaceOfServiceCode NVARCHAR(10),
--    TransactionUnits INT,
--    SumAllowable DECIMAL(18,2),
--    SumAdjustments DECIMAL(18,2),
--    SumPayments DECIMAL(18,2),
--    BlueCrossChoiceRateCalc DECIMAL(18,2),
--    BlueCrossAdvantageRateCalc DECIMAL(18,2),
--    BlueCrossPreferredRateCalc DECIMAL(18,2),
--    BlueCrossTraditionalRateCalc DECIMAL(18,2),
--    BlueCrossChoiceFacilityRate DECIMAL(18,2),
--    BlueCrossChoiceNonFacilityRate DECIMAL(18,2),
--    BlueCrossAdvantageFacilityRate DECIMAL(18,2),
--    BlueCrossAdvantageNonFacilityRate DECIMAL(18,2),
--    BlueCrossPreferredFacilityRate DECIMAL(18,2),
--    BlueCrossPreferredNonFacilityRate DECIMAL(18,2),
--    BlueCrossTraditionalFacilityRate DECIMAL(18,2),
--    BlueCrossTraditionalNonFacilityRate DECIMAL(18,2)
--);

---- Insert data into the temp table
--WITH Payments AS (
--    SELECT 
--        TransactionParentSourceID,
--        SUM(CASE WHEN TransactionType IN ('Adjustment') THEN TransactionAmount ELSE 0 END) AS TotalAdjustments,
--        SUM(CASE WHEN TransactionType IN ('Payment','Refund') THEN TransactionAmount ELSE 0 END) AS TotalPayments,
--		SUM(CASE 
--				WHEN TransactionType IN ('Adjustment') 
--				AND TransactionDescription not like ('%Admin%') 
--				AND TransactionDescription NOT LIKE '%SEQUESTRATION WRITE-OFF%'  --I added this 3/13, need to check with chris
--				THEN TransactionAmount ELSE 0 END) AS TotalAdjustmentsCorrect
--    FROM fact.vPBPaymentsandAdjustments pa
--    WHERE TransactionPayerPlanID IS NOT NULL
--      AND TransactionType IN ('Payment','Refund','Adjustment')
--    GROUP BY TransactionParentSourceID
--),

---- Get distinct FeeScheduleFacilityRate for each CPT Code, FeeScheduleID, and FeeScheduleModifier
--FeeScheduleRates AS (
--    SELECT FeeScheduleProcedureCode,
--           FeeScheduleID,
--           FeeScheduleModifier,
--           FacilityRate,
--           NonFacilityRate
--    FROM (
--        SELECT 
--            FeeScheduleProcedureCode,
--            FeeScheduleID,
--            NULLIF(FeeScheduleModifier, '') AS FeeScheduleModifier, -- Convert empty strings to NULL
--            FeeScheduleFacilityRate AS FacilityRate, 
--            FeeScheduleNonFacilityRate AS NonFacilityRate,
--            ROW_NUMBER() OVER (
--                PARTITION BY FeeScheduleProcedureCode, FeeScheduleID
--                ORDER BY 
--                    CASE 
--                        WHEN FeeScheduleModifier = '26' THEN 1
--                        WHEN FeeScheduleModifier = 'TC' THEN 2
--                        WHEN FeeScheduleModifier IS NULL THEN 3
--                        ELSE 4  -- Any other unexpected modifier (should not happen)
--                    END
--            ) AS ModifierRank
--        FROM dim.FeeScheduleRates
--        WHERE FeeScheduleID IN ('0~BlueCrossChoice', '0~BlueCrossAdvantage', '0~BlueCrossPreferred', '0~BlueCrossTraditional')
--    ) ranked
--    WHERE ModifierRank = 1  -- Keep only the highest-priority modifier per CPT
--)

--INSERT INTO #TempTable
--SELECT
--	c.TransactionBillingProviderID,
--	c.TransactionPracticeID,
--    c.TransactionSourceID,
--    c.PatientMRN,
--    c.TransactionParentSourceID,
--    c.TransactionID,
--    c.TransactionDateOfPosting,
--    c.TransactionDateOfService,
--    c.TransactionPaymentLagPost,
--    c.TransactionDateOfForecastCollection,
--    c.FeeScheduleName,
--    c.TransactionCPTCode,
--    c.TransactionModifier1,
--    c.TransactionModifier2,
--    c.TransactionModifier3,
--    c.TransactionModifier4,
--    c.MidlevelDiscount,
--    c.MultProcModifier,
--    c.ModifierDiscount,
--    c.TransactionPlaceOfServiceCode,
--    c.TransactionUnits,
--    c.TransactionAmount + p.TotalAdjustmentsCorrect AS SumAllowable,
--    p.TotalAdjustments AS SumAdjustments,
--    p.TotalPayments AS SumPayments,

--    -- Facility Rate for Each Fee Schedule Calculation
--    c.TransactionUnits * (ISNULL(CONVERT(DECIMAL(18,2),c.MultProcModifier),1)
--                            * ISNULL(c.ModifierDiscount,1.0)
--                            * CASE WHEN c.TransactionPlaceOfServiceCode IN ('21','22') THEN f_choice.FacilityRate ELSE f_choice.NonFacilityRate END
--                            ) AS BlueCrossChoiceRateCalc,
--    c.TransactionUnits * (ISNULL(CONVERT(DECIMAL(18,2),c.MultProcModifier),1)
--                            * ISNULL(c.ModifierDiscount,1.0)
--                            * CASE WHEN c.TransactionPlaceOfServiceCode IN ('21','22') THEN f_adv.FacilityRate ELSE f_adv.NonFacilityRate END
--                            ) AS BlueCrossAdvantageRateCalc,
--    c.TransactionUnits * (ISNULL(CONVERT(DECIMAL(18,2),c.MultProcModifier),1)
--                            * ISNULL(c.ModifierDiscount,1.0)
--                            * CASE WHEN c.TransactionPlaceOfServiceCode IN ('21','22') THEN f_pref.FacilityRate ELSE f_pref.NonFacilityRate END
--                            ) AS BlueCrossPreferredRateCalc,
--    c.TransactionUnits * (ISNULL(CONVERT(DECIMAL(18,2),c.MultProcModifier),1)
--                            * ISNULL(c.ModifierDiscount,1.0)
--                            * CASE WHEN c.TransactionPlaceOfServiceCode IN ('21','22') THEN f_trad.FacilityRate ELSE f_trad.NonFacilityRate END
--                            ) AS BlueCrossTraditionalRateCalc,

--    -- Raw Facility and Non-Facility Rates
--    f_choice.FacilityRate AS BlueCrossChoiceFacilityRate,
--    f_choice.NonFacilityRate AS BlueCrossChoiceNonFacilityRate,
--    f_adv.FacilityRate AS BlueCrossAdvantageFacilityRate,
--    f_adv.NonFacilityRate AS BlueCrossAdvantageNonFacilityRate,
--    f_pref.FacilityRate AS BlueCrossPreferredFacilityRate,
--    f_pref.NonFacilityRate AS BlueCrossPreferredNonFacilityRate,
--    f_trad.FacilityRate AS BlueCrossTraditionalFacilityRate,
--    f_trad.NonFacilityRate AS BlueCrossTraditionalNonFacilityRate

--FROM fact.vPBCharges c
--LEFT JOIN Payments p 
--    ON p.TransactionParentSourceID = c.TransactionID

---- Join distinct FeeScheduleRates for each FeeScheduleID while considering modifiers
--LEFT JOIN FeeScheduleRates f_choice 
--    ON f_choice.FeeScheduleProcedureCode = c.TransactionCPTCode
--    AND f_choice.FeeScheduleID = '0~BlueCrossChoice'
--    AND (f_choice.FeeScheduleModifier IS NULL OR f_choice.FeeScheduleModifier = '' 
--         OR f_choice.FeeScheduleModifier IN (c.TransactionModifier1, c.TransactionModifier2, c.TransactionModifier3, c.TransactionModifier4))--This join create duplicates with the RC modifier see the example 1~4602083

--LEFT JOIN FeeScheduleRates f_adv 
--    ON f_adv.FeeScheduleProcedureCode = c.TransactionCPTCode
--    AND f_adv.FeeScheduleID = '0~BlueCrossAdvantage'
--    AND (f_adv.FeeScheduleModifier IS NULL OR f_adv.FeeScheduleModifier = '' 
--         OR f_adv.FeeScheduleModifier IN (c.TransactionModifier1, c.TransactionModifier2, c.TransactionModifier3, c.TransactionModifier4))

--LEFT JOIN FeeScheduleRates f_pref 
--    ON f_pref.FeeScheduleProcedureCode = c.TransactionCPTCode
--    AND f_pref.FeeScheduleID = '0~BlueCrossPreferred'
--    AND (f_pref.FeeScheduleModifier IS NULL OR f_pref.FeeScheduleModifier = '' 
--         OR f_pref.FeeScheduleModifier IN (c.TransactionModifier1, c.TransactionModifier2, c.TransactionModifier3, c.TransactionModifier4))

--LEFT JOIN FeeScheduleRates f_trad 
--    ON f_trad.FeeScheduleProcedureCode = c.TransactionCPTCode
--    AND f_trad.FeeScheduleID = '0~BlueCrossTraditional'
--    AND (f_trad.FeeScheduleModifier IS NULL OR f_trad.FeeScheduleModifier = '' 
--         OR f_trad.FeeScheduleModifier IN (c.TransactionModifier1, c.TransactionModifier2, c.TransactionModifier3, c.TransactionModifier4))

--WHERE 1=1 
--AND c.FeeScheduleName IN ('BlueTraditional','BlueAdvantage','BlueChoice','BluePreferred')
--  AND c.TransactionCPTCode IS NOT NULL
--  AND YEAR(c.TransactionDateOfService) = 2024;
--  INSERT INTO rpt.BCBSCorrected
--  SELECT * FROM
--	(SELECT
--	p.ProviderFullName
--	,ps.PracticeName,
--	sub.* FROM(
--	SELECT *,
--	CASE 
--    WHEN SumAllowable = BlueCrossChoiceRateCalc 
--         AND SumAllowable = BlueCrossAdvantageRateCalc 
--         AND SumAllowable = BlueCrossPreferredRateCalc 
--         AND SumAllowable = BlueCrossTraditionalRateCalc 
--    THEN FeeScheduleName 
--    ELSE 
--        CASE 
--            WHEN SumAllowable BETWEEN BlueCrossChoiceRateCalc - 0.1 AND BlueCrossChoiceRateCalc + 0.1 THEN 'BlueChoice'
--            WHEN SumAllowable BETWEEN BlueCrossAdvantageRateCalc - 0.1 AND BlueCrossAdvantageRateCalc + 0.1 THEN 'BlueAdvantage'
--            WHEN SumAllowable BETWEEN BlueCrossPreferredRateCalc - 0.1 AND BlueCrossPreferredRateCalc + 0.1 THEN 'BluePreferred'
--            WHEN SumAllowable BETWEEN BlueCrossTraditionalRateCalc - 0.1 AND BlueCrossTraditionalRateCalc + 0.1 THEN 'BlueTraditional'
--            WHEN BlueCrossChoiceFacilityRate IS NULL THEN 'No FeeSchedule'
--            ELSE 'Other Problem' 
--        END 
--END AS CorrectPlan,
--		CASE 
--    WHEN SumAllowable = BlueCrossChoiceNonFacilityRate 
--         AND SumAllowable = BlueCrossAdvantageNonFacilityRate 
--         AND SumAllowable = BlueCrossPreferredNonFacilityRate 
--         AND SumAllowable = BlueCrossTraditionalNonFacilityRate 
--    THEN FeeScheduleName 
--    ELSE 
--        CASE 
--            WHEN SumAllowable BETWEEN BlueCrossChoiceNonFacilityRate - 0.1 AND BlueCrossChoiceNonFacilityRate + 0.1  THEN 'BlueChoice'
--			WHEN SumAllowable BETWEEN BlueCrossAdvantageNonFacilityRate - 0.1  AND BlueCrossAdvantageNonFacilityRate + 0.1  THEN 'BlueAdvantage'
--			WHEN SumAllowable BETWEEN BlueCrossPreferredNonFacilityRate - 0.1  AND BlueCrossPreferredNonFacilityRate + 0.1  THEN 'BluePreferred'
--			WHEN SumAllowable BETWEEN BlueCrossTraditionalNonFacilityRate - 0.1  AND BlueCrossTraditionalNonFacilityRate + 0.1  THEN 'BlueTraditional'
--			WHEN BlueCrossChoiceFacilityRate IS NULL THEN 'No FeeSchedule'
--			ELSE 'Other Problem'
 
--        END 
--END AS CorrectPlanNonFacility,
--NULL as SumCharge
	
--	from #TempTable) sub
--	left join dim.vProviders p on sub.TransactionBillingProviderID = p.ProviderID
--	left join dim.vPractices ps on sub.TransactionPracticeID = ps.PracticeID

--	WHERE 1=1

--	AND sub.CorrectPlan NOT IN ('No FeeSchedule','Other Problem')
--	--AND sub.CorrectPlan NOT IN ('No FeeSchedule')
--	AND sub.FeeScheduleName <> sub.CorrectPlan) subquery

 

--    -- Drop the temp table at the end
--    DROP TABLE #TempTable;

--END;



--------------------------------OLD QUERY BEST PERFORMANCE ---------------------------------------------------------------------------------------------------/
GO
