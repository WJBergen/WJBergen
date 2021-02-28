---Author:		William J. Bergen  <<<<<<<<<needs text msg for dbs offline>>>>>>>>>>
---
---Date:		10/05/12
---
---Purpose:		The purpose of this stored procedure is to check the status of all services
---				that pertain to SQL Server and if they are NOT required services send an HTML
---				email indicating the status is NOT in a RUNNING state.
---				The short name for this procedure is MS4C
---				This stored procedure requires a table to exist as follows:
---			CREATE TABLE DBATASKS.[dbo].[monitored_services_servers]
---                     (
---	                 [servername] [nvarchar](50) NOT NULL
---                     ) ON [PRIMARY]
---
---01/17/2017 major modification by Bill Bergen to handle the following:
---NOTE:  the server name on which this script is to run must be eleminated from the list of servers 
---being checked.  This must be hard coded to avoid the necessity of dynamic sql if @@servername was used.
---Not only does this version of the script check to see if the required services (database engine and 
---sql agent) are started but it uses openrowset to check all databases on all servers being checked to see 
---if they are online and in multiuser mode and not in read only mode.
---if any of these conditions exist then an email will be sent to the dbateam with an html report attached
---
---
--- 
---				

USE [DBATASKS]
go
/****** Object:  Table [dbo].[monitored_services_servers]    Script Date: 10/05/2012 13:16:30 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[monitored_services_servers]') AND type in (N'U'))
begin
DROP TABLE [dbo].[monitored_services_servers]
end
USE [DBATASKS]
go

/****** Object:  Table [dbo].[monitored_services_servers]    Script Date: 10/05/2012 13:16:30 ******/
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

CREATE TABLE DBATASKS.[dbo].[monitored_services_servers]
(
	[servername] [nvarchar](50) NOT NULL
) ON [PRIMARY]
---
---the following insert statements come from running the following command against the cms registered 
---servers on uphappndc521
---select 'insert into DBATASKS.dbo.monitored_services_servers  values(''' + ltrim(rtrim(@@servername)) + ''');'
---
insert into DBATASKS.dbo.monitored_services_servers  values('SURGWEB');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHAPPNDC492');
insert into DBATASKS.dbo.monitored_services_servers  values('CARETRACK');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHAPPNDC509');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHAPPNDC514');
insert into DBATASKS.dbo.monitored_services_servers  values('LABWEB');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHAPPCCH016');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHAPPNDC285');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSNDC057\SQL1');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSNDC036\DEV');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSNDC036');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHAPPNDC524');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSNDC084\PARADIGM');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSNDC120');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHAPPNDC513');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSNDC103');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSNDC092\SQL1');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSNDC121');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSNDC098');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSNDC054\SQL1');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSNDC023');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSNDC139');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDSSNDC007');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHSCISTAGESQL');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC002');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC001');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHSTDOC');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC008');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC027A\SQL1');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC026B\SQL2');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC027B\SQL2');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSPHI013');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC006');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSCCH001');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC052');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC040');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC044A');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC044E\SQL5');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC026A\SQL1');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC044D\SQL4');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSPHI001\ECWEBDB');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSPHI001\ECTRAINDB');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSPHI012\HRNNC2008R2');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC044C\SQL3');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSPHI001');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC044B\SQL2');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHSPCA');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC048');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC048B\SQL2');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC047A');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSNDC097');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC047B\SQL2');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSPHI010');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC049A');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHAPPNDC521');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBPHI001B\SQL2');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC040A\DW');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC007');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSNDC056\sql1');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHVDBNDC040A\DW');
insert into DBATASKS.dbo.monitored_services_servers  values('UPHDBSNDC055\SQL1');




---				This table will contain the name of each server on which the services are to be 
---				checked.
---				NOTE: IN ORDER TO AVOID FALSE MESSAGES INDICATING THAT A REQUIRED SERVICES NOT
---				IN A RUNNING STATE USE THE VIRTUAL SQL SERVER CLUSTER NAME RATHER THAN THE 
---				PHYSICAL NODE NAMES.
---				There is an outer loop for the server names and an inner look which cleans up 
---				the multi-line output from the 
---				SC \\servername query type= service
---				service control command.
---				The outer loop provides the server names.
---				The output from the SC command shown above looks like the following:
---
/*
SERVICE_NAME: MSDTC
DISPLAY_NAME: Distributed Transaction Coordinator
        TYPE               : 10  WIN32_OWN_PROCESS  
        STATE              : 4  RUNNING 
                                (STOPPABLE, NOT_PAUSABLE, ACCEPTS_SHUTDOWN)
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x0
        WAIT_HINT          : 0x0

SERVICE_NAME: msftesql
DISPLAY_NAME: SQL Server FullText Search (MSSQLSERVER)
        TYPE               : 10  WIN32_OWN_PROCESS  
        STATE              : 4  RUNNING 
                                (STOPPABLE, NOT_PAUSABLE, ACCEPTS_SHUTDOWN)
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x0
        WAIT_HINT          : 0x0

SERVICE_NAME: MSSQLSERVER
DISPLAY_NAME: SQL Server (MSSQLSERVER)
        TYPE               : 10  WIN32_OWN_PROCESS  
        STATE              : 4  RUNNING 
                                (STOPPABLE, PAUSABLE, ACCEPTS_SHUTDOWN)
        WIN32_EXIT_CODE    : 0  (0x0)
        SERVICE_EXIT_CODE  : 0  (0x0)
        CHECKPOINT         : 0x0
        WAIT_HINT          : 0x0
*/
---
---				The only lines of output that we are interested in are the 
---				SERVICE_NAME, DISPLAY_NAME, STATE and the line after the state which shows
---				the states that the server could be changed to.
---
---				The output when the four lines are concatenated looks like the following 
---				(note---the output is all on a single line rather than the way it is broken up 
---				 above --- spaces are removed for ease in viewing)
---surrogate_key  servername     sample_date              cola                        colb                                              colc                cold
----------------- -------------- ------------------------ --------------------------- ------------------------------------------------- ------------------  -------------------------------------------
---193            UPHAPPNDC233   2012-10-05 13:29:10.813  SERVICE_NAME: MSDTC         DISPLAY_NAME: Distributed Transaction Coordinator STATE : 4  RUNNING  (STOPPABLE, NOT_PAUSABLE, ACCEPTS_SHUTDOWN)
---196            UPHAPPNDC233   2012-10-05 13:29:10.813  SERVICE_NAME: MSSQLSERVER   DISPLAY_NAME: SQL Server (MSSQLSERVER)            STATE : 4  RUNNING  (STOPPABLE, PAUSABLE, ACCEPTS_SHUTDOWN)
---
---
---				In the event that a state OTHER than RUNNING is generated for the required services names of 
---				MSSQLSERVER and SQLSERVERAGENT an html email will be sent to sqlalerts indicating that 
---				the service is has a status that is NOT RUNNING and that action needs to be taken.
---

set nocount on 
set @version					int 
set @version = 7
print 'This is version ===> ' + ltrim(rtrim(cast(@version as char)))
declare	@counter				int
declare	@database_problems_hold	int
declare	@line_info_hold			varchar(3000)
declare	@line_info_hold_a		varchar(3000)
declare	@line_info_hold_b		varchar(3000)
declare	@line_info_hold_c		varchar(3000)
declare	@line_info_hold_d		varchar(3000)
declare	@sc_cmd					varchar(3000)
declare	@server_name_hold		sysname
declare	@cola_hold				varchar(3000)
declare	@colc_hold				varchar(3000)
declare	@msg					varchar(3000)
declare	@rc						int
create table #service_control_output_work_1
(
cola			varchar(3000)
)
---
---
---
create table #service_control_output_work_2
(
surrogate_key	bigint identity(1, 1),
servername		sysname,
sample_date		datetime,
cola			varchar(3000),
colb			varchar(3000),
colc			varchar(3000),
cold			varchar(3000)
)
---
---
---
create table #service_control_output
(
sample_date			datetime,
server_name			sysname,
service_name		sysname,
service_state		varchar(1000),
service_state_2		varchar(1000)
)
---
---
---
declare server_cursor cursor static 
for 
select servername 
from DBATASKS.dbo.monitored_services_servers
order by servername
open server_cursor
fetch server_cursor into @server_name_hold
while (@@fetch_status = 0)
begin
print 'working on server ' + @server_name_hold
set @sc_cmd = 'SC \\' + ltrim(rtrim(@server_name_hold)) + ' query type= service '
print @sc_cmd
---
---
---
insert into #service_control_output_work_1
(
cola
)
---------EXEC xp_cmdshell 'SC \\MJHXCL8-THINK query "MSSQLServer" '
---------EXEC xp_cmdshell 'SC \\MJHXCL8-THINK query "MSSQLServer" | FIND "STATE"'
---------EXEC xp_cmdshell 'SC \\UPHVDBNDC007 query type= service '
EXEC master.dbo.xp_cmdshell @sc_cmd
---
---
---
delete from #service_control_output_work_1
where 
cola is null
or
cola like '%NULL%'
or 
cola like '%TYPE%'
or
cola like '%WIN32%'
or 
cola like '%SERVICE_EXIT_CODE%'
or 
cola like '%CHECKPOINT%'
or
cola like '%WAIT_HINT%'
---
---FOR DEBUGGING
---
/*
print 'BEFORE'
select *
from #service_control_output_work_1
*/
---
---
---
declare row_cursor cursor static
for 
select * 
from #service_control_output_work_1
set @counter = 0
open row_cursor 
fetch row_cursor into @line_info_hold
set @counter = 1
while (@@fetch_status = 0)
begin
if @counter = 1 
begin
set @line_info_hold_a = @line_info_hold
end 
---
if @counter = 2 
begin
set @line_info_hold_b = @line_info_hold
end
---
if @counter = 3 
begin
set @line_info_hold_c = @line_info_hold
end 
---
if @counter = 4
begin
set @line_info_hold_d = @line_info_hold
insert into #service_control_output_work_2
(
servername,
sample_date,
cola,
colb,
colc,
cold
)
values (@server_name_hold, getdate(), @line_info_hold_a, @line_info_hold_b, @line_info_hold_c, @line_info_hold_d)
set @counter = 0
---
---
---
---
---FOR DEBUGGING
---
/*
print 'Intermediate pre-delete'
select *
from #service_control_output_work_2;
*/
---
---
---
delete top (4) from #service_control_output_work_1
end
fetch row_cursor into @line_info_hold
set @counter = @counter + 1
end
close row_cursor
deallocate row_cursor
---
---Check only the SQL Server serices
---
delete 
from #service_control_output_work_2
where  
cola not like '%MSSQLServer%' 
and
cola not like  '%SQLServerAGENT%'
and
cola not like  '%MSDTC%'
and
cola not like  '%%sqlbrowser%'
and
cola not like  '%MSSQLServerOLAPService%'
and
cola not like  '%ReportServer%'
---
---
---
---
---FOR DEBUGGING
---
/*
print 'Intermediate post-delete'
select *
from #service_control_output_work_2
*/
---
---
---
fetch server_cursor into @server_name_hold
end
close server_cursor
deallocate server_cursor
---
---Now create the HTML email for MSSQLSERVER not RUNNING or SQLSERVERAGENT not RUNNING
---A cursor is require in case multiple servers are down then multiple messages will be 
---sent 
---
declare service_cursor cursor static
for
select servername, cola, colc
from #service_control_output_work_2
where
( 
cola like 'SERVICE_NAME: MSSQLSERVER%'
and 
colc not like '%RUNNING%'
)
or
( 
cola like 'SERVICE_NAME: SQLSERVERAGENT%'
and 
colc not like '%RUNNING%'
)
order by servername, sample_date, cola;
open service_cursor
fetch service_cursor into @server_name_hold, @cola_hold, @colc_hold
while (@@fetch_status = 0)
begin
set @msg = 'The sql server <b>'	+ @server_name_hold + '</b>' +
			+ ' has service <b>'	+ @cola_hold + '</b>' +
			+ ' with status <b>'   + @colc_hold+ '</b>' 
EXEC @rc = msdb.dbo.sp_send_dbmail
------     @recipients = ''SQLDBAlerts@uphs.upenn.edu',
     @recipients = 'william.bergen@uphs.upenn.edu',
     @importance = 'high',
     @subject = 'Multiple_Server_SQL_Server_Service_Checker',
     @body_format = 'html',
     @body = @msg,
     @exclude_query_output = 1
fetch service_cursor into @server_name_hold, @cola_hold, @colc_hold
end
---
---
---
close service_cursor;
deallocate service_cursor;
---
---FOR DEBUGGING 
---
/*
select * from #service_control_output_work_1;
select * from #service_control_output_work_2;
select * from #service_control_output;
*/
---
---create the temp table to hold all the info for all the databases on all the servers being checked
---one for work and one with the current date (sample date addeded)
select top 0
	@@servername as servername 
	, [name] as databasename
	, database_id
	, user_access_desc
	, state_desc
	, is_read_only
	, is_auto_close_on
	, is_auto_shrink_on
	, is_in_standby
	, is_cleanly_shutdown
into #temp_server_database_status_work
from sys.databases 
where 
user_access_desc <> 'MULTIUSER'
or 
state_desc <> 'ONLINE'
or 
is_read_only = 1
order by name;
---
---
---
select top 0
	@@servername as servername 
	, [name] as databasename
	, database_id
	, user_access_desc
	, state_desc
	, is_read_only
	, is_auto_close_on
	, is_auto_shrink_on
	, is_in_standby
	, is_cleanly_shutdown
	, getdate() as sample_date
into #temp_server_database_status
from sys.databases 
where 
user_access_desc <> 'MULTIUSER'
or 
state_desc <> 'ONLINE'
or 
is_read_only = 1
order by name;




---
---now we want to do an open query against the same servers used above to 
---determine if there are any databases that are not multiuser, not online or in read only status 
---the following is the query that is used to determine these conditions 
---select 
---	@@servername as servername 
---	, name as databasename
---	, database_id
---	, user_access_desc
---	, state_desc
---	, is_read_only
---	, is_auto_close_on
---	, is_auto_shrink_on
---	, is_in_standby
---	, is_cleanly_shutdown
---from sys.databases 
---where 
---user_access_desc <> 'MULTIUSER'
---or 
---state_desc <> 'ONLINE'
---or 
---is_read_only = 1
---order by name
---
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

---
---NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
---REMEMBER YOU CAN NOT OPEN AN OPENROWSET CONNECTION TO YOURSELF 
---THUS THE MACHINE THAT THIS SCRIPT IS RUNNING ON <<<CAN NOT>>> BE IN THE LIST OF SERVERS 
---THAT GO INTO THE #MULTIPLE_OPENROWSET_ACCESS TABLE SHOWN BELOW.
---

 ---
 ---
 ---
select [servername]
from   DBATASKS.dbo.monitored_services_servers   
where [servername] not like '%UPHAPPNDC521%';
 ---
 ---
 ---
 declare @openrowset_cmd_original	nvarchar(2000);
 declare @openrowset_cmd_modified	nvarchar(2000);
 declare @sql_stmt					nvarchar(2000);
 set @sql_stmt = 
'
select 
	@@servername as servername 
	, [name] as databasename
	, database_id
	, user_access_desc
	, state_desc
	, is_read_only
	, is_auto_close_on
	, is_auto_shrink_on
	, is_in_standby
	, is_cleanly_shutdown
from sys.databases 
where 
user_access_desc <> ''''MULTIUSER''''
or 
state_desc <> ''''ONLINE''''
or 
is_read_only = 1
order by [name]
---------------------------END OF EXTRACTION
'
print @sql_stmt
set @openrowset_cmd_original = 
' 
 SELECT  * 
   FROM    OPENROWSET (''SQLOLEDB'',''Server=targetservernametargetinstancename;Trusted_Connection=yes;'','''
+ @sql_stmt 
+ ''');'


print '@openrowset_cmd_original ****************************************************************'
print @openrowset_cmd_original
declare server_cursor cursor static
for
select [servername]
 from   DBATASKS.dbo.monitored_services_servers
where [servername] not like '%UPHAPPNDC521%';
open server_cursor;
fetch next from server_cursor into @server_name_hold
while (@@fetch_status = 0)
begin
print 'checking datbases on server ===> ' + @server_name_hold;
set @openrowset_cmd_modified = null;
set @openrowset_cmd_modified = @openrowset_cmd_original;
set @openrowset_cmd_modified = replace(@openrowset_cmd_modified, 'targetservernametargetinstancename', @server_name_hold)
print @openrowset_cmd_modified
print '@openrowset_cmd_modified ****************************************************************'
insert into #temp_server_database_status_work
exec master.sys.sp_executesql @openrowset_cmd_modified;
fetch next from server_cursor into @server_name_hold;
end 
close server_cursor;
deallocate server_cursor;

---
---
---
insert into #temp_server_database_status
select *
from #temp_server_database_status
---
---FOR DEBUGGING ONLY
---
print 'FOR DEBUGGING ONLY'
select *
from #temp_server_database_status
---
---
---
select *
from #temp_server_database_status
where 
user_access_desc <> 'MULTIUSER'
or 
state_desc <> 'ONLINE'
or 
is_read_only = 1
order by servername, databasename;
---
---determine if an email needs to be sent
---
set @database_problems_hold = 0
select @database_problems_hold = count(*)
from #temp_server_database_status
where 
user_access_desc <> 'MULTIUSER'
or 
state_desc <> 'ONLINE'
or 
is_read_only = 1
order by servername, databasename;
if @database_problems_hold <> 0
begin




end
---
---
---
drop table #service_control_output_work_1
drop table #service_control_output_work_2
drop table #service_control_output
drop table #temp_server_database_status_work;
drop table #temp_server_database_status;
set nocount off 


