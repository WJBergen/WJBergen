---
---This is Auditing_Server_Database_Owner_from_MAPS_and_Aimees_List_001.sql
---
select *
from Full_Information_set
---
---
---
update [Server_DBOwner_Application_Information].[dbo].[Full_Information_set]
	set [Computer Name] = replace([Computer Name], '.UPHS.PENNHEALTH.PRV', '')
---
---
---
select *
from [Server_DBOwner_Application_Information].[dbo].[SevOwn]
where 
[database name] <> ''
and 
server like 'UPHVDB%'
---
---
---
select 
	fis.[Computer Name]
	, fis.[SQL Server Instance Name]
	, fis.[SQL Server Product Name]
	, fis.[SQL Server Version]
	, fis.[SQL Server Service Pack]
	, fis.[SQL Server Edition]
	, fis.[clustered?]
	, fis.[SQL Server Cluster Network Name]
	, fis.[Current Operating System]
	, fis.[Operating System Service Pack Level]
	, fis.[Machine Type]
	, so.[Owner] as ServerOwner
	, so.notes
into #temp1
from 
[Server_DBOwner_Application_Information].[dbo].[Full_Information_set] fis
join
[Server_DBOwner_Application_Information].[dbo].[SevOwn] so
on 
fis.[Computer Name] = so.server
where 
so.[Database Name] = ''
---
---
---
select 
	fis.[Computer Name]
	, fis.[SQL Server Instance Name]
	, fis.[SQL Server Product Name]
	, fis.[SQL Server Version]
	, fis.[SQL Server Service Pack]
	, fis.[SQL Server Edition]
	, fis.[clustered?]
	, fis.[SQL Server Cluster Network Name]
	, fis.[Current Operating System]
	, fis.[Operating System Service Pack Level]
	, fis.[Machine Type]
	, so.[Database Name]
	, so.[Owner] as DatabaseOwner
	, so.notes
into #temp2
from 
[Server_DBOwner_Application_Information].[dbo].[Full_Information_set] fis
join
[Server_DBOwner_Application_Information].[dbo].[SevOwn] so
on 
so.server like fis.[SQL Server Cluster Network Name]
where 
so.[Database Name] <> ''
---
---
---
select *
from #temp1
select *
from #temp2
---
---
---




---
---
---
drop table #temp1
drop table #temp2


---
---Phase II
---

select [Database Name]
		, substring([Database Name], 1, (charindex(char(9), [Database Name], 1) ))
from 
[Server_DBOwner_Application_Information].[dbo].[SqlServerDatabaseDetails-08-09-2016-13h20m10s_ALL_SHEETS_DB_SUMMARY_SHEET] 





update [Server_DBOwner_Application_Information].[dbo].[SqlServerDatabaseDetails-08-09-2016-13h20m10s_ALL_SHEETS_DB_SUMMARY_SHEET] 
set [Database Name] = 
	substring([Database Name], 1, (charindex(char(9), [Database Name], 1) ))


update [Server_DBOwner_Application_Information].[dbo].[SqlServerDatabaseDetails-08-09-2016-13h20m10s_ALL_SHEETS_DB_SUMMARY_SHEET] 
set [Server Name] = 
	replace(cast([Server Name] as varchar(max)), '.UPHS.PENNHEALTH.PRV', '')

update [Server_DBOwner_Application_Information].[dbo].[SqlServerAssessment-08-09-2016_GOOD_LIST]
set [Computer Name] = 
	replace(cast([Computer Name] as varchar(max)), '.UPHS.PENNHEALTH.PRV', '')

select 
	a.[Computer Name]
	, a.[SQL Server Instance Name]
	, a.[SQL Server Product Name]
	, a.[SQL Server Service Pack]
	, a.[SQL Server Edition]
	, a.[Clustered?]
	, a.[SQL Server Cluster Network Name]
	, a.[Current Operating System]
	, a.[Operating System Service Pack Level]
	, a.[Machine Type]
	, b.[SQL Server Database Engine Instance Name]
	, b.[SQL Server Product Name]
	, b.[Database Name]

from 
[Server_DBOwner_Application_Information].[dbo].[SqlServerAssessment-08-09-2016_GOOD_LIST] a
join
[Server_DBOwner_Application_Information].[dbo].[SqlServerDatabaseDetails-08-09-2016-13h20m10s_ALL_SHEETS_DB_SUMMARY_SHEET] b
on 
cast(a.[Computer Name] as varchar(max)) = cast(b.[Server Name] as varchar(max))
where 
cast(b.[Database Name] as varchar(max)) not in
('master', 'model', 'msdb', 'tempdb', 'DBATASKS', 'ReportServerTempDB')  ---<<<<problems










---
---
---

