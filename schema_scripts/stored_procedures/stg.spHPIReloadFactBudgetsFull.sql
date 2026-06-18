-- =============================================
-- Author:		Chris Cross
-- Create date: 03/14/2023
-- Description:	Extracts, Transforms and Loads Data from INTERNAL Source System into a dim Table
-- Change Control
--	1. 04/19/2023 - Chris Cross - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spHPIReloadFactBudgetsFull]
AS
BEGIN
SET NOCOUNT ON;


 DELETE FROM fact.Budgets WHERE BudgetDataSourceID = 0

 INSERT INTO fact.Budgets
 ([BudgetID]
      ,[BudgetDatasourceID]
      ,[BudgetSourceID]
      ,[BudgetTypeID]
      ,[BudgetDate]
      ,[BudgetLocationID]
      ,[BudgetDepartmentID]
      ,[BudgetServiceLineID]
      ,[BudgetSpecialtyID]
      ,[BudgetProviderID]
      ,[BudgetPayerGroupID]
      ,[BudgetPayerCategoryID]
      ,[BudgetPayerID]
      ,[BudgetPayerPlanID]
      ,[BudgetValue]
      ,[BudgetIsActive]
      ,[BudgetUpdatedDatetime]
	)

 SELECT
	concat('0~',s.BudgetID) as BudgetID
	,0 as BudgetDatasourceID
	,CONVERT(varchar(100),s.BudgetID) as BudgetSourceID
	,concat('0~',s.BudgetTypeID) as[BudgetTypeID]
      ,[BudgetDate]
      ,case when s.BudgetLocationID IS NOT NULL THEN concat('0~',s.BudgetLocationID) END AS [BudgetLocationID]
      ,case when s.BudgetDepartmentID IS NOT NULL THEN concat('0~',s.BudgetDepartmentID) END AS [BudgetDepartmentID]
      ,case when s.BudgetServiceLineID IS NOT NULL THEN concat('0~',s.BudgetServiceLineID) END AS [BudgetServiceLineID]
      ,case when s.BudgetSpecialtyID IS NOT NULL THEN concat('0~',s.BudgetSpecialtyID) END AS [BudgetSpecialtyID]
      ,case when s.BudgetProviderID IS NOT NULL THEN concat('0~',s.BudgetProviderID) END AS [BudgetProviderID]
      ,case when s.BudgetPayerGroupID IS NOT NULL THEN concat('0~',s.BudgetPayerGroupID) END AS [BudgetPayerGroupID]
      ,case when s.BudgetPayerCategoryID IS NOT NULL THEN concat('0~',s.BudgetPayerCategoryID) END AS [BudgetPayerCategoryID]
      ,case when s.BudgetPayerID IS NOT NULL THEN concat('0~',s.BudgetPayerID) END AS [BudgetPayerID]
      ,case when s.BudgetPayerPlanID IS NOT NULL THEN concat('0~',s.BudgetPayerPlanID) END AS [BudgetPayerPlanID]
      ,[BudgetValue]
      ,[BudgetIsActive]
	,GETDATE() AS [BudgetUpdatedDateTime]
 FROM [HPIApp].dbo.Budgets s

/*
insert into dim.Specialties SELECT '0~BARI',0,'BARI','Bariatrics','BARI',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~DERM',0,'DERM','Dermatology','DERM',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~EMER',0,'EMER','Emergency Medicine','EMER',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~ENDO',0,'ENDO','Endocrinology','ENDO',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~FAMI',0,'FAMI','Family Medicine','FAMI',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~GAST',0,'GAST','Gastro','GAST',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~GENE',0,'GENE','General Surgery','GENE',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~INTE',0,'INTE','Internal Medicine','INTE',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~NEUR',0,'NEUR','Neurosurgery','NEUR',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~EYES',0,'EYES','Eyes','EYES',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~ORTH',0,'ORTH','Ortho','ORTH',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~PAIN',0,'PAIN','Pain Management','PAIN',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~PEDS',0,'PEDS','Pediatrics','PEDS',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~PLAS',0,'PLAS','Plastic Surgery','PLAS',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~RHEU',0,'RHEU','Rheumatology','RHEU',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~SPOR',0,'SPOR','Sports Medicine','SPOR',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~UROL',0,'UROL','Urology','UROL',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~GYNE',0,'GYNE','Gynecology','GYNE',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~SPIN',0,'SPIN','Spine','SPIN',NULL,1,NULL,GETDATE()
insert into dim.Specialties SELECT '0~ENT',0,'ENT','ENT','ENT',NULL,1,NULL,GETDATE()
*/


END
GO
