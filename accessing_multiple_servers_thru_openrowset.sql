---
---This is accessing_multiple_servers_thru_openrowset.sql
---

---
---on the source server (the one running the query going to a bunch of target servers) the 
---following <<<MUST>>> be run
---
/*
exec sp_configure 'Ad Hoc Distributed Queries', 1
go
reconfigure with override;
go
*/
---
---This table will hold the names of all the servers from which we want to extract data 
---
---NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE
---YOU USE THE SERVER NAME <<<WITHOUT>>> THE INSTANCE NAME 
---
---
---
USE [DBATASKS]
GO

/****** Object:  Table [dbo].[old_file_info_components]    Script Date: 10/24/2014 11:59:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[old_file_info_components_all_servers]') AND type in (N'U'))
DROP TABLE [dbo].[old_file_info_components_all_servers]
GO

USE [DBATASKS]
GO

/****** Object:  Table [dbo].[old_file_info_components_all_servers]    Script Date: 10/24/2014 11:59:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[old_file_info_components_all_servers]
(
    [cms_name_of_server]		[varchar](250) null,
	[name_of_server]			[varchar](250) NULL,
	[sample_date]				[datetime] NULL,
	[path_of_file]				[varchar](2000) NULL,
	[name_of_file]				[varchar](2000) NULL,
	[file_size]					[varchar](50) NULL,
	[file_date]					[varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

---
---This table will hold the names of all the servers from which we want to extract data 
---USE [DBATASKS]
GO

/****** Object:  Table [dbo].[old_file_info_components]    Script Date: 10/24/2014 11:59:56 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[multiple_openrowset_access]') AND type in (N'U'))
DROP TABLE [dbo].[multiple_openrowset_access]
GO

create table DBATASKS.dbo.multiple_openrowset_access
(
moa_server_name		nvarchar(250)
);
checkpoint;
---
---
---
--------------('UPHAPPNDC005'), 
-------------- ('UPHAPPNDC125'),
-------------- ('UPHAPPNDC137'),
-------------- ('UPHAPPNDC214'),
-------------- ('UPHAPPNDC285'),
-------------- ('UPHAPPNDC361'),
-------------- ('UPHDSSNDC007'),
-------------- ('UPHMANNDC009'),
-------------- ('UPHMANNDC012'),
-------------- ('UPHDBSNDC077'),
-------------- ('UPHSDEV2'),
-------------- ('UPHVDBNDC002'),

---
---NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
---USE THE SERVERNAME <<<WITHOUT>>> THE INSTANCE NAME
---
insert into DBATASKS.dbo.multiple_openrowset_access
(
moa_server_name
)
values 
 ('UPHDBSNDC036'),
 ('UPHDBSNDC036\DEV'),
 ('UPHDBSNDC055\SQL1'),
 ('UPHDBSNDC056\SQL1'),
 ('UPHDBSNDC057\SQL1'),
 ('UPHDBSNDC061\SQL1, 16001'),
 ('UPHDBSNDC103'),
 ('UPHSCISTAGESQL'),
 ('UPHVDBNDC001'),
 ('UPHVDBNDC007'),
 ('UPHVDBNDC026A\SQL1'),
 ('UPHVDBNDC026B\SQL2'),
 ('UPHVDBNDC027A\SQL1'),
 ('UPHVDBNDC027B\SQL2'),
 ('UPHVDBNDC037'),
 ('UPHVDBNDC040'),
 ('UPHVDBNDC040A\DW'),
 ('UPHVDBPHI001B\SQL2');
 ---
 ---
 ---
 select moa_server_name
 from   DBATASKS.dbo.multiple_openrowset_access;
 ---
 ---
 ---
 declare @cms_server_name_hold		nvarchar(250)
 declare @openrowset_cmd_original	nvarchar(500)
 declare @openrowset_cmd_modified	nvarchar(500)
 set @openrowset_cmd_original = 
 '
 SELECT  * 
   FROM    OPENROWSET (''SQLNCLI'',''Server=targetservername;Trusted_Connection=yes;'',
  ''Select ''''targetservername'''', * 
   from DBATASKS.dbo.old_file_info_components  
   order by file_date asc'') 
  AS tbl
 '
 print @openrowset_cmd_original
 declare server_cursor cursor static
 for
 select moa_server_name
 from DBATASKS.dbo.multiple_openrowset_access
 open server_cursor;
 fetch next from server_cursor into @cms_server_name_hold
 while (@@fetch_status = 0)
 begin
 set @openrowset_cmd_modified = replace(@openrowset_cmd_original, 'targetservername', @cms_server_name_hold)
 print @openrowset_cmd_modified
 insert into [DBATASKS].[dbo].[old_file_info_components_all_servers]
 exec master.sys.sp_executesql @openrowset_cmd_modified
 fetch next from server_cursor into @cms_server_name_hold

 end 
 close server_cursor;
 deallocate server_cursor;