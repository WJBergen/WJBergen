---
---This is A_framework_to_backup_databases_on_Availability_Groups.sql
---
/*

FROM:  http://www.sqlservercentral.com/scripts/AlwaysOn/168176/?utm_source=SSC&utm_medium=pubemail
A framework to backup databases on Availability Groups

 By Gaby Abed, 2018/02/20  



This script generates a health status of each db in an AG (and list of DBs not in AG) and uses 
an IF/THEN block to check if the synchronization_state_desc is healthy. 
Feel free to insert in the part marked INSERT BACKUP CODE HERE your preferred backup scripts, or 
trusted third party ones such as Ola Hallengren's.  
Please note, this is very rough, and does not check for other criteria such as the DB being online, 
and what kind of backup (Full, Diff, Tlog) is required, but hopefully this will be usefuI. 



Ideally, this script and modifications can be wrapped in a proc that is deployed to all servers, 
both standalone and those in HA's, as a job.  
n theory, if you want, you can backup the transaction logs on the secondary, and full on primary.  
This would require a bit of a tweak with the IF/THEN block. 



*/
---
---
---
-- Please change the section marked '-- INSERT BACKUP CODE HERE' as needed

set nocount on

SELECT adc.database_name,
	ag.NAME AS ag_name,
	drs.synchronization_state_desc
INTO #SYNC_STATUS
FROM sys.dm_hadr_database_replica_states AS drs
INNER JOIN sys.availability_databases_cluster AS adc ON drs.group_id = adc.group_id
	AND drs.group_database_id = adc.group_database_id
INNER JOIN sys.availability_groups AS ag ON ag.group_id = drs.group_id
INNER JOIN sys.availability_replicas AS ar ON drs.group_id = ar.group_id
	AND drs.replica_id = ar.replica_id
WHERE replica_server_name = CAST(SERVERPROPERTY('SERVERNAME') AS VARCHAR(MAX))
ORDER BY DATABASE_NAME

SELECT *
FROM #sync_status

SET NOCOUNT ON

CREATE TABLE #tmp_db_ars (
	replica_id UNIQUEIDENTIFIER,
	group_id UNIQUEIDENTIFIER
	)

CREATE TABLE #tmp_db_ags (
	group_id UNIQUEIDENTIFIER,
	NAME SYSNAME
	)

DECLARE @HasViewPermission INT

SELECT @HasViewPermission = HAS_PERMS_BY_NAME(NULL, NULL, 'VIEW SERVER STATE')

IF (@HasViewPermission = 1)
BEGIN
	INSERT INTO #tmp_db_ars
	SELECT replica_id,
		group_id
	FROM master.sys.availability_replicas

	INSERT INTO #tmp_db_ags
	SELECT group_id,
		NAME
	FROM master.sys.availability_groups
END

SELECT
	--distinct
	dtb.NAME [DBName],
	ISNULL(ags.NAME, '') AS [AvailabilityGroupName],
	ISNULL(sys.fn_hadr_backup_is_preferred_replica(dtb.NAME), 1) AS BackupPreference,
	ISNULL(sync.synchronization_state_desc, '') AS synchronization_state_desc
INTO #work_to_do
FROM master.sys.databases AS dtb
LEFT OUTER JOIN #tmp_db_ars AS ars ON dtb.replica_id = ars.replica_id
LEFT OUTER JOIN #tmp_db_ags AS ags ON ars.group_id = ags.group_id
LEFT OUTER JOIN #sync_status AS sync ON sync.AG_NAME = ags.NAME
	AND SYNC.database_name = DTB.NAME
WHERE (dtb.NAME <> 'tempdb' and dtb.state_desc = 'ONLINE')

SELECT *
FROM #work_to_do
ORDER BY 1 --, BackupPreference, DBName

DECLARE @DBName VARCHAR(max),
	@AGName VARCHAR(max),
	@BackupPreference INT,
	@SynchStateDesc VARCHAR(max)

SELECT TOP 1 @dbname = DBName,
	@AGName = AvailabilityGroupName,
	@BackupPreference = BackupPreference,
	@SynchStateDesc = synchronization_state_desc
FROM #work_to_do
ORDER BY AvailabilityGroupName

WHILE (@@rowcount > 0)
BEGIN
	IF (
	-- IF DB IS NOT PART OF AN AG, 
	-- OR IF IT IS PART OF AN AG AND HAS A BACKUP PREFERENCE = 1 AND IS IN A SYNCHRONIZED STATE
			@AGName = ''
			OR (
				@AGName <> ''
				AND @BackupPreference <> 0
				AND @SynchStateDesc = 'SYNCHRONIZED'
				)
			)
	     BEGIN
		-- INSERT BACKUP CODE HERE
		  PRINT '-- backup: ' + @DBName + ''
		END
	ELSE
		PRINT '-- no backup: ' + @DBName + ''

	DELETE #work_to_do
	WHERE DBName = @DBName

	SELECT TOP 1 @dbname = DBName,
		@AGName = AvailabilityGroupName,
		@BackupPreference = BackupPreference,
		@SynchStateDesc = synchronization_state_desc
	FROM #work_to_do
	ORDER BY AvailabilityGroupName
END
GO

DROP TABLE #tmp_db_ars
DROP TABLE #tmp_db_ags
DROP TABLE #work_to_do
DROP TABLE #sync_status
