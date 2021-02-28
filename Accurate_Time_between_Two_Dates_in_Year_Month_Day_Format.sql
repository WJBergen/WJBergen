---
---This is Accurate_Time_between_Two_Dates_in_Year_Month_Day_Format.sql
---
/*
Accurate Time between Two Dates in Year, Month,Day Format
By Vimal Lohani, 2016/03/29 


This is a function, please follow the comments on script to use it. 

FROM:  http://www.sqlservercentral.com/scripts/Date+Difference/113184/


*/

/****** Object:  UserDefinedFunction [dbo].[fn_TotaltimeBetweendates]    Script Date: 7/10/2014 9:43:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Created By Vimal Lohani
--Modified By ChrisM@Work
--Select [dbo].[fn_TotaltimeBetweendates] (Getdate(), '06/13/1990' )
--Select [dbo].[fn_TotaltimeBetweendates] ('06/13/1990', GetDate())
alter Function [dbo].[fn_TotaltimeBetweendates] (@Fromdate datetime, @Todate datetime )
Returns nvarchar(40)
as
Begin
if(@Fromdate>@Todate)
		begin
			Declare @Tempvar datetime=@Fromdate
					set @Fromdate=@Todate
					set @Todate=@Tempvar
		end
return (SELECT 
	CAST(Years AS VARCHAR(4)) + ' Years :' + CAST(Months AS VARCHAR(2)) + ' Months :' + CAST([Days] AS VARCHAR(2)) + ' Days'
FROM ( -- f
	SELECT 
		Years, Months, [Days] = DATEDIFF(DAY,DATEADD(MONTH,Months,DATEADD(YEAR,Years,@Fromdate)),@Todate) 
			- CASE WHEN DATEADD(DAY,DATEDIFF(DAY,DATEADD(MONTH,Months,DATEADD(YEAR,Years,@Fromdate)),@Todate),DATEADD(MONTH,Months,DATEADD(YEAR,Years,@Fromdate))) > @Todate THEN 1 ELSE 0 END  
	FROM ( -- e
		SELECT Years, [Months] = DATEDIFF(MONTH,DATEADD(YEAR,Years,@Fromdate),@Todate) 
			- CASE WHEN DATEADD(MONTH,DATEDIFF(MONTH,DATEADD(YEAR,Years,@Fromdate),@Todate),DATEADD(YEAR,Years,@Fromdate)) > @Todate THEN 1 ELSE 0 END
		FROM ( -- d
			SELECT 
				[Years] = DATEDIFF(YEAR,@Fromdate,@Todate) - CASE WHEN DATEADD(YEAR,DATEDIFF(YEAR,@Fromdate,@Todate),@Fromdate) > @Todate THEN 1 ELSE 0 END
		) d
	) e
) f )
End