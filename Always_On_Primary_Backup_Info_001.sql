---
---This is Always_On_Primary_Backup_Info_001.sql
---
drop table if exists #AG_INFO
drop table if exists #FILE_INFO
---
---
---
SELECT
	@@servername as servername
	, Groups.[Name] AS AGname
	, AGDatabases.database_name AS Databasename
	, sys.fn_hadr_is_primary_replica (AGDatabases.database_name) as primary_replica_setting
	, case 
		when sys.fn_hadr_is_primary_replica (AGDatabases.database_name) <> 1 then 'THIS DATABASE IS NOT A PRIMARY REPLICA--BACKUP NOT POSSIBLE'
	  else 'THIS DATABASE IS A PRIMARY REPLICA--BACKUP IS POSSIBLE'
      end as Backup_Possible
INTO #AG_INFO
FROM 
sys.dm_hadr_availability_group_states States
INNER JOIN 
master.sys.availability_groups Groups 
ON 
States.group_id = Groups.group_id
INNER JOIN 
sys.availability_databases_cluster AGDatabases 
ON 
Groups.group_id = AGDatabases.group_id
WHERE 
primary_replica = @@Servername
ORDER BY
	AGname ASC,
	Databasename ASC;
---
---
---
SELECT
    d.name AS 'Database_Name',
    m.name AS 'File_Name',
    m.size as size_in_bytes,
    m.size * 8/1024 'Size_in_MB',
    SUM(m.size * 8/1024) OVER (PARTITION BY d.name) AS 'Database Total',
    m.max_size
INTO #FILE_INFO
FROM sys.master_files m
INNER JOIN sys.databases d ON
d.database_id = m.database_id;
---
---
---
select
	'***AVAILABILITY_INFO***'
	, AG.*
	, '***FILE_INFO***'
	, FI.*
from 
	#AG_INFO AG
INNER JOIN
	#FILE_INFO FI
ON
AG.Databasename = FI.Database_Name;