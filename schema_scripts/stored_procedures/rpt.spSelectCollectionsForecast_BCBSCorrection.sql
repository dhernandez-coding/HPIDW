CREATE PROCEDURE [rpt].[spSelectCollectionsForecast_BCBSCorrection] as



/*Create #TEMP_Charges Table*/
DROP TABLE IF EXISTS #TEMP_Charges 

	SELECT
		DATEFROMPARTS(YEAR(t.TransactionDateOfForecastCollection),MONTH(t.TransactionDateOfForecastCollection),1) as ReportPeriodDate
		,'Forecast' as CollectionType
		,t.TransactionDatasourceID as DatasourceID
		,t.TransactionPracticeID as PracticeID
		,t.TransactionBillingProviderID as BillingProviderID
		,t.TransactionPayerPlanID as PrimaryPayerPlanID
		,t.FeeScheduleID as FeeScheduleID
		,t.TransactionCPTCode as CPTCode
		,count(1) as TransactionCount
		,sum(t.TransactionUnits) as TransactionUnits
		,sum(t.TransactionAmount) as TotalCharges
		,sum(t.CalculatedFeeSchedule) as TotalCollections
		,min(t.TransactionID) as ExampleTransactionID
		,GETDATE() as AsOfDatetime
	INTO #TEMP_Charges
	FROM fact.vPBChargeCorrected t 
		--left join rpt.PBPaymentLag pd ON pd.PracticeID = t.TransactionPracticeID  
		left join dim.Practices pr ON pr.PracticeID = t.TransactionPracticeID
		--inner join #Balance b on b.TransactionParentSourceID = t.TransactionParentSourceID
	WHERE 1=1
		--AND t.TransactionDatasourceID = 5
		AND t.TransactionDateOfPosting >= '1/1/2024' /*Fee schedules are loaded for 2024 forward*/
		AND t.TransactionDateOfPosting >= DATEFROMPARTS(YEAR(GETDATE())-2,1,1)
		AND t.TransactionType = 'Charge'
		AND pr.PracticeCompany = 'TPG'
		AND pr.PracticeIsActive = 1
		AND t.TransactionAmount <> 0 /*added per Nick's request on 12/4*/
		--AND t.TransactionCPTCode = '27236'
	GROUP BY 
		DATEFROMPARTS(YEAR(t.TransactionDateOfForecastCollection),MONTH(t.TransactionDateOfForecastCollection),1) -- ReportPeriod
		,t.TransactionDatasourceID
		,t.TransactionPracticeID
		,t.TransactionBillingProviderID
		,t.TransactionPayerPlanID
		,t.FeeScheduleID
		,t.TransactionCPTCode

/*Create #TEMP_Collections Table*/
DROP TABLE IF EXISTS #TEMP_Collections 

		SELECT
			DATEFROMPARTS(YEAR(p.TransactionDateOfPosting),MONTH(p.TransactionDateOfPosting),1) as ReportPeriodDate
			,'Actual' as CollectionType
			,p.TransactionDatasourceID
			,pt.PracticeID
			,c.TransactionBillingProviderID as ChargeBillingProviderID
			,c.TransactionPayerPlanID as PrimaryPayerPlanID
			,COALESCE(CASE WHEN bc.CorrectPlan ='BlueChoice' then '0~BlueCrossChoice'
						  WHEN bc.CorrectPlan ='BluePreferred' then '0~BlueCrossPreferred'
						  WHEN bc.CorrectPlan ='BlueAdvantage' then '0~BlueCrossAdvantage'
						  WHEN bc.CorrectPlan ='BlueTraditional' then '0~BlueCrossTraditional'
						  ELSE fs.FeeScheduleID END,fs.FeeScheduleID) as FeeScheduleID
			,c.TransactionCPTCode as ChargeCPTCode
			,count(1) as PaymentCount
			,sum(p.TransactionUnits) as TransactionUnits
			,NULL AS TotalCharges
			,sum(p.TransactionAmount) as TotalCollections
			,min(p.TransactionID) as ExampleTransactionID
			,GETDATE() as AsOfDatetime
		INTO #TEMP_Collections
		FROM [fact].[vPBPaymentsandAdjustmentsCorrected] p

			INNER JOIN fact.vPBChargeCorrected c ON c.TransactionID = p.TransactionParentSourceID
			LEFT JOIN rpt.BCBSCorrected bc on bc.TransactionSourceID = c.TransactionParentSourceID
			LEFT JOIN map.PayerPlanFeeSchedules pfs ON pfs.PayerPlanID = c.TransactionPayerPlanID
			LEFT JOIN dim.FeeSchedules fs ON fs.FeeScheduleID = pfs.FeeScheduleID --I was not including this line because was giving me duplicates trying to debug it 
			left join map.ProviderLinking pl ON pl.ChildProviderID = c.TransactionBillingProviderID
			left join map.PracticeDepartments pd ON pd.DepartmentID = c.TransactionDepartmentID
			left join map.vPracticeProviders pp ON pp.ParentProviderID = pl.ParentProviderID
									AND pp.PracticeProviderEffectiveDate <= c.TransactionDateOfPosting 
									AND pp.PracticeProviderEndDate >= c.TransactionDateOfPosting
									AND (/*This is here to handle duplicates with Murphi Scarborough at multiple practices*/
												(pl.ParentProviderID in ('0~1588209423') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (c.TransactionDatasourceID = 5 AND pp.PracticeID = '0~RGS')
																													  OR (c.TransactionDatasourceID = 1 AND pp.PracticeID = '0~RLN'))) )
												/*This is here to handle duplicates with Amy James at multiple practices*/
												OR (pl.ParentProviderID in ('0~1679132823') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (c.TransactionDatasourceID = 5 AND pp.PracticeID = '0~MDW')
																													  OR (c.TransactionDatasourceID = 1 AND pp.PracticeID = '0~CGW'))) )
												/*Chris Cross - 10.7.24 - Added Olivo, Pape, and Dunkleberger due to practicing at PBJ, NMO, and NRJ; Defaults to PBJ if no mapped department defined in Epic*/
												OR (pl.ParentProviderID in ('0~1992746200','0~1891761136','0~1376509828') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND  pp.PracticeID = '0~PBJ') ) )
												/*Chris Cross - 02.18.25 - Added Jill Yingling due to practicing at MBJ and RLN; Defaults to RLN if no mapped department defined in Epic*/
												OR (pl.ParentProviderID in ('0~1245788231') 
													AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND pp.PracticeID = '0~RLN') ) )
												/*All other providers without specific mapping issues due to multiple practices as defined above*/
												OR pl.ParentProviderID not in ('0~1588209423','0~1679132823','0~1992746200','0~1891761136','0~1376509828','0~1245788231'))
												--AND pp.ProviderID = t.TransactionBillingProviderID
			left join dim.Practices pt ON pt.PracticeID = COALESCE(pd.PracticeID,pp.PracticeID)
			left join dim.Payers py ON py.PayerID = p.TransactionPayerID
			left join dim.PayerGroups pyg ON pyg.PayerGroupID = py.PayerGroupID
		WHERE 1=1
			AND p.TransactionType = 'Payment'
			--AND p.TransactionDatasourceID = 5
			--AND pyg.PayerGroupName <> 'Self-Pay' /*Insurance Payments Only*/
			AND c.TransactionDateOfPosting >= '1/1/2024'--DATEADD(DAY,-365,GETDATE())
			AND p.TransactionDateOfPosting >= DATEADD(DAY,2,c.TransactionDateOfService) /*Exclude Date of Service Collections*/
			AND pt.PracticeCompany = 'TPG'
			AND pt.PracticeIsActive = 1
			AND p.TransactionAmount <> 0
			--AND pt.PracticeID in ('0~TAK','0~SJA')

		GROUP BY 
			p.TransactionDatasourceID
			,DATEFROMPARTS(YEAR(p.TransactionDateOfPosting),MONTH(p.TransactionDateOfPosting),1)
			,pt.PracticeID
			,c.TransactionBillingProviderID
			,c.TransactionCPTCode
			,c.TransactionPayerPlanID
			,COALESCE(CASE WHEN bc.CorrectPlan ='BlueChoice' then '0~BlueCrossChoice'
						  WHEN bc.CorrectPlan ='BluePreferred' then '0~BlueCrossPreferred'
						  WHEN bc.CorrectPlan ='BlueAdvantage' then '0~BlueCrossAdvantage'
						  WHEN bc.CorrectPlan ='BlueTraditional' then '0~BlueCrossTraditional'
						  ELSE fs.FeeScheduleID END,fs.FeeScheduleID)

/*Return Consolidated Forecast and Actuals*/

SELECT * FROM #TEMP_Charges

UNION ALL

SELECT * FROM #TEMP_Collections
GO
