CREATE procedure [stg].[spAPMCustomersReloadFactVisits2Full] as

DELETE FROM fact.Visits2 WHERE VisitDatasourceID = 12

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
	concat('12~', v.voucher_number,'~',v.department_id) VisitID
	,12	[VisitDatasourceID]
	,v.voucher_number	[VisitSourceID]
	,concat('12~', v.patient_id)	[VisitPatientID]
	,concat('12~', v.voucher_number)	[VisitAccountID]
	,concat('12~', v.location_id)	[VisitLocationID]
	,concat('12~', v.department_id)	[VisitDepartmentID]
	,null	[VisitRoomID]
	,concat('12~', v.[Actual_Prov_Practitioner_ID])	[VisitPrimaryProviderID]
	,concat('12~', v.[Actual_Prov_Practitioner_ID])	[VisitAppointmentProviderID]
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
FROM [TIEVMDB03].Ntier_HPI_Customers.[PM].[Vouchers] v
WHERE 1=1
	AND v.update_status in (0,1) /*Not Voided*/
	AND v.department_id in ('36','45','46','48','47') --Added 47 for include  Bryant Street Family Medicine
	AND v.service_date >= '2023-01-01'
GO
