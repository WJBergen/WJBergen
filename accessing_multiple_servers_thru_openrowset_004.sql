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
set concat_null_yields_null off
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

('UPHAPPNDC521', ''),
('SURGWEB', ''),
('UPHAPPNDC492', ''),
('UPHAPPNDC524', ''),
('UPHDBSNDC120', ''),
('UPHAPPNDC285', ''),
('UPHDBSNDC057', 'SQL1'),
('UPHDBSNDC103', ''),
('UPHDBSNDC023', ''),
('UPHAPPNDC513', ''),
('UPHDBSNDC036', ''),
('UPHAPPNDC509', ''),
('CARETRACK', ''),
('UPHAPPNDC514', ''),
('UPHDBSNDC036', 'DEV'),
('UPHDBSNDC084', 'paradigm'),
---------------('UPHAPPNDC125', ''),
('UPHDBSNDC139', ''),
('UPHDBSNDC056', 'SQL1'),
('UPHDBSNDC092', 'SQL1'),
('UPHDBSNDC121', ''),
('UPHDBSNDC098', ''),
('UPHDBSNDC055', 'SQL1'),
---------------('UPHSPSM1', ''),
('UPHDSSNDC007', ''),
('UPHVDBNDC008', ''),
('UPHSTDOC', ''),
('UPHSCISTAGESQL', ''),
('UPHVDBNDC002', ''),
('LABWEB', ''),
('UPHVDBNDC027A', 'SQL1'),
('UPHVDBNDC027B', 'SQL2'),
('UPHVDBNDC026A', 'SQL1'),
('UPHVDBNDC026B', 'SQL2'),
('UPHVDBNDC006', ''),
('UPHVDBNDC047A', ''),
('UPHVDBNDC047B', 'SQL2'),
('UPHVDBNDC040', ''),
('UPHVDBNDC040A', ''),
('UPHVDBNDC040A', 'DW'),
('UPHDBSPHI013', ''),
('UPHVDBNDC044D', 'SQL4'),
('UPHAPPCCH016', ''),
('UPHVDBNDC052', ''),
('UPHVDBNDC044A', ''),
('UPHVDBNDC044E', 'SQL5'),
('UPHVDBNDC044C', 'SQL3'),
('UPHVDBNDC044B', 'SQL2'),
('UPHVDBNDC049A', ''),
('UPHVDBNDC048B', 'SQL2'),
('UPHVDBNDC048', ''),
('UPHDBSPHI001', 'ECTRAINDB'),
('UPHDBSPHI012', 'HRNNC2008R2'),
('UPHDBSPHI001', 'ECWEBDB'),
('UPHDBSCCH001', ''),
('UPHDBSPHI001', ''),
('UPHSPCA', ''),
('UPHDBSPHI010', ''),
('UPHVDBPHI001B', 'SQL2'),
('UPHDBSNDC097', ''),
('UPHVDBNDC007', ''),
('UPHDBSNDC054', 'SQL1'),
('UPHVDBNDC001', '')

;
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
 ''
 set concat_null_yields_null off
---
---This is List_All_Domain_Ids_on_a_Server_001.sql
---
CREATE TABLE ##tempww 
(
    LoginName nvarchar(max),
    DBname nvarchar(max),
    Username nvarchar(max), 
    AliasName nvarchar(max)
);

INSERT INTO ##tempww 
EXEC master..sp_msloginmappings ;

-- display results ONLY for domain ids
delete from ##tempww
where 
LoginName not like ''''UPHS\%'''';
---
---dont analyze the service accounts
---
delete from ##tempww
where 
LoginName like ''''UPHS\svc%'''';
---
---delete UPHS\DbAdminTeam
---
delete from ##tempww
where 
LoginName = ''''UPHS\DbAdminTeam'''';
---
---
---

SELECT * 
FROM   ##tempww 
ORDER BY LoginName;

----------------select COUNT(distinct LoginName)
----------------FROM   ##tempww;
-------------------
-------------------
-------------------
----------------SELECT distinct LoginName 
----------------FROM   ##tempww 
----------------ORDER BY LoginName;

-- cleanup
DROP TABLE ##tempww;
---------------------------END OF EXTRACTION
''
'
----------------------print '@sql_stmt ****************************************************************'
print @sql_stmt
set @openrowset_cmd_original = 
' 
 SELECT  * 
   FROM    OPENROWSET (''SQLOLEDB'',''Server=targetservernametargetinstancename;Trusted_Connection=yes;'','
+ @sql_stmt 
+ ')'


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
 -------set @openrowset_cmd_modified = replace(@openrowset_cmd_original, 'server\instance', @cms_server_name_hold + '\' + @cms_instance_name_hold)
 set @openrowset_cmd_modified = null
  if @cms_instance_name_hold is not null
 begin
 set @openrowset_cmd_modified = replace(@openrowset_cmd_modified, 'targetservernametargetinstancename', @cms_server_name_hold + '\' +@cms_instance_name_hold)
 end
 else  ---for unnamed instances
 begin
 set @openrowset_cmd_modified = replace(@openrowset_cmd_modified, 'targetservernametargetinstancename', @cms_server_name_hold)
 end
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






