CREATE FUNCTION [dbo].[GetAge] ( @DateOfBirth    DATETIME, 
                                     @AsOfDate       DATETIME )
RETURNS INT
AS
BEGIN

    DECLARE @vAge INT
    
    IF @DateOfBirth >= @AsOfDate
        RETURN 0

    SET @vAge = DATEDIFF(YY, @DateOfBirth, @AsOfDate)

    IF MONTH(@DateOfBirth) > MONTH(@AsOfDate) OR
      (MONTH(@DateOfBirth) = MONTH(@AsOfDate) AND
       DAY(@DateOfBirth)   > DAY(@AsOfDate))
        SET @vAge = @vAge - 1

    RETURN @vAge
END
GO
