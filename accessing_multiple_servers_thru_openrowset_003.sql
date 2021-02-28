---
---This is accessing_multiple_servers_thru_openrowset_003.sql
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
---REMEMBER TO CHANGETHE TEMP TABLE #multiple_openrowset_access TO A PERMANENT TABLE UNDER DBATASKS
---
USE [DBATASKS]
GO

/****** Object:  Table [dbo].[old_file_info_components]    Script Date: 10/24/2014 11:59:56 ******/
IF  EXISTS (SELECT * FROM DBATASKS.sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[old_file_info_components_all_servers]') AND type in (N'U'))
DROP TABLE DBATASKS.[dbo].[old_file_info_components_all_servers]
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
create table #multiple_openrowset_access
(
moa_server_name		sysname,
moa_instance_name	sysname
);
checkpoint;
---
---NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
---REMEMBER YOU CAN NOT OPEN AN OPENROWSET CONNECTION TO YOURSELF 
---THUS THE MACHINE THAT THIS SCRIPT IS RUNNING ON <<<CAN NOT>>> BE IN THE LIST OF SERVERS 
---THAT GO INTO THE #MULTIPLE_OPENROWSET_ACCESS TABLE SHOWN BELOW.
---
insert into #multiple_openrowset_access
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
 from   #multiple_openrowset_access;
 ---
 ---
 ---
 declare @cms_server_name_hold		nvarchar(250)
 declare @cms_instance_name_hold	nvarchar(250)
 declare @openrowset_cmd_original	nvarchar(2000)
 declare @openrowset_cmd_modified	nvarchar(2000)
 declare @sql_stmt					nvarchar(2000)
 set @sql_stmt = 
 '
 ''''
---
---This is List_All_Domain_Ids_on_a_Server_001.sql
---
CREATE TABLE #tempww 
(
    LoginName nvarchar(max),
    DBname nvarchar(max),
    Username nvarchar(max), 
    AliasName nvarchar(max)
)

INSERT INTO #tempww 
EXEC master..sp_msloginmappings 

-- display results ONLY for domain ids
delete from #tempww
where 
LoginName not like ''UPHS\%''
---
---dont analyze the service accounts
---
delete from #tempww
where 
LoginName like ''UPHS\svc%''
---
---
---
print ''SHOW ALL DOMAIN USER INFO''
print ''*************************''
SELECT * 
FROM   #tempww 
ORDER BY LoginName
print ''SHOW COUNT OF ALL DOMAIN USER INFO''
print ''**********************************''
select COUNT(distinct LoginName)
FROM   #tempww
---
---
---
print ''SHOW DISTINCT DOMAIN USER INFO''
print ''******************************''
SELECT distinct LoginName 
FROM   #tempww 
ORDER BY LoginName

-- cleanup
DROP TABLE #tempww
''''
'
print '@sql_stmt ****************************************************************'
print @sql_stmt
set @openrowset_cmd_original = 
' 
 SELECT  * 
   FROM    OPENROWSET (''SQLOLEDB'',''Server=targetservername; INSTANCENAME=targetinstancename;Trusted_Connection=yes;'','
+ @sql_stmt 


 print '@openrowset_cmd_original ****************************************************************'
  print @openrowset_cmd_original
 print @openrowset_cmd_original
 declare server_cursor cursor static
 for
 select moa_server_name, moa_instance_name
 from #multiple_openrowset_access
 open server_cursor;
 fetch next from server_cursor into @cms_server_name_hold, @cms_instance_name_hold
 while (@@fetch_status = 0)
 begin
 set @openrowset_cmd_modified = replace(@openrowset_cmd_original, 'targetservername', @cms_server_name_hold)
 set @openrowset_cmd_modified = replace(@openrowset_cmd_modified, 'targetinstancename', @cms_instance_name_hold)
 print @openrowset_cmd_modified
 ----------------insert into [DBATASKS].[dbo].[old_file_info_components_all_servers]
 exec master.sys.sp_executesql @openrowset_cmd_modified
 fetch next from server_cursor into @cms_server_name_hold, @cms_instance_name_hold

 end 
 close server_cursor;
 deallocate server_cursor;

 ---
 ---
 ---
 drop table #multiple_openrowset_access;




















---------------------------------------------
---------------------------------------------
--------------------------------------------
---
---This is accessing_multiple_servers_thru_openrowset_002.sql
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
---REMEMBER TO CHANGETHE TEMP TABLE #multiple_openrowset_access TO A PERMANENT TABLE UNDER DBATASKS
---
USE [DBATASKS]
GO

/****** Object:  Table [dbo].[old_file_info_components]    Script Date: 10/24/2014 11:59:56 ******/
IF  EXISTS (SELECT * FROM DBATASKS.sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[old_file_info_components_all_servers]') AND type in (N'U'))
DROP TABLE DBATASKS.[dbo].[old_file_info_components_all_servers]
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
create table #multiple_openrowset_access
(
moa_server_name		sysname,
moa_instance_name	sysname
);
checkpoint;
---
---NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
---REMEMBER YOU CAN NOT OPEN AN OPENROWSET CONNECTION TO YOURSELF 
---THUS THE MACHINE THAT THIS SCRIPT IS RUNNING ON <<<CAN NOT>>> BE IN THE LIST OF SERVERS 
---THAT GO INTO THE #MULTIPLE_OPENROWSET_ACCESS TABLE SHOWN BELOW.
---
insert into #multiple_openrowset_access
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
 from   #multiple_openrowset_access;
 ---
 ---
 ---
 declare @cms_server_name_hold		nvarchar(250)
 declare @cms_instance_name_hold	nvarchar(250)
 declare @openrowset_cmd_original	nvarchar(2000)
 declare @openrowset_cmd_modified	nvarchar(2000)
 declare @sql_stmt					nvarchar(2000)
---set @sql_stmt = 
 print '@sql_stmt ****************************************************************'
print @sql_stmt
set @openrowset_cmd_original = 
' 
 SELECT  * 
   FROM    OPENROWSET (''SQLOLEDB'',''Server=targetservername; INSTANCENAME=targetinstancename;Trusted_Connection=yes;'',  
   ''CREATE TABLE #tempww (LoginName nvarchar(max), DBname nvarchar(max), Username nvarchar(max), AliasName nvarchar(max)); insert into #tempww EXEC master..sp_msloginmappings; select * from #tempww; drop table #tempww '') as tbl
'

 print '@openrowset_cmd_original ****************************************************************'
 print @openrowset_cmd_original
 declare server_cursor cursor static
 for
 select moa_server_name, moa_instance_name
 from #multiple_openrowset_access
 open server_cursor;
 fetch next from server_cursor into @cms_server_name_hold, @cms_instance_name_hold
 while (@@fetch_status = 0)
 begin
 set @openrowset_cmd_modified = replace(@openrowset_cmd_original, 'targetservername', @cms_server_name_hold)
 set @openrowset_cmd_modified = replace(@openrowset_cmd_modified, 'targetinstancename', @cms_instance_name_hold)
 print @openrowset_cmd_modified
 ----------------insert into [DBATASKS].[dbo].[old_file_info_components_all_servers]
 exec master.sys.sp_executesql @openrowset_cmd_modified
 fetch next from server_cursor into @cms_server_name_hold, @cms_instance_name_hold

 end 
 close server_cursor;
 deallocate server_cursor;

 ---
 ---
 ---
 drop table #multiple_openrowset_access;

