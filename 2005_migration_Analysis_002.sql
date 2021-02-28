---
---Must run seperately from the above 
---Shows total data and log size for each data
---
select @@servername as clustername
		, a.name as databasename 
		, (
			SELECT 
-----------			DB_NAME(database_id) AS DatabaseName,
			sum((size*8)/1024) SizeMB
			FROM sys.master_files
			WHERE DB_NAME(database_id) = a.name
			group by DB_name(database_Id)
		  ) as Total_DB_Sizein_MB
from sys.databases a
where name not in 
('master', 'model', 'msdb', 'tempdb', 'ReportServer', 'ReportServerTempDB')




---
---Query_to_get_Database_Size_and_Growth_Report.sql
---
use master
go
select 
	b.name DB_Name
	, a.name Logical_name
	, a.filename File_Name
	, cast((a.size * 8.00) / 1024 as numeric(12,2)) as DB_Size_in_MB
	, case 
	  when a.growth > 100 then 'In MB' 
	  else 'In Percentage' 
	  end File_Growth
	, cast(case 
		   when a.growth > 100 then (a.growth * 8.00) / 1024
		   else (((a.size * a.growth) / 100) * 8.00) / 1024
		   end as numeric(12,2)) File_Growth_Size_in_MB
    , case 
      when ( maxsize = -1 or maxsize=268435456 ) then 'AutoGrowth Not Restricted' 
      else 'AutoGrowth Restricted' 
      end AutoGrowth_Status
from 
sysaltfiles a
join 
sysdatabases b 
on a.dbid = b.dbid
where DATABASEPROPERTYEX(b.name, 'status') = 'ONLINE'
order by b.name


---
---Query to show the sum of all mdf and ndf files as well as the sum of all ldf files by database.sql
---
---Must be run seperate from the others above
---

use master
go
select 
	b.name DB_Name
	, a.name Logical_name
	, a.filename File_Name
	, cast((a.size * 8.00) / 1024 as numeric(12,2)) as DB_Size_in_MB
	, case 
	  when a.growth > 100 then 'In MB' 
	  else 'In Percentage' 
	  end File_Growth
	, cast(case 
		   when a.growth > 100 then (a.growth * 8.00) / 1024
		   else (((a.size * a.growth) / 100) * 8.00) / 1024
		   end as numeric(12,2)) File_Growth_Size_in_MB
    , case 
      when ( maxsize = -1 or maxsize=268435456 ) then 'AutoGrowth Not Restricted' 
      else 'AutoGrowth Restricted' 
      end AutoGrowth_Status
into #temp_total_mdf_and_ldf_info
from 
sysaltfiles a
join 
sysdatabases b 
on a.dbid = b.dbid
where DATABASEPROPERTYEX(b.name, 'status') = 'ONLINE'
order by b.name
---
---
---
select	@@servername as servername
		, sum(db_size_in_mb) as total_mdf_plus_ndf_in_mb
from #temp_total_mdf_and_ldf_info
where 
file_name like '%.mdf'
or
file_name like '%.ndf';
---
---
---
select	@@servername as servername
		,sum(db_size_in_mb) as total_ldf_in_mb
from #temp_total_mdf_and_ldf_info
where 
file_name like '%.ldf';
---
---
---
drop table #temp_total_mdf_and_ldf_info 


---
---Show who has sa rights on a server
---
select name from sys.syslogins
where sysadmin = 1

---
---this is dbo_rights_all_databases_on_a_server.sql
---
---DO NOT RUN UNDER THE MASTER DATABASE ELSE DATABASES WILL BE MISSING FROM THE LIST
---
---
create table #temp_info
(
servername			sysname, 
databasename		sysname,
rolename            varchar(30),
member              varchar(50)
);
insert into #temp_Info
(
servername, 
databasename,
rolename,
member 
)
exec master.sys.sp_MSforeachdb ' use [?]
select
	@@servername as servername 
	, substring(db_name(), 1, 50) as [database_name]
	, substring(r.[name], 1, 15) as [role]
	, substring(p.[name], 1, 30) as [member] 
from 
	sys.database_role_members m
join
	sys.database_principals r 
on m.role_principal_id = r.principal_id
join
	sys.database_principals p 
on m.member_principal_id = p.principal_id
where
db_name() not in (''master'', ''model'', ''msdb'', ''tempdb'', ''ReportServer'', ''ReportServerDb'', ''DBATASKS'')
and
r.name = ''db_owner''
order by p.name, db_name()

'

select servername, databasename, member, rolename
from #temp_info
order by databasename, member;
---
---
---
drop table #temp_info
---
---
---