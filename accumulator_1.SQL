drop procedure dbo.WJB_sprConcatStrings
go
CREATE procedure dbo.WJB_sprConcatStrings
 @@user_id varchar(30),
 @@return_string varchar(8000) output
AS
BEGIN
    DECLARE @s varchar(8000)
    SET @s = ''
    SELECT @s = @s + COALESCE(a.ServicesProvider_cd, '')
    FROM Ebus_Rpt.dbo.Business_Services_Provider_Attributes a
    WHERE a.login_id = login_id
    set @@return_string = @s
END
GO
