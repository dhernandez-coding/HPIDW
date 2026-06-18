create VIEW [dbo].[zzMIGRATE_dimPractices] as

/*Practice Tables in all DBs*/

--select * from dim.Practices p --where p.PracticeName like '%OKC ORTHOPEDICS%'
--select * from dim.zTEST_Practices  --Currently used in fact.vEpicReferrals (spHPIReloadDimPracticesFull,vEpicReferrals --> vEpicReferralProviders, vUSPI_DIM_physician_referral)
--select * from hpi_etl.dbo.nPractices
--


/* Practices Migration from DW/HPIAPP to HERO Notes...
1. Disregard dim.zzPractices
2. 

--Next Steps...
1. Create a final list of practices in HERO from consolidated dim.Practices + dim.zTEST_Practices (exc. Test records) ...from dim.zMIGRATE_Practices
2. Load into HERO
3. Create a bridge view that says old dim.Practices ID + new PracticeID
4. Replace all instances of dim.Practices.PracticeID with hpi_etl.dbo.nPractices.PracticeID (Pending decision on all downstream effects)

*/

select 'HPIDW' as 'Source',
	  [PracticeID]
      ,[PracticeDataSourceID]
      ,[PracticeSourceID]
      ,[PracticeName]
      ,[PracticeAbbreviation]
      ,[PracticeDataSource]
      ,[PracticeCompany]
      ,[PracticeIsActive]
      ,[PracticeIsSameStore]
      ,[PracticeUpdatedDatetime]
      ,[PracticeGLLocationID]
      ,[PracticeGLLocation]
      ,[PracticeGLPracticeID]
      ,[PracticeSpecialty]
      ,[PracticeSameStoreDate]
from hpidw.dim.Practices p

UNION ALL

select 'HPIAPP' as 'Source',
	p.[PracticeID]
      ,p.[PracticeDataSourceID]
      ,p.[PracticeSourceID]
      ,p.[PracticeName]
      ,p.[PracticeAbbreviation]
      ,p.[PracticeDataSource]
      ,p.[PracticeCompany]
      ,p.[PracticeIsActive]
      ,p.[PracticeIsSameStore]
      ,p.[PracticeUpdatedDatetime]
      ,p.[PracticeGLLocationID]
      ,p.[PracticeGLLocation]
      ,p.[PracticeGLPracticeID]
      ,p.[PracticeSpecialty]
      ,NULL as PracticeSameStoreDate
from hpidw.dim.zTEST_Practices p
 LEFT JOIN hpidw.dim.Practices zp ON zp.PracticeID = p.PracticeSourceID
where zp.PracticeID is null
	and p.PracticeName not like '%test%'
	and p.PracticeSourceID <> '0'
	and p.PracticeName not like 'Destin%'


/*
--All references to PracticeID in tables that will need to be handled
select heroid,* from hpi_etl.dbo.nPractices p where p.PracticeID = '0~ACC'
select * from dim.practices p where p.PracticeID = '0~ACC' -- <--replaced with 0~321 from HeroID
select * from map.PracticeDepartments p where p.PracticeID = '0~ACC'
select * from map.PracticeLocations p where p.PracticeID = '0~ACC'
select * from map.PracticeProviders p where p.PracticeID = '0~ACC'

select * from rpt.BlueBooks p where p.PracticeID = '0~ACC'
select * from rpt.MetricValues p where p.PracticeID = '0~ACC'
select * from rpt.PBPaymentLag p where p.PracticeID = '0~ACC'
select * from rpt.spSelectCollectionsForecastBCBS p where p.PracticeID = '0~ACC'
*/




/*In zTEST_Practices not currently in HERO
select
	p.PracticeID
	,p.PracticeName
	,zp.PracticeID 
	,zp.PracticeName
from hpidw.dim.zTEST_Practices p
 LEFT JOIN hpi_etl.dbo.nPractices zp ON zp.PracticeID = p.PracticeSourceID
where zp.PracticeID is null
order by zp.PracticeID asc
*/

/*--Look for all references of dim.Practices

-- ============================================================
-- Find all Views and Stored Procedures referencing a table/column
-- ============================================================

DECLARE @TableName  NVARCHAR(128) = 'Practices';   -- Set table name (or NULL for any)
DECLARE @ColumnName NVARCHAR(128) = '';  -- Set column name (or NULL for any)

SELECT
    obj.type_desc                        AS object_type,
    SCHEMA_NAME(obj.schema_id)           AS schema_name,
    obj.name                             AS object_name,
    m.definition                         AS object_definition
FROM sys.objects obj
JOIN sys.sql_modules m ON obj.object_id = m.object_id
WHERE obj.type IN ('V', 'P')   -- V = View, P = Stored Procedure
  AND (
        @TableName IS NULL
        OR m.definition LIKE '%' + @TableName + '%'
      )
  AND (
        @ColumnName IS NULL
        OR m.definition LIKE '%' + @ColumnName + '%'
      )
ORDER BY
    obj.type_desc,
    SCHEMA_NAME(obj.schema_id),
    obj.name;



-- ============================================================
-- Find all Views and Stored Procedures that reference a View
-- ============================================================

DECLARE @ViewName NVARCHAR(128) = 'vEpicReferrals';  -- Set to NULL to find ALL view references

SELECT
    ref.type_desc                           AS referencing_type,
    SCHEMA_NAME(ref.schema_id)              AS referencing_schema,
    ref.name                                AS referencing_object,
    SCHEMA_NAME(dep_view.schema_id)         AS referenced_view_schema,
    dep_view.name                           AS referenced_view,
    m.definition                            AS referencing_definition
FROM sys.sql_expression_dependencies d
JOIN sys.objects ref      ON ref.object_id      = d.referencing_id
JOIN sys.objects dep_view ON dep_view.object_id  = d.referenced_id
JOIN sys.sql_modules m    ON m.object_id         = d.referencing_id
WHERE ref.type   IN ('P', 'V')       -- Referencing object is a Proc or View
  AND dep_view.type = 'V'            -- Referenced object must be a View
  AND (
        @ViewName IS NULL
        OR dep_view.name = @ViewName
      )
ORDER BY
    referenced_view,
    referencing_type,
    referencing_schema,
    referencing_object;


-- ============================================================
-- Find All Tables That Contain a Specific Column
-- ============================================================

DECLARE @ColumnName NVARCHAR(128) = 'PracticeID';  -- Set to NULL for all columns

SELECT
    SCHEMA_NAME(t.schema_id)    AS table_schema,
    t.name                      AS table_name,
    c.name                      AS column_name,
    tp.name                     AS data_type,
    c.max_length                AS max_length,
    c.precision                 AS precision,
    c.scale                     AS scale,
    c.is_nullable               AS is_nullable,
    c.is_identity               AS is_identity,
    c.column_id                 AS column_ordinal
FROM sys.columns c
JOIN sys.tables  t  ON t.object_id  = c.object_id
JOIN sys.types   tp ON tp.user_type_id = c.user_type_id
WHERE t.type = 'U'   -- User-defined tables only
  AND (
        @ColumnName IS NULL
        OR c.name = @ColumnName          -- exact match
        -- OR c.name LIKE '%' + @ColumnName + '%'  -- uncomment for partial match
      )
ORDER BY
    table_schema,
    table_name,
    c.column_id;

*/


--select * from dim.zzMIGRATE_Practices p group by PracticeCompany
GO
