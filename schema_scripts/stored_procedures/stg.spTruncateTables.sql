-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Truncates Tables for Nighly Reload
-- Change Control
--	1. 11/23/2022 - Initial build of procedure
--  2. 02/07/2023 - added medhostarmastinsurance
-- =============================================
CREATE PROCEDURE [stg].[spTruncateTables]
AS
BEGIN
SET NOCOUNT ON;
truncate table dim.Departments
truncate table dim.Locations
truncate table dim.Payers
truncate table dim.ProcedureCodes
truncate table dim.Providers
truncate table dim.Patients
truncate table stg.APMVisits
truncate table fact.Visits
truncate table stg.MedhostArMastInsurance
END
GO
