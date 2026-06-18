Create Procedure stg.spMedhostNSReloadDimVisitTypes
as

DELETE FROM dim.VisitTypes WHERE VisitTypeDataSourceID = 2

INSERT INTO dim.VisitTypes

select
	  CONCAT('2~', SVCODE) VisitTypeID
	 ,2 VisitTypeDataSourceID
	 ,SVCODE VisitTypeSourceID
	 ,SVDESC VisitTypeName
	 ,SVHSV VisitTypeAbbreviation
	 ,1 VisitTypeIsActive
	 ,getdate() VisitTypeUpdatedDatetime
  FROM OPENQUERY([hmsls],'
	select
		SVCODE
		,SVDESC
		,SVHSV
	from MHD32.HOSPF100.MRSERV svc
	--where 1=1
	--fetch first 1000 rows only
	') v
GO
