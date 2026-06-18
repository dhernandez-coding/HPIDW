CREATE PROCEDURE [stg].[spUKGGetAccessToken]

AS


	Declare @URL varchar(max) = 'https://secure.saashr.com/ta/rest/v1/login'
	Declare @Body varchar(8000) = '{
  "credentials": {
    "username": "eric.silvestri",
    "password": "St@ndard$$78910",
    "company": "6124450"
  }
}'

	Declare @Object as Int;
	Declare @apiKey NVARCHAR(100) = '9w4g20mlg2qmr30pgmj5m08buvmbjgw7';
	Declare @ResponseTable as table(Json_Table nvarchar(max))
	--Code Snippet
	Exec sp_OACreate 'MSXML2.ServerXMLHttp.3.0', @Object OUT;
	Exec sp_OAMethod @Object, 'open', NULL, 'post',
					 @URL, --Your Web Service Url (invoked)
					 'false'
	EXEC sp_OAMethod @Object, 'setRequestHeader', null, 'Content-Type', 'application/json'
	EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Api-Key', @apiKey; -- Add API key to the header
	Exec sp_OAMethod @Object, 'send',null,@Body
	Exec sp_OAMethod @Object, 'responseText', @ResponseTable OUTPUT
--	EXEC sp_OAGetErrorInfo @Object

	INSERT INTO @ResponseTable(Json_Table) EXEC sp_OAGetProperty @Object, 'responseText'
	select * from @ResponseTable

	DECLARE @json nvarchar(max) = (select top 1 Json_Table from @ResponseTable)


UPDATE dbo.Platforms 
SET PlatformAccessToken = (select top 1 j.[value] from OPENJSON(@json) j)
WHERE PlatformID = 1
--where j.[key] = 'access_token'
GO
