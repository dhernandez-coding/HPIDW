CREATE TABLE [dim].[ViewColumns] (
    [ViewName] VARCHAR(200) NULL,
    [ViewColumnName] VARCHAR(200) NULL,
    [ViewColumnDataType] VARCHAR(20) NULL,
    [ViewColumnMaxLength] FLOAT NULL,
    [ViewColumnIsNullable] BIT NULL,
    [ViewColumnsLoadDatetime] DATETIME NULL,
    [ViewID] VARCHAR(350) NULL
);
GO
