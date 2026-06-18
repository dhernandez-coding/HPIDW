CREATE VIEW [rpt].[vMult] 
	
	--with schemabinding 
	AS 
					SELECT 
				TransactionVisitID as TransactionVisitID
				--, TransactionParentSourceID --TransactionID, 
				, TransactionCPTCode
				--TransactionCPTDescription,
				, max(cpt.rvu) Rvu
				--TransactionModifier1, 
				--TransactionModifier2, 
				--TransactionModifier3, 
				--TransactionModifier4,
				, ROW_NUMBER() OVER(PARTITION BY [TransactionVisitID] ORDER BY max(cpt.RVU) desc) as row_num
				FROM [fact].[Transactions2] t
					LEFT JOIN dim.CPTCode cpt ON cpt.CPTCode = t.TransactionCPTCode 
												AND t.TransactionDateOfPosting >= cpt.EffectiveStartDate 
												AND t.TransactionDateOfPosting < cpt.EffectiveEndDate
				WHERE 1=1 -- AND TransactionAccountID = '1~19228230'
				AND (TransactionModifier1 = '51' OR TransactionModifier2 = '51' OR TransactionModifier3 = '51' OR TransactionModifier4 = '51')
				AND TransactionBillingType = 'PB'
				AND TransactionType = 'Charge'
				--AND TransactionStatus = 'Active' /*Excluding Voided Transactions*/
				AND YEAR(TransactionDateOfPosting) >= (year(getdate()) - 2)
				--AND TransactionID = '259626168

				GROUP BY  --TransactionID,
				[TransactionVisitID],
				--TransactionParentSourceID,
				TransactionCPTCode
				--TransactionCPTDescription,
				--cpt.rvu,
			--	TransactionModifier1, 
				--TransactionModifier2, 
				--TransactionModifier3, 
				--TransactionModifier4
GO
