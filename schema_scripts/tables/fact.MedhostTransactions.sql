CREATE TABLE [fact].[MedhostTransactions] (
    [recid] VARCHAR(50) NULL,
    [patno] INT NULL,
    [seqnum] INT NULL,
    [cycle] INT NULL,
    [trdate] VARCHAR(20) NULL,
    [tcode] INT NULL,
    [tamt] DECIMAL(18,2) NULL,
    [glnum] INT NULL,
    [ptype] VARCHAR(20) NULL,
    [fincl] VARCHAR(20) NULL,
    [optdsc] VARCHAR(50) NULL,
    [isotrdate] DATE NULL,
    [isoodate] DATE NULL,
    [isomtendd] DATE NULL,
    [HospitalAbrev] VARCHAR(50) NULL
);
GO
