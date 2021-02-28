---
---This is age_of_statistics_in_days_all_databases_on_a_server_004.sql
---
declare @sql_stmt				nvarchar(4000)
declare @sql_stmt_modified		nvarchar(4000)
declare	@db_name_hold	sysname
---
---
---
select *
from sys.databases 
---
---
---
declare db_cursor cursor static 
for 
select name 
from sys.databases
where 
name not in ('master', 'model', 'msdb','tempdb', 'ReportServer', 'ReportServerTempDB', 'DBATASKS')
and 
state_desc = 'ONLINE'   ----------online 
order by name 
open db_cursor 
fetch next from db_cursor into @db_name_hold
---
---
---
set @sql_stmt = 
'
declare @statistics_days_old int
set @statistics_days_old = 0
use [?]
SELECT
	@@servername as servername
----------	, @@version as sql_version
	, db_name() as databasename
    , sp.stats_id
	, object_name(so.parent_object_id) as table_name
	, stat.name as indexname
	, object_id(stat.name) as indexobjectid
	,  filter_definition
	, last_updated
	, rows
	, rows_sampled
	, steps
	, unfiltered_rows
	, modification_counter
	, datediff(dd, last_updated, getdate()) as age_of_statistics_in_days
into #temp_stat_info
FROM 
[?].sys.stats AS stat 
CROSS APPLY 
[?].sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
join
[?].sys.objects so
on so.object_id = object_id(stat.name)
WHERE 
@@version not like (''%2000%'')
and
@@version not like (''%2005%'')
and
''[?]'' not in (''tempdb'', ''master'', ''model'', ''msdb'', ''ReportServer'', ''ReportServerTempDB'')
and
datediff(dd, last_updated, getdate()) > @statistics_days_old 
and 
stat.name not in (''clst'', ''clust'', ''nc'', ''nc1'', ''nc2'')
and 
stat.name not like (''_WA%'')
and 
object_id(stat.name) is not null;
---
--- to get just the name of the databases that need reindex/reorg
---
select 
	servername
----------	, @@version as sql_version
	, databasename
    , stats_id
	, table_name
	, indexname
	, indexobjectid
	, filter_definition
	, last_updated
	, rows
	, rows_sampled
	, steps
	, unfiltered_rows
	, modification_counter
	, age_of_statistics_in_days
from  #temp_stat_info
where 
age_of_statistics_in_days > @statistics_days_old
and 
databasename not in (''tempdb'', ''master'', ''model'', ''msdb'', ''ReportServer'', ''ReportServerTempDB'', ''DBATASKS'')
----group by databasename
order by databasename;
---
drop table #temp_stat_info

'
---
---
---
while (@@FETCH_STATUS = 0)
begin
set @sql_stmt_modified = null
set @sql_stmt_modified = @sql_stmt
set @sql_stmt_modified = REPLACE(@sql_stmt_modified, '?', @db_name_hold)
print @sql_stmt_modified
exec  sp_executesql @sql_stmt_modified



fetch next from db_cursor into @db_name_hold
end
---
---
---
close db_cursor;
deallocate db_cursor;