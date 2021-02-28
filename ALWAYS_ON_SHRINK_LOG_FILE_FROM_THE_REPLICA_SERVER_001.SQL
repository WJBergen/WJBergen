---
---This is ALWAYS_ON_SHRINK_LOG_FILE_FROM_THE_REPLICA_SERVER_001.SQL
---
---
---This is always_on_primary_database_info_001.sql
---
declare	@dbname_hold						sysname
declare	@fn_hadr_is_primary_replica_value	int
declare	@rc									int
declare	@sql_cmd							varchar(4000)
declare	db_cursor cursor static
for
select name
from sys.sysdatabases
where 
name not in ('tempdb');
open db_cursor;
fetch next from db_cursor into @dbname_hold
while (@@FETCH_STATUS = 0)
begin
set @sql_cmd = concat('select ''', @dbname_hold, ''', sys.fn_hadr_is_primary_replica(''' , @dbname_hold, ''')' )
print @sql_cmd
fetch next from db_cursor into @dbname_hold
end
close db_cursor;
deallocate db_cursor;

---
---REMEMBER THAT THE SHRINK OF THE LOG FILE <<<CAN ONLY>>> BE DONE ON THE REPLICA
---AND NOT THE PRIMARY.
---THE ABOVE SCRIPT SHOULD BE RUN ALONE TO GET THE NAME OF THE PRIMARY SERVER 
---
BACKUP DATABASE [CitrixCitrixPennMedicineProdXASite] 
TO  DISK = N'E:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\ctxprodsite_aod.bak' 
WITH NOFORMAT, NOINIT,  NAME = N'CitrixCitrixPennMedicineProdXASite-Full Database Backup', 
SKIP, NOREWIND, NOUNLOAD,  STATS = 10, compression
GO


BACKUP log  [CitrixCitrixPennMedicineProdXASite] 
TO  DISK = N'E:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\ctxsite_log_aod.trn' 
WITH NOFORMAT, NOINIT,  NAME = N'CitrixCitrixPennMedicineProdXASite-LOG Backup', 
SKIP, NOREWIND, NOUNLOAD,  STATS = 10, compression
GO

BACKUP log  [CitrixCitrixPennMedicineProdXASite] 
TO  DISK = N'E:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\ctxsite02_log_aod.trn' 
WITH NOFORMAT, NOINIT,  NAME = N'CitrixCitrixPennMedicineProdXASite-LOG Backup', 
SKIP, NOREWIND, NOUNLOAD,  STATS = 10, compression
GO

use [CitrixCitrixPennMedicineProdXASite]
GO
dbcc shrinkfile (2,1024)

dbcc loginfo

select * from sys.dm_tran_database_transactions
