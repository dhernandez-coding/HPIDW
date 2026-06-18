CREATE PROCEDURE [rpt].[spExportAllPressGaneyFiles]
    @startdate DATE,
    @enddate DATE

/*
-- =============================================
-- Author:		Zeke Herrera
-- Create date: 08/30/2023
-- Description:	Compiles data from all Press Ganey Stored Procedures for Export
-- Change Control
--	
-- =============================================
*/

AS
BEGIN




EXEC [HPIDW].[rpt].[spPG_ED_Daily] @startdate, @enddate;


EXEC [HPIDW].[rpt].[spPG_HPI_CH_Inpatient_Daily] @startdate, @enddate;


EXEC [HPIDW].[rpt].[spPG_HPI_CH_OAS_Daily] @startdate, @enddate;


EXEC [HPIDW].[rpt].[spPG_HPI_CH_Outpatient_Daily] @startdate, @enddate;


EXEC [HPIDW].[rpt].[spPG_HPI_CH_Outpatient_PTDaily] @startdate, @enddate;


EXEC [HPIDW].[rpt].[spPG_HPI_NWSH_Inpatient_Daily] @startdate, @enddate;


EXEC [HPIDW].[rpt].[spPG_HPI_NWSH_OAS_Daily] @startdate, @enddate;


EXEC [HPIDW].[rpt].[spPG_HPI_NWSH_Outpatient_Daily] @startdate, @enddate;





END;
GO
