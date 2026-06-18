CREATE Procedure [rpt].[BlueBookFullReload]
as


Exec rpt.spLoadBlueBookVisits;
Exec rpt.spLoadBlueBookNonAssistVisits;
Exec rpt.spLoadBlueBookVisitInfo;

Exec rpt.spLoadBlueBookCharges;
Exec rpt.spLoadBlueBookChargeLag;
Exec rpt.spLoadBlueBookPayments;
Exec rpt.spLoadBlueBookPaymentLag;
Exec rpt.spLoadBlueBookAR;
Exec rpt.spLoadBlueBookRevenueExpenses;
Exec rpt.spLoadBlueBookCash;
Exec rpt.spLoadBlueBookAdjustments;
GO
