---
---This is Alter_to_shrink_001.sql
---
---
---This alter statement sets the database to single user mode
---if you are running this in a tsql window then remember that <<<ALL>>> work must be done in that window and NO OTHER
---
---the command immediately below will cancel all transaction and rollback any uncommitted transactions
---
USE master;
GO
ALTER DATABASE spaceobserver2
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;

---
---now set the database to multiuser mode so that you can continue with the shrinking of the log files 
---
ALTER DATABASE spaceobserver2
SET MULTI_USER;

---
---Now run both commands to shrink the files 
---below are the meanings of notruncate and truncateonly
---
---
/*

NOTRUNCATE
Moves allocated pages from the end of a data file to unallocated pages in the front of the file with or without specifying target_percent. 
The free space at the end of the file is not returned to the operating system, and the physical size of the file does not change. 
Therefore, when NOTRUNCATE is specified, the file appears not to shrink. NOTRUNCATE is applicable only to data files. 
The log files are not affected. This option is not supported for FILESTREAM filegroup containers.

TRUNCATEONLY
Releases all free space at the end of the file to the operating system but does not perform any page movement inside the file. 
The data file is shrunk only to the last allocated extent. target_size is ignored if specified with TRUNCATEONLY.
The TRUNCATEONLY option does not move information in the log, but does remove inactive VLFs from the end of the log file. 
This option is not supported for FILESTREAM filegroup containers.



*/
dbcc shrinkfile(SpaceObserver2_log, 1000, NOTRUNCATE)
dbcc shrinkfile(SpaceObserver2_log, 1000, TRUNCATEONLY)



---
---the opentran statement will show you information about open transaction (basically uncommitted data)
---it is not necessary and is placed in this document for documentation and communication with the user whose transactions 
---you are going to kill so that the shrink can be done
---

--------------dbcc opentran(spaceobserver2)


/*
---Remember in order to backup a transaction log the database can not be in simple mode
---
---backing up a tlog <only> when other than simple mode
---
BACKUP LOG EMPLOYEE
TO DISK = 'E:\LogBackup\EmployeeDB_log.TRN';

*/


/*
--
---This query will show the database name and the date
---of the last transaction log backup
---
select	d.name
	, max(b.backup_finish_date) as backup_finish_date
	, d.recovery_model_desc
into
#temp1	
from	
master.sys.databases d
left outer join
msdb..backupset b
on 
	b.database_name = d.name
and
	b.type = 'L'
group by d.name, d.recovery_model_desc
order by d.name, backup_finish_date desc;
---
---Now select only the full recovery model dbs
---
select
	name
	, backup_finish_date
	, recovery_model_desc
from #temp1
where recovery_model_desc <> 'SIMPLE';
---
---
---
drop table #temp1

*/	
