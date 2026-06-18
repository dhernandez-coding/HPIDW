CREATE PROCEDURE [rpt].[spSelectProForma] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
TRUNCATE TABLE rpt.ProformaActuals
INSERT INTO rpt.ProformaActuals (
    ProformaActualFiscalYear,
    ProformaActualFiscalPeriod,
    ProformaActualProviderFullName,
    ProformaActualReportingProviderID,
    ProformaActualFormattedDate,
    ProformaActualOfficeVisitsSum,
    ProformaActualSurgicalVisitsSum
)
SELECT 
    sub.FiscalYear AS ProformaActualFiscalYear,
    sub.FiscalPeriod AS ProformaActualFiscalPeriod,
    sub.ProviderFullName AS ProformaActualProviderFullName,
    sub.[ReportingProviderID] AS ProformaActualReportingProviderID,
    sub.FormattedDate AS ProformaActualFormattedDate,
    SUM(CASE 
            WHEN sub.ReportGroupLevel1 = 'Office Visits' AND sub.FiscalPeriodValue >= 0 THEN sub.FiscalPeriodValue 
            ELSE 0 
        END) AS ProformaActualOfficeVisitsSum,
    SUM(CASE 
            WHEN sub.ReportGroupLevel1 = 'Surgical Visits' AND sub.FiscalPeriodValue >= 0 THEN sub.FiscalPeriodValue 
            ELSE 0 
        END) AS ProformaActualSurgicalVisitsSum
FROM (
    SELECT 
        [BlueBooksID],
        [FiscalYear],
        [FiscalPeriod],
        CONVERT(DATE, '01-' + [FiscalYearPeriod], 106) AS FormattedDate,
        [ReportSection],
        [ReportGroupLevel1],
        [ReportGroupLevel2],
        [PracticeID],
        [ReportingProviderID],
        p.ProviderFullName,
        [FiscalPeriodValue],
        [UpdatedDatetime]
    FROM [HPIDW].[rpt].[BlueBooks] bb
    LEFT JOIN dim.vproviders p ON p.ProviderID = bb.ReportingProviderID
    WHERE 1 = 1
        AND bb.ReportSection = 'Visits'
        AND bb.ReportGroupLevel1 IN ('Office Visits', 'Surgical Visits')
        AND [ReportingProviderID] IN ('5~144782', '5~127137', '5~105864', '5~143697', '5~126434', '5~144543')
) sub
GROUP BY
    sub.FiscalYear,
    sub.FiscalPeriod,
    sub.ProviderFullName,
    sub.[ReportingProviderID],
    sub.FormattedDate
ORDER BY
    sub.ProviderFullName;

END
GO
