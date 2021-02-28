---
---This is 10_ways_to_reduce_the_database_size_and_improve_performance_in_SQL_Server.sql
---It is the scripts from 10_ways_to_reduce_the_database_size_and_improve_performance_in_SQL_Server.docx
---
print 'The script below provides you the information about space allocation on per-index basis in the database. You can easily modify it to aggregate on per-table basis or drill-down on per-allocation unit basis; however, at that stage I usually prefer to work on the index level.'

;with SpaceInfo(ObjectId, IndexId, TableName, IndexName
    ,Rows, TotalSpaceMB, UsedSpaceMB)
as
( 
    select  
        t.object_id as [ObjectId]
        ,i.index_id as [IndexId]
        ,s.name + '.' + t.Name as [TableName]
        ,i.name as [Index Name]
        ,sum(p.[Rows]) as [Rows]
        ,sum(au.total_pages) * 8 / 1024 as [Total Space MB]
        ,sum(au.used_pages) * 8 / 1024 as [Used Space MB]
    from    
        sys.tables t with (nolock) join 
            sys.schemas s with (nolock) on 
                s.schema_id = t.schema_id
            join sys.indexes i with (nolock) on 
                t.object_id = i.object_id
            join sys.partitions p with (nolock) on 
                i.object_id = p.object_id and 
                i.index_id = p.index_id
            cross apply
            (
                select 
                    (sum(a.total_pages) * 1.0) as total_pages
                    ,(sum(a.used_pages) * 1.0) as used_pages
                from sys.allocation_units a with (nolock)
                where p.partition_id = a.container_id 
            ) au
    where   
        i.object_id > 255
    group by
        t.object_id, i.index_id, s.name, t.name, i.name
)
select 
    ObjectId
    , IndexId
    , TableName
    , IndexName
    , Rows
    , TotalSpaceMB
    , UsedSpaceMB
    , (TotalSpaceMB - UsedSpaceMB) as [ReservedSpaceMB]
into #temp_stuff
from 
    SpaceInfo		
order by
    TotalSpaceMB desc
option (recompile);

print 'Show all index information without percentages'
select *
from #temp_stuff
order by TotalSpaceMB desc 

print 'Show those indexes that have zero reserved space left'
select *
from #temp_stuff
where ReservedSpaceMB =  0.0
order by TotalSpaceMB desc 

print 'Show those indexes that have some reserved space left'
select *
from #temp_stuff
where ReservedSpaceMB <> 0.0
order by TotalSpaceMB desc 


select	*
		, cast((UsedSpaceMB / TotalSpaceMB) as decimal(16, 9)) * 100.00  as percent_used
		, cast((ReservedSpaceMB / TotalSpaceMB) as decimal(16, 9)) * 100.00 as percent_Unused
from #temp_stuff
where ReservedSpaceMB <> 0.0
order by TotalSpaceMB desc 



----------drop table #temp_stuff;