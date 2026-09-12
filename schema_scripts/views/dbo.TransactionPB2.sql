CREATE VIEW dbo.TransactionPB2 AS
SELECT
    t.TransactionID,
    t.TransactionDatasourceID,
    t.TransactionBillingProviderID,
    COALESCE(t.TransactionDepartmentID, tc.TransactionDepartmentID) AS TransactionDepartmentID,
    t.TransactionDateOfPosting,
    pl.ParentProviderID,
    tier1.PracticeID AS Tier1_Department_PracticeID,
    tier2.PracticeID AS Tier2_ExactChildMatch_PracticeID,
    tier3.PracticePracticeID AS Tier3_DefaultFallback_PracticeID,
    COALESCE(tier1.PracticeID, tier2.PracticeID, tier3.PracticePracticeID) AS TransactionPracticeID,
    CASE
        WHEN tier1.PracticeID IS NOT NULL THEN 'department_match'
        WHEN tier2.PracticeID IS NOT NULL THEN 'exact_child_match'
        WHEN tier3.PracticePracticeID IS NOT NULL THEN 'default_fallback'
        ELSE 'unresolved'
    END AS ResolutionMethod,
    pt.PracticeGLLocationID,
    pt.PracticeGLPracticeID
FROM fact.TransactionsPB t
    LEFT JOIN fact.TransactionsPB tc
        ON tc.TransactionID = t.TransactionParentID
        AND tc.TransactionType = 'Charge'
        AND t.TransactionType <> 'Charge'
    LEFT JOIN map.vProviderLinking pl
        ON pl.ChildProviderID = t.TransactionBillingProviderID
    OUTER APPLY (
        SELECT TOP 1 spd.PracticeID
        FROM stg.PracticeDepartment spd
        WHERE spd.DepartmentID = COALESCE(t.TransactionDepartmentID, tc.TransactionDepartmentID)
            AND spd.PracticeDepartmentIsActive = 1
            AND spd.PracticeDepartmentEffectiveDate <= t.TransactionDateOfPosting
            AND spd.PracticeDepartmentEndDate >= t.TransactionDateOfPosting
    ) tier1
    OUTER APPLY (
        SELECT TOP 1 spp.PracticeID
        FROM stg.PracticeProviders spp
        WHERE spp.ProviderID = t.TransactionBillingProviderID
            AND spp.PracticeProviderIsActive = 1
            AND spp.PracticeProviderEffectiveDate <= t.TransactionDateOfPosting
            AND spp.PracticeProviderEndDate >= t.TransactionDateOfPosting
        ORDER BY spp.PracticeProviderEffectiveDate DESC
    ) tier2
    OUTER APPLY (
        SELECT TOP 1 hpr.PracticePracticeID
        FROM HPIApp.dbo.PracticeProviders hpp
            JOIN HPIApp.dbo.Providers hp ON hp.ProviderID = hpp.ProviderID
            JOIN HPIApp.dbo.Practices hpr ON hpr.PracticeID = hpp.PracticeID
        WHERE hp.ProviderProviderID = pl.ParentProviderID
            AND hpp.PracticeProviderIsDefaultPractice = 1
            AND hpp.PracticeProviderIsActive = 1
    ) tier3
    LEFT JOIN dim.vPractices pt
        ON pt.PracticeID = COALESCE(tier1.PracticeID, tier2.PracticeID, tier3.PracticePracticeID)
WHERE t.TransactionDateOfPosting >= DATEFROMPARTS(YEAR(GETDATE()) - 2, 1, 1)
GO
