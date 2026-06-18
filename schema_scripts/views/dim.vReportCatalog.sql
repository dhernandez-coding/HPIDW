CREATE VIEW dim.vReportCatalog
AS
SELECT 
    w.PBWorkspaceName,
    d.PBDatasetName,
    r.PBReportName,
    r.PBReportWebUrl,
    r.PBReportIsActive,
    CASE 
        WHEN d.PBDatasetName IS NULL THEN 'Paginated Report'
        ELSE 'PBI Report'
    END AS ReportType
FROM dim.PBReports r
LEFT JOIN dim.PBWorkspaces w 
    ON w.PBWorkspaceID = r.PBWorkspaceID
LEFT JOIN dim.PBDatasets d 
    ON d.PBDatasetSourceID = r.PBDatasetID;
GO
