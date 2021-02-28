---
---2005_migration_Analysis_001.sql
---
---
---Show all available information from kyle Weber's AD analysis
---
select *
from [WJB_2005_migration_conversion].[dbo].[All_Server_Database_Info]
where
clustername is not null
and 
caption like '%2005%'
order by clustername, sqlinstance, computername
---
---jUst show the cluster names for now
---
select distinct(clustername)
from [WJB_2005_migration_conversion].[dbo].[All_Server_Database_Info]
where
clustername is not null
and 
caption like '%2005%'
---
---Must run seperately from the above 
---
select @@servername as clustername
		, a.name as databasename 
		, (
			SELECT 
------------			DB_NAME(database_id) AS DatabaseName,
			sum((size*8)/1024) SizeMB
			FROM sys.master_files
			WHERE DB_NAME(database_id) = a.name
			group by DB_name(database_Id)
		  ) as Total_DB_Sizein_MB
from sys.databases a
where name not in 
('master', 'model', 'msdb', 'tempdb', 'ReportServer', 'ReportServerTempDB')
