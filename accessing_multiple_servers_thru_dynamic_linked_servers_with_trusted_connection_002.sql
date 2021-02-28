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
---Building a global temp table for multiple TEST servers 
---
create table ##multiple_openrowset_access
(
moa_server_name		sysname,
moa_instance_name	sysname
);
checkpoint;
---
---NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
---THIS SCRIPT IS WILL BUILD A LINKED SERVER THAT IS USING THE CREDENTIALS OF THE PERSON RUNNING THE SCRIPT
---IN A TRUSTED FASHION.  THERE IS NO NEED TO BUILD OR HAVE SPECIAL ACCOUNTS SO THAT THIS SCRIPT CAN RUN 
---ON ANY SERVER SO LONG AS YOU ARE USING YOUR A1 ID
---
---
---The following have named pipes disabled
------('UPHDBSNDC036', ''),
------('UPHDBSNDC036', 'DEV'),
insert into ##multiple_openrowset_access
(
moa_server_name,
moa_instance_name
)
values 
('UPHVDBNDC026A', 'SQL1'),
('UPHVDBNDC026B', 'SQL2'),
('UPHVDBNDC047A', ''),
('UPHVDBNDC047B', 'SQL2'),
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
declare @cms_instance_name_hold		nvarchar(250)
declare @linkedserver_cmd_original 	nvarchar(2000)
declare @linkedserver_cmd_modified 	nvarchar(2000)
declare @server_instance		nvarchar(2000)
declare @server_instance_2		nvarchar(2000)
declare @sql_stmt			nvarchar(2000)
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
---create work table for output from sp_msloginmappings modified with 
---serverinstance name and sample date
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
 ---
 ---
 ---
set @linkedserver_cmd_original = 
'USE [master]'
+ char(10)
+ 'EXEC master.dbo.sp_addlinkedserver'
+ char(10)
+ '	@server= ''linkedservernameplaceholder'''
+ char(10)
+ '	, @srvproduct=N''xxx'''
+ char(10)
+ '	, @provider=N''SQLOLEDB'''
+ char(10)
+ '	, @datasrc=N''datasrcnameplaceholder'''
+ char(10)
--------------------------, @catalog=N'PAHUP_rpt' 
+ '---'
+ char(10)
+ '---To set the security context to NOT BE MADE'
+ char(10)
+ '---'
+ char(10)
+ 'EXEC master.dbo.sp_droplinkedsrvlogin'
+ char(10)
+ '	@rmtsrvname=''linkedservernameplaceholder'''
+ char(10)
+ '	, @locallogin=NULL '
+ char(10)
+ 'EXEC master.dbo.sp_addlinkedsrvlogin ''linkedservernameplaceholder'', ''TRUE'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''linkedservernameplaceholder'', @optname=N''collation compatible'', @optvalue=N''true'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''linkedservernameplaceholder'', @optname=N''data access'', @optvalue=N''true'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''linkedservernameplaceholder'', @optname=N''dist'', @optvalue=N''false'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''linkedservernameplaceholder'', @optname=N''pub'', @optvalue=N''false'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''linkedservernameplaceholder'', @optname=N''rpc'', @optvalue=N''true'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''linkedservernameplaceholder'', @optname=N''rpc out'', @optvalue=N''true'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''linkedservernameplaceholder'', @optname=N''sub'', @optvalue=N''false'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''linkedservernameplaceholder'', @optname=N''connect timeout'', @optvalue=N''0'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''linkedservernameplaceholder'', @optname=N''collation name'', @optvalue=null'
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''linkedservernameplaceholder'', @optname=N''lazy schema validation'', @optvalue=N''false'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''linkedservernameplaceholder'', @optname=N''query timeout'', @optvalue=N''0'''
+ char(10)
+ 'EXEC master.dbo.sp_serveroption @server=N''linkedservernameplaceholder'', @optname=N''use remote collation'', @optvalue=N''true'''
+ char(10)
---
---
---
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
 set @server_instance_2 = @cms_server_name_hold + '\' + @cms_instance_name_hold
end 
else 
begin
set @server_instance = @cms_server_name_hold 
set @server_instance_2 = @cms_server_name_hold 
end
print @server_instance
print @server_instance_2
set @linkedserver_cmd_modified = replace(@linkedserver_cmd_original, 'linkedservernameplaceholder',  'L_' + @server_instance)
set @linkedserver_cmd_modified = replace(@linkedserver_cmd_modified, 'datasrcnameplaceholder',  @server_instance_2)
print @linkedserver_cmd_modified
print @linkedserver_cmd_modified
EXEC master.dbo.sp_executesql @linkedserver_cmd_modified
print 'LINKED SERVER ' + @server_instance_2 + ' successfully added '
---
---BEGINNING OF YOUR CODE TO BE RUN ON MULTIPLE SERVERS HERE
---
---
---Need to use dynameic sql because linkedserver_cmd_modified is a local variable
---
set @sql_stmt =
'
select '
+ char(10)
+ '''' + @server_instance_2 + ''' as serverinstance'
+ char(10)
+ ', getdate() as sample_date'
+ char(10)
+ ', name as databasename'
+ char(10)
+ 'from [L_' + @server_instance + '].master.sys.databases'
print @sql_stmt
exec master.dbo.sp_executesql @sql_stmt








---
---END OF YOUR CODE TO BE RUN ON MULTIPLE SERVERS HERE
---
---
---Drop linked server 
---
set @sql_stmt = 
'exec master.dbo.sp_dropserver @server = ''L_' +  @server_instance + ''''
print @sql_stmt 
exec master.dbo.sp_executesql @sql_stmt
----------------------------------------------------EXEC master.dbo.sp_executesql @sql_stmt
print 'LINKED SERVER L_' + @server_instance + ' successfully dropped '
fetch next from server_cursor into @cms_server_name_hold, @cms_instance_name_hold
end  
---
---
---

 ---
 ---
 ---
close server_cursor;
deallocate server_cursor;
/*
print 'ALL IDS PRIOR TO DELETION'
print '*************************'
select *
from ##tempww_modified
order by server_instance, DBname;
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
or 
LoginName like 'UPHS\svc%'

---
---
---
print 'ALL IDS AFTER  DELETION'
print '***********************'
select *
from ##tempww_modified
order by server_instance, DBname;
---
---
---
drop table ##multiple_openrowset_access;
drop table ##tempww_modified;
drop table ##tempww;

*/




