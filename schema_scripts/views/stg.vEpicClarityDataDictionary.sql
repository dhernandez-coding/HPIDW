CREATE view [stg].[vEpicClarityDataDictionary] as 
SELECT 
	A.*
FROM OPENQUERY([CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM],'
SELECT
              T.TABLE_ID as TableID
			  ,T.TABLE_NAME as TableName
              ,CLARITY_TBL_COLS.LINE                                               as Column_Number
              ,T.IS_EXTRACTED_YN as IsExtracted
              ,T.DEPRECATED_YN as IsDeprecated
              ,T.LOAD_FREQUENCY as LoadFrequency
			  ,t.TABLE_INTRODUCTION as TableDescription
              ,CLARITY_COL.COLUMN_NAME
              ,CLARITY_COL_INIITM.COLUMN_INI                                as INI
              ,CLARITY_COL_INIITM.COLUMN_ITEM                               as Item 
              ,CLARITY_COL.DATA_TYPE
              ,Clarity_col.CLARITY_PRECISION
              ,clarity_col.CLARITY_SCALE
              ,Clarity_col.HOUR_FORMAT
              ,CLARITY_COL.DESCRIPTION                                      as ColumnDescription
FROM clarity.[dbo].CLARITY_TBL t
              INNER JOIN clarity.dbo.CLARITY_TBL_COLS ON t.TABLE_ID = CLARITY_TBL_COLS.TABLE_ID
              INNER JOIN clarity.dbo.CLARITY_COL ON CLARITY_TBL_COLS.COLUMN_ID = CLARITY_COL.COLUMN_ID
              LEFT JOIN clarity.dbo.CLARITY_COL_INIITM ON CLARITY_COL.COLUMN_ID = CLARITY_COL_INIITM.COLUMN_ID AND CLARITY_COL_INIITM.LINE=1   
WHERE 1=1
              AND LEFT(t.TABLE_ID,1) = ''C''  --> Custom tables
              --AND t.TABLE_NAME like ''%HSP_ACC%''
			  AND CLARITY_COL.COLUMN_NAME like ''%ROOM%''
			  --AND CLARITY_COL_INIITM.COLUMN_INI = ''ETR''
			  --AND CLARITY_COL_INIITM.COLUMN_ITEM = ''0.10''
ORDER BY
              t.TABLE_NAME
              ,CLARITY_TBL_COLS.LINE
'
) A
GO
