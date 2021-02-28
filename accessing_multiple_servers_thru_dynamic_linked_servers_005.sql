---
---This is accessing_multiple_servers_thru_dynamic_linked_servers_005.sql
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
---THIS SCRIPT SHOULD BE RUN ON UPHVDBNDC048 OR WHEREVER THE 
---AD_USER_INFO DATABASE EXISTS
---
---
---
---REMEMBER TO CHANGETHE TEMP TABLE ##multiple_openrowset_access TO A PERMANENT TABLE UNDER DBATASKS
---
---REMEMBER TO USE THE DYNAMICALLY CREATED LINKED SERVER NAME IN YOUR CODE WHICH APPEARES AFTER THE 
---LINKED SERVERS ARE CREATED.
---
---NOTE THE REMOVAL OF THE TRAILING COMMA NOTE BELOW WHEN YOU REBUILD THE LIST OF SERVERS FOR WHICH A 
---LINKED SERVER IS TO BE BUILT
---
---NOTE ALSO THAT AD IS PERIODICALLY CLEANED UP OF OLD, DISABLED, AND DELETED IDS.  THUS, THIS PROCEDURE WILL 
---<<<ONLY>>> SHOW THOSE IDS THAT ARE CURRENTLY IN AD THAT ARE MARKED AS DISABLED AND READY FOR DELETION FROM 
---ACTIVE DIRECTORY
---
---IN ORDER TO FIND USERS THAT YOU KNOW ARE NO LONGER EMPLOYED AT UPHS THAT HAVE BEEN PURGED FROM
---ACTIVE DIRECTORY YOU SHOULD USE THE FOLLOWING QUERY AGAINST EITHER THE CMS SERVERS OR 
---REPLACE THE EXISTING QUERY BELOW WITH THE FOLLOWING QUERY WITHOUT THE INSERT STATEMENT
------SELECT 
------ name, 
------ substring(name, 6, len(replace(name, 'UPHS\', ''))), 
------ type_desc 
------ FROM .master.sys.server_principals
------ WHERE 
------ TYPE IN ('U', 'S', 'G')
------ and 
------ name not like '%##%'
------ and 
------ name not like 'NT SERVICE%'
------ and 
------ name not like 'NT AUTHORITY%'
------ and 
------ name not like 'uphs\DbAdminTeam%'
------ and  
------ name <> 'sa'
------ and 
------ type_desc not in ('SQL_LOGIN')
------ and 
------ name not like ('svc%')
------ and
------ name not like ('%$')
------ and 
------ (
------ substring(name, 6, len(replace(name, 'UPHS\', ''))) like 'venat%'
------ or
------ substring(name, 6, len(replace(name, 'UPHS\', ''))) like 'chat%'
------ or
------ substring(name, 6, len(replace(name, 'UPHS\', ''))) like 'rati%'
------ or
------ substring(name, 6, len(replace(name, 'UPHS\', ''))) like 'mistr%'
------ )
------ ORDER BY name, type_desc;
---
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
---NOTE NOTE NOTE NOTE NOTE NOTE
---============================= 
---Run the following command on the CMS to get a list of server and instance names to use 
---below 
---
---REMEMBER TO REMOVE THE TRAILING COMMA FROM THE VERY LAST LINE <<<<<<<<<<<===========
---
---
---set concat_null_yields_null off 
---select 
---	'(''' 
---	+ cast(SERVERPROPERTY('MachineName') as varchar(50))
---	+ ''',''' 
---	+ cast(SERVERPROPERTY('InstanceName') as varchar(50)) 
---	+ ''')' 
---	+ ',' 
---
---
---
---
---
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
---------------('UPHSPSM1',''),
('UPHVDBNDC002',''),
('UPHAPPNDC492',''),
('SURGWEB',''),
('UPHDBSNDC120',''),
('CARETRACK',''),
('UPHAPPNDC509',''),
('UPHVDBNDC008',''),
('UPHAPPNDC514',''),
('UPHDBSNDC097',''),
('UPHDBSNDC023',''),
('UPHDBSNDC103',''),
('UPHAPPNDC285',''),
('UPHDBSNDC121',''),
('UPHAPPNDC524',''),
('UPHDBSNDC054','SQL1'),
('UPHDBSNDC055','SQL1'),
('UPHDBSNDC036','DEV'),
('UPHDBSNDC057','SQL1'),
('UPHSTDOC',''),
('UPHDBSNDC139',''),
('UPHVDBNDC027A','SQL1'),
('UPHDBSNDC092','SQL1'),
--------------('UPHAPPNDC125',''),
('UPHAPPNDC513',''),
('UPHVDBNDC027B','SQL2'),
('UPHDBSNDC098',''),
('UPHDSSNDC007',''),
('UPHVDBNDC026B','SQL2'),
('UPHVDBNDC006',''),
('UPHVDBNDC040A','DW'),
('UPHVDBNDC040A','DW'),
('UPHVDBNDC044A',''),
('UPHVDBNDC026A','SQL1'),
('LABWEB',''),
('UPHVDBNDC044C','SQL3'),
('UPHDBSPHI013',''),
('UPHVDBNDC040',''),
('UPHDBSNDC036',''),
('UPHVDBNDC052',''),
('UPHVDBNDC047A',''),
('UPHVDBNDC044D','SQL4'),
('UPHVDBNDC044B','SQL2'),
('UPHVDBNDC049A',''),
('UPHVDBNDC047B','SQL2'),
('UPHVDBNDC044E','SQL5'),
('UPHVDBNDC048',''),
('UPHDBSNDC084','PARADIGM'),
('UPHDBSPHI012','HRNNC2008R2'),
('UPHVDBNDC007',''),
('UPHVDBNDC048B','SQL2'),
('UPHDBSPHI010',''),
('UPHSPCA',''),
('UPHAPPCCH016',''),
('UPHDBSPHI001','ECWEBDB'),
('UPHDBSPHI001','ECTRAINDB'),
('UPHDBSNDC056','SQL1'),
('UPHDBSPHI001',''),
('UPHDBSCCH001',''),
('UPHVDBPHI001B','SQL2'),
('UPHAPPNDC521',''),
('UPHSCISTAGESQL',''),
('UPHVDBNDC001','');
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
sample_date		datetime,
server_name		nvarchar(2000),
instance_name		nvarchar(2000),
name			nvarchar(2000),
name_minus_domain	nvarchar(2000),
account_type		nvarchar(2000), 
action_to_be_taken	nvarchar(2000),
action_to_disable	nvarchar(2000)
);


 
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
'insert into ##tempww'
+ char(10)
+ '('
+ char(10)
+ ' sample_date, '
+ char(10)
+ ' server_name, '
+ char(10)
+ ' instance_name, '
+ char(10)
+ ' name, '
+ char(10)
+ ' name_minus_domain, '
+ char(10)
+ 'account_type, '
+ char(10)
+ 'action_to_be_taken, '
+ char(10)
+ 'action_to_disable '
+ char(10)
+ ')'
+ char(10)
+ 'SELECT '
+ char(10)
+ 'getdate(),' 
+ char(10)
+ '''' + @cms_server_name_hold + ''','
+ char(10)
+ '''' + @cms_instance_name_hold + ''','
+ char(10)
+ 'name,' 
+ char(10)
+ 'substring(name, 6, len(replace(name, ''UPHS\'', ''''))), '
+ char(10)
+ 'type_desc, '
+ char(10)
+ 'null, '
+ char(10)
+ '''' + 'ALTER LOGIN name WITH DISABLE' + ''''
+ char(10)
+ 'FROM L_' + @server_instance + '.master.sys.server_principals '
+ char(10) 
+ 'WHERE' 
+ char(10)
+ 'TYPE IN (''U'', ''S'', ''G'')'
+ char(10)
+ 'and '
+ char(10)
+ 'name not like ''%##%'''
+ char(10)
+ 'and '
+ char(10)
+ 'name not like ''NT SERVICE%'''
+ char(10)
+ 'and '
+ char(10)
+ 'name not like ''NT AUTHORITY%'''
+ char(10)
+ 'and '
+ char(10)
+ 'name not like ''uphs\DbAdminTeam%'''
+ char(10)
+ 'and ' 
+ char(10)
+ 'name <> ''sa'''
+ char(10)
+ 'and '
+ char(10)
+ 'type_desc not in (''SQL_LOGIN'')'
--------------------------+ char(10)
--------------------------+ 'and '
--------------------------+ char(10)
--------------------------+ 'name not like ''%a1%'''
+ char(10)
+ 'and '
+ char(10)
+ 'name not like (''svc%'')'
+ char(10)
+ 'and '
+ char(10)
+ 'name not like (''%$'')'
+ char(10)
+ 'ORDER BY name, type_desc;'

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

print 'ALL IDS PRIOR TO DELETION'
print '*************************'
select *
from ##tempww
where server_name = 'UPHVDBNDC006'
order by server_name, name_minus_domain;
---
---NOW COMPARE TO THE EXTINCT USERS 
---
update ##tempww
	set action_to_be_taken = 'ANALYZE AND DELETE'
where 
name_minus_domain in 
		(select top 1 NT_USER 
		 from AD_USER_INFO.[dbo].[AD_Extinct_Users_tbl] b
		 where b.NT_USER = ##tempww.name_minus_domain);

select *
from ##tempww
where action_to_be_taken is not null
order by server_name, name;

---
---Get a list of distinct names since an individual can exist on multiple servers
---
select distinct(name)
from ##tempww
where action_to_be_taken is not null
group by name
order by name;


drop table ##multiple_openrowset_access;
drop table ##tempww;








