---
---This is age_of_statistics_in_days_single_database.sql
---
declare @statistics_days_old int
set @statistics_days_old = 0
SELECT
	@@servername
	, db_name()
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
FROM 
sys.stats AS stat 
CROSS APPLY 
sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
join
sys.objects so
on so.object_id = object_id(stat.name)
WHERE 
datediff(dd, last_updated, getdate()) > @statistics_days_old 
and 
stat.name not in ('clst', 'clust', 'nc', 'nc1', 'nc2')
and 
stat.name not like ('_WA%')
and 
object_id(stat.name) is not null;
---
---
---
SELECT OBJECT_NAME(object_id) [TableName], 
       name [IndexName],
       STATS_DATE(object_id, stats_id) [LastStatsUpdate]
FROM sys.stats
WHERE name NOT LIKE '_WA%'
AND STATS_DATE(object_id, stats_id) IS NOT NULL
AND OBJECTPROPERTY(object_id, 'IsMSShipped') = 0
ORDER BY TableName, IndexName