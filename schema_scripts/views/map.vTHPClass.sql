CREATE VIEW  map.vTHPClass AS
--Created by: Diego Hernandez 3/12/2026 to map and clean classes not assigned to providers

		SELECT DISTINCT 
		t.class,
		CASE WHEN t.Class in (SELECT ProviderSourceID from dim.Providers p WHERE p.ProviderDataSourceID = 18) THEN t.Class
			ELSE NULL END AS FixedClass,
		t.Practice
		FROM [HPIDW].[stg].[THPTransactions] t
GO
