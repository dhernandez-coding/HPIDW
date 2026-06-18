CREATE TABLE [stg].[MedicareFeeSchedule] (
    [Year] INT NULL,
    [CarrierNumber] INT NULL,
    [PricingLocality] INT NULL,
    [HCPCSCode] VARCHAR(50) NULL,
    [Modifier] VARCHAR(50) NULL,
    [NonFacilityFeeSchedAmt] FLOAT NULL,
    [FacilityFeeSchedAmt] FLOAT NULL,
    [PCTCIndicator] NVARCHAR(50) NULL,
    [StatusCode] INT NULL,
    [MultipleSurgeryIndicator] NVARCHAR(50) NULL,
    [FlatVisitFee] INT NULL,
    [NonFacilityTherapyReductionAmt] FLOAT NULL,
    [FacilityTherapyReductionAmt] FLOAT NULL,
    [OPPSIndicator] INT NULL,
    [OPPSNonFacilityFeeAmt] FLOAT NULL,
    [OPPSFacilityFeeAmt] FLOAT NULL
);
GO
