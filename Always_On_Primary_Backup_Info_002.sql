---
---This is Always_On_Primary_Backup_Info_002.sql
---
---
---
---
/*
FROM:  https://docs.microsoft.com/en-us/sql/relational-databases/system-functions/sys-fn-hadr-is-primary-replica-transact-sql?view=sql-server-ver15

If sys.fn_hadr_is_primary_replica ( @dbname ) <> 1   
BEGIN  
-- If this is not the primary replica, exit (probably without error).  
END  
-- If this is the primary replica, continue to do the backup.

ALSO FROM
https://blog.pythian.com/list-of-sql-server-databases-in-an-availability-group/




*/

set textsize 2147483647
drop table if exists #AG_INFO
drop table if exists #FILE_INFO
drop table if exists #ALL_AG_INFO
drop table if exists #backup_info_tbl
---
---
---
SELECT
@@servername as server_name
, AG.name AS [AvailabilityGroupName]
, ISNULL(agstates.primary_replica, '') AS [PrimaryReplicaServerName]
, ISNULL(arstates.role, 3) AS [LocalReplicaRole]
, arstates.role_desc as role_description
, arstates.operational_state
, arstates.operational_state_desc
, case 
  when arstates.role <> 1 then 'THIS DATABASE IS <<<NOT>>> A PRIMARY REPLICA--BACKUP NOT POSSIBLE'
  else 'THIS DATABASE IS A PRIMARY REPLICA--BACKUP IS POSSIBLE'
  end as Backup_Possible
, dbcs.database_name AS [DatabaseName]
, ISNULL(dbrs.synchronization_state, 0) AS [SynchronizationState]
, ISNULL(dbrs.is_suspended, 0) AS [IsSuspended]
, ISNULL(dbcs.is_database_joined, 0) AS [IsJoined]
INTO #AG_INFO
FROM 
master.sys.availability_groups AS AG
LEFT OUTER JOIN 
master.sys.dm_hadr_availability_group_states as agstates
ON 
AG.group_id = agstates.group_id
INNER JOIN 
master.sys.availability_replicas AS AR
ON AG.group_id = AR.group_id
INNER JOIN 
master.sys.dm_hadr_availability_replica_states AS arstates
ON 
AR.replica_id = arstates.replica_id AND arstates.is_local = 1
INNER JOIN 
master.sys.dm_hadr_database_replica_cluster_states AS dbcs
ON 
arstates.replica_id = dbcs.replica_id
LEFT OUTER JOIN 
master.sys.dm_hadr_database_replica_states AS dbrs
ON 
dbcs.replica_id = dbrs.replica_id 
AND 
dbcs.group_database_id = dbrs.group_database_id
ORDER BY AG.name ASC, dbcs.database_name;
---
---
---
SELECT
    d.name AS 'Database_Name',
    m.name AS 'File_Name',
    m.size as size_in_bytes,
    m.size * 8/1024 'Size_in_MB',
    SUM(m.size * 8/1024) OVER (PARTITION BY d.name) AS 'Database_Total',
    m.max_size
INTO #FILE_INFO
FROM sys.master_files m
INNER JOIN sys.databases d ON
d.database_id = m.database_id;
---
---
---
select
	'***AVAILABILITY_INFO***' AS AVAILABILITY_INFO
	, AG.server_name
	, AvailabilityGroupName
	, PrimaryReplicaServerName
	, LocalReplicaRole
	, role_description
	, operational_state
	, operational_state_desc
	, Backup_Possible
	, DatabaseName
	, SynchronizationState
	, IsSuspended
	, IsJoined
	, '***FILE_INFO***' AS FILE_INFO
	, FI.Database_Name
    , FI.File_Name
    , FI.size_in_bytes
    , FI.Size_in_MB
    , FI.Database_Total
    , FI.max_size
INTO #ALL_AG_INFO
from 
	#AG_INFO AG
INNER JOIN
	#FILE_INFO FI
ON
AG.Databasename = FI.Database_Name
ORDER BY FI.Database_Total DESC;
---
---
---
select *
from #ALL_AG_INFO;
---
---
---
declare	@Database_Name_Hold		sysname
declare	@Database_Total_Hold	int
DECLARE @BackupPath				VARCHAR(256)     
DECLARE @BackupFileName			VARCHAR(256)     
DECLARE @BackupDate				VARCHAR(20) 
DECLARE	@BACKUP_CMD				VARCHAR(MAX)
SELECT @BackupDate = CONVERT(VARCHAR(20),GETDATE(),120)
select @BackupDate = replace(replace(@BackupDate, ':', '_'), ' ', '_') 
------PRINT @BackupDate
declare	db_name_cursor cursor static
for
select distinct Database_Name, Database_Total
from #ALL_AG_INFO
where 
role_description = 'SECONDARY'   -----------PRIMARY
and
operational_state_desc = 'ONLINE'
and
Database_Name not like '%log'     ----------for mdf ordering by size 
order by Database_Total desc;
---
---
---
---
---The following code reads the registry to determine the current path for sql server backups
---
---
create table #backup_info_tbl
(
value		varchar(300),
data		varchar(2000)
)
insert into #backup_info_tbl
(
value,
data
)
EXEC [master].dbo.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\MSSQLServer', N'BackupDirectory'
---
---
---
select *
from #backup_info_tbl
---
---
---
SET @BackupPath = (select data + '\' from #backup_info_tbl)   -----backup path with a trailing backslash from the registry
    
---
---
---
open db_name_cursor;
fetch next from db_name_cursor into @Database_Name_Hold, @Database_Total_Hold;
while (@@FETCH_STATUS = 0)
begin
 ---
 ---
 ---  
SET @BackupFileName = @BackupPath + @Database_Name_Hold + '_full_backup_' + @BackupDate + '.bak' 
select @BackupFileName    
----------BACKUP DATABASE @Database_Name_Hold TO DISK = @BackupFileName with COMPRESSION, init 
SET @BACKUP_CMD  =
	'BACKUP DATABASE ' +  @Database_Name_Hold + ' TO DISK = N''' + @BackupFileName + ''''
	+ char(10)
	+ ' WITH NOFORMAT, NOINIT,  NAME = N''' + @Database_Name_Hold + '-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD, STATS = 10, compression;'
select @BACKUP_CMD
--------------exec sp_executesql @BACKUP_CMD
select @@ERROR
---
---
---
fetch next from db_name_cursor into @Database_Name_Hold, @Database_Total_Hold;

end
---
---
---
close		db_name_cursor;
deallocate	db_name_cursor;
