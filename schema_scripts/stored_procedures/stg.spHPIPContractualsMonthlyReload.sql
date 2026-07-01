CREATE PROCEDURE [stg].[spHPIPContractualsMonthlyReload]
AS
BEGIN

   IF OBJECT_ID(N'tempdb..#ARSnaphot') IS NOT NULL
    BEGIN
        DROP TABLE #ARSnaphot3
    END

    IF OBJECT_ID(N'tempdb..#ReimbRate') IS NOT NULL
    BEGIN
        DROP TABLE #ReimbRate
    END
	   IF OBJECT_ID(N'tempdb..#ARSnaphot1') IS NOT NULL
    BEGIN
        DROP TABLE #ARSnapshot4
    END

    IF OBJECT_ID(N'tempdb..#ReimbRate1') IS NOT NULL
    BEGIN
        DROP TABLE #ReimbRate1
    END

    -- Step 1: Creating the temporary table #ARSnaphot with summarized AR data
    SELECT 
        CASE 
            WHEN d.DepartmentID IN ('5~43001006001','5~43001007001','5~43001008001','5~43002001001') 
            THEN d.DepartmentName 
            ELSE p.ProviderFullName 
        END + '-' + 
        CASE
			WHEN pp.PayerCategoryName = 'Liability/Third Party/Accident'
			THEN 'Liability'	 
            WHEN pp.PayerGroupName IN ('Medicaid', 'Medicare') 
            THEN 'Government Payers' 
            ELSE pp.PayerGroupName 
        END AS ARSnapshotID,
        arh.ARHistoryDate,
        arh.TransactionDataSourceID,
        d.DepartmentName,
        CASE
		    WHEN pp.PayerCategoryName = 'Liability/Third Party/Accident'
			THEN 'Liability'
            WHEN pp.PayerGroupName IN ('Medicaid', 'Medicare') 
            THEN 'Government Payers' 
            ELSE pp.PayerGroupName 
        END AS ARFinancialClass,
        CASE 
            WHEN d.DepartmentID IN ('5~43001006001','5~43001007001','5~43001008001','5~43002001001') 
            THEN d.DepartmentName 
            ELSE p.ProviderFullName 
        END AS ProviderName,
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge BETWEEN 0 AND 30 
            THEN arh.TransactionARAmountActive
            ELSE 0 
        END) AS "0to30",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge BETWEEN 31 AND 120 
            THEN arh.TransactionARAmountActive
            ELSE 0 
        END) AS "31to120",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge BETWEEN 121 AND 150 
            THEN arh.TransactionARAmountActive
            ELSE 0 
        END) AS "121to150",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge > 150 
            THEN arh.TransactionARAmountActive
        END) AS "150+",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge BETWEEN 0 AND 150 
            THEN arh.TransactionARAmountActive
            ELSE 0 
        END) AS "Under150",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge BETWEEN 0 AND 30 
            THEN arh.TransactionARAmountBadDebt
            ELSE 0 
        END) AS "BD0to30",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge BETWEEN 31 AND 120 
            THEN arh.TransactionARAmountBadDebt
            ELSE 0 
        END) AS "BD31to120",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge BETWEEN 121 AND 150 
            THEN arh.TransactionARAmountBadDebt
            ELSE 0 
        END) AS "BD121to150",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge > 150 
            THEN arh.TransactionARAmountBadDebt
        END) AS "BD150+",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge BETWEEN 0 AND 150 
            THEN arh.TransactionARAmountBadDebt
            ELSE 0 
        END) AS "BDUnder150",
        CASE 
            WHEN SUM(arh.TransactionARAmountAll) < 0 
            THEN 1 
            ELSE 0 
        END AS IsARCredit,
        'Snapshot' AS PeriodCategory
    INTO #ARSnaphot3 --APM
    FROM [HPIDW].[rpt].[ARHistoryPB] arh
    LEFT JOIN [HPIDW].dim.vDepartments d ON d.DepartmentID = arh.TransactionDepartmentID
    LEFT JOIN HPIDW.dim.vProviders p ON p.ProviderID = arh.TransactionBillingProviderID
    LEFT JOIN HPIDW.dim.vPayers pp ON pp.PayerID = arh.CurrentPayerID
    WHERE ARHistoryDate >= DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, GETDATE())), MONTH(DATEADD(MONTH, -1, GETDATE())), 1)
        AND ARHistoryDate <= EOMONTH(DATEADD(MONTH, -1, GETDATE()))
		AND arh.[TransactionDataSourceID] = 1 --APM
        AND (d.DepartmentName LIKE '%HPI Physicians, LLC%' OR d.DepartmentID = '1~24' OR d.DepartmentName = 'HPI BILLING OFFICE')
    GROUP BY 
        CASE 
            WHEN d.DepartmentID IN ('5~43001006001','5~43001007001','5~43001008001','5~43002001001') 
            THEN d.DepartmentName 
            ELSE p.ProviderFullName 
        END,
        CASE
			WHEN pp.PayerCategoryName = 'Liability/Third Party/Accident'
			THEN 'Liability' 
            WHEN pp.PayerGroupName IN ('Medicaid', 'Medicare') 
            THEN 'Government Payers' 
            ELSE pp.PayerGroupName 
        END,
        arh.ARHistoryDate,
        arh.TransactionDataSourceID,
        d.DepartmentName,
        d.DepartmentID,
		pp.PayerCategoryName,
        pp.PayerGroupName,
        p.ProviderFullName,
        arh.TransactionServiceDateAge;

    -- Step 2: Creating the temporary table #ReimbRate
    SELECT
        CASE 
            WHEN d.DepartmentID IN ('5~43001006001','5~43001007001','5~43001008001','5~43002001001') 
            THEN d.DepartmentName 
            ELSE p.ProviderFullName 
        END + '-' + 
        CASE
			WHEN pp.PayerCategoryName = 'Liability/Third Party/Accident'
			THEN 'Liability' 
            WHEN pp.PayerGroupName IN ('Medicaid', 'Medicare') 
            THEN 'Government Payers' 
            ELSE pp.PayerGroupName 
        END AS ReimbRateID, 
        CASE 
            WHEN d.DepartmentID IN ('5~43001006001','5~43001007001','5~43001008001','5~43002001001') 
            THEN d.DepartmentName 
            ELSE p.ProviderFullName 
        END AS ProviderName,
        CASE
			WHEN pp.PayerCategoryName = 'Liability/Third Party/Accident'
			THEN 'Liability' 
            WHEN pp.PayerGroupName IN ('Medicaid', 'Medicare') 
            THEN 'Government Payers' 
            ELSE pp.PayerGroupName 
        END AS ARFinancialClass,
        SUM(CASE WHEN t.TransactionType = 'Charge' THEN t.TransactionAmount ELSE 0 END) AS Charges,
        SUM(CASE WHEN t.TransactionType = 'Payment' THEN t.TransactionAmount ELSE 0 END) AS Payments,
        CASE 
            WHEN DATEFROMPARTS(LEFT(t.TransactionReportPeriodDate, 4), RIGHT(t.TransactionReportPeriodDate, 2), 1) 
            BETWEEN DATEADD(MONTH, -9, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) 
            AND DATEADD(MONTH, -4, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) 
            THEN 'Y' 
            ELSE 'N' 
        END AS ARTrailing6Months
    INTO #ReimbRate --APM
    FROM HPIDW.fact.vTransactionsPB t
    LEFT JOIN HPIDW.dim.vDepartments d ON d.DepartmentID = t.TransactionDepartmentID
    LEFT JOIN HPIDW.dim.vProviders p ON p.ProviderID = t.TransactionBillingProviderID
    LEFT JOIN HPIDW.dim.vPayers pp ON pp.PayerID = t.TransactionPayerID
    LEFT JOIN HPIDW.dim.vPractices pr ON pr.PracticeID = t.TransactionPracticeID
    WHERE d.DepartmentName LIKE '%HPI Physicians, LLC%' OR d.DepartmentID = '1~24' OR d.DepartmentName = 'HPI BILLING OFFICE'
		AND t.TransactionDataSource = 'APM' -- APM
    GROUP BY
        p.ProviderFullName,
		pp.PayerCategoryName,
        pp.PayerGroupName,
        d.DepartmentID,
        d.DepartmentName,
        t.TransactionReportPeriodDate;

	SELECT 
        CASE 
            WHEN d.DepartmentID IN ('5~43001006001','5~43001007001','5~43001008001','5~43002001001') 
            THEN d.DepartmentName 
            ELSE p.ProviderFullName 
        END + '-' + 
        CASE
			WHEN pp.PayerCategoryName = 'Liability/Third Party/Accident'
			THEN 'Liability'	 
            WHEN pp.PayerGroupName IN ('Medicaid', 'Medicare') 
            THEN 'Government Payers' 
            ELSE pp.PayerGroupName 
        END AS ARSnapshotID,
        arh.ARHistoryDate,
        arh.TransactionDataSourceID,
        d.DepartmentName,
        CASE
		    WHEN pp.PayerCategoryName = 'Liability/Third Party/Accident'
			THEN 'Liability'
            WHEN pp.PayerGroupName IN ('Medicaid', 'Medicare') 
            THEN 'Government Payers' 
            ELSE pp.PayerGroupName 
        END AS ARFinancialClass,
        CASE 
            WHEN d.DepartmentID IN ('5~43001006001','5~43001007001','5~43001008001','5~43002001001') 
            THEN d.DepartmentName 
            ELSE p.ProviderFullName 
        END AS ProviderName,
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge BETWEEN 0 AND 30 
            THEN arh.TransactionARAmountActive
            ELSE 0 
        END) AS "0to30",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge BETWEEN 31 AND 120 
            THEN arh.TransactionARAmountActive
            ELSE 0 
        END) AS "31to120",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge BETWEEN 121 AND 150 
            THEN arh.TransactionARAmountActive
            ELSE 0 
        END) AS "121to150",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge > 150 
            THEN arh.TransactionARAmountActive
        END) AS "150+",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge BETWEEN 0 AND 150 
            THEN arh.TransactionARAmountActive
            ELSE 0 
        END) AS "Under150",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge BETWEEN 0 AND 30 
            THEN arh.TransactionARAmountBadDebt
            ELSE 0 
        END) AS "BD0to30",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge BETWEEN 31 AND 120 
            THEN arh.TransactionARAmountBadDebt
            ELSE 0 
        END) AS "BD31to120",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge BETWEEN 121 AND 150 
            THEN arh.TransactionARAmountBadDebt
            ELSE 0 
        END) AS "BD121to150",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge > 150 
            THEN arh.TransactionARAmountBadDebt
        END) AS "BD150+",
        SUM(CASE 
            WHEN arh.TransactionServiceDateAge BETWEEN 0 AND 150 
            THEN arh.TransactionARAmountBadDebt
            ELSE 0 
        END) AS "BDUnder150",
        CASE 
            WHEN SUM(arh.TransactionARAmountAll) < 0 
            THEN 1 
            ELSE 0 
        END AS IsARCredit,
        'Snapshot' AS PeriodCategory
    INTO #ARSnapshot4 --EPIC
    FROM [HPIDW].[rpt].[ARHistoryPB] arh
    LEFT JOIN [HPIDW].dim.vDepartments d ON d.DepartmentID = arh.TransactionDepartmentID
    LEFT JOIN HPIDW.dim.vProviders p ON p.ProviderID = arh.TransactionBillingProviderID
    LEFT JOIN HPIDW.dim.vPayers pp ON pp.PayerID = arh.CurrentPayerID
    WHERE ARHistoryDate >= DATEFROMPARTS(YEAR(DATEADD(MONTH, -1, GETDATE())), MONTH(DATEADD(MONTH, -1, GETDATE())), 1)
        AND ARHistoryDate <= EOMONTH(DATEADD(MONTH, -1, GETDATE()))
		AND arh.[TransactionDataSourceID] = 5 --EPIC
        AND (d.DepartmentName LIKE '%HPIP%' OR d.DepartmentID = '1~24' OR d.DepartmentName = 'HPI BILLING OFFICE')
    GROUP BY 
        CASE 
            WHEN d.DepartmentID IN ('5~43001006001','5~43001007001','5~43001008001','5~43002001001') 
            THEN d.DepartmentName 
            ELSE p.ProviderFullName 
        END,
        CASE
			WHEN pp.PayerCategoryName = 'Liability/Third Party/Accident'
			THEN 'Liability' 
            WHEN pp.PayerGroupName IN ('Medicaid', 'Medicare') 
            THEN 'Government Payers' 
            ELSE pp.PayerGroupName 
        END,
        arh.ARHistoryDate,
        arh.TransactionDataSourceID,
        d.DepartmentName,
        d.DepartmentID,
		pp.PayerCategoryName,
        pp.PayerGroupName,
        p.ProviderFullName,
        arh.TransactionServiceDateAge;

    -- Step 2: Creating the temporary table #ReimbRate
    SELECT
        CASE 
            WHEN d.DepartmentID IN ('5~43001006001','5~43001007001','5~43001008001','5~43002001001') 
            THEN d.DepartmentName 
            ELSE p.ProviderFullName 
        END + '-' + 
        CASE
			WHEN pp.PayerCategoryName = 'Liability/Third Party/Accident'
			THEN 'Liability' 
            WHEN pp.PayerGroupName IN ('Medicaid', 'Medicare') 
            THEN 'Government Payers' 
            ELSE pp.PayerGroupName 
        END AS ReimbRateID, 
        CASE 
            WHEN d.DepartmentID IN ('5~43001006001','5~43001007001','5~43001008001','5~43002001001') 
            THEN d.DepartmentName 
            ELSE p.ProviderFullName 
        END AS ProviderName,
        CASE
			WHEN pp.PayerCategoryName = 'Liability/Third Party/Accident'
			THEN 'Liability' 
            WHEN pp.PayerGroupName IN ('Medicaid', 'Medicare') 
            THEN 'Government Payers' 
            ELSE pp.PayerGroupName 
        END AS ARFinancialClass,
        SUM(CASE WHEN t.TransactionType = 'Charge' THEN t.TransactionAmount ELSE 0 END) AS Charges,
        SUM(CASE WHEN t.TransactionType = 'Payment' THEN t.TransactionAmount ELSE 0 END) AS Payments,
        CASE 
            WHEN DATEFROMPARTS(LEFT(t.TransactionReportPeriodDate, 4), RIGHT(t.TransactionReportPeriodDate, 2), 1) 
            BETWEEN DATEADD(MONTH, -9, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) 
            AND DATEADD(MONTH, -4, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) 
            THEN 'Y' 
            ELSE 'N' 
        END AS ARTrailing6Months
    INTO #ReimbRate1 --EPIC
    FROM HPIDW.fact.vTransactionsPB t
    LEFT JOIN HPIDW.dim.vDepartments d ON d.DepartmentID = t.TransactionDepartmentID
    LEFT JOIN HPIDW.dim.vProviders p ON p.ProviderID = t.TransactionBillingProviderID
    LEFT JOIN HPIDW.dim.vPayers pp ON pp.PayerID = t.TransactionPayerID
    LEFT JOIN HPIDW.dim.vPractices pr ON pr.PracticeID = t.TransactionPracticeID
    WHERE d.DepartmentName LIKE '%HPIP%' OR d.DepartmentID = '1~24' OR d.DepartmentName = 'HPI BILLING OFFICE'
		AND t.TransactionDataSource = 'EPIC' --EPIC
    GROUP BY
        p.ProviderFullName,
		pp.PayerCategoryName,
        pp.PayerGroupName,
        d.DepartmentID,
        d.DepartmentName,
        t.TransactionReportPeriodDate;

    -- Combine Data from Temporary Tables and Calculate Final Metrics
    WITH CTE AS (
        SELECT 
            AR.ARSnapshotID,
            AR.ARFinancialClass,
            AR.ProviderName,
            SUM(AR."0to30") AS "0to30",
            SUM(AR."31to120") AS "31to120",
            SUM(AR."121to150") AS "121to150",
            SUM(AR."150+") AS "150+",
            SUM(AR."Under150") AS "Under150",
            SUM(AR."BD0to30") AS "BD0to30",
            SUM(AR."BD31to120") AS "BD31to120",
            SUM(AR."BD121to150") AS "BD121to150",
            SUM(AR."BD150+") AS "BD150+",
            SUM(AR."BDUnder150") AS "BDUnder150",
            NULL AS Charges,
            NULL AS Payments,
            NULL AS ReimbursementPct,
			--AR.TransactionDataSourceID,
            AR.ARHistoryDate
        FROM #ARSnaphot3 AR
        WHERE AR.ARHistoryDate = EOMONTH(DATEADD(MONTH, -1, GETDATE()))
        GROUP BY 
            AR.ARSnapshotID,
            AR.ARFinancialClass,
            AR.ProviderName,
			--AR.TransactionDataSourceID,
            AR.ARHistoryDate
        UNION ALL
        SELECT
            RR.ReimbRateID,
            RR.ARFinancialClass,
            RR.ProviderName,
            0 AS "0to30",
            0 AS "31to120",
            0 AS "121to150",
            0 AS "150+",
            0 AS "Under150",
            0 AS "BD0to30",
            0 AS "BD31to120",
            0 AS "BD121to150",
            0 AS "BD150+",
            0 AS "BDUnder150",
            RR.Charges,
            RR.Payments,
            CASE 
                WHEN SUM(RR.Charges) = 0 or SUM(RR.Charges) IS NULL THEN 0.40
                WHEN -(SUM(RR.Payments) / SUM(RR.Charges)) > 0.80 
                    AND RR.ProviderName IN ('HPIP CHN ANESTHESIA','HPIP CHS ANESTHESIA','HPIP NWSH ANESTHESIA') 
                THEN 0.228
                WHEN -(SUM(RR.Payments) / SUM(RR.Charges)) > 0.80 
                    AND RR.ARFinancialClass  <> 'Self-Pay' 
                THEN 0.80
                WHEN -(SUM(RR.Payments) / SUM(RR.Charges)) > 0.80 
                    AND RR.ARFinancialClass = 'Self-Pay' 
                THEN 0.40
                ELSE -(SUM(RR.Payments) / SUM(RR.Charges))
            END as ReimbursementPct,
			--'1' AS TransactionDataSourceID,
            NULL AS ARHistoryDate
        FROM #ReimbRate RR
        WHERE RR.ARTrailing6Months = 'Y'
		GROUP BY
			RR.ReimbRateID,
            RR.ARFinancialClass,
            RR.ProviderName,
			RR.Charges,
            RR.Payments
		UNION ALL
		SELECT 
            AR.ARSnapshotID,
            AR.ARFinancialClass,
            AR.ProviderName,
            SUM(AR."0to30") AS "0to30",
            SUM(AR."31to120") AS "31to120",
            SUM(AR."121to150") AS "121to150",
            SUM(AR."150+") AS "150+",
            SUM(AR."Under150") AS "Under150",
            SUM(AR."BD0to30") AS "BD0to30",
            SUM(AR."BD31to120") AS "BD31to120",
            SUM(AR."BD121to150") AS "BD121to150",
            SUM(AR."BD150+") AS "BD150+",
            SUM(AR."BDUnder150") AS "BDUnder150",
            NULL AS Charges,
            NULL AS Payments,
            NULL AS ReimbursementPct,
			--AR.TransactionDataSourceID,
            AR.ARHistoryDate
        FROM #ARSnapshot4 AR
        WHERE AR.ARHistoryDate = EOMONTH(DATEADD(MONTH, -1, GETDATE()))
        GROUP BY 
            AR.ARSnapshotID,
            AR.ARFinancialClass,
            AR.ProviderName,
			--AR.TransactionDataSourceID,
            AR.ARHistoryDate
        UNION ALL
        SELECT
            RR.ReimbRateID,
            RR.ARFinancialClass,
            RR.ProviderName,
            0 AS "0to30",
            0 AS "31to120",
            0 AS "121to150",
            0 AS "150+",
            0 AS "Under150",
            0 AS "BD0to30",
            0 AS "BD31to120",
            0 AS "BD121to150",
            0 AS "BD150+",
            0 AS "BDUnder150",
            RR.Charges,
            RR.Payments,
            CASE 
                WHEN SUM(RR.Charges) = 0 or SUM(RR.Charges) IS NULL THEN 0.40
                WHEN -(SUM(RR.Payments) / SUM(RR.Charges)) > 0.80 
                    AND RR.ProviderName IN ('HPIP CHN ANESTHESIA','HPIP CHS ANESTHESIA','HPIP NWSH ANESTHESIA') 
                THEN 0.228
                WHEN -(SUM(RR.Payments) / SUM(RR.Charges)) > 0.80 
                    AND RR.ARFinancialClass  <> 'Self-Pay' 
                THEN 0.80
                WHEN -(SUM(RR.Payments) / SUM(RR.Charges)) > 0.80 
                    AND RR.ARFinancialClass = 'Self-Pay' 
                THEN 0.40
                ELSE -(SUM(RR.Payments) / SUM(RR.Charges))
            END as ReimbursementPct,
			--'5' AS TransactionDataSourceID,
            NULL AS ARHistoryDate
        FROM #ReimbRate1 RR
        WHERE RR.ARTrailing6Months = 'Y'
		GROUP BY
			RR.ReimbRateID,
            RR.ARFinancialClass,
            RR.ProviderName,
			RR.Charges,
            RR.Payments
    )
      INSERT INTO [HPIDW].[rpt].HPIPContractualSummary (
        ProviderName,
        ARFinancialClass,
        [0to30],
        [31to120],
        [121to150],
        [150+],
        Under150,
        BD0to30,
        BD31to120,
        BD121to150,
        BD150Plus,
        BDUnder150,
        Charges,
        Payments,
        ReimbursementPct,
        ARHistoryDate
    )
    SELECT 
        CTE.ProviderName,
        CTE.ARFinancialClass,
        SUM(CTE."0to30") AS "0to30",
        SUM(CTE."31to120") AS "31to120",
        SUM(CTE."121to150") AS "121to150",
        SUM(CTE."150+") AS "150+",
        SUM(CTE."Under150") AS "Under150",
        SUM(CTE."BD0to30") AS "BD0to30",
        SUM(CTE."BD31to120") AS "BD31to120",
        SUM(CTE."BD121to150") AS "BD121to150",
        SUM(CTE."BD150+") AS "BD150+",
        SUM(CTE."BDUnder150") AS "BDUnder150",
        SUM(CTE.Charges) AS Charges,
        SUM(CTE.Payments) AS Payments,
        CASE 
            WHEN SUM(CTE.Charges) = 0 or SUM(CTE.Charges) IS NULL THEN 0.40
            WHEN -(SUM(CTE.Payments) / SUM(CTE.Charges)) > 0.80 
                AND CTE.ProviderName IN ('HPIP CHN ANESTHESIA','HPIP CHS ANESTHESIA','HPIP NWSH ANESTHESIA') 
            THEN 0.228
            WHEN -(SUM(CTE.Payments) / SUM(CTE.Charges)) > 0.80 
                AND CTE.ARFinancialClass  <> 'Self-Pay' 
            THEN 0.80
            WHEN -(SUM(CTE.Payments) / SUM(CTE.Charges)) > 0.80 
                AND CTE.ARFinancialClass = 'Self-Pay' 
            THEN 0.40
            ELSE -(SUM(CTE.Payments) / SUM(CTE.Charges))
        END as ReimbursementPct,
		--CTE.TransactionDataSourceID,
        EOMONTH(DATEADD(MONTH, -1, GETDATE())) as ARHistoryDate
    FROM CTE
    GROUP BY 
        CTE.ARSnapshotID,
        CTE.ARFinancialClass,
        CTE.ProviderName;
		--CTE.TransactionDataSourceID;
END;




--May HPIP CHN Anesthesia corrections from Debra Vermillia
--update rpt.HPIPContractualSummary SET [0to30] = 209510.12, [31to120] = 338439.47, [121to150] = 130969.84, [150+] = 225324, [Under150] = 678919.43
--where ProviderName = 'HPIP CHN ANESTHESIA' and [ARFinancialClass] = 'Other Commercial'


--June HPIP CHN Anesthesia corrections from Debra Vermillia
--update rpt.HPIPContractualSummary SET [0to30] = 276871.08, [31to120] = 272118.08, [121to150] = 104188.67, [150+] = 300444.89, [Under150] = 653177.83
--where ProviderName = 'HPIP CHN ANESTHESIA' and [ARHistoryDate] = '2024-06-30' and [ARFinancialClass] = 'Other Commercial' 


--July HPIP CHN Anesthesia corrections from Debra Vermillia
--update rpt.HPIPContractualSummary SET [0to30] = 68805.00, [31to120] = 262396.58, [121to150] = 82415.28, [150+] = 281453.84, [Under150] = 413616.86
--where ProviderName = 'HPIP CHN ANESTHESIA' and [ARHistoryDate] = '2024-07-31' and [ARFinancialClass] = 'Other Commercial' 


--August HPIP CHN Anesthesia corrections from Debra Vermillia
--update rpt.HPIPContractualSummary SET [0to30] = 355440.00, [31to120] = 294784.07, [121to150] = 30210.76, [150+] = 294033.86, [Under150] = 680434.83
--where ProviderName = 'HPIP CHN ANESTHESIA' and [ARHistoryDate] = '2024-08-31' and [ARFinancialClass] = 'Other Commercial' 


--September HPIP CHN Anesthesia corrections from Debra Vermillia
--update rpt.HPIPContractualSummary SET [0to30] = 185062.84, [31to120] = 146419.49, [121to150] = 12281.75, [150+] = 198177.57, [Under150] = 343764.08
--where ProviderName = 'HPIP CHN ANESTHESIA' and [ARHistoryDate] = '2024-09-30' and [ARFinancialClass] = 'Other Commercial' 


--November HPIP CHN Anesthesia corrections from Debra Vermillia
--update rpt.HPIPContractualSummary SET [0to30] = 256382.98, [31to120] = 128391.07, [121to150] = 11813.10, [150+] = 145718.45, [Under150] = 396587.15
--where ProviderName = 'HPIP CHN ANESTHESIA' and [ARHistoryDate] = '2024-11-30' and [ARFinancialClass] = 'Other Commercial' 


--December HPIP CHN Anesthesia corrections from Debra Vermillia
--update rpt.HPIPContractualSummary SET [0to30] = 246675.74, [31to120] = 102050.14, [121to150] = 15186.95, [150+] = 140237.95, [Under150] = 363912.83
--where ProviderName = 'HPIP CHN ANESTHESIA' and [ARHistoryDate] = '2024-11-30' and [ARFinancialClass] = 'Other Commercial' 


--January HPIP CHN Anesthesia corrections from Debra Vermillia
--update rpt.HPIPContractualSummary SET [0to30] = 177837.63, [31to120] = 90109.66, [121to150] = 19197.22, [150+] = 62738.44, [Under150] = 287144.51
--where ProviderName = 'HPIP CHN ANESTHESIA' and [ARHistoryDate] = '2025-01-31' and [ARFinancialClass] = 'Other Commercial' 
		


--February HPIP CHN Anesthesia corrections from Debra Vermillia
--update rpt.HPIPContractualSummary SET [0to30] = 152629.57, [31to120] = 72758.41, [121to150] = 12926.00, [150+] = 67379.66, [Under150] = 238313.98
--where ProviderName = 'HPIP CHN ANESTHESIA' and [ARHistoryDate] = '2025-02-28' and [ARFinancialClass] = 'Other Commercial' 


--March HPIP CHN Anesthesia corrections from Debra Vermillia
--update rpt.HPIPContractualSummary SET [0to30] = 147875.29, [31to120] = 65387.15, [121to150] = 6531.00, [150+] = 59036.29, [Under150] = 219793.44
--where ProviderName = 'HPIP CHN ANESTHESIA' and [ARHistoryDate] = '2025-03-31' and [ARFinancialClass] = 'Other Commercial' 


--April HPIP CHN Anesthesia corrections from Debra Vermillia
--update rpt.HPIPContractualSummary SET [0to30] = 207076.32, [31to120] = 104504.96, [121to150] = 9464.60, [150+] = 59725.35, [Under150] = 321045.88
--where ProviderName = 'HPIP CHN ANESTHESIA' and [ARHistoryDate] = '2025-04-30' and [ARFinancialClass] = 'Other Commercial' 


--May HPIP CHN Anesthesia corrections from Debra Vermillia
--update rpt.HPIPContractualSummary SET [0to30] = 142957.62, [31to120] = 93064.65, [121to150] = 13283.31, [150+] = 37929.38, [Under150] = 249305.58
--where ProviderName = 'HPIP CHN ANESTHESIA' and [ARHistoryDate] = '2025-05-31' and [ARFinancialClass] = 'Other Commercial'
GO
