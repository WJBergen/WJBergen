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