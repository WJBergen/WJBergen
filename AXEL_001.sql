USE AXEL
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[spr_AXEL_OFACWBX_file_create') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[spr_spr_AXEL_OFACWBX_file_create]
GO
create procedure dbo.spr_AXEL_OFACWBX_file_create
as 
---
---Name:	spr_AXEL_OFACWBX_file_create
---Create Date:	5/13/2004
---Author:	WJB
---Version:	1.0
---Purpose	This is used to create the data dump from tbClients in the AXEL 
---		database from WIL-SQL-02.
---		The production output sequential file will be placed in
---		\\INGFTP\MOMOUTBOUND.OFACWBX.txt
---		This directory is the Momentum directory
---
-----USE AXEL
set nocount on
set concat_null_yields_null off 
declare @account_balance int
declare @officer_number  tinyint
declare @profit_center   tinyint 
declare @current_yyyymmdd char(8)
declare @current_yyyy char(4)
declare @current_mm   char(2)
declare @current_dd   char(2)
set @account_balance = 0
set @officer_number  = 0
set @profit_center   = 0
set @current_yyyy = cast(datepart(yyyy, getdate()) as char(4)) 
set @current_mm = cast(datepart(mm, getdate()) as char(2))
set @current_dd = cast(datepart(dd, getdate()) as char(2))
set @current_mm = 
	case
		when @current_mm >= '1' and @current_mm <= '9' then 
			'0' + @current_mm
		else @current_mm
	end
set @current_dd = 
	case
		when @current_dd >= '1' and @current_dd <= '9' then 
			'0' + @current_dd
		else @current_dd
	end
set @current_yyyymmdd = @current_yyyy + @current_mm + @current_dd
-----print @current_yyyy
-----print @current_mm
-----print @current_dd
-----print @current_yyyymmdd
select 
	'WBX001'
	+ cast(replicate(' ', (18 - len(clientid))) + cast(clientid as char) as char(18))
	+ cast(@current_yyyymmdd as char(8))
	+ upper(cast((rtrim(FirstName) 
		+ ' ' + rtrim(MiddleName) 
		+ ' ' + rtrim(LastName)
		+ ' ' + rtrim(Suffix)) as char(35)))
	+ space(35)
	+ space(35)
-----	+ case 
-----		when FirstName is null then space(35) 
-----		else cast(substring(FirstName, 1, 35) as char(35))
-----	  end
-----	+ case 
-----		when MiddleName is null then space(35) 
-----		else cast(substring(MiddleName, 1, 35) as char(35))
-----	  end
-----	+ case 						    ------?????????
-----		when LastName is null then space(35) 	    ------??do you want suffix
-----		else cast(LastName + Suffix as char(35))    ------??custodian
-----	  end						    ------?????????
-----	+ case 						    ------?????????
-----		when LastName is null then space(35) 	    ------??do you want suffix
-----		else cast(substring(LastName, 1, 35) as char(35))    ------??custodian
-----	  end						    ------?????????
	+ upper(case
		when address1 is null then space(35) 
		else cast(rtrim(address1) as char(35))
	  end)
	+ upper(case
		when address2 is null then space(35)
		else cast(rtrim(address2) as char(35))
	  end)
	+ upper(case
		when address3 is null then space(35)
		else cast(rtrim(address3) as char(35))
	  end)
	+ upper(case
		when city is null then space(35)
		else cast(rtrim(city) as char(35))
	  end)
	+ upper(case
		when state is null then space(2)
		else cast(rtrim(state) as char(2))
	  end)
-----	+ cast(rtrim(PostalCode) as char(5))            -----??????zip code
	+ upper(case
		when country is null then space(5)
		else cast(rtrim(Country) as char(5))
	  end)
	+ '0000000000'				------??????Account balance
	+ '000000' 				------??????officer number + profit center
	+ case
		when tin is null then space(30)
		else cast(replace(rtrim(tin), '-', '') as char(30))
	  end
from AXEL.dbo.tb_Clients
set nocount off
set concat_null_yields_null on