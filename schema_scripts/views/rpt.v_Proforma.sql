CREATE VIEW rpt.v_Proforma AS
SELECT 
    pd.ProformaID,
    pd.ProformaName,
    pd.ProformaOutpatientEncounters,
    pd.ProformaProceduralEncounters,
    pd.ProformaMonth,
    pd.ProformaMonthNumber,
    pd.ProformaYear,
    ISNULL(pa.ProformaActualOfficeVisitsSum, 0) AS ActualOfficeVisitsSum,
    ISNULL(pa.ProformaActualSurgicalVisitsSum, 0) AS ActualSurgicalVisitsSum
FROM 
    rpt.ProformaData pd
LEFT JOIN 
    rpt.ProformaActuals pa
ON 
    pa.ProformaActualReportingProviderID = pd.ProformaID -- Matching ProformaID
    AND pa.ProformaActualFormattedDate = pd.ProformaMonth; -- Matching Date
GO
