-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 09/08/2022
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [fact].[spAPMLoadTransactionsFull]
AS
BEGIN
SET NOCOUNT ON;
select
	*,
	case SourceTransactionProcedureCategoryAbbreviation
		when 'AUDIT' then 'AUDITORY'
		when 'BLADD' then 'BLAD'
		when 'BONE' then 'BONEDEN'
		when 'CAT II' then 'CATII'
		when 'CAT III' then 'CATIII'
		when 'EVALMGT' then 'EVALMGMT'
		when 'IMMUN' then 'IMMUNIZ'
		when 'LAB' then 'PATHLAB'
		when 'OTHER3' then 'OTHER'
		when 'US' then 'ULTRASND'
	else SourceTransactionProcedureCategoryAbbreviation
	end SourceTransactionProcedureCategoryAbbreviation
--Left off at Trx_Code Clean
from
(
select
	1 DataSourceID,
	t.SourceTransactionVisitID,
	t.SourceTransactionVisitNumber,
	t.SourceTransactionType,
	t.SourceTransactionUpdateStatus,
	t.SourceTransactionDateOfPosting,
	t.SourceTransactionDateOfService,
	month(t.SourceTransactionDateOfPosting) TransactionReportPeriodMonth,
	year(t.SourceTransactionDateOfPosting) TransactionReportPeriodYear,
	t.SourceTransactionDepartmentAbbreviation,
	t.SourceTransactionProcedureCode,
	case when t.SourceTransactionProcedureCode in('76705','76536','76700') then
		case when t.SourceTransactionDepartmentAbbreviation = 'FTMC' then 'US'
		else SourceTransactionProcedureCategoryAbbreviation
		end
	else SourceTransactionProcedureCategoryAbbreviation
	end SourceTransactionProcedureCategoryAbbreviation,
	t.SourceTransactionUnits,
	t.SourceTransactionAmount,
	t.SourceTransactionLocationAbbreviation,
	t.SourceTransactionCodeDescription,
	case when t.SourceTransactionProcedureCode = 'Infusion' then 'Infusion' else
		case when la.SurgeryFlag = 'Y' then 'Surgery' else
			case  t.SourceTransactionProcedureCategoryAbbreviation 
				when 'PREVEST' then 'Established PT'
				when 'EVALEST' then 'Established PT'
				when 'NEWEM' then 'New PT'
				when 'PREVNP' then 'New PT'
				when 'PATHLAB' then 'Pathlab'
				when 'LAB' then 'Pathlab'
				when 'POSTOP' then 'Post Op'
				when 'NOSHOW' then 'No Show'
				else ''
			end 
		end
	end VisitCategory

--if([Practice Dr]="Dr. Stacey Foshee",0,CALCULATE(SUM(Charges[Units]),Charges[POS Surgical]="Y"))
--if(and([Trnsfm_Visit Cat NoShow]>0,[Fees]=0),"No Show","Established PT")))))))
--TransactionReferringProvider  Comes from the Visit
--TransactionReportProvider  Comes from the Visit
--TransactionPracticeProvider  Comes from the Visit
--TransactionPayerSubCategory  Comes from Visit - Payer Sub Category

from stg.Transactions t
left join
(
	select        
		p.Place_Of_Service_ID, 
		max(c.Billing_Code) AS BillingCode, 
		p.Abbreviation LocationAbbreviation, 
		v.Surgery SurgeryFlag, 
		max(v.[Place of Service Name]) AS LocationDescription
	from tievmdb03.Ntier_627200.pm.Places_Of_Service p
	inner join tievmdb03.Ntier_627200.pm.POS_Billing_Codes c ON p.Place_Of_Service_ID = c.Place_Of_Service_ID 
	inner join tievmdb03.Ntier_627200.dbo.[Dict_POS Billing Codes CSV] v ON c.Billing_Code = v.[Code(s)]
	group by 
		p.Place_Of_Service_ID, 
		p.Abbreviation, 
		v.Surgery
) la on t.SourceTransactionLocationAbbreviation = la.LocationAbbreviation
--where t.SourceTransactionProcedureCode = 'Infusion'
)a
END
GO
