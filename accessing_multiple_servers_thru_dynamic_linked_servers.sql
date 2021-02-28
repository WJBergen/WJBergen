---
---This is accessing_multiple_servers_thru_dynamic_linked_servers.sql
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
---This table will hold the names of all the servers and instances from which we want to 
---extract data 
---
---NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
---
---REMEMBER TO CHANGETHE TEMP TABLE ##multiple_openrowset_access TO A PERMANENT TABLE UNDER DBATASKS
---
USE [DBATASKS]
GO

/****** Object:  Table [dbo].[old_file_info_components]    Script Date: 10/24/2014 11:59:56 ******/
IF  EXISTS (SELECT * FROM DBATASKS.sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[old_file_info_components_all_servers]') AND type in (N'U'))
begin
DROP TABLE DBATASKS.[dbo].[old_file_info_components_all_servers]
end
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
---
---testing openrowset against multiple TEST servers 
---
create table ##multiple_openrowset_access
(
moa_server_name		sysname,
moa_instance_name	sysname
);
checkpoint;
---
---NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
---REMEMBER YOU CAN NOT OPEN AN OPENROWSET CONNECTION TO YOURSELF 
---THUS THE MACHINE THAT THIS SCRIPT IS RUNNING ON <<<CAN NOT>>> BE IN THE LIST OF SERVERS 
---THAT GO INTO THE ##multiple_openrowset_access TABLE SHOWN BELOW.
---
insert into ##multiple_openrowset_access
(
moa_server_name,
moa_instance_name
)
values 
('UPHDBSNDC036', ''),
('UPHDBSNDC036', 'DEV'),
('UPHVDBNDC047A','SQL1'),
('UPHVDBNDC027A', 'SQL1'),
('UPHVDBNDC027B', 'SQL2');
 ---
 ---
 ---
 select moa_server_name, moa_instance_name
 from   ##multiple_openrowset_access;
 ---
 ---
 ---
declare @cms_server_name_hold		nvarchar(250)
declare @cms_instance_name_hold	nvarchar(250)
declare @linkedserver_cmd_original nvarchar(2000)
declare @linkedserver_cmd_modified nvarchar(2000)
declare @server_instance			nvarchar(2000)
declare @sql_stmt					nvarchar(2000)
---
---create work table for output from sp_msloginmappings
---
create table ##tempww 
(
LoginName nvarchar(2000),
DBname nvarchar(2000),
Username nvarchar(2000), 
AliasName nvarchar(2000)
);
---
---create work table for output from sp_msloginmappings modified with serverinstance name and sample date
---
create table ##tempww_modified
(
sample_date		datetime,
server_instance	sysname,
LoginName		nvarchar(2000),
DBname			nvarchar(2000),
Username		nvarchar(2000), 
AliasName		nvarchar(2000)
)

 
 declare server_cursor cursor static
 for
 select moa_server_name, moa_instance_name
 from ##multiple_openrowset_access
 open server_cursor;
 fetch next from server_cursor into @cms_server_name_hold, @cms_instance_name_hold
 set @linkedserver_cmd_original = 
 'EXEC master.dbo.sp_addlinkedserver @server = ''placeholdername'', @srvproduct = '''', 
                          @provider = ''sQLOLEDB'', @datasrc = ''' + @@servername + ''' '
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''placeholdername'', @optname=N''collation compatible'', @optvalue=N''true'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''placeholdername'', @optname=N''data access'', @optvalue=N''true'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''placeholdername'', @optname=N''dist'', @optvalue=N''false'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''placeholdername'', @optname=N''pub'', @optvalue=N''false'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''placeholdername'', @optname=N''rpc'', @optvalue=N''true'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''placeholdername'', @optname=N''rpc out'', @optvalue=N''true'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''placeholdername'', @optname=N''sub'', @optvalue=N''false'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''placeholdername'', @optname=N''connect timeout'', @optvalue=N''0'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''placeholdername'', @optname=N''collation name'', @optvalue=null'
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''placeholdername'', @optname=N''lazy schema validation'', @optvalue=N''false'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''placeholdername'', @optname=N''query timeout'', @optvalue=N''0'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''placeholdername'', @optname=N''use remote collation'', @optvalue=N''true'''
+ char(10)
print '*************@linkedserver_cmd_original is as follows: '
print @linkedserver_cmd_original
 while (@@fetch_status = 0)
 begin
 ---
 ---create a linked server that will be deleted immediately after use 
 ---
if @cms_instance_name_hold <> ''
begin
 set @server_instance = @cms_server_name_hold + '_' + @cms_instance_name_hold
end 
else 
begin
set @server_instance = @cms_server_name_hold 
end
print @server_instance
set @linkedserver_cmd_modified = replace(@linkedserver_cmd_original, 'placeholdername', 'sync_ids_' + @server_instance)
print @linkedserver_cmd_modified
EXEC master.dbo.sp_executesql @linkedserver_cmd_modified
---
---now grab the information from the specific server and put it into a global temp table 
---but move it right away to a table that contains the same data but with the sample date 
---and the server/instance name
---
truncate table ##tempww
set @sql_stmt = 'EXEC ' + 'sync_ids_' + @server_instance + '.master.dbo.sp_msloginmappings'
print @sql_stmt
insert into ##tempww
exec master.dbo.sp_executesql @sql_stmt
---
---Now copy data from #tempww to #tempww_modified
---
insert into ##tempww_modified
(
sample_date,
server_instance,
LoginName,
DBname,
Username,
AliasName
)
select 
	getdate()
	, @server_instance
	, LoginName
	, DBname
	, Username
	, AliasName
from ##tempww
---
---
---
set @sql_stmt = 
'exec sp_dropserver @server = ''sync_ids_' + @server_instance + ''''
print @sql_stmt 
EXEC master.dbo.sp_executesql @sql_stmt
fetch next from server_cursor into @cms_server_name_hold, @cms_instance_name_hold
end  
---
---cleanup and drop last linked server
---

 ---
 ---
 ---
close server_cursor;
deallocate server_cursor;
------------set @sql_stmt = 
------------'exec sp_dropserver @server = ''' + @server_instance + ''''
------------print @sql_stmt 
------------EXEC master.dbo.sp_executesql @sql_stmt

select *
from ##tempww_modified;
---
---
---
delete from ##tempww_modified
where DBname in ('master', 'model', 'msdb', 'tempdb', 'ReportServer', 'ReportServerTempDB');
delete from ##tempww_modified
where 
DBname is null
or 
DBname = 'NULL'
or 
DBname = 'DBATASKS'
or 
DBname like 'Spotlight%'
---
---
---
select *
from ##tempww_modified;
---
---
---
drop table ##multiple_openrowset_access
drop table ##tempww_modified
drop table ##tempww






