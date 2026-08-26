CREATE PROCEDURE [dim].[spReloadHeroSpecialties_INCREMENTAL] as
		
 -- Description: INCREMENTAL reload for dim.Specialties--_Hero
MERGE dim.Specialties--_Hero 
AS target
USING (
    SELECT
        concat('0~', SpecialtyId) as SpecialtyId
        ,0 as SpecialtyDataSourceID
        ,SpecialtyId as SpecialtySourceId
        ,SpecialtyName
        ,Left(SpecialtyName, 4) as SpecialtyAbbreviation
        ,NULL as SpecialtyDescription
        ,IsActive as SpecialtyIsActive
        ,NULL as SpecialtyCoPayApplies
        ,ModifiedDate as SpecialtyUpdatedDateTime
    FROM hero.Specialtiess
) AS source
ON target.SpecialtyId = source.SpecialtyId

WHEN MATCHED THEN
    UPDATE SET
       
        target.SpecialtyName           = source.SpecialtyName
        ,target.SpecialtyAbbreviation   = source.SpecialtyAbbreviation
        ,target.SpecialtyDescription    = source.SpecialtyDescription
        ,target.SpecialtyIsActive       = source.SpecialtyIsActive
        ,target.SpecialtyCoPayApplies   = source.SpecialtyCoPayApplies
        ,target.SpecialtyUpdatedDateTime = source.SpecialtyUpdatedDateTime

WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        [SpecialtyId]
        ,[SpecialtyDataSourceID]
        ,[SpecialtySourceId]
        ,[SpecialtyName]
        ,[SpecialtyAbbreviation]
        ,[SpecialtyDescription]
        ,[SpecialtyIsActive]
        ,[SpecialtyCoPayApplies]
        ,[SpecialtyUpdatedDateTime]
    )
    VALUES (
        source.SpecialtyId
        ,source.SpecialtyDataSourceID
        ,source.SpecialtySourceId
        ,source.SpecialtyName
        ,source.SpecialtyAbbreviation
        ,source.SpecialtyDescription
        ,source.SpecialtyIsActive
        ,source.SpecialtyCoPayApplies
        ,source.SpecialtyUpdatedDateTime
    )

WHEN NOT MATCHED BY SOURCE THEN
    UPDATE SET
        target.SpecialtyIsActive = 0;
GO
