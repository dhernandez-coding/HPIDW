-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 08/10/2022
-- Description:	Pulls Locations Data from Medhost Source System
-- Change Control
--	1. 08/10/2022 - Initial build of procedure
-- =============================================
CREATE PROCEDURE [etl].[spMedhostCPTCodes]
AS
BEGIN
SET NOCOUNT ON;
declare @SourceCount int = (select count(1) from [HMSLS].[MHD32].[DWHMS].[C_CPTCODE])
declare @dwCount int = (select count(1) from CPTCodes)

if @SourceCount > @dwCount begin
truncate table CPTCodes
insert into CPTCodes select * from [HMSLS].[MHD32].[DWHMS].[C_CPTCODE]
end
END
GO
