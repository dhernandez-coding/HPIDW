-- =============================================
-- Author:		Ryan Tisserand
-- Create date: 03/10/2023
-- Description:	Extracts, Transforms and Loads Patient Data from Medhost NS Source System into a dim Table
-- Change Control
--	1. 03/10/2023 - Chris Cross - Initial build of procedure
-- =============================================
CREATE PROCEDURE [stg].[spMedhostNSReloadDimPatientsFull]
AS
BEGIN
SET NOCOUNT ON;

delete from dim.Patients where PatientDataSourceID = 2

insert into dim.Patients
(
	PatientID,
	PatientDataSourceID,
	PatientSourceID,
	PatientMRN,
	PatientFirstName,
	PatientMiddleInitial,
	PatientLastName,
	PatientFullName,
	PatientGender,
	PatientDateOfBirth,
	PatientSSN,
	PatientHomePhone,
	PatientWorkPhone,
	PatientWorkPhoneExtension,
	PatientMobilePhone,
	PatientEmailAddress,
	PatientStreetAddress1,
	PatientStreetAddress2,
	PatientCity,
	PatientState,
	PatientZipCode,
	PatientIsActive,
	PatientUpdatedDateTime
)
select
	'2~' + CONVERT(varchar(100),p.HISTN) as PatientID,
	2 as PatientDataSourceID,
	p.HISTN as PatientSourceID,
	p.HISTN as PatientMRN,
   CASE WHEN 0 = CHARINDEX(' ',p.PNAME)  
         THEN NULL  --no spaces @ all?  then 1st name is all we have
         ELSE SUBSTRING(
                         p.PNAME
                        ,CHARINDEX(' ',p.PNAME)+1
                        ,LEN(p.PNAME)
                       )
    END as PatientFirstName,
	CASE WHEN LEFT(RIGHT(SUBSTRING(p.PNAME,CHARINDEX(' ',p.PNAME)+1,LEN(p.PNAME)),2),1) = ' '
		 THEN RIGHT(SUBSTRING(p.PNAME,CHARINDEX(' ',p.PNAME)+1,LEN(p.PNAME)),1) END as PatientMiddleInitial,
	CASE WHEN 0 = CHARINDEX(' ',p.PNAME)
         THEN p.PNAME --No space? return the whole thing
         ELSE SUBSTRING(
                         p.PNAME
                        ,1
                        ,CHARINDEX(' ',p.PNAME)-1
                       )
     END  as  PatientLastName,
	p.PNAME as PatientFullName,
	p.SEX PatientGender,
    CASE WHEN ISDATE(p.ISOHDOB) = 0 THEN null ELSE convert(date,p.ISOHDOB) END as PatientDateOfBirth,
	p.SSN PatientSSN,
	case when p.PHONE = '' THEN NULL ELSE CONCAT('(',p.HARCD,') ',LEFT(p.PHONE,3),'-',RIGHT(p.PHONE,4)) END as PatientHomePhone,
	NULL as PatientWorkPhone,
	'' PatientWorkPhoneExtension,
	'' PatientMobilePhone,
	NULL as PatientEmailAddress,
	p.PADR1 as PatientStreetAddress1,
	p.PADR2 PatientStreetAddress2,
	p.HCITY PatientCity,
	RIGHT(p.HCITY,2) as PatientState,
	p.ZIP PatientZipCode,
	case when p.EXPIRED = 'Y' then 0 else 1 end as PatientIsActive, /*Lookup Value in [100.65.16.148].[CLARITY].[ORGFILTER].[ZC_PATIENT_STATUS]:  Alive or Deceased*/
	getdate() PatientUpdatedDateTime

FROM OPENQUERY([hmsls],'
	select
	*
	from HOSPF100.PATHISTM --DICTIONARY
	where 1=1 
	') p

END
GO
