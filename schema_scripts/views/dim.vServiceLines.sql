create view dim.vServiceLines as 
Select [ServiceLineID]
      ,[ServiceLineName]
      ,[ServiceLineGroupID]
      ,[ServiceLineIsActive]
      ,[ServiceLineCreatedDate]
      ,[ServiceLineCreatedByUserID]
      ,[ServiceLineModifiedDate]
      ,[ServiceLineModifiedByUserID]
      ,[ValidFrom]
      ,[ValidTo]
      ,[CreatedDate]
      ,[ModifiedDate]
      ,[ModifiedBy]
      ,[DeletedDate]
      ,[DeletedBy]
      ,[IsDeleted]
      ,[IsActive]
  FROM [hpi_etl].[dbo].[ServiceLiness]
GO
