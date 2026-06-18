-- =============================================
-- Author:		Eric Silvestri
-- Create date: 08/29/2025
-- Description:	Extracts, Transforms and Loads Coding Data from EPIC Source System into a fact Table
-- Change Control

-- =============================================
CREATE PROCEDURE [stg].[spEPICReloadFactCodingFull]
AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Creating @StagingTable...';

    DECLARE @StagingTable TABLE (
    CodingAccountID varchar(50),
	CodingDataSource int,
	CodingAccountSourceID varchar(50),
	CodingSequence int,
	CodingStatusDate datetime,
	CodingStatusComment  varchar(255),
	CodingStatus varchar(50),
	CodingUser varchar(50),
	CodingUpdateDate datetime
    );

    -- Insert manual Self-Pay record
    INSERT INTO @StagingTable (
		CodingAccountID,
		CodingDataSource,
		CodingAccountSourceID,
		CodingSequence,
		CodingStatusDate,
		CodingStatusComment,
		CodingStatus,
		CodingUser,
		CodingUpdateDate
    )



	 SELECT
	CONCAT('5~',c.HSP_ACCOUNT_ID)AS CodingAccountID
	,5 AS CodingDataSource
	,c.HSP_ACCOUNT_ID AS CodingAccountSourceID
	,c.LINE AS CodingSequence
	,c.CDSTS_HX_DATE AS CodingStatusDate
	,c.CDSTS_HX_CMT	AS CodingStatusComment
	,cs.name AS CodingStatus
	,e.NAME AS CodingUser
	,GETDATE() AS CodingUpdateDate
 FROM [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].HSP_ACCT_CDSTS_HX c
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_SVC_SUCCESS ss ON ss.SVC_SUCCESS_C = c.CDSTS_HX_SVC_STS_C
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_COMPLETN_STS_HA cs ON cs.COMPLETN_STS_HA_C = c.CDSTS_HX_STS_C
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_EMP e ON e.USER_ID = c.CDSTS_HX_ASGN_USER_ID
	LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_SER s ON s.PROV_ID = c.CM_PHY_OWNER_ID



    -- Proceed only if enough data was returned
    IF (SELECT COUNT(1) FROM @StagingTable) >= 10
    BEGIN
        BEGIN TRANSACTION;
            PRINT 'At least 10 records found. Proceeding to delete and reload.';

            DELETE FROM fact.Coding WHERE CodingDataSource = 5;

            INSERT INTO fact.Coding (
                CodingAccountID,
				CodingDataSource,
				CodingAccountSourceID,
				CodingSequence,
				CodingStatusDate,
				CodingStatusComment,
				CodingStatus,
				CodingUser,
				CodingUpdateDate
            )
            SELECT 
                CodingAccountID,
				CodingDataSource,
				CodingAccountSourceID,
				CodingSequence,
				CodingStatusDate,
				CodingStatusComment,
				CodingStatus,
				CodingUser,
				CodingUpdateDate
            FROM @StagingTable;

        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        PRINT 'Less than 10 records in the staging table. Ending job without delete and reload...';
    END
END;
GO
