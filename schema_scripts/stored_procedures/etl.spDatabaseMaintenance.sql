CREATE   PROCEDURE etl.spDatabaseMaintenance
     @DatasourceID           int    = NULL
    ,@DoIntegrityCheck       bit    = 0
    ,@PhysicalOnly           bit    = 0        -- faster CHECKDB, fewer logical checks
    ,@DoIndexes              bit    = 1
    ,@DoColumnstore          bit    = 1
    ,@DoHeaps                bit    = 1
    ,@DoStatistics           bit    = 1
    ,@DoLogCleanup           bit    = 1
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
    ,@LogRetentionDays       int    = 90
    ,@WhatIf                 bit    = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
         @RunStart     datetime = GETDATE()
        ,@StopAt       datetime = DATEADD(MINUTE, @MaxRuntimeMinutes, GETDATE())
        ,@StartDate    datetime
        ,@ObjStart     datetime
        ,@SQL          nvarchar(max)
        ,@Online       bit
        ,@LogUsedPct   float
        ,@ErrorCount   int = 0
        ,@Done         int
        ,@Failed       int
        ,@Skipped      int
        ,@Rows         int
        ,@Total        int
        ,@Schema       sysname
        ,@Table        sysname
        ,@Index        sysname
        ,@Stat         sysname
        ,@PartNo       int
        ,@PartCount    int
        ,@Action       varchar(20)
        ,@RowCount     bigint
        ,@Mode         varchar(20) = CASE WHEN @WhatIf = 1 THEN ' (WhatIf)' ELSE '' END;

    -- ONLINE rebuilds: Enterprise/Developer (3), Azure SQL DB (5), Managed Instance (8)
    SET @Online = CASE WHEN CAST(SERVERPROPERTY('EngineEdition') AS int) IN (3, 5, 8) THEN 1 ELSE 0 END;


    /* =========================================================================
       1. INTEGRITY CHECK
       ========================================================================= */
    IF @DoIntegrityCheck = 1
    BEGIN
        SET @StartDate = GETDATE();

        BEGIN TRY

            IF @WhatIf = 1
                PRINT 'DBCC CHECKDB (0) WITH NO_INFOMSGS, ALL_ERRORMSGS' + CASE WHEN @PhysicalOnly = 1 THEN ', PHYSICAL_ONLY' ELSE '' END + ';';
            ELSE IF @PhysicalOnly = 1
                DBCC CHECKDB (0) WITH NO_INFOMSGS, ALL_ERRORMSGS, PHYSICAL_ONLY;
            ELSE
                DBCC CHECKDB (0) WITH NO_INFOMSGS, ALL_ERRORMSGS;

            INSERT INTO etl.ErrorLogs (
                 ErrorLogDatasourceID
                ,ErrorLogName
                ,ErrorLogCode
                ,ErrorLogSchema
                ,ErrorLogDescription
                ,ErrorLogStartDate
                ,ErrorLogEndDate
            ) VALUES (
                 @DatasourceID
                ,'etl.spDatabaseMaintenance_CHECKDB'
                ,'SUCCESS'
                ,'ALL'
                ,CONCAT('DBCC CHECKDB on ', DB_NAME(), ' completed successfully.', @Mode)
                ,@StartDate
                ,GETDATE()
            );

        END TRY
        BEGIN CATCH

            SET @ErrorCount += 1;

            INSERT INTO etl.ErrorLogs (
                 ErrorLogDatasourceID
                ,ErrorLogName
                ,ErrorLogCode
                ,ErrorLogSchema
                ,ErrorLogDescription
                ,ErrorLogStartDate
                ,ErrorLogEndDate
            ) VALUES (
                 @DatasourceID
                ,'etl.spDatabaseMaintenance_CHECKDB'
                ,CAST(ERROR_NUMBER() AS varchar(100))
                ,'ALL'
                ,CONCAT(
                    'Error Line: ',  ERROR_LINE(),
                    ' | Severity: ', ERROR_SEVERITY(),
                    ' | Message: ',  ERROR_MESSAGE()
                 )
                ,@StartDate
                ,GETDATE()
            );

        END CATCH
    END


    /* =========================================================================
       2. ROWSTORE INDEXES (clustered + nonclustered b-trees)
       ========================================================================= */
    IF @DoIndexes = 1
    BEGIN
        SET @StartDate = GETDATE();

        BEGIN TRY

            SELECT @Done = 0, @Failed = 0, @Skipped = 0;

            DROP TABLE IF EXISTS #Idx;

            SELECT
                 SchemaName     = s.name
                ,TableName      = o.name
                ,IndexName      = i.name
                ,PartitionNo    = ps.partition_number
                ,PartitionCount = pc.PartitionCount
                ,FragPct        = ps.avg_fragmentation_in_percent
                ,PageCount      = ps.page_count
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

            DECLARE curIdx CURSOR LOCAL FAST_FORWARD FOR
                SELECT SchemaName, TableName, IndexName, PartitionNo, PartitionCount, IndexAction
                FROM #Idx
                ORDER BY FragPct * PageCount DESC;   -- most impactful first

            OPEN curIdx;

            WHILE 1 = 1
            BEGIN
                FETCH NEXT FROM curIdx INTO @Schema, @Table, @Index, @PartNo, @PartCount, @Action;
                IF @@FETCH_STATUS <> 0 BREAK;

                -- Guard rails: runtime window and transaction log headroom
                SELECT @LogUsedPct = used_log_space_in_percent FROM sys.dm_db_log_space_usage;
                IF @LogUsedPct >= @MaxLogUsedPct
                BEGIN
                    CHECKPOINT;  -- frees log in SIMPLE recovery
                    SELECT @LogUsedPct = used_log_space_in_percent FROM sys.dm_db_log_space_usage;
                END

                IF GETDATE() >= @StopAt OR @LogUsedPct >= @MaxLogUsedPct
                BEGIN
                    SET @Skipped += 1;
                    CONTINUE;
                END

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

                SET @ObjStart = GETDATE();

                BEGIN TRY

                    IF @WhatIf = 1 PRINT @SQL;
                    ELSE EXEC sys.sp_executesql @SQL;

                    SET @Done += 1;

                END TRY
                BEGIN CATCH

                    SET @Failed += 1;
                    SET @ErrorCount += 1;

                    INSERT INTO etl.ErrorLogs (
                         ErrorLogDatasourceID
                        ,ErrorLogName
                        ,ErrorLogCode
                        ,ErrorLogSchema
                        ,ErrorLogDescription
                        ,ErrorLogStartDate
                        ,ErrorLogEndDate
                    ) VALUES (
                         @DatasourceID
                        ,'etl.spDatabaseMaintenance_INDEX'
                        ,CAST(ERROR_NUMBER() AS varchar(100))
                        ,@Schema
                        ,CONCAT(
                            'Command: ',     @SQL,
                            ' | Error Line: ',  ERROR_LINE(),
                            ' | Severity: ', ERROR_SEVERITY(),
                            ' | Message: ',  ERROR_MESSAGE()
                         )
                        ,@ObjStart
                        ,GETDATE()
                    );

                END CATCH
            END

            CLOSE curIdx;
            DEALLOCATE curIdx;

            INSERT INTO etl.ErrorLogs (
                 ErrorLogDatasourceID
                ,ErrorLogName
                ,ErrorLogCode
                ,ErrorLogSchema
                ,ErrorLogDescription
                ,ErrorLogStartDate
                ,ErrorLogEndDate
            ) VALUES (
                 @DatasourceID
                ,'etl.spDatabaseMaintenance_INDEX'
                ,'SUCCESS'
                ,'ALL'
                ,CONCAT('Rowstore index maintenance completed successfully.', @Mode,
                        ' Processed: ', @Done, ' | Failed: ', @Failed,
                        ' | Skipped (time/log limit): ', @Skipped)
                ,@StartDate
                ,GETDATE()
            );

        END TRY
        BEGIN CATCH

            SET @ErrorCount += 1;

            INSERT INTO etl.ErrorLogs (
                 ErrorLogDatasourceID
                ,ErrorLogName
                ,ErrorLogCode
                ,ErrorLogSchema
                ,ErrorLogDescription
                ,ErrorLogStartDate
                ,ErrorLogEndDate
            ) VALUES (
                 @DatasourceID
                ,'etl.spDatabaseMaintenance_INDEX'
                ,CAST(ERROR_NUMBER() AS varchar(100))
                ,'ALL'
                ,CONCAT(
                    'Error Line: ',  ERROR_LINE(),
                    ' | Severity: ', ERROR_SEVERITY(),
                    ' | Message: ',  ERROR_MESSAGE()
                 )
                ,@StartDate
                ,GETDATE()
            );

        END CATCH
    END


    /* =========================================================================
       3. COLUMNSTORE INDEXES
          REORGANIZE compresses CLOSED delta rowgroups and cleans up deleted
          rows. OPEN delta stores are left alone on purpose: forcing them
          closed creates small, inefficient rowgroups.
       ========================================================================= */
    IF @DoColumnstore = 1
    BEGIN
        SET @StartDate = GETDATE();

        BEGIN TRY

            SELECT @Done = 0, @Failed = 0, @Skipped = 0;

            DROP TABLE IF EXISTS #Cs;

            SELECT
                 SchemaName     = s.name
                ,TableName      = o.name
                ,IndexName      = i.name
                ,PartitionNo    = rg.partition_number
                ,PartitionCount = pc.PartitionCount
                ,DeletedPct     = SUM(rg.deleted_rows) * 100.0 / NULLIF(SUM(rg.total_rows), 0)
                ,ClosedGroups   = SUM(CASE WHEN rg.state_desc = 'CLOSED' THEN 1 ELSE 0 END)
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
            GROUP BY s.name, o.name, i.name, rg.partition_number, pc.PartitionCount
            HAVING SUM(rg.deleted_rows) * 100.0 / NULLIF(SUM(rg.total_rows), 0) >= @ColumnstoreDeletedPct
                OR SUM(CASE WHEN rg.state_desc = 'CLOSED' THEN 1 ELSE 0 END) > 0;

            DECLARE curCs CURSOR LOCAL FAST_FORWARD FOR
                SELECT SchemaName, TableName, IndexName, PartitionNo, PartitionCount
                FROM #Cs
                ORDER BY DeletedPct DESC;

            OPEN curCs;

            WHILE 1 = 1
            BEGIN
                FETCH NEXT FROM curCs INTO @Schema, @Table, @Index, @PartNo, @PartCount;
                IF @@FETCH_STATUS <> 0 BREAK;

                IF GETDATE() >= @StopAt
                BEGIN
                    SET @Skipped += 1;
                    CONTINUE;
                END

                SET @SQL =
                      N'ALTER INDEX ' + QUOTENAME(@Index)
                    + N' ON ' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table)
                    + N' REORGANIZE'
                    + CASE WHEN @PartCount > 1 THEN N' PARTITION = ' + CAST(@PartNo AS nvarchar(10)) ELSE N'' END
                    + N';';

                SET @ObjStart = GETDATE();

                BEGIN TRY

                    IF @WhatIf = 1 PRINT @SQL;
                    ELSE EXEC sys.sp_executesql @SQL;

                    SET @Done += 1;

                END TRY
                BEGIN CATCH

                    SET @Failed += 1;
                    SET @ErrorCount += 1;

                    INSERT INTO etl.ErrorLogs (
                         ErrorLogDatasourceID
                        ,ErrorLogName
                        ,ErrorLogCode
                        ,ErrorLogSchema
                        ,ErrorLogDescription
                        ,ErrorLogStartDate
                        ,ErrorLogEndDate
                    ) VALUES (
                         @DatasourceID
                        ,'etl.spDatabaseMaintenance_COLUMNSTORE'
                        ,CAST(ERROR_NUMBER() AS varchar(100))
                        ,@Schema
                        ,CONCAT(
                            'Command: ',     @SQL,
                            ' | Error Line: ',  ERROR_LINE(),
                            ' | Severity: ', ERROR_SEVERITY(),
                            ' | Message: ',  ERROR_MESSAGE()
                         )
                        ,@ObjStart
                        ,GETDATE()
                    );

                END CATCH
            END

            CLOSE curCs;
            DEALLOCATE curCs;

            INSERT INTO etl.ErrorLogs (
                 ErrorLogDatasourceID
                ,ErrorLogName
                ,ErrorLogCode
                ,ErrorLogSchema
                ,ErrorLogDescription
                ,ErrorLogStartDate
                ,ErrorLogEndDate
            ) VALUES (
                 @DatasourceID
                ,'etl.spDatabaseMaintenance_COLUMNSTORE'
                ,'SUCCESS'
                ,'ALL'
                ,CONCAT('Columnstore maintenance completed successfully.', @Mode,
                        ' Processed: ', @Done, ' | Failed: ', @Failed,
                        ' | Skipped (time limit): ', @Skipped)
                ,@StartDate
                ,GETDATE()
            );

        END TRY
        BEGIN CATCH

            SET @ErrorCount += 1;

            INSERT INTO etl.ErrorLogs (
                 ErrorLogDatasourceID
                ,ErrorLogName
                ,ErrorLogCode
                ,ErrorLogSchema
                ,ErrorLogDescription
                ,ErrorLogStartDate
                ,ErrorLogEndDate
            ) VALUES (
                 @DatasourceID
                ,'etl.spDatabaseMaintenance_COLUMNSTORE'
                ,CAST(ERROR_NUMBER() AS varchar(100))
                ,'ALL'
                ,CONCAT(
                    'Error Line: ',  ERROR_LINE(),
                    ' | Severity: ', ERROR_SEVERITY(),
                    ' | Message: ',  ERROR_MESSAGE()
                 )
                ,@StartDate
                ,GETDATE()
            );

        END CATCH
    END


    /* =========================================================================
       4. HEAPS (tables with no clustered index)
          Forwarded records make every scan do extra random reads.
          Note: ALTER TABLE ... REBUILD also rebuilds the table's nonclustered
          indexes.
       ========================================================================= */
    IF @DoHeaps = 1
    BEGIN
        SET @StartDate = GETDATE();

        BEGIN TRY

            SELECT @Done = 0, @Failed = 0, @Skipped = 0;

            DROP TABLE IF EXISTS #Heap;

            SELECT
                 SchemaName   = s.name
                ,TableName    = o.name
                ,ForwardedPct = ps.forwarded_record_count * 100.0 / NULLIF(ps.record_count, 0)
            INTO #Heap
            FROM sys.objects AS o
            JOIN sys.schemas AS s ON s.schema_id = o.schema_id
            JOIN sys.indexes AS i ON i.object_id = o.object_id AND i.index_id = 0
            CROSS APPLY sys.dm_db_index_physical_stats(DB_ID(), o.object_id, 0, NULL, 'SAMPLED') AS ps
            WHERE o.type = 'U'
              AND o.is_ms_shipped = 0
              AND ps.alloc_unit_type_desc = 'IN_ROW_DATA'
              AND ps.page_count >= @MinPageCount
              AND ps.forwarded_record_count * 100.0 / NULLIF(ps.record_count, 0) >= @HeapForwardedPct;

            DECLARE curHeap CURSOR LOCAL FAST_FORWARD FOR
                SELECT SchemaName, TableName
                FROM #Heap
                ORDER BY ForwardedPct DESC;

            OPEN curHeap;

            WHILE 1 = 1
            BEGIN
                FETCH NEXT FROM curHeap INTO @Schema, @Table;
                IF @@FETCH_STATUS <> 0 BREAK;

                SELECT @LogUsedPct = used_log_space_in_percent FROM sys.dm_db_log_space_usage;
                IF @LogUsedPct >= @MaxLogUsedPct
                BEGIN
                    CHECKPOINT;
                    SELECT @LogUsedPct = used_log_space_in_percent FROM sys.dm_db_log_space_usage;
                END

                IF GETDATE() >= @StopAt OR @LogUsedPct >= @MaxLogUsedPct
                BEGIN
                    SET @Skipped += 1;
                    CONTINUE;
                END

                SET @SQL =
                      N'ALTER TABLE ' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table)
                    + N' REBUILD WITH (MAXDOP = ' + CAST(@MaxDOP AS nvarchar(10))
                    + CASE WHEN @Online = 1 THEN N', ONLINE = ON' ELSE N'' END
                    + N');';

                SET @ObjStart = GETDATE();

                BEGIN TRY

                    IF @WhatIf = 1 PRINT @SQL;
                    ELSE EXEC sys.sp_executesql @SQL;

                    SET @Done += 1;

                END TRY
                BEGIN CATCH

                    SET @Failed += 1;
                    SET @ErrorCount += 1;

                    INSERT INTO etl.ErrorLogs (
                         ErrorLogDatasourceID
                        ,ErrorLogName
                        ,ErrorLogCode
                        ,ErrorLogSchema
                        ,ErrorLogDescription
                        ,ErrorLogStartDate
                        ,ErrorLogEndDate
                    ) VALUES (
                         @DatasourceID
                        ,'etl.spDatabaseMaintenance_HEAP'
                        ,CAST(ERROR_NUMBER() AS varchar(100))
                        ,@Schema
                        ,CONCAT(
                            'Command: ',     @SQL,
                            ' | Error Line: ',  ERROR_LINE(),
                            ' | Severity: ', ERROR_SEVERITY(),
                            ' | Message: ',  ERROR_MESSAGE()
                         )
                        ,@ObjStart
                        ,GETDATE()
                    );

                END CATCH
            END

            CLOSE curHeap;
            DEALLOCATE curHeap;

            INSERT INTO etl.ErrorLogs (
                 ErrorLogDatasourceID
                ,ErrorLogName
                ,ErrorLogCode
                ,ErrorLogSchema
                ,ErrorLogDescription
                ,ErrorLogStartDate
                ,ErrorLogEndDate
            ) VALUES (
                 @DatasourceID
                ,'etl.spDatabaseMaintenance_HEAP'
                ,'SUCCESS'
                ,'ALL'
                ,CONCAT('Heap maintenance completed successfully.', @Mode,
                        ' Processed: ', @Done, ' | Failed: ', @Failed,
                        ' | Skipped (time/log limit): ', @Skipped)
                ,@StartDate
                ,GETDATE()
            );

        END TRY
        BEGIN CATCH

            SET @ErrorCount += 1;

            INSERT INTO etl.ErrorLogs (
                 ErrorLogDatasourceID
                ,ErrorLogName
                ,ErrorLogCode
                ,ErrorLogSchema
                ,ErrorLogDescription
                ,ErrorLogStartDate
                ,ErrorLogEndDate
            ) VALUES (
                 @DatasourceID
                ,'etl.spDatabaseMaintenance_HEAP'
                ,CAST(ERROR_NUMBER() AS varchar(100))
                ,'ALL'
                ,CONCAT(
                    'Error Line: ',  ERROR_LINE(),
                    ' | Severity: ', ERROR_SEVERITY(),
                    ' | Message: ',  ERROR_MESSAGE()
                 )
                ,@StartDate
                ,GETDATE()
            );

        END CATCH
    END


    /* =========================================================================
       5. STATISTICS
          Runs after index work. REBUILD already refreshes that index's stats
          with a full scan (those are skipped via last_updated >= @RunStart);
          REORGANIZE does not, so those get picked up here.
          Threshold: @StatsModifiedPct of rows changed, OR the SQRT(1000 * rows)
          rule SQL Server's own auto-update uses, whichever comes first.
       ========================================================================= */
    IF @DoStatistics = 1
    BEGIN
        SET @StartDate = GETDATE();

        BEGIN TRY

            SELECT @Done = 0, @Failed = 0, @Skipped = 0;

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

            DECLARE curStats CURSOR LOCAL FAST_FORWARD FOR
                SELECT SchemaName, TableName, StatName, TableRows
                FROM #Stats
                ORDER BY ModCount DESC;

            OPEN curStats;

            WHILE 1 = 1
            BEGIN
                FETCH NEXT FROM curStats INTO @Schema, @Table, @Stat, @RowCount;
                IF @@FETCH_STATUS <> 0 BREAK;

                IF GETDATE() >= @StopAt
                BEGIN
                    SET @Skipped += 1;
                    CONTINUE;
                END

                SET @SQL =
                      N'UPDATE STATISTICS ' + QUOTENAME(@Schema) + N'.' + QUOTENAME(@Table)
                    + N' ' + QUOTENAME(@Stat)
                    + CASE WHEN @RowCount <= @StatsFullScanMaxRows THEN N' WITH FULLSCAN' ELSE N'' END
                    + N';';

                SET @ObjStart = GETDATE();

                BEGIN TRY

                    IF @WhatIf = 1 PRINT @SQL;
                    ELSE EXEC sys.sp_executesql @SQL;

                    SET @Done += 1;

                END TRY
                BEGIN CATCH

                    SET @Failed += 1;
                    SET @ErrorCount += 1;

                    INSERT INTO etl.ErrorLogs (
                         ErrorLogDatasourceID
                        ,ErrorLogName
                        ,ErrorLogCode
                        ,ErrorLogSchema
                        ,ErrorLogDescription
                        ,ErrorLogStartDate
                        ,ErrorLogEndDate
                    ) VALUES (
                         @DatasourceID
                        ,'etl.spDatabaseMaintenance_STATS'
                        ,CAST(ERROR_NUMBER() AS varchar(100))
                        ,@Schema
                        ,CONCAT(
                            'Command: ',     @SQL,
                            ' | Error Line: ',  ERROR_LINE(),
                            ' | Severity: ', ERROR_SEVERITY(),
                            ' | Message: ',  ERROR_MESSAGE()
                         )
                        ,@ObjStart
                        ,GETDATE()
                    );

                END CATCH
            END

            CLOSE curStats;
            DEALLOCATE curStats;

            INSERT INTO etl.ErrorLogs (
                 ErrorLogDatasourceID
                ,ErrorLogName
                ,ErrorLogCode
                ,ErrorLogSchema
                ,ErrorLogDescription
                ,ErrorLogStartDate
                ,ErrorLogEndDate
            ) VALUES (
                 @DatasourceID
                ,'etl.spDatabaseMaintenance_STATS'
                ,'SUCCESS'
                ,'ALL'
                ,CONCAT('Statistics maintenance completed successfully.', @Mode,
                        ' Updated: ', @Done, ' | Failed: ', @Failed,
                        ' | Skipped (time limit): ', @Skipped)
                ,@StartDate
                ,GETDATE()
            );

        END TRY
        BEGIN CATCH

            SET @ErrorCount += 1;

            INSERT INTO etl.ErrorLogs (
                 ErrorLogDatasourceID
                ,ErrorLogName
                ,ErrorLogCode
                ,ErrorLogSchema
                ,ErrorLogDescription
                ,ErrorLogStartDate
                ,ErrorLogEndDate
            ) VALUES (
                 @DatasourceID
                ,'etl.spDatabaseMaintenance_STATS'
                ,CAST(ERROR_NUMBER() AS varchar(100))
                ,'ALL'
                ,CONCAT(
                    'Error Line: ',  ERROR_LINE(),
                    ' | Severity: ', ERROR_SEVERITY(),
                    ' | Message: ',  ERROR_MESSAGE()
                 )
                ,@StartDate
                ,GETDATE()
            );

        END CATCH
    END


    /* =========================================================================
       6. LOG TABLE CLEANUP
          Deletes in batches so it doesn't bloat the transaction log.
          Set @DoLogCleanup = 0 if you want to keep etl.ErrorLogs history forever.
       ========================================================================= */
    IF @DoLogCleanup = 1 AND @LogRetentionDays IS NOT NULL
    BEGIN
        SET @StartDate = GETDATE();

        BEGIN TRY

            SET @Total = 0;

            IF @WhatIf = 1
                SELECT @Total = COUNT(*)
                FROM etl.ErrorLogs
                WHERE ErrorLogUpdatedDatetime < DATEADD(DAY, -@LogRetentionDays, @RunStart);
            ELSE
            BEGIN
                WHILE 1 = 1
                BEGIN
                    DELETE TOP (5000)
                    FROM etl.ErrorLogs
                    WHERE ErrorLogUpdatedDatetime < DATEADD(DAY, -@LogRetentionDays, @RunStart);

                    SET @Rows = @@ROWCOUNT;
                    SET @Total += @Rows;
                    IF @Rows < 5000 BREAK;
                END
            END

            INSERT INTO etl.ErrorLogs (
                 ErrorLogDatasourceID
                ,ErrorLogName
                ,ErrorLogCode
                ,ErrorLogSchema
                ,ErrorLogDescription
                ,ErrorLogStartDate
                ,ErrorLogEndDate
            ) VALUES (
                 @DatasourceID
                ,'etl.spDatabaseMaintenance_CLEANUP'
                ,'SUCCESS'
                ,'etl'
                ,CONCAT('etl.ErrorLogs cleanup completed successfully.', @Mode,
                        ' Rows older than ', @LogRetentionDays, ' days removed: ', @Total)
                ,@StartDate
                ,GETDATE()
            );

        END TRY
        BEGIN CATCH

            SET @ErrorCount += 1;

            INSERT INTO etl.ErrorLogs (
                 ErrorLogDatasourceID
                ,ErrorLogName
                ,ErrorLogCode
                ,ErrorLogSchema
                ,ErrorLogDescription
                ,ErrorLogStartDate
                ,ErrorLogEndDate
            ) VALUES (
                 @DatasourceID
                ,'etl.spDatabaseMaintenance_CLEANUP'
                ,CAST(ERROR_NUMBER() AS varchar(100))
                ,'etl'
                ,CONCAT(
                    'Error Line: ',  ERROR_LINE(),
                    ' | Severity: ', ERROR_SEVERITY(),
                    ' | Message: ',  ERROR_MESSAGE()
                 )
                ,@StartDate
                ,GETDATE()
            );

        END CATCH
    END


    /* =========================================================================
       Fail the job if anything failed, so Agent alerts fire.
       ========================================================================= */
    IF @ErrorCount > 0
    BEGIN
        DECLARE @FailMsg nvarchar(2048) =
            CONCAT(N'etl.spDatabaseMaintenance finished with ', @ErrorCount,
                   N' error(s). See etl.ErrorLogs where ErrorLogName LIKE ''etl.spDatabaseMaintenance%''.');
        THROW 50001, @FailMsg, 1;
    END
END
GO
