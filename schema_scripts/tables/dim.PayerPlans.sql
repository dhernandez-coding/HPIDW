CREATE TABLE [dim].[PayerPlans] (
    [PayerPlanID] VARCHAR(50) NOT NULL,
    [PayerPlanDataSourceID] INT NOT NULL,
    [PayerPlanSourceID] VARCHAR(50) NOT NULL,
    [PayerID] VARCHAR(50) NOT NULL,
    [PayerPlanName] VARCHAR(100) NULL,
    [PayerPlanContractNumber] VARCHAR(50) NULL,
    [PayerPlanIsActive] BIT NULL,
    [PayerPlanUpdatedDatetime] DATETIME NULL,
    CONSTRAINT [PK__PayerPla__065BDE9B64FE8424] PRIMARY KEY ([PayerPlanID])
);
GO
