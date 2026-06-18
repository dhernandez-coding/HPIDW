Create Procedure rpt.BlueBookFinancialRelaod
as


Exec rpt.spLoadBlueBookRevenueExpenses;
Exec rpt.spLoadBlueBookCash;
GO
