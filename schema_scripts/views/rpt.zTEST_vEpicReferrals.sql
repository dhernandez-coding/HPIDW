--select * from rpt.vEpicReferrals where ReferralID in (10026746)





--select * from rpt.zTEST_vEpicReferrals
--select * from rpt.vEpicReferrals

CREATE VIEW [rpt].[zTEST_vEpicReferrals] as


   
	select r.[REFERRAL_ID] as ReferralID
		   
		   ,c.PROV_NAME as ReferredByProvider
		   ,CASE WHEN c.[PROV_ID] IS NOT NULL THEN CONCAT('5~',c.PROV_ID) END as ReferredByProviderID
		   ,prb.PracticeID as ReferredByPracticeID
		   --,db.DepartmentName as ReferredByDepartment
		   ,d.DEPARTMENT_NAME as ReferredByDepartment
		   ,CASE WHEN r.[REFD_BY_DEPT_ID] is not null THEN CONCAT('5~',[REFD_BY_DEPT_ID]) END as ReferredByDepartmentID
		   ,COALESCE(l.LOC_NAME,pos.POS_NAME) as ReferredByLocation
		   ,CASE WHEN r.[REFD_BY_LOC_POS_ID] is not null THEN CONCAT('5~',r.[REFD_BY_LOC_POS_ID]) END as ReferredByLocationID
		   
		   ,CASE WHEN prb.PracticeID IS NOT NULL THEN prb.PracticeName
				 WHEN r.[REFERRING_PROV_ID] IS NOT null THEN c.PROV_NAME
			     --WHEN r.[REFD_BY_DEPT_ID] IS NOT NULL THEN d.DEPARTMENT_NAME
				 --WHEN r.[REFD_BY_LOC_POS_ID] IS NOT NULL THEN COALESCE(l.LOC_NAME,pos.POS_NAME)
				 ELSE '*No Referred By Specified*' END as ReferredBy
		   ,CASE WHEN r.[REFERRING_PROV_ID] IS NULL 
					  AND r.[REFD_BY_DEPT_ID] IS NULL 
					  AND r.[REFD_BY_LOC_POS_ID] IS NULL THEN 'No' ELSE 'Yes' END AS IsReferredByPopulated
		   ,ppb.PracticeProviderIsAffiliate as IsReferredByAffiliate
		   ,ppb.PracticeProviderIsSpecialist as IsReferredByHPISpecialist
		   ,CASE WHEN ISNULL(ppb.PracticeProviderIsSpecialist,0) = 0 THEN 1 ELSE 0 END  as IsReferredByHPIPrimaryCare
		   ,ppb.PracticeProviderIsReferralTarget as IsReferredByTarget

		   ,c1.PROV_NAME as ReferredToProvider
		   ,CASE WHEN r.[REFERRAL_PROV_ID] IS NOT NULL THEN CONCAT('5~',r.[REFERRAL_PROV_ID]) END as ReferredToProviderID
		   ,prt.PracticeID as ReferredToPracticeID
		   --,dt.DepartmentName as ReferredToDepartment
		   ,d1.DEPARTMENT_NAME as ReferredToDepartment
		   ,CASE WHEN r.[REFD_TO_DEPT_ID] is not null THEN CONCAT('5~',r.[REFD_TO_DEPT_ID]) END as ReferredToDepartmentID
		   ,COALESCE(l1.LOC_NAME,pos1.POS_NAME) as ReferredToLocation
		   ,CASE WHEN r.[REFD_TO_LOC_POS_ID] is not null THEN CONCAT('5~',r.[REFD_TO_LOC_POS_ID]) END as ReferredToLocationID
		   
		   ,CASE WHEN prt.PracticeID IS NOT NULL THEN prt.PracticeName
				 WHEN r.[REFERRAL_PROV_ID] IS NOT null THEN c1.PROV_NAME
			     WHEN r.[REFD_TO_DEPT_ID] IS NOT NULL THEN d1.DEPARTMENT_NAME
				 WHEN r.[REFD_TO_LOC_POS_ID] IS NOT NULL THEN COALESCE(l1.LOC_NAME,pos1.POS_NAME)
				 ELSE '*No Referred To Specified*' END as ReferredTo

		   ,CASE WHEN prt.PracticeID IS NOT NULL THEN CONCAT('Practice: ', prt.practiceID)
				 WHEN r.[REFERRAL_PROV_ID] IS NOT null THEN CONCAT('Provider: ', r.[REFERRAL_PROV_ID])
			     WHEN r.[REFD_TO_DEPT_ID] IS NOT NULL THEN CONCAT('Department: ',r.[REFD_TO_DEPT_ID])
				 WHEN r.[REFD_TO_LOC_POS_ID] IS NOT NULL THEN CONCAT('Location/POS: ',r.[REFD_TO_LOC_POS_ID])
				 ELSE '*No Referred To Specified*' END as ReferredToID

		   ,CASE WHEN r.[REFERRAL_PROV_ID] IS NULL 
					  AND r.[REFD_TO_DEPT_ID] IS NULL 
					  AND r.[REFD_TO_LOC_POS_ID] IS NULL THEN 'No' ELSE 'Yes' END AS IsReferredToPopulated
		   ,ppt.PracticeProviderIsAffiliate as IsReferredToAffiliate
		   ,ppt.PracticeProviderIsSpecialist as IsReferredToHPISpecialist
		   ,CASE WHEN ISNULL(ppt.PracticeProviderIsSpecialist,0) = 0 THEN 1 ELSE 0 END  as IsReferredToHPIPrimaryCare
		   ,ppt.PracticeProviderIsReferralTarget as IsReferredToTarget

		   ,r.[ENTRY_DATE]	as ReferralEntryDate
		   ,r.[ADMISSION_DATE] as ReferralDateOfAdmission
		   ,r.[DISCHARGE_DATE] as ReferralDateOfDischarge
		   ,r.[START_DATE] as ReferralStartDate
		   ,r.[EXP_DATE] as ReferralExpirationDate
		   ,apt.NAME as ReferralPeriodForAuthorizedVisit
		   ,rar.NAME as ReferralAuthorizationReason
		   ,rcr.NAME as ReferralReasonForClosing
		   ,dr.NAME as ReferralReasonForDenial
		   ,dir.NAME as ReferralDispositionStatus
		   ,dv.NAME as ReferralDispositionValue
		   ,es.NAME as ReferralEntrySource
		   ,rp.NAME as ReferralPriority
		   ,s.NAME as ReferredBySpecialty
		   ,rts.NAME as ReferredToSpecialty
		   ,rs.NAME as ReferralStatus
		   ,rc.NAME as ReferralClass
		   ,rt.NAME as ReferralType
		   ,rfr.NAME as ReferralReason
		   ,ss.NAME as ReferralScheduleStatus
	   
		   ,op.PROC_ID as ReferralOrderProcedureID
		   ,op.DESCRIPTION as ReferralOrderProcedure
		   ,ot.NAME as ReferralOrderType
		   ,oc.NAME as ReferralOrderClass

		   ,r.[PAT_ID] as ReferralPatientID
		   ,p.PatientFullName AS PatientFullName
		   ,p.PatientMRN AS PatientMRN
		   ,r.[SERV_AREA_ID] as ReferralServiceAreaID
		   ,r.[COVERAGE_ID] as ReferralCoverageID
		   ,r.[CARRIER_ID] as ReferralCarrierID
		   ,r.[PAYOR_ID] as ReferralPayorID
		   ,r.[PLAN_ID] as ReferralPlanID
		   ,r.[SERV_DATE] as ReferralDateOfService
		   ,r.[UPDATE_DATE] as ReferralUpdateDate
		   ,r.[SCHED_BY_DATE] as ReferralScheduleByDate
		   ,r.[IB_STATUS_EXPLAN] as ReferralStatusExplain
		   ,r.[DECISION_DATE] as ReferralDecisionDate
		   --,rh.HX_USER_ID
		   ,GETDATE() as AsOfDatetime
	from [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].REFERRAL r
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].REFERRAL_SOURCE src ON src.REFERRING_PROV_ID = r.REFERRING_PROV_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_SER c on src.REF_PROVIDER_ID = c.PROV_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_SER c1 on r.REFERRAL_PROV_ID = c1.PROV_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_DEP d on d.DEPARTMENT_ID = r.REFD_BY_DEPT_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_DEP d1 on d1.DEPARTMENT_ID = r.REFD_TO_DEPT_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_LOC l on l.LOC_ID = r.REFD_BY_LOC_POS_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_POS pos on pos.POS_ID = r.REFD_BY_LOC_POS_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_LOC l1 on l1.LOC_ID = r.REFD_TO_LOC_POS_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].CLARITY_POS pos1 on pos1.POS_ID = r.REFD_TO_LOC_POS_ID
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_AUTH_PER_TYPE apt on r.AUTH_PERIOD_TYPE_C = apt.AUTH_PERIOD_TYPE_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_RFL_AUTH_RSN rar on r.AUTH_RSN_C = rar.AUTH_RSN_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_RFL_CLOSE_RSN rcr on r.CLOSE_RSN_C = rcr.RFL_CLOSE_RSN_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_RFL_DENY_RSN dr on r.DENY_RSN_C = dr.DENY_RSN_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_DISP_RSN dir on r.DISP_RSN_C = dir.DISP_RSN_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_DISP_VAL dv on r.DISP_VAL_C = dv.DISP_VAL_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_ENTRY_SOURCE es on r.ENTRY_SOURCE_C = es.ENTRY_SOURCE_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_RFL_PRIORITY rp on r.PRIORITY_C = rp.PRIORITY_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_SPECIALTY s on r.PROV_SPEC_C = s.SPECIALTY_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_REFD_TO_SPEC rts on r.REFD_TO_SPEC_C = rts.REFD_TO_SPEC_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_RFL_STATUS rs on r.RFL_STATUS_C = rs.RFL_STATUS_C 
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_RFL_TYPE rt on r.RFL_TYPE_C = rt.RFL_TYPE_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_RSN_FOR_RFL rfr on r.RSN_FOR_RFL_C = rfr.RSN_FOR_RFL_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ZC_SCHED_STATUS ss on r.SCHED_STATUS_C = ss.SCHED_STATUS_C
		left join [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_RFL_CLASS] rc ON rc.RFL_CLASS_C = r.RFL_CLASS_C
	
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[REFERRAL_ORDER_ID] ro ON ro.REFERRAL_ID = r.REFERRAL_ID AND ro.LINE = 1
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].ORDER_PROC op on op.ORDER_PROC_ID = ro.ORDER_ID
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_ORDER_TYPE] ot ON ot.ORDER_TYPE_C = op.ORDER_TYPE_C
		LEFT JOIN [CLARITYRDBMS.CORP.INTEGRIS-HEALTH.COM].[CLARITY].[ORGFILTER].[ZC_ORDER_CLASS] oc ON oc.ORDER_CLASS_C = op.ORDER_CLASS_C

		left join dim.Patients p on CONCAT('5~',r.[PAT_ID]) = p.PatientID
		
		left join dim.vDepartments db on db.DepartmentID = CONCAT('5~',r.[REFD_BY_DEPT_ID]) 
		left join dim.vDepartments dt on dt.DepartmentID = CONCAT('5~',r.[REFD_TO_DEPT_ID]) 
		--left join dim.Practices pt on pt.PracticeID = dt.PracticeID
		
		--left join map.EpicPracticeProviders ppb ON ppb.ProviderID = CONCAT('5~',c.PROV_ID)
		left join map.ProviderLinking plb ON plb.ChildProviderID = CONCAT('5~',c.PROV_ID)
		left join map.zTEST_PracticeProviders ppb ON ppb.ProviderID = plb.ParentProviderID AND ppb.PracticeProviderIsDefaultReferralPractice = 1

		--left join map.EpicPracticeProviders ppt ON ppt.ProviderID = CONCAT('5~',c1.PROV_ID)
		left join map.ProviderLinking plt ON plt.ChildProviderID = CONCAT('5~',c1.PROV_ID)
		left join map.zTEST_PracticeProviders ppt ON ppt.ProviderID = plt.ParentProviderID AND ppt.PracticeProviderIsDefaultReferralPractice = 1


		left join map.EpicPracticeLocations lt ON lt.LocationID = CONCAT('5~',r.[REFD_TO_LOC_POS_ID])
		
		left join dim.zTEST_Practices prb ON prb.PracticeID = CASE --WHEN CONCAT('5~',c.PROV_ID) = '5~125582' AND db.PracticeID IS NOT NULL THEN db.PracticeID /*Exception for Murphi Scarborough who practices at 2 clinics*/
															 WHEN ppb.PracticeID IS NOT NULL THEN ppb.PracticeID
															 --WHEN db.PracticeID IS NOT NULL THEN db.PracticeID /*Removed as Referred By Department is not reliably used in Epic*/
															 WHEN r.[REFERRING_PROV_ID] is not null THEN '0~352'--'0~EXT0' /*Map all unmapped records to External as long as something exists in the Referred By*/
															 END
		
		left join dim.zTEST_Practices prt ON prt.PracticeID = CASE --WHEN CONCAT('5~',c1.PROV_ID) = '5~125582' AND dt.PracticeID IS NOT NULL THEN dt.PracticeID /*Exception for Murphi Scarborough who practices at 2 clinics*/
															 WHEN ppt.PracticeID IS NOT NULL THEN ppt.PracticeID 
															 WHEN dt.PracticeID IS NOT NULL THEN dt.PracticeID
															 WHEN lt.PracticeID IS NOT NULL THEN lt.PracticeID
															 WHEN r.[REFERRAL_PROV_ID] IS NULL 
																	AND r.[REFD_TO_DEPT_ID] IS NULL
																	AND r.[REFD_TO_LOC_POS_ID] IS NULL THEN NULL
															 ELSE '0~352'--'0~EXT0' /*Map all unmapped records to External as long as something exists in the Referred To*/
														 END--COALESCE(ppt.PracticeID,dt.PracticeID)

	where 1=1 --and r.REFERRAL_ID IN (2460304,2183315)
	and (d.SERV_AREA_ID in ('425','430') OR d1.SERV_AREA_ID in ('425','430') OR r.[SERV_AREA_ID] in ('425','430'))
	/*8.16.24 --Excluding this list of order procedures as they are not helpful for tracking referral activity for HPI*/
	and ISNULL(op.DESCRIPTION,'') not like 'NM %' /*exclude Nuclear Med referrals*/
	and ISNULL(op.DESCRIPTION,'') not in (
			'AMB REF PALLIATIVE CARE SERVICES'
			,'AMB REFERRAL FOR ORTHOTICS'
			,'AMB REFERRAL TO HEPATOLOGY'
			,'AMB REFERRAL TO HOME HEALTH'
			,'AMB REFERRAL TO HOME HOSPICE'
			,'AMB REFERRAL TO HYPERBARIC OXYGEN THERAPY'
			,'AMB REFERRAL TO IMMUNOLOGY'
			,'AMB REFERRAL TO NEUROPSYCHOLOGY'
			,'AMB REFERRAL TO NUTRITION SERVICES'
			,'AMB REFERRAL TO ORTHOTIST & PROSTHETIST'
			,'AMB REFERRAL TO PEDIATRIC ENDOCRINOLOGY'
			,'AMB REFERRAL TO PEDIATRIC GASTROENTEROLOGY'
			,'AMB REFERRAL TO PEDIATRIC ORTHOPEDICS'
			,'AMB REFERRAL TO PEDIATRIC UROLOGY'
			,'AMB REFERRAL TO SKILLED NURSING FACILITY'
			,'AMB REFERRAL TO SLEEP MEDICINE'
			,'AMB REFERRAL TO SOONER START'
			,'AMB REFERRAL TO SPEECH THERAPY'
			,'BI MAMMO DIAGNOSTIC BILATERAL'
			,'BI MAMMO DIAGNOSTIC LEFT'
			,'BI MAMMO DIAGNOSTIC POST PROCEDURE LEFT'
			,'BI MAMMO DIAGNOSTIC POST PROCEDURE RIGHT'
			,'BI TOMOSYNTHESIS DIAGNOSTIC BILATERAL'
			,'BI TOMOSYNTHESIS DIAGNOSTIC LEFT'
			,'BI TOMOSYNTHESIS DIAGNOSTIC RIGHT'
			,'BI TOMOSYNTHESIS SCREENING BILATERAL'
			,'BI TOMOSYNTHESIS SCREENING RIGHT'
			,'BONE DENSITOMETRY APPENDICULAR SKELETON'
			,'BONE DENSITOMETRY AXIAL SKELETON 77080'
			,'CASE REQUEST OPERATING ROOM'
			,'CYST REMOVAL'
			,'DISCHARGE DRESSING'
			,'DISCHARGE INSTRUCTIONS'
			,'DISCHARGE RESPIRATORY TREATMENT'
			,'DME HOME OXYGEN THERAPY'
			,'DME SUPPLIES'
			,'ECG 12-LEAD'
			,'ECHOCARDIOGRAM COMPLETE TRANSTHORACIC'
			,'ECHOCARDIOGRAM COMPLETE WITH BUBBLE STUDY'
			,'EXTENDED HOLTER - READ ONLY'
			,'HOLTER MONITOR - CONTRACT CUSTOMERS'
			,'INCENTIVE SPIROMETRY'
			,'IP CONSULT TO HOSPICE'
			,'NURSING COMMUNICATION'
			,'PET/CT PSMA SKULL BASE-MIDTHIGH INT'
			,'PET/CT SKULL BASE - MIDTHIGH INT'
			,'PET/CT SKULL BASE - MIDTHIGH SUB'
			,'PET/CT WHOLE BODY - INT'
			,'PULMONARY FUNCTION TEST'
			,'SLEEP STUDY,HOME UNNATENDED & RESP EFFORT'
			,'SMOKING CESSATION - OK TOBACCO HELPLINE FOR COUNSELING'
			,'SPLIT NIGHT SLEEP STUDY'
			,'US AAA SCREENING'
			,'US ABD PARACENTESIS WITH IMAGE'
			,'US ABD PARACENTESIS WITHOUT IMAGE'
			,'US ABDOMEN COMPLETE'
			,'US ABDOMEN LIMITED'
			,'US ABDOMINAL AORTA'
			,'US BIOPSY NEEDLE THYROID'
			,'US BREAST COMPLETE BILATERAL'
			,'US BREAST COMPLETE LEFT'
			,'US BREAST LIMITED BILATERAL'
			,'US BREAST LIMITED LEFT'
			,'US BREAST LIMITED RIGHT'
			,'US DOPPLER ABDOMINAL'
			,'US DOPPLER ARTERIAL ARM LEFT - RAD'
			,'US DOPPLER ARTERIAL ARM RIGHT - RAD'
			,'US DOPPLER ARTERIAL LEG LEFT - RAD'
			,'US DOPPLER ARTERIAL LEG RIGHT - RAD'
			,'US DOPPLER ARTERIAL LEGS BILATERAL'
			,'US DOPPLER ARTERIAL LEGS BILATERAL - RAD'
			,'US DOPPLER CAROTID'
			,'US DOPPLER CAROTID COMPLETE - RAD'
			,'US DOPPLER VENOUS ARM LEFT - RAD'
			,'US DOPPLER VENOUS ARM RIGHT'
			,'US DOPPLER VENOUS ARM RIGHT - RAD'
			,'US DOPPLER VENOUS LEG LEFT'
			,'US DOPPLER VENOUS LEG LEFT - RAD'
			,'US DOPPLER VENOUS LEG RIGHT'
			,'US DOPPLER VENOUS LEG RIGHT - RAD'
			,'US DOPPLER VENOUS LEGS BILATERAL'
			,'US DOPPLER VENOUS LEGS BILATERAL - RAD'
			,'US EXTREMITY COMPLETE NONVASC LEFT'
			,'US EXTREMITY COMPLETE NONVASC RIGHT'
			,'US EXTREMITY LIMITED NONVASC LEFT'
			,'US EXTREMITY LIMITED NONVASC RIGHT'
			,'US GALLBLADDER'
			,'US GB LIVER PANCREAS'
			,'US GUIDED FINE NEEDLE ASPIRATION'
			,'US KIDNEYS AND BLADDER'
			,'US KIDNEYS COMPLETE W DOPPLER ABDOMINAL'
			,'US OB COMP <14 WKS SINGLE FETUS 76801'
			,'US OB FOLLOW-UP REPEAT 76816'
			,'US PELVIC 76856'
			,'US PELVIS LIMITED 76857'
			,'US SCROTUM AND TESTICLES'
			,'US SOFT TISSUE ABDOMEN/CHEST'
			,'US SOFT TISSUE NECK/HEAD'
			,'US SOFT TISSUE OTHER'
			,'US THYROID'
			,'US TRANSVAGINAL (OB) 76817'
			,'US TRANSVAGINAL 76830'
			,'USI ABDOMEN LIMITED'
			,'USI EXTREMITY LIMITED NONVAS LEFT'
			,'XR ABDOMEN 1 VW'
			,'XR ABDOMEN 2 VW AP/LATERAL'
			,'XR ABDOMEN 2 VW FLAT W UPRIGHT AND/OR DECUBITUS'
			,'XR ABDOMEN 2 VW W CHEST 1 VW (ACUTE ABD SERIES)'
			,'XR ACROMIOCLAVICULAR JOINTS BILATERAL W WO WEIGHTS'
			,'XR ANKLE 3+ VW BILATERAL'
			,'XR ANKLE 3+ VW LEFT'
			,'XR ANKLE 3+ VW RIGHT'
			,'XR CALCANEUS 2+ VW BILATERAL'
			,'XR CALCANEUS 2+ VW LEFT'
			,'XR CALCANEUS 2+ VW RIGHT'
			,'XR CERVICAL SPINE 1 VW'
			,'XR CERVICAL SPINE FLEX/EXT ONLY 2-3 VW'
			,'XR CERVICAL SPINE ROUTINE 2-3 VW'
			,'XR CERVICAL SPINE W FLEX/EXT 4-5 VW'
			,'XR CERVICAL SPINE W OBL/FLEX/EXT 6+ VW'
			,'XR CERVICAL SPINE W OBLIQUES 4-5 VW'
			,'XR CHEST 1 VW'
			,'XR CHEST 2 VW'
			,'XR CLAVICLE LEFT'
			,'XR CLAVICLE RIGHT'
			,'XR ELBOW 2 VW LEFT'
			,'XR ELBOW 2 VW RIGHT'
			,'XR ELBOW 3+ VW LEFT'
			,'XR ELBOW 3+ VW RIGHT'
			,'XR FACIAL BONES < 3 VW'
			,'XR FACIAL BONES 3+ VW'
			,'XR FINGER 2+ VW LEFT'
			,'XR FINGER 2+ VW RIGHT'
			,'XR FOOT 2 VW BILATERAL'
			,'XR FOOT 3+ VW BILATERAL'
			,'XR FOOT 3+ VW LEFT'
			,'XR FOOT 3+ VW RIGHT'
			,'XR FOREARM 2 VW LEFT'
			,'XR FOREARM 2 VW RIGHT'
			,'XR HAND 2 VW BILATERAL'
			,'XR HAND 3+ VW BILATERAL'
			,'XR HAND 3+ VW LEFT'
			,'XR HAND 3+ VW RIGHT'
			,'XR HIP 1 VW RIGHT'
			,'XR HIP 2+ VW BILATERAL'
			,'XR HIP 2+ VW LEFT'
			,'XR HIP 2+ VW RIGHT'
			,'XR HIP 2+ VW RIGHT W AP PELVIS'
			,'XR HIP 3+ VIEWS BILATERAL'
			,'XR KNEE 1 OR 2 VW BILATERAL'
			,'XR KNEE 1 OR 2 VW LEFT'
			,'XR KNEE 1 OR 2 VW RIGHT'
			,'XR KNEE 3 VW BILATERAL'
			,'XR KNEE 3 VW LEFT'
			,'XR KNEE 3 VW RIGHT'
			,'XR KNEE 4+ VW BILATERAL'
			,'XR KNEE 4+ VW LEFT'
			,'XR KNEE 4+ VW RIGHT'
			,'XR KNEE BILATERAL AP STANDING'
			,'XR KUB ONLY'
			,'XR LUMBAR SPINE ROUTINE 2-3 VW'
			,'XR LUMBAR SPINE W FLEX/EXT 4-5 VW'
			,'XR LUMBAR SPINE W OBL/FLEX/EXT 6+ VW'
			,'XR LUMBAR SPINE W OBLIQUES 4-5 VW'
			,'XR MANDIBLE 4+ VW'
			,'XR ORBITS 4+ VW'
			,'XR PELVIS'
			,'XR PELVIS 3+ VW'
			,'XR PELVIS W BILATERAL HIPS 2 VW'
			,'XR PELVIS W LATERAL HIP LEFT'
			,'XR PELVIS W LATERAL HIP RIGHT'
			,'XR RIBS 2 VW LEFT'
			,'XR RIBS 2 VW RIGHT'
			,'XR RIBS LEFT W PA CHEST'
			,'XR SACROILIAC JOINTS 1 OR 2 VW'
			,'XR SACROILIAC JOINTS 3+ VW'
			,'XR SCAPULA LEFT'
			,'XR SCOLIOSIS SPINE ENTIRE SPINE 1 VW'
			,'XR SCOLIOSIS SPINE ENTIRE SPINE 2-3 VW'
			,'XR SHOULDER 2+ VW BILATERAL'
			,'XR SHOULDER 2+ VW LEFT'
			,'XR SHOULDER 2+ VW RIGHT'
			,'XR SKULL < 4 VW'
			,'XR SKULL COMPLETE 4+ VW'
			,'XR THORACIC SPINE 2 VW'
			,'XR THORACIC SPINE 4+ VW'
			,'XR THORACIC SPINE W SWIMMERS 3 VW'
			,'XR TIBIA FIBULA 2 VW BILATERAL'
			,'XR TIBIA FIBULA 2 VW LEFT'
			,'XR TIBIA FIBULA 2 VW RIGHT'
			,'XR TOE 2+ VW LEFT'
			,'XR TOE 2+ VW RIGHT'
			,'XR WRIST 2 VW BILATERAL'
			,'XR WRIST 2 VW RIGHT'
			,'XR WRIST 3+ VW BILATERAL'
			,'XR WRIST 3+ VW LEFT'
			,'XR WRIST 3+ VW RIGHT'
			,'ZIO MCOT 28 DAY MONITOR'
			,'ZIO PATCH EXTENDED HOLTER-MAILOUT'
		)
GO
