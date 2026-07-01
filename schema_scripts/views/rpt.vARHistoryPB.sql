CREATE VIEW [rpt].[vARHistoryPB] as 
SELECT
	   ar.[ARHistoryID]
      ,ar.[ARHistoryDate]
      ,ar.[TransactionDataSourceID]
	  ,ds.DataSourceName as TransactionDataSource
      ,ar.[TransactionSourceID]
      ,ar.[TransactionType]
      ,ar.[TransactionLocationID]
      ,ar.[TransactionDepartmentID]
      ,ar.[TransactionPlaceOfServiceID]
      ,ar.[TransactionPlaceOfServiceType]
      ,ar.[TransactionGuarantorID]
      ,ar.[TransactionGuarantorType]
      ,ar.[TransactionAccountID]
      ,ar.[TransactionAccountClass]
      ,ar.[TransactionVisitID]
      ,ar.[TransactionVisitType]
      ,ar.[CurrentFinancialClass]
      ,ar.[CurrentPayerID]
      ,ar.[CurrentPayerPlanID]
      ,ar.[OriginalFinancialClass]
      ,ar.[OriginalPayerID]
      ,ar.[OriginalPayerPlanID]
      ,ar.[TransactionServiceProviderID]
      ,ar.[TransactionBillingProviderID]
	  ,pt.PracticeID as TransactionPracticeID
      ,ar.[TransactionCode]
      ,ar.[TransactionDescription]
      ,ar.[TransactionCPTCode]
      ,ar.[TransactionModifier1]
      ,ar.[TransactionModifier2]
      ,ar.[TransactionModifier3]
      ,ar.[TransactionModifier4]
      ,ar.[TransactionUnits]
      ,ar.[TransactionLedgerType]
      ,ar.[TransactionOriginalAmount]
      ,ar.[TransactionARAmountAll]
      ,ar.[TransactionARAmountSelfPay]
      ,ar.[TransactionARAmountInsurance]
      ,ar.[TransactionARAmountActive]
      ,ar.[TransactionARAmountBadDebt]
      ,ar.[TransactionServiceDate]
      ,ar.[TransactionServiceDateAge]
	   ,CASE WHEN ar.[TransactionServiceDateAge] < 0 THEN '0'
		    WHEN ar.[TransactionServiceDateAge] BETWEEN 0 AND 30 THEN '1'
			WHEN ar.[TransactionServiceDateAge] BETWEEN 31 AND 60 THEN '2'
			WHEN ar.[TransactionServiceDateAge] BETWEEN 61 AND 90 THEN '3'
			WHEN ar.[TransactionServiceDateAge] BETWEEN 91 AND 120 THEN '4'
			WHEN ar.[TransactionServiceDateAge] > 120 THEN '5'
			ELSE NULL END as TransactionARAgingBucketSort
	  ,CASE WHEN ar.[TransactionServiceDateAge] < 0 THEN 'Undistributed'
			WHEN ar.[TransactionServiceDateAge] BETWEEN 0 AND 30 THEN '0-30'
			WHEN ar.[TransactionServiceDateAge] BETWEEN 31 AND 60 THEN '31-60'
			WHEN ar.[TransactionServiceDateAge] BETWEEN 61 AND 90 THEN '61-90'
			WHEN ar.[TransactionServiceDateAge] BETWEEN 91 AND 120 THEN '91-120'
			WHEN ar.[TransactionServiceDateAge] > 120 THEN '121+'
			ELSE NULL END as TransactionARAgingBucket
      ,ar.[TransactionPostDate]
      ,ar.[TransactionPostDateAge]
      ,ar.[TransactionInsuranceAgeDate]
      ,ar.[TransactionInsuranceAge]
      ,ar.[TransactionFirstClaimDate]
      ,ar.[TransactionLastClaimDate]
      ,ar.[TransactionSelfPayAgeDate]
      ,ar.[TransactionSelfPayAge]
      ,ar.[ARHistoryUpdatedDatetime]
	  ,ar.IsMostRecentAR
	  ,CASE WHEN ar.TransactionARAmountAll < 0 THEN 'Yes' ELSE 'No' END AS IsCreditBalance
FROM (
		SELECT 
			[ARHistoryID]
			,[ARHistoryDate]
			,[TransactionDataSourceID]
			,[TransactionSourceID]
			,[TransactionType]
			,[TransactionLocationID]
			,[TransactionDepartmentID]
			,[TransactionPlaceOfServiceID]
			,[TransactionPlaceOfServiceType]
			,[TransactionGuarantorID]
			,[TransactionGuarantorType]
			,[TransactionAccountID]
			,[TransactionAccountClass]
			,[TransactionVisitID]
			,[TransactionVisitType]
			,[CurrentFinancialClass]
			,[CurrentPayerID]
			,[CurrentPayerPlanID]
			,[OriginalFinancialClass]
			,[OriginalPayerID]
			,[OriginalPayerPlanID]
			,[TransactionServiceProviderID]
			,[TransactionBillingProviderID]
			,[TransactionCode]
			,[TransactionDescription]
			,[TransactionCPTCode]
			,[TransactionModifier1]
			,[TransactionModifier2]
			,[TransactionModifier3]
			,[TransactionModifier4]
			,[TransactionUnits]
			,[TransactionLedgerType]
			,[TransactionOriginalAmount]
			,[TransactionARAmountAll]
			,[TransactionARAmountSelfPay]
			,[TransactionARAmountInsurance]
			,[TransactionARAmountActive]
			,[TransactionARAmountBadDebt]
			,[TransactionServiceDate]
			,[TransactionServiceDateAge]
			,[TransactionPostDate]
			,[TransactionPostDateAge]
			,[TransactionInsuranceAgeDate]
			,[TransactionInsuranceAge]
			,[TransactionFirstClaimDate]
			,[TransactionLastClaimDate]
			,[TransactionSelfPayAgeDate]
			,[TransactionSelfPayAge]
			,[ARHistoryUpdatedDatetime]
			,'No' as IsMostRecentAR
		FROM rpt.ARHistoryPB arh
		WHERE 1=1
			AND arh.ARHistoryDate >= DATEADD(month,-13,GETDATE()) /*Return only the last 12 months of data*/

		UNION ALL

		SELECT 
			[ARHistoryID]
			,[ARHistoryDate]
			,[TransactionDataSourceID]
			,[TransactionSourceID]
			,[TransactionType]
			,[TransactionLocationID]
			,[TransactionDepartmentID]
			,[TransactionPlaceOfServiceID]
			,[TransactionPlaceOfServiceType]
			,[TransactionGuarantorID]
			,[TransactionGuarantorType]
			,[TransactionAccountID]
			,[TransactionAccountClass]
			,[TransactionVisitID]
			,[TransactionVisitType]
			,[CurrentFinancialClass]
			,[CurrentPayerID]
			,[CurrentPayerPlanID]
			,[OriginalFinancialClass]
			,[OriginalPayerID]
			,[OriginalPayerPlanID]
			,[TransactionServiceProviderID]
			,[TransactionBillingProviderID]
			,[TransactionCode]
			,[TransactionDescription]
			,[TransactionCPTCode]
			,[TransactionModifier1]
			,[TransactionModifier2]
			,[TransactionModifier3]
			,[TransactionModifier4]
			,[TransactionUnits]
			,[TransactionLedgerType]
			,[TransactionOriginalAmount]
			,[TransactionARAmountAll]
			,[TransactionARAmountSelfPay]
			,[TransactionARAmountInsurance]
			,[TransactionARAmountActive]
			,[TransactionARAmountBadDebt]
			,[TransactionServiceDate]
			,[TransactionServiceDateAge]
			,[TransactionPostDate]
			,[TransactionPostDateAge]
			,[TransactionInsuranceAgeDate]
			,[TransactionInsuranceAge]
			,[TransactionFirstClaimDate]
			,[TransactionLastClaimDate]
			,[TransactionSelfPayAgeDate]
			,[TransactionSelfPayAge]
			,[ARHistoryUpdatedDatetime]
			,'Yes' as IsMostRecentAR
		FROM rpt.ARCurrentPB arc
		WHERE 1=1
		) ar
	left join dim.Datasources ds ON ds.DataSourceID = ar.TransactionDataSourceID
	--left join map.ProviderLinking pl ON pl.ChildProviderID = ar.TransactionBillingProviderID
	--left join map.PracticeDepartments pd ON pd.DepartmentID = ar.TransactionDepartmentID
	--left join map.vPracticeProviders pp ON pp.ParentProviderID = pl.ParentProviderID
	--									AND pp.PracticeProviderEffectiveDate <= ar.TransactionPostDate 
	--									AND pp.PracticeProviderEndDate >= ar.TransactionPostDate
	--									/*This is here to handle duplicates with Amy James and Murphi Scarborough at multiple practices*/
	--									AND ((ar.TransactionBillingProviderID in ('1~19898','5~126867','1~19711','5~125582') AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND ar.TransactionBillingProviderID = pp.ProviderID)))
	--										  OR ar.TransactionBillingProviderID not in ('1~19898','5~126867','1~19711','5~125582'))
	--									--AND pp.ProviderID = t.TransactionBillingProviderID
	left join map.ProviderLinking pl ON pl.ChildProviderID = ar.TransactionBillingProviderID
	left join map.PracticeDepartments pd ON pd.DepartmentID = ar.TransactionDepartmentID
	left join map.vPracticeProviders pp ON pp.ParentProviderID = pl.ParentProviderID
								AND pp.PracticeProviderEffectiveDate <= ar.TransactionPostDate 
								AND pp.PracticeProviderEndDate >= ar.TransactionPostDate
								AND (/*This is here to handle duplicates with Murphi Scarborough at multiple practices*/
											(pl.ParentProviderID in ('0~1588209423') 
												AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (ar.TransactionDatasourceID = 5 AND pp.PracticeID = '0~RGS')
																													OR (ar.TransactionDatasourceID = 1 AND pp.PracticeID = '0~RLN'))) )
											/*This is here to handle duplicates with Amy James at multiple practices*/
											OR (pl.ParentProviderID in ('0~1679132823') 
												AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (ar.TransactionDatasourceID = 5 AND pp.PracticeID = '0~MDW')
																													OR (ar.TransactionDatasourceID = 1 AND pp.PracticeID = '0~CGW'))) )
											/*Chris Cross - 10.7.24 - Added Olivo, Pape, and Dunkleberger due to practicing at PBJ, NMO, and NRJ; Defaults to PBJ if no mapped department defined in Epic*/
											OR (pl.ParentProviderID in ('0~1992746200','0~1891761136','0~1376509828') 
												AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND  pp.PracticeID = '0~PBJ') ) )
											/*Chris Cross - 02.18.25 - Added Jill Yingling due to practicing at MBJ and RLN; Defaults to RLN if no mapped department defined in Epic*/
											OR (pl.ParentProviderID in ('0~1245788231') 
												AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND pp.PracticeID = '0~RLN') ) )
											/*This is here to handle duplicates with Paul Maitino at multiple practices*/
											OR (pl.ParentProviderID in ('0~1376507665') 
												AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (ar.TransactionDepartmentID = '12~45' AND pp.PracticeID = '0~JRS')
																													OR (ar.TransactionDepartmentID = '12~46' AND pp.PracticeID = '0~OPCL'))) )
											/*This is here to handle duplicates with Calvin Johnson at multiple practices*/
											OR (pl.ParentProviderID in ('0~1063484251') 
												AND (pp.PracticeID = pd.PracticeID OR (pd.PracticeID is null AND (ar.TransactionDepartmentID = '12~48' AND pp.PracticeID = '0~JCJ')
																													OR (ar.TransactionDepartmentID = '12~36' AND pp.PracticeID = '0~JCJ')
																													OR (ar.TransactionDepartmentID = '1~19' AND pp.PracticeID = '0~JCJ2')
																													OR (ar.TransactionDepartmentID = '1~5' AND pp.PracticeID = '0~JCJ2'))) )
											/*All other providers without specific mapping issues due to multiple practices as defined above*/
											OR pl.ParentProviderID not in ('0~1588209423','0~1679132823','0~1992746200','0~1891761136','0~1376509828','0~1245788231','0~1376507665','0~1063484251'))
	left join dim.vPractices pt ON pt.PracticeID = COALESCE(pd.PracticeID,pp.PracticeID)
WHERE 1=1




	--select * FROM rpt.ARHistoryPB ar where ar.TransactionServiceDateAge < 0
GO
