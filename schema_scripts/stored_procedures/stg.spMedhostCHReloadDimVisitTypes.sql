Create Procedure stg.spMedhostCHReloadDimVisitTypes
as

DELETE FROM dim.VisitTypes WHERE VisitTypeDataSourceID = 8

INSERT INTO dim.VisitTypes

select
	  CONCAT('8~', SVCODE) VisitTypeID
	 ,8 VisitTypeDataSourceID
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
	from MHD32.HOSPF110.MRSERV svc
	--where 1=1
	--fetch first 1000 rows only
	') v
GO
