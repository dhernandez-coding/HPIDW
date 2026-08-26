CREATE procedure [map].[spReloadHeroPracticeProviders_INCREMENTAL] as
		MERGE map.PracticeProviders--_Hero 
		AS target
		USING (
			SELECT
				[PracticeProviderID]
				,[PracticeID]
				,[ProviderID]
				,[ProviderAbbreviation]
				,[PracticeProviderIsPrimary]
				,[PracticeProviderEffectiveDate]
				,[PracticeProviderEndDate]
				,[PracticeProviderIsActive]
				,[PracticeProviderUpdatedDatetime]
				,[PracticeProviderFTE]
				,[PracticeProviderAllocationPercent]
				,[PracticeProviderLocation]
				,[PracticeProviderIsSpecialist]
				,[PracticeProviderIsMidLevel]
				,[PracticeProviderGLType]
				,[PracticeProviderGLTypeID]
				,[PracticeProviderGLProviderID]
				,[PracticeProviderDHSType]
			FROM hero.vPracticeProviders
		) AS source
		ON  target.PracticeID = source.PracticeID
		AND target.ProviderID = source.ProviderID

		WHEN MATCHED THEN
			UPDATE SET
				target.PracticeProviderID                  = source.PracticeProviderID
				,target.ProviderAbbreviation                = source.ProviderAbbreviation
				,target.PracticeProviderIsPrimary           = source.PracticeProviderIsPrimary
				,target.PracticeProviderEffectiveDate       = source.PracticeProviderEffectiveDate
				,target.PracticeProviderEndDate             = source.PracticeProviderEndDate
				,target.PracticeProviderIsActive            = source.PracticeProviderIsActive
				,target.PracticeProviderUpdatedDatetime     = source.PracticeProviderUpdatedDatetime
				,target.PracticeProviderFTE                 = source.PracticeProviderFTE
				,target.PracticeProviderAllocationPercent   = source.PracticeProviderAllocationPercent
				,target.PracticeProviderLocation            = source.PracticeProviderLocation
				,target.PracticeProviderIsSpecialist        = source.PracticeProviderIsSpecialist
				,target.PracticeProviderIsMidLevel          = source.PracticeProviderIsMidLevel
				,target.PracticeProviderGLType              = source.PracticeProviderGLType
				,target.PracticeProviderGLTypeID            = source.PracticeProviderGLTypeID
				,target.PracticeProviderGLProviderID        = source.PracticeProviderGLProviderID
				,target.PracticeProviderDHSType             = source.PracticeProviderDHSType

		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				[PracticeProviderID]
				,[PracticeID]
				,[ProviderID]
				,[ProviderAbbreviation]
				,[PracticeProviderIsPrimary]
				,[PracticeProviderEffectiveDate]
				,[PracticeProviderEndDate]
				,[PracticeProviderIsActive]
				,[PracticeProviderUpdatedDatetime]
				,[PracticeProviderFTE]
				,[PracticeProviderAllocationPercent]
				,[PracticeProviderLocation]
				,[PracticeProviderIsSpecialist]
				,[PracticeProviderIsMidLevel]
				,[PracticeProviderGLType]
				,[PracticeProviderGLTypeID]
				,[PracticeProviderGLProviderID]
				,[PracticeProviderDHSType]
			)
			VALUES (
				source.PracticeProviderID
				,source.PracticeID
				,source.ProviderID
				,source.ProviderAbbreviation
				,source.PracticeProviderIsPrimary
				,source.PracticeProviderEffectiveDate
				,source.PracticeProviderEndDate
				,source.PracticeProviderIsActive
				,source.PracticeProviderUpdatedDatetime
				,source.PracticeProviderFTE
				,source.PracticeProviderAllocationPercent
				,source.PracticeProviderLocation
				,source.PracticeProviderIsSpecialist
				,source.PracticeProviderIsMidLevel
				,source.PracticeProviderGLType
				,source.PracticeProviderGLTypeID
				,source.PracticeProviderGLProviderID
				,source.PracticeProviderDHSType
			);
GO
