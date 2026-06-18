CREATE procedure [stg].[spAPMReloadFactVisits2Full] as

DELETE FROM fact.Visits2 WHERE VisitDatasourceID = 1

	INSERT INTO fact.Visits2 
	  ([VisitID]
      ,[VisitDatasourceID]
      ,[VisitSourceID]
      ,[VisitPatientID]
      ,[VisitAccountID]
      ,[VisitLocationID]
      ,[VisitDepartmentID]
      ,[VisitRoomID]
      ,[VisitPrimaryProviderID]
      ,[VisitAppointmentProviderID]
      ,[VisitAdmittingProviderID]
      ,[VisitAttendingProviderID]
      ,[VisitDischargeProviderID]
      ,[VisitType]
      ,[VisitService]
      ,[VisitStatus]
      ,[VisitDateOfService]
      ,[VisitDatetimeOfService]
      ,[VisitDateOfScheduling]
      ,[VisitDateOfAppointment]
      ,[VisitDateOfAdmission]
      ,[VisitDateOfDischarge]
      ,[VisitDateofClosing]
      ,[VisitDateOfCancellation]
      ,[VisitCancellationReason]
      ,[VisitIsPrimary]
      ,[VisitIsActive]
      ,[VisitUpdatedDatetime]
	)
select
	concat('1~', v.voucher_number) VisitID
	,1	[VisitDatasourceID]
	,v.voucher_number	[VisitSourceID]
	,concat('1~', v.patient_id)	[VisitPatientID]
	,concat('1~', v.voucher_number)	[VisitAccountID]
	,concat('1~', v.location_id)	[VisitLocationID]
	,concat('1~', v.department_id)	[VisitDepartmentID]
	,null	[VisitRoomID]
	,concat('1~', v.[Actual_Prov_Practitioner_ID])	[VisitPrimaryProviderID]
	,concat('1~', v.[Actual_Prov_Practitioner_ID])	[VisitAppointmentProviderID]
	,null	[VisitAdmittingProviderID]
	,null	[VisitAttendingProviderID]
	,null	[VisitDischargeProviderID]
	,null	[VisitType]
	,null	[VisitService]
	,CASE WHEN v.update_status in (0,1) THEN 'Completed'
		  WHEN v.update_status in (3,5) THEN 'Voided' 
		  END [VisitStatus]
	,v.service_date	[VisitDateOfService]
	,cast(v.service_date as datetime) [VisitDatetimeOfService]
	,null [VisitDateOfScheduling]
	,cast(v.service_date as date) [VisitDateOfAppointment]
	,cast(v.service_date as date) [VisitDateOfAdmission]
	,cast(v.service_date as date) [VisitDateOfDischarge]
	,cast (v.billing_date as date) as [VisitDateofClosing]
	,null	[VisitDateOfCancellation]
	,null	[VisitCancellationReason]
	,1	[VisitIsPrimary]
	,CASE WHEN v.update_status in (3,5) THEN 0 ELSE 1 END	[VisitIsActive]
	,getdate()	[VisitUpdatedDatetime]
--select count(1), count(distinct voucher_number), count(distinct voucher_id)
FROM [TIEVMDB03].[Ntier_627200].[PM].[Vouchers] v
WHERE 1=1
	AND v.update_status in (0,1) /*Not Voided*/
GO
