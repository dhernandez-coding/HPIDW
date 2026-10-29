/*
================================================================================
  dbo.spDatabaseMaintenance
--------------------------------------------------------------------------------
  Maintenance for the data warehouse database. Run it AFTER the nightly ETL
  loads finish, never alongside them.

  Steps (each one is optional):
    1. Integrity check        DBCC CHECKDB (run weekly)
    2. Rowstore indexes       REORGANIZE / REBUILD based on fragmentation
    3. Columnstore indexes    REORGANIZE when deleted rows / closed rowgroups pile up
    4. Heaps                  ALTER TABLE ... REBUILD when forwarded records pile up
    5. Statistics             UPDATE STATISTICS on stats with enough modifications

  Output (no permanent log table needed):
    - Progress messages stream to the Messages tab as each object is processed.
    - Result set 1: one row per object with its measurements, the command,
      and SUCCESS / FAILED / SKIPPED / WHATIF.
    - Result set 2: counts per step and status.
    - If anything failed, the proc THROWs at the end so the Agent job is marked
      failed and its notification fires.

  Safety rails:
    - Stops starting new work once @MaxRuntimeMinutes is reached.
    - Skips index/heap work while the transaction log is above @MaxLogUsedPct.
    - One failed index or stat is recorded and skipped; the rest keep going.

  @WhatIf = 1 (dry run): runs the read-only analysis queries, executes nothing,
  issues no CHECKPOINT, writes nothing. Result set 1 shows exactly what would
  have run and why. Dry runs also gather page density for each candidate
  index (@IncludePageDensity).

  Example calls:
    EXEC dbo.spDatabaseMaintenance;                         -- nightly, after ETL
    EXEC dbo.spDatabaseMaintenance @DoIntegrityCheck = 1;   -- weekly
    EXEC dbo.spDatabaseMaintenance @WhatIf = 1;             -- dry run
================================================================================
*/
CREATE   PROCEDURE dbo.spDatabaseMaintenance
     @DoIntegrityCheck       bit    = 0
    ,@PhysicalOnly           bit    = 0        -- faster CHECKDB, fewer logical checks
    ,@DoIndexes              bit    = 1
    ,@DoColumnstore          bit    = 1
    ,@DoHeaps                bit    = 1
    ,@DoStatistics           bit    = 1
    ,@ReorgThresholdPct      float  = 10.0     -- fragmentation % to REORGANIZE
    ,@RebuildThresholdPct    float  = 30.0     -- fragmentation % to REBUILD
    ,@MinPageCount           int    = 1000     -- ignore small indexes (~8 MB)
    ,@ColumnstoreDeletedPct  float  = 10.0
    ,@HeapForwardedPct       float  = 10.0
    ,@StatsModifiedPct       float  = 10.0
    ,@StatsFullScanMaxRows   bigint = 10000000 -- FULLSCAN at or below this, default sample above
    ,@MaxDOP                 int    = 0
    ,@MaxRuntimeMinutes      int    = 180
    ,@MaxLogUsedPct          float  = 70.0
    ,@WhatIf                 bit    = 0
    ,@IncludePageDensity     bit    = NULL     -- NULL = on for dry runs, off for real runs
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
         @RunStart     datetime = GETDATE()
        ,@StopAt       datetime = DATEADD(MINUTE, @MaxRuntimeMinutes, GETDATE())
        ,@ObjStart     datetime
        ,@SQL          nvarchar(max)
        ,@Online       bit
        ,@LogUsedPct   float
        ,@ErrorCount   int = 0
        ,@SkipReason   nvarchar(100)
        ,@Msg          nvarchar(2047)
        ,@Schema       sysname
        ,@Table        sysname
        ,@Index        sysname
        ,@Stat         sysname
        ,@PartNo       int
        ,@PartCount    int
        ,@Action       varchar(20)
        ,@RowCount     bigint
        ,@Detail       nvarchar(400)
        ,@ObjectName   nvarchar(400)
        ,@IndexType    varchar(40)
        ,@StepStart    datetime
        ,@PhaseStart   datetime
        ,@Rows         int;

    -- Page density needs a SAMPLED scan of each candidate index, so by default
    -- it's only gathered on dry runs. Pass 1 or 0 to override.
    SET @IncludePageDensity = ISNULL(@IncludePageDensity, @WhatIf);

    -- ONLINE rebuilds: Enterprise/Developer (3), Azure SQL DB (5), Managed Instance (8)
    SET @Online = CASE WHEN CAST(SERVERPROPERTY('EngineEdition') AS int) IN (3, 5, 8) THEN 1 ELSE 0 END;

    CREATE TABLE #Results (
         ResultID      int IDENTITY(1,1) PRIMARY KEY
        ,Step          varchar(20)    NOT NULL
        ,ObjectName    nvarchar(400)  NULL
        ,IndexType     varchar(40)    NULL       -- Rowstore / Columnstore / Heap
        ,Detail        nvarchar(400)  NULL
        ,Command       nvarchar(max)  NULL
        ,Status        varchar(20)    NOT NULL   -- SUCCESS / FAILED / SKIPPED / WHATIF
        ,ErrorNumber   int            NULL
        ,ErrorMessage  nvarchar(4000) NULL
        ,StartTime     datetime       NULL
        ,EndTime       datetime       NULL
    );

    SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | RUN | Maintenance started on ', DB_NAME(), CASE WHEN @WhatIf = 1 THEN N' (WhatIf - nothing will be changed)' ELSE N'' END), 2047);
    RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;


    /* =========================================================================
       1. INTEGRITY CHECK
       ========================================================================= */
    IF @DoIntegrityCheck = 1
    BEGIN
        SET @SQL = N'DBCC CHECKDB (0) WITH NO_INFOMSGS, ALL_ERRORMSGS'
                 + CASE WHEN @PhysicalOnly = 1 THEN N', PHYSICAL_ONLY' ELSE N'' END + N';';
        SET @StepStart = GETDATE();
        SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | CHECKDB | Step started'), 2047);
        RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;
        SET @ObjStart = GETDATE();
        SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | CHECKDB |   running: ', @SQL), 2047);
        RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;

        BEGIN TRY

            IF @WhatIf = 0
                EXEC sys.sp_executesql @SQL;

            INSERT INTO #Results (Step, ObjectName, Command, Status, StartTime, EndTime)
            VALUES ('CHECKDB', DB_NAME(), @SQL, CASE WHEN @WhatIf = 1 THEN 'WHATIF' ELSE 'SUCCESS' END, @ObjStart, GETDATE());

        END TRY
        BEGIN CATCH

            SET @ErrorCount += 1;

            INSERT INTO #Results (Step, ObjectName, Command, Status, ErrorNumber, ErrorMessage, StartTime, EndTime)
            VALUES ('CHECKDB', DB_NAME(), @SQL, 'FAILED', ERROR_NUMBER(), ERROR_MESSAGE(), @ObjStart, GETDATE());

        END CATCH

        -- Step summary
        SELECT @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | CHECKDB | Step finished in ',
                                  DATEDIFF(SECOND, @StepStart, GETDATE()), N' sec | ',
                                  ISNULL(SUM(CASE WHEN Status IN ('SUCCESS', 'WHATIF') THEN 1 ELSE 0 END), 0), N' done, ',
                                  ISNULL(SUM(CASE WHEN Status = 'FAILED'  THEN 1 ELSE 0 END), 0), N' failed, ',
                                  ISNULL(SUM(CASE WHEN Status = 'SKIPPED' THEN 1 ELSE 0 END), 0), N' skipped'), 2047)
        FROM #Results
        WHERE Step = 'CHECKDB';
        RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;
    END


    /* =========================================================================
       2. ROWSTORE INDEXES (clustered + nonclustered b-trees)
       ========================================================================= */
    IF @DoIndexes = 1
    BEGIN
        SET @StepStart = GETDATE();
        SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | INDEX | Step started'), 2047);
        RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;

        BEGIN TRY

            SET @PhaseStart = GETDATE();
            DROP TABLE IF EXISTS #Idx;

            SELECT
                 ObjectID       = i.object_id
                ,IndexID        = i.index_id
                ,SchemaName     = s.name
                ,TableName      = o.name
                ,IndexName      = i.name
                ,PartitionNo    = ps.partition_number
                ,PartitionCount = pc.PartitionCount
                ,FragPct        = ps.avg_fragmentation_in_percent
                ,PageCount      = ps.page_count
                ,PageDensityPct = CAST(NULL AS float)
                ,IndexType      = CASE i.type WHEN 1 THEN 'Rowstore - Clustered'
                                              ELSE      'Rowstore - Nonclustered' END
                ,IndexAction    = CASE
                                    WHEN ps.avg_fragmentation_in_percent >= @RebuildThresholdPct THEN 'REBUILD'
                                    WHEN i.allow_page_locks = 0                                  THEN 'REBUILD' -- REORGANIZE needs page locks
                                    ELSE 'REORGANIZE'
                                  END
            INTO #Idx
            FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ps
            JOIN sys.indexes AS i ON i.object_id = ps.object_id AND i.index_id = ps.index_id
            JOIN sys.objects AS o ON o.object_id = i.object_id
            JOIN sys.schemas AS s ON s.schema_id = o.schema_id
            CROSS APPLY (
                SELECT PartitionCount = COUNT(*)
                FROM sys.partitions AS p
                WHERE p.object_id = i.object_id AND p.index_id = i.index_id
            ) AS pc
            WHERE o.type = 'U'
              AND o.is_ms_shipped = 0
              AND i.type IN (1, 2)              -- clustered / nonclustered rowstore
              AND i.is_disabled = 0
              AND i.is_hypothetical = 0
              AND ps.index_level = 0
              AND ps.alloc_unit_type_desc = 'IN_ROW_DATA'
              AND ps.page_count >= @MinPageCount
              AND ps.avg_fragmentation_in_percent >= @ReorgThresholdPct;

            SELECT @Rows = COUNT(*) FROM #Idx;
            SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | INDEX | Fragmentation scan finished in ', DATEDIFF(SECOND, @PhaseStart, GETDATE()), N' sec | ', @Rows, N' candidate index(es)'), 2047);
            RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;

            -- Page density (how full the leaf pages are). LIMITED mode doesn't
            -- return it, so do a SAMPLED pass over the candidate indexes only.
            IF @IncludePageDensity = 1
                UPDATE x
                SET    PageDensityPct = d.avg_page_space_used_in_percent
                FROM   #Idx AS x
                CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(), x.ObjectID, x.IndexID, x.PartitionNo, 'SAMPLED') AS d
                WHERE  d.index_level = 0
                  AND  d.alloc_unit_type_desc = 'IN_ROW_DATA';

            IF @IncludePageDensity = 1
            BEGIN
                SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | INDEX | Page density scan finished in ', DATEDIFF(SECOND, @PhaseStart, GETDATE()), N' sec total'), 2047);
                RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;
            END

            DECLARE curIdx CURSOR LOCAL FAST_FORWARD FOR
                SELECT SchemaName, TableName, IndexName, PartitionNo, PartitionCount, IndexAction,
                       CONCAT('Frag ', CAST(FragPct AS decimal(5,1)), '% | ', PageCount, ' pages',
                              CASE WHEN PageDensityPct IS NOT NULL
                                   THEN CONCAT(' | Density ', CAST(PageDensityPct AS decimal(5,1)), '%')
                                   ELSE '' END,
                              ' | Partition ', PartitionNo, ' of ', PartitionCount),
                       IndexType
                FROM #Idx
                ORDER BY FragPct * PageCount DESC;   -- most impactful first

            OPEN curIdx;

            WHILE 1 = 1
            BEGIN
                FETCH NEXT FROM curIdx INTO @Schema, @Table, @Index, @PartNo, @PartCount, @Action, @Detail, @IndexType;
                IF @@FETCH_STATUS <> 0 BREAK;

                SET @ObjectName = QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table) + N'.' + QUOTENAME(@Index);

                SET @SQL =
                      N'ALTER INDEX ' + QUOTENAME(@Index)
                    + N' ON ' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table)
                    + N' ' + CAST(@Action AS nvarchar(20))
                    + CASE WHEN @PartCount > 1 THEN N' PARTITION = ' + CAST(@PartNo AS nvarchar(10)) ELSE N'' END
                    + CASE WHEN @Action = 'REBUILD'
                           THEN N' WITH (SORT_IN_TEMPDB = ON, MAXDOP = ' + CAST(@MaxDOP AS nvarchar(10))
                                + CASE WHEN @Online = 1 THEN N', ONLINE = ON' ELSE N'' END
                                + N')'
                           ELSE N''
                      END
                    + N';';

                -- Guard rails: runtime window and transaction log headroom
                SELECT @LogUsedPct = used_log_space_in_percent FROM sys.dm_db_log_space_usage;
                IF @LogUsedPct >= @MaxLogUsedPct AND @WhatIf = 0
                BEGIN
                    CHECKPOINT;  -- frees log in SIMPLE recovery
                    SELECT @LogUsedPct = used_log_space_in_percent FROM sys.dm_db_log_space_usage;
                END

                SET @SkipReason = CASE
                                    WHEN GETDATE() >= @StopAt             THEN N'Runtime limit reached'
                                    WHEN @LogUsedPct >= @MaxLogUsedPct    THEN CONCAT(N'Log ', CAST(@LogUsedPct AS decimal(5,1)), N'% used')
                                  END;

                IF @SkipReason IS NOT NULL
                BEGIN
                    INSERT INTO #Results (Step, ObjectName, IndexType, Detail, Command, Status, ErrorMessage)
                    VALUES ('INDEX', @ObjectName, @IndexType, @Detail, @SQL, 'SKIPPED', @SkipReason);
                    CONTINUE;
                END

                SET @ObjStart = GETDATE();
                IF @WhatIf = 0
                BEGIN
                    SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | INDEX |   running: ', @SQL), 2047);
                    RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;
                END

                BEGIN TRY

                    IF @WhatIf = 0
                        EXEC sys.sp_executesql @SQL;

                    INSERT INTO #Results (Step, ObjectName, IndexType, Detail, Command, Status, StartTime, EndTime)
                    VALUES ('INDEX', @ObjectName, @IndexType, @Detail, @SQL, CASE WHEN @WhatIf = 1 THEN 'WHATIF' ELSE 'SUCCESS' END, @ObjStart, GETDATE());

                END TRY
                BEGIN CATCH

                    SET @ErrorCount += 1;

                    INSERT INTO #Results (Step, ObjectName, IndexType, Detail, Command, Status, ErrorNumber, ErrorMessage, StartTime, EndTime)
                    VALUES ('INDEX', @ObjectName, @IndexType, @Detail, @SQL, 'FAILED', ERROR_NUMBER(), ERROR_MESSAGE(), @ObjStart, GETDATE());

                END CATCH

                -- Per-object result and duration
                SELECT TOP (1) @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | INDEX |   ', Status, N' in ',
                                                  DATEDIFF(SECOND, @ObjStart, GETDATE()), N' sec | ', ObjectName), 2047)
                FROM #Results
                ORDER BY ResultID DESC;
                RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;
            END

            CLOSE curIdx;
            DEALLOCATE curIdx;

        END TRY
        BEGIN CATCH

            SET @ErrorCount += 1;

            INSERT INTO #Results (Step, ObjectName, Status, ErrorNumber, ErrorMessage, EndTime)
            VALUES ('INDEX', N'(step failed)', 'FAILED', ERROR_NUMBER(), ERROR_MESSAGE(), GETDATE());

        END CATCH

        -- Step summary
        SELECT @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | INDEX | Step finished in ',
                                  DATEDIFF(SECOND, @StepStart, GETDATE()), N' sec | ',
                                  ISNULL(SUM(CASE WHEN Status IN ('SUCCESS', 'WHATIF') THEN 1 ELSE 0 END), 0), N' done, ',
                                  ISNULL(SUM(CASE WHEN Status = 'FAILED'  THEN 1 ELSE 0 END), 0), N' failed, ',
                                  ISNULL(SUM(CASE WHEN Status = 'SKIPPED' THEN 1 ELSE 0 END), 0), N' skipped'), 2047)
        FROM #Results
        WHERE Step = 'INDEX';
        RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;
    END


    /* =========================================================================
       3. COLUMNSTORE INDEXES
          REORGANIZE compresses CLOSED delta rowgroups and cleans up deleted
          rows. OPEN delta stores are left alone on purpose: forcing them
          closed creates small, inefficient rowgroups.
       ========================================================================= */
    IF @DoColumnstore = 1
    BEGIN
        SET @StepStart = GETDATE();
        SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | COLUMNSTORE | Step started'), 2047);
        RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;

        BEGIN TRY

            SET @PhaseStart = GETDATE();
            DROP TABLE IF EXISTS #Cs;

            SELECT
                 SchemaName     = s.name
                ,TableName      = o.name
                ,IndexName      = i.name
                ,PartitionNo    = rg.partition_number
                ,PartitionCount = pc.PartitionCount
                ,DeletedPct     = SUM(rg.deleted_rows) * 100.0 / NULLIF(SUM(rg.total_rows), 0)
                ,ClosedGroups   = SUM(CASE WHEN rg.state_desc = 'CLOSED' THEN 1 ELSE 0 END)
                ,IndexType      = CASE i.type WHEN 5 THEN 'Columnstore - Clustered'
                                              ELSE      'Columnstore - Nonclustered' END
            INTO #Cs
            FROM sys.dm_db_column_store_row_group_physical_stats AS rg
            JOIN sys.indexes AS i ON i.object_id = rg.object_id AND i.index_id = rg.index_id
            JOIN sys.objects AS o ON o.object_id = i.object_id
            JOIN sys.schemas AS s ON s.schema_id = o.schema_id
            CROSS APPLY (
                SELECT PartitionCount = COUNT(*)
                FROM sys.partitions AS p
                WHERE p.object_id = i.object_id AND p.index_id = i.index_id
            ) AS pc
            WHERE o.type = 'U'
              AND o.is_ms_shipped = 0
              AND i.type IN (5, 6)              -- clustered / nonclustered columnstore
              AND i.is_disabled = 0
            GROUP BY s.name, o.name, i.name, i.type, rg.partition_number, pc.PartitionCount
            HAVING SUM(rg.deleted_rows) * 100.0 / NULLIF(SUM(rg.total_rows), 0) >= @ColumnstoreDeletedPct
                OR SUM(CASE WHEN rg.state_desc = 'CLOSED' THEN 1 ELSE 0 END) > 0;

            SELECT @Rows = COUNT(*) FROM #Cs;
            SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | COLUMNSTORE | Rowgroup scan finished in ', DATEDIFF(SECOND, @PhaseStart, GETDATE()), N' sec | ', @Rows, N' candidate(s)'), 2047);
            RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;

            DECLARE curCs CURSOR LOCAL FAST_FORWARD FOR
                SELECT SchemaName, TableName, IndexName, PartitionNo, PartitionCount,
                       CONCAT('Deleted ', CAST(ISNULL(DeletedPct, 0) AS decimal(5,1)), '% | ',
                              ClosedGroups, ' closed rowgroup(s) | Partition ', PartitionNo, ' of ', PartitionCount),
                       IndexType
                FROM #Cs
                ORDER BY DeletedPct DESC;

            OPEN curCs;

            WHILE 1 = 1
            BEGIN
                FETCH NEXT FROM curCs INTO @Schema, @Table, @Index, @PartNo, @PartCount, @Detail, @IndexType;
                IF @@FETCH_STATUS <> 0 BREAK;

                SET @ObjectName = QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table) + N'.' + QUOTENAME(@Index);

                SET @SQL =
                      N'ALTER INDEX ' + QUOTENAME(@Index)
                    + N' ON ' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table)
                    + N' REORGANIZE'
                    + CASE WHEN @PartCount > 1 THEN N' PARTITION = ' + CAST(@PartNo AS nvarchar(10)) ELSE N'' END
                    + N';';

                IF GETDATE() >= @StopAt
                BEGIN
                    INSERT INTO #Results (Step, ObjectName, IndexType, Detail, Command, Status, ErrorMessage)
                    VALUES ('COLUMNSTORE', @ObjectName, @IndexType, @Detail, @SQL, 'SKIPPED', N'Runtime limit reached');
                    CONTINUE;
                END

                SET @ObjStart = GETDATE();
                IF @WhatIf = 0
                BEGIN
                    SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | COLUMNSTORE |   running: ', @SQL), 2047);
                    RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;
                END

                BEGIN TRY

                    IF @WhatIf = 0
                        EXEC sys.sp_executesql @SQL;

                    INSERT INTO #Results (Step, ObjectName, IndexType, Detail, Command, Status, StartTime, EndTime)
                    VALUES ('COLUMNSTORE', @ObjectName, @IndexType, @Detail, @SQL, CASE WHEN @WhatIf = 1 THEN 'WHATIF' ELSE 'SUCCESS' END, @ObjStart, GETDATE());

                END TRY
                BEGIN CATCH

                    SET @ErrorCount += 1;

                    INSERT INTO #Results (Step, ObjectName, IndexType, Detail, Command, Status, ErrorNumber, ErrorMessage, StartTime, EndTime)
                    VALUES ('COLUMNSTORE', @ObjectName, @IndexType, @Detail, @SQL, 'FAILED', ERROR_NUMBER(), ERROR_MESSAGE(), @ObjStart, GETDATE());

                END CATCH

                -- Per-object result and duration
                SELECT TOP (1) @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | COLUMNSTORE |   ', Status, N' in ',
                                                  DATEDIFF(SECOND, @ObjStart, GETDATE()), N' sec | ', ObjectName), 2047)
                FROM #Results
                ORDER BY ResultID DESC;
                RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;
            END

            CLOSE curCs;
            DEALLOCATE curCs;

        END TRY
        BEGIN CATCH

            SET @ErrorCount += 1;

            INSERT INTO #Results (Step, ObjectName, Status, ErrorNumber, ErrorMessage, EndTime)
            VALUES ('COLUMNSTORE', N'(step failed)', 'FAILED', ERROR_NUMBER(), ERROR_MESSAGE(), GETDATE());

        END CATCH

        -- Step summary
        SELECT @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | COLUMNSTORE | Step finished in ',
                                  DATEDIFF(SECOND, @StepStart, GETDATE()), N' sec | ',
                                  ISNULL(SUM(CASE WHEN Status IN ('SUCCESS', 'WHATIF') THEN 1 ELSE 0 END), 0), N' done, ',
                                  ISNULL(SUM(CASE WHEN Status = 'FAILED'  THEN 1 ELSE 0 END), 0), N' failed, ',
                                  ISNULL(SUM(CASE WHEN Status = 'SKIPPED' THEN 1 ELSE 0 END), 0), N' skipped'), 2047)
        FROM #Results
        WHERE Step = 'COLUMNSTORE';
        RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;
    END


    /* =========================================================================
       4. HEAPS (tables with no clustered index)
          Forwarded records make every scan do extra random reads.
          Note: ALTER TABLE ... REBUILD also rebuilds the table's nonclustered
          indexes. The SAMPLED scan below reads real pages on large heaps.
       ========================================================================= */
    IF @DoHeaps = 1
    BEGIN
        SET @StepStart = GETDATE();
        SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | HEAP | Step started'), 2047);
        RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;

        BEGIN TRY

            SET @PhaseStart = GETDATE();
            DROP TABLE IF EXISTS #HeapList;
            DROP TABLE IF EXISTS #Heap;

            -- Materialize the heap list FIRST. If the DMF below is cross-applied
            -- straight against sys.indexes, the optimizer is free to call it for
            -- tables before the index_id = 0 filter is applied, which raises
            -- error 2591 on any table that has a clustered index.
            -- Uses cheap partition stats to drop small heaps before the
            -- (more expensive) SAMPLED scan.
            SELECT
                 o.object_id
                ,SchemaName = s.name
                ,TableName  = o.name
            INTO #HeapList
            FROM sys.objects AS o
            JOIN sys.schemas AS s ON s.schema_id = o.schema_id
            JOIN sys.indexes AS i ON i.object_id = o.object_id AND i.index_id = 0
            WHERE o.type = 'U'
              AND o.is_ms_shipped = 0
              AND (SELECT SUM(ps.in_row_data_page_count)
                   FROM sys.dm_db_partition_stats AS ps
                   WHERE ps.object_id = o.object_id AND ps.index_id = 0) >= @MinPageCount;

            SELECT @Rows = COUNT(*) FROM #HeapList;
            SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | HEAP | ', @Rows, N' heap(s) over ', @MinPageCount, N' pages to scan'), 2047);
            RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;

            SELECT
                 hl.SchemaName
                ,hl.TableName
                ,ForwardedPct = ps.forwarded_record_count * 100.0 / NULLIF(ps.record_count, 0)
                ,PageCount    = ps.page_count
            INTO #Heap
            FROM #HeapList AS hl
            CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(), hl.object_id, 0, NULL, 'SAMPLED') AS ps
            WHERE ps.alloc_unit_type_desc = 'IN_ROW_DATA'
              AND ps.page_count >= @MinPageCount
              AND ps.forwarded_record_count * 100.0 / NULLIF(ps.record_count, 0) >= @HeapForwardedPct;

            SELECT @Rows = COUNT(*) FROM #Heap;
            SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | HEAP | Forwarded-record scan finished in ', DATEDIFF(SECOND, @PhaseStart, GETDATE()), N' sec | ', @Rows, N' candidate(s)'), 2047);
            RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;

            DECLARE curHeap CURSOR LOCAL FAST_FORWARD FOR
                SELECT SchemaName, TableName,
                       CONCAT('Forwarded ', CAST(ForwardedPct AS decimal(5,1)), '% | ', PageCount, ' pages')
                FROM #Heap
                ORDER BY ForwardedPct DESC;

            OPEN curHeap;

            WHILE 1 = 1
            BEGIN
                FETCH NEXT FROM curHeap INTO @Schema, @Table, @Detail;
                IF @@FETCH_STATUS <> 0 BREAK;

                SET @ObjectName = QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table);

                SET @SQL =
                      N'ALTER TABLE ' + @ObjectName
                    + N' REBUILD WITH (MAXDOP = ' + CAST(@MaxDOP AS nvarchar(10))
                    + CASE WHEN @Online = 1 THEN N', ONLINE = ON' ELSE N'' END
                    + N');';

                SELECT @LogUsedPct = used_log_space_in_percent FROM sys.dm_db_log_space_usage;
                IF @LogUsedPct >= @MaxLogUsedPct AND @WhatIf = 0
                BEGIN
                    CHECKPOINT;
                    SELECT @LogUsedPct = used_log_space_in_percent FROM sys.dm_db_log_space_usage;
                END

                SET @SkipReason = CASE
                                    WHEN GETDATE() >= @StopAt             THEN N'Runtime limit reached'
                                    WHEN @LogUsedPct >= @MaxLogUsedPct    THEN CONCAT(N'Log ', CAST(@LogUsedPct AS decimal(5,1)), N'% used')
                                  END;

                IF @SkipReason IS NOT NULL
                BEGIN
                    INSERT INTO #Results (Step, ObjectName, IndexType, Detail, Command, Status, ErrorMessage)
                    VALUES ('HEAP', @ObjectName, 'Heap', @Detail, @SQL, 'SKIPPED', @SkipReason);
                    CONTINUE;
                END

                SET @ObjStart = GETDATE();
                IF @WhatIf = 0
                BEGIN
                    SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | HEAP |   running: ', @SQL), 2047);
                    RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;
                END

                BEGIN TRY

                    IF @WhatIf = 0
                        EXEC sys.sp_executesql @SQL;

                    INSERT INTO #Results (Step, ObjectName, IndexType, Detail, Command, Status, StartTime, EndTime)
                    VALUES ('HEAP', @ObjectName, 'Heap', @Detail, @SQL, CASE WHEN @WhatIf = 1 THEN 'WHATIF' ELSE 'SUCCESS' END, @ObjStart, GETDATE());

                END TRY
                BEGIN CATCH

                    SET @ErrorCount += 1;

                    INSERT INTO #Results (Step, ObjectName, IndexType, Detail, Command, Status, ErrorNumber, ErrorMessage, StartTime, EndTime)
                    VALUES ('HEAP', @ObjectName, 'Heap', @Detail, @SQL, 'FAILED', ERROR_NUMBER(), ERROR_MESSAGE(), @ObjStart, GETDATE());

                END CATCH

                -- Per-object result and duration
                SELECT TOP (1) @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | HEAP |   ', Status, N' in ',
                                                  DATEDIFF(SECOND, @ObjStart, GETDATE()), N' sec | ', ObjectName), 2047)
                FROM #Results
                ORDER BY ResultID DESC;
                RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;
            END

            CLOSE curHeap;
            DEALLOCATE curHeap;

        END TRY
        BEGIN CATCH

            SET @ErrorCount += 1;

            INSERT INTO #Results (Step, ObjectName, Status, ErrorNumber, ErrorMessage, EndTime)
            VALUES ('HEAP', N'(step failed)', 'FAILED', ERROR_NUMBER(), ERROR_MESSAGE(), GETDATE());

        END CATCH

        -- Step summary
        SELECT @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | HEAP | Step finished in ',
                                  DATEDIFF(SECOND, @StepStart, GETDATE()), N' sec | ',
                                  ISNULL(SUM(CASE WHEN Status IN ('SUCCESS', 'WHATIF') THEN 1 ELSE 0 END), 0), N' done, ',
                                  ISNULL(SUM(CASE WHEN Status = 'FAILED'  THEN 1 ELSE 0 END), 0), N' failed, ',
                                  ISNULL(SUM(CASE WHEN Status = 'SKIPPED' THEN 1 ELSE 0 END), 0), N' skipped'), 2047)
        FROM #Results
        WHERE Step = 'HEAP';
        RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;
    END


    /* =========================================================================
       5. STATISTICS
          Runs after index work. REBUILD already refreshes that index's stats
          with a full scan (those are skipped via last_updated >= @RunStart);
          REORGANIZE does not, so those get picked up here.
          Threshold: @StatsModifiedPct of rows changed, OR the SQRT(1000 * rows)
          rule SQL Server's own auto-update uses, whichever comes first.
          Note: in a dry run, stats on indexes that WOULD have been rebuilt
          still show here, since nothing was actually rebuilt.
       ========================================================================= */
    IF @DoStatistics = 1
    BEGIN
        SET @StepStart = GETDATE();
        SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | STATS | Step started'), 2047);
        RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;

        BEGIN TRY

            SET @PhaseStart = GETDATE();
            DROP TABLE IF EXISTS #Stats;

            SELECT
                 SchemaName = s.name
                ,TableName  = o.name
                ,StatName   = st.name
                ,TableRows  = sp.rows
                ,ModCount   = sp.modification_counter
            INTO #Stats
            FROM sys.stats AS st
            JOIN sys.objects AS o ON o.object_id = st.object_id
            JOIN sys.schemas AS s ON s.schema_id = o.schema_id
            CROSS APPLY sys.dm_db_stats_properties(st.object_id, st.stats_id) AS sp
            WHERE o.type = 'U'
              AND o.is_ms_shipped = 0
              AND sp.modification_counter > 0
              AND (sp.last_updated IS NULL OR sp.last_updated < @RunStart)
              AND (
                       sp.modification_counter * 100.0 / NULLIF(sp.rows, 0) >= @StatsModifiedPct
                    OR sp.modification_counter >= SQRT(1000.0 * sp.rows)
                  );

            SELECT @Rows = COUNT(*) FROM #Stats;
            SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | STATS | Statistics check finished in ', DATEDIFF(SECOND, @PhaseStart, GETDATE()), N' sec | ', @Rows, N' candidate(s)'), 2047);
            RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;

            DECLARE curStats CURSOR LOCAL FAST_FORWARD FOR
                SELECT SchemaName, TableName, StatName, TableRows,
                       CONCAT(TableRows, ' rows | ', ModCount, ' modified (',
                              CAST(ModCount * 100.0 / NULLIF(TableRows, 0) AS decimal(18,1)), '%)')
                FROM #Stats
                ORDER BY ModCount DESC;

            OPEN curStats;

            WHILE 1 = 1
            BEGIN
                FETCH NEXT FROM curStats INTO @Schema, @Table, @Stat, @RowCount, @Detail;
                IF @@FETCH_STATUS <> 0 BREAK;

                SET @ObjectName = QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table) + N'.' + QUOTENAME(@Stat);

                SET @SQL =
                      N'UPDATE STATISTICS ' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table)
                    + N' ' + QUOTENAME(@Stat)
                    + CASE WHEN @RowCount <= @StatsFullScanMaxRows THEN N' WITH FULLSCAN' ELSE N'' END
                    + N';';

                IF GETDATE() >= @StopAt
                BEGIN
                    INSERT INTO #Results (Step, ObjectName, IndexType, Detail, Command, Status, ErrorMessage)
                    VALUES ('STATS', @ObjectName, NULL, @Detail, @SQL, 'SKIPPED', N'Runtime limit reached');
                    CONTINUE;
                END

                SET @ObjStart = GETDATE();
                IF @WhatIf = 0
                BEGIN
                    SET @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | STATS |   running: ', @SQL), 2047);
                    RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;
                END

                BEGIN TRY

                    IF @WhatIf = 0
                        EXEC sys.sp_executesql @SQL;

                    INSERT INTO #Results (Step, ObjectName, IndexType, Detail, Command, Status, StartTime, EndTime)
                    VALUES ('STATS', @ObjectName, NULL, @Detail, @SQL, CASE WHEN @WhatIf = 1 THEN 'WHATIF' ELSE 'SUCCESS' END, @ObjStart, GETDATE());

                END TRY
                BEGIN CATCH

                    SET @ErrorCount += 1;

                    INSERT INTO #Results (Step, ObjectName, IndexType, Detail, Command, Status, ErrorNumber, ErrorMessage, StartTime, EndTime)
                    VALUES ('STATS', @ObjectName, NULL, @Detail, @SQL, 'FAILED', ERROR_NUMBER(), ERROR_MESSAGE(), @ObjStart, GETDATE());

                END CATCH

                -- Per-object result and duration
                SELECT TOP (1) @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | STATS |   ', Status, N' in ',
                                                  DATEDIFF(SECOND, @ObjStart, GETDATE()), N' sec | ', ObjectName), 2047)
                FROM #Results
                ORDER BY ResultID DESC;
                RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;
            END

            CLOSE curStats;
            DEALLOCATE curStats;

        END TRY
        BEGIN CATCH

            SET @ErrorCount += 1;

            INSERT INTO #Results (Step, ObjectName, Status, ErrorNumber, ErrorMessage, EndTime)
            VALUES ('STATS', N'(step failed)', 'FAILED', ERROR_NUMBER(), ERROR_MESSAGE(), GETDATE());

        END CATCH

        -- Step summary
        SELECT @Msg = LEFT(CONCAT(CONVERT(char(8), GETDATE(), 108), N' | STATS | Step finished in ',
                                  DATEDIFF(SECOND, @StepStart, GETDATE()), N' sec | ',
                                  ISNULL(SUM(CASE WHEN Status IN ('SUCCESS', 'WHATIF') THEN 1 ELSE 0 END), 0), N' done, ',
                                  ISNULL(SUM(CASE WHEN Status = 'FAILED'  THEN 1 ELSE 0 END), 0), N' failed, ',
                                  ISNULL(SUM(CASE WHEN Status = 'SKIPPED' THEN 1 ELSE 0 END), 0), N' skipped'), 2047)
        FROM #Results
        WHERE Step = 'STATS';
        RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;
    END


    /* =========================================================================
       RESULTS
       ========================================================================= */
    -- 1. Every object touched, skipped, or failed
    SELECT ResultID, Step, ObjectName, IndexType, Detail, Status, Command, ErrorNumber, ErrorMessage,
           StartTime, EndTime, DurationSec = DATEDIFF(SECOND, StartTime, EndTime)
    FROM #Results
    ORDER BY ResultID;

    -- 2. Summary per step
    SELECT Step, Status, ObjectCount = COUNT(*),
           TotalDurationSec = SUM(ISNULL(DATEDIFF(SECOND, StartTime, EndTime), 0))
    FROM #Results
    GROUP BY Step, Status
    ORDER BY MIN(ResultID), Status;

    SET @Msg = CONCAT(CONVERT(char(8), GETDATE(), 108), N' | RUN | Maintenance finished',
                      CASE WHEN @WhatIf = 1 THEN N' (WhatIf)' ELSE N'' END,
                      N' in ', DATEDIFF(SECOND, @RunStart, GETDATE()), N' sec | Errors: ', @ErrorCount);
    RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;

    -- Fail the job if anything failed, so Agent alerts fire.
    -- Each failure is printed first so it shows in the Messages tab and job history.
    IF @ErrorCount > 0
    BEGIN
        DECLARE @FailID int = 0;

        WHILE 1 = 1
        BEGIN
            SELECT TOP (1)
                 @FailID = ResultID
                ,@Msg    = LEFT(CONCAT(N'FAILED | ', Step, N' | ', ObjectName,
                                       N' | Error ', ErrorNumber, N': ', ErrorMessage), 2047)
            FROM #Results
            WHERE Status = 'FAILED' AND ResultID > @FailID
            ORDER BY ResultID;

            IF @@ROWCOUNT = 0 BREAK;
            RAISERROR('%s', 0, 1, @Msg) WITH NOWAIT;
        END

        SET @Msg = CONCAT(N'dbo.spDatabaseMaintenance finished with ', @ErrorCount,
                          N' error(s). Details are in the FAILED lines above.');
        THROW 50001, @Msg, 1;
    END
END
GO
