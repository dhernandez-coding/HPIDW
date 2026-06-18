CREATE FUNCTION dbo.SplitExecCalls
(
    @Input NVARCHAR(MAX)
)
RETURNS @Output TABLE (
    ProcedureCall NVARCHAR(MAX)
)
AS
BEGIN
    DECLARE @Start INT = 1
    DECLARE @Next INT
    WHILE @Start <= LEN(@Input)
    BEGIN
        SET @Next = CHARINDEX('exec', LOWER(@Input), @Start + 4)
        IF @Next = 0 SET @Next = LEN(@Input) + 1
        
        INSERT INTO @Output (ProcedureCall)
        SELECT LTRIM(RTRIM(SUBSTRING(@Input, @Start, @Next - @Start)))
        WHERE SUBSTRING(@Input, @Start, 4) LIKE 'exec'

        SET @Start = @Next
    END
    RETURN
END
GO
