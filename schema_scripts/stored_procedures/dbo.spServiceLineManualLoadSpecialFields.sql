create procedure spServiceLineManualLoadSpecialFields as

-- update case adj:

update dim.ServiceLines
set ServiceLineCaseAdjustment = 1

update dim.ServiceLines
	set ServiceLineCaseAdjustment = 16
where ServiceLineGroupID = '0~3'

-- update scheddaysout:

update 
dim.ServiceLines
	set ServiceLineAvgDaysScheduledOut = 6
where ServiceLineName in ('Eyes', 'Gastro', 'Gynecology', 'Ortho')


update 
dim.ServiceLines
	set ServiceLineAvgDaysScheduledOut = 3
where ServiceLineName in ('Pain')

update 
dim.ServiceLines
	set ServiceLineAvgDaysScheduledOut = 5
where ServiceLineName in ('General')

update 
dim.ServiceLines
	set ServiceLineAvgDaysScheduledOut = 8
where ServiceLineName in ('ENT', 'Urology')


update 
dim.ServiceLines
	set ServiceLineAvgDaysScheduledOut = 9
where ServiceLineName in ('Spine')


select * from dim.ServiceLines
GO
