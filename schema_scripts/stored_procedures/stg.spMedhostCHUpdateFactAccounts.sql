-- nw

CREATE procedure [stg].[spMedhostCHUpdateFactAccounts] as

update a
set
	a.AccountTotalPayments = t.Payments
	,a.AccountTotalAdjustments = t.Adjustments
	,a.AccountTotalBalance = (a.AccountTotalCharges + t.Adjustments + t.Payments)
from fact.Accounts a
inner join (
	select
		TransactionAccountID
		,sum (case when transactiontype= 'Charge' then TransactionAmount else 0 end) Charges
		,sum (case when transactiontype= 'Adjustment' then TransactionAmount else 0 end) Adjustments
		,sum (case when transactiontype= 'Payment' then TransactionAmount else 0 end) Payments
	  FROM [HPIDW].[fact].[Transactions2]
	  where TransactionDatasourceID in ('8') -- ch
	  group by TransactionAccountID) t on a.AccountID = t.TransactionAccountID
GO
