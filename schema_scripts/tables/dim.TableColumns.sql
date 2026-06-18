CREATE TABLE [dim].[TableColumns] (
    [TableName] VARCHAR(200) NULL,
    [TableColumnName] VARCHAR(200) NULL,
    [TableDataType] NVARCHAR(128) NULL,
    [TableMaxLength] FLOAT NULL,
    [TableIsNullable] BIT NULL,
    [TableIsIdentity] BIT NULL,
    [TableLastModifyDatetime] DATETIME NULL,
    [TableLoadDatetime] DATETIME NULL,
    [TableID] VARCHAR(350) NULL,
    [DatabaseName] VARCHAR(150) NULL
);
GO
