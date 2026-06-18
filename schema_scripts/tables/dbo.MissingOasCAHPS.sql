CREATE TABLE [dbo].[MissingOasCAHPS] (
    [Client_ID] SMALLINT NOT NULL,
    [HCAHPS_ID] DATE NOT NULL,
    [Uploaded] NVARCHAR(50) NOT NULL,
    [Survey_ID] BIGINT NOT NULL,
    [Unique_ID] BIGINT NOT NULL,
    [Procedure_Date] DATE NOT NULL,
    [Issue] NVARCHAR(50) NOT NULL,
    [Demograph_Rollup] NVARCHAR(50) NOT NULL,
    [Demograph] NVARCHAR(50) NOT NULL,
    [Demograph_Value] NVARCHAR(50) NULL
);
GO
