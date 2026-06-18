CREATE PROCEDURE [rpt].[spAPMBankReconciliation]
(
      @Tenant_ID                INT          = 1
    , @Operator_ID              INT          = 1543
    , @DateFrom                 DATE
    , @DateTo                   DATE
    , @DateSelection            INT          = 0        -- 0 Paid, 1 Updated, 2 Entered
    , @ExcludeCorrectionBatches BIT          = 1
    , @IncludeUnassigned        BIT          = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------
    -- TEMP TABLES
    ------------------------------------------------------------
    CREATE TABLE #Departments (
        Tenant_ID INT,
        Department_ID INT,
        Description VARCHAR(200)
    );

    INSERT INTO #Departments
    SELECT *
    FROM OPENQUERY(tievmdb03,
        'SELECT Tenant_ID, Department_ID, Description
         FROM Ntier_627200.PM.fnDepartments(1,1543)'
    );

    CREATE TABLE #Assigned (
        Batch VARCHAR(50),
        Practice VARCHAR(200),
        TransactionCategory VARCHAR(200),
        TransactionAbbrev VARCHAR(20),
        TransactionDesc VARCHAR(200),
        DatePaid DATE,
        Reference VARCHAR(100),
        PatientAccount VARCHAR(50),
        Voucher_Number INT,
        Amount NUMERIC(16,2),
        OperatorName VARCHAR(200),
        DateEntered DATE,
        DateUpdated DATE
    );

    ------------------------------------------------------------
    -- Build dynamic WHERE for date choice
    ------------------------------------------------------------
    DECLARE @DateField NVARCHAR(50);
    SET @DateField = CASE @DateSelection
                        WHEN 0 THEN 'Date_Paid'
                        WHEN 1 THEN 'Date_Updated'
                        WHEN 2 THEN 'Date_Entered'
                     END;

    ------------------------------------------------------------
    -- Dynamic SQL for ASSIGNED payments
    ------------------------------------------------------------
    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = '
        INSERT INTO #Assigned
        SELECT
              t1.Batch_Number,
              d.Description,
              t1.Tran_Cat_Desc,
              t1.Tran_Code_Abbr,
              t1.Tran_Code_Desc,
              t1.Date_Paid,
              t1.Reference,
              CASE WHEN t1.Voucher_Number IS NULL THEN ''A#'' ELSE ''P#'' END + t1.Patient_Number,
              t1.Voucher_Number,
              t1.Amount,
              t1.Operator_Name,
              t1.Date_Entered,
              t1.Date_Updated
        FROM OPENQUERY(tievmdb03,
            ''SELECT *
              FROM Ntier_627200.PM.vwBankReconcilPmts
              WHERE Tenant_ID = ' + CAST(@Tenant_ID AS VARCHAR(10)) + '
                AND CONVERT(DATE, ' + @DateField + ')
                    BETWEEN ''''' + CONVERT(VARCHAR(10), @DateFrom, 120) + ''''' 
                        AND ''''' + CONVERT(VARCHAR(10), @DateTo, 120) + '''''
                AND (' + CAST(@ExcludeCorrectionBatches AS VARCHAR(1)) + ' <> 1 OR Correction_Batch = 0)
				AND Division_ID=1
            '') t1
        INNER JOIN #Departments d
            ON d.Tenant_ID = t1.Tenant_ID
           AND d.Department_ID = t1.Department_ID;
    ';

    EXEC sp_executesql @SQL;

    ------------------------------------------------------------
    -- Dynamic SQL for UNASSIGNED payments
    ------------------------------------------------------------
    IF @IncludeUnassigned = 1
    BEGIN
        SET @SQL = '
            INSERT INTO #Assigned
            SELECT
                  t1.Batch_Number,
                  d.Description,
                  t1.Tran_Cat_Desc,
                  t1.Tran_Code_Abbr,
                  t1.Tran_Code_Desc,
                  t1.Date_Paid,
                  t1.Reference,
                  CASE WHEN t1.Voucher_Number IS NULL THEN ''A#'' ELSE ''P#'' END + t1.Patient_Number,
                  t1.Voucher_Number,
                  t1.Amount,
                  t1.Operator_Name,
                  t1.Date_Entered,
                  t1.Date_Updated
            FROM OPENQUERY(tievmdb03,
                ''SELECT *
                  FROM Ntier_627200.PM.vwBankReconcilUnassigned
                  WHERE Tenant_ID = ' + CAST(@Tenant_ID AS VARCHAR(10)) + '
                    AND CONVERT(DATE, ' + @DateField + ')
                        BETWEEN ''''' + CONVERT(VARCHAR(10), @DateFrom, 120) + '''''
                            AND ''''' + CONVERT(VARCHAR(10), @DateTo, 120) + '''''
                    AND (' + CAST(@ExcludeCorrectionBatches AS VARCHAR(1)) + ' <> 1 OR Correction_Batch = 0)
					AND Division_ID=1
                '') t1
            INNER JOIN #Departments d
                ON d.Tenant_ID = t1.Tenant_ID
               AND (d.Department_ID = t1.Department_ID OR t1.Department_ID IS NULL);
        ';

        EXEC sp_executesql @SQL;
    END;

    ------------------------------------------------------------
    -- FINAL OUTPUT
    ------------------------------------------------------------
    SELECT *
    FROM #Assigned
    ORDER BY
          Batch,
          Practice,
          TransactionCategory,
          DatePaid,
          Reference,
          PatientAccount;

END;
GO
