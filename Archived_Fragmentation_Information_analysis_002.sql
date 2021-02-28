print 'Total number of indices'
select COUNT(*) / 2
from UPHS_Archived_Fragmentation_Information.dbo.Archived_Fragmentation_Information
where 
start_time > '2015-03-20 00:00:00'
and 
start_time < '2015-03-24 00:00:00'
---
---
---
print 'those indices that were not be processed'
select COUNT(*) / 2
from UPHS_Archived_Fragmentation_Information.dbo.Archived_Fragmentation_Information
where 
collection_date > '2015-03-20 00:00:00'
and 
collection_date < '2015-03-24 00:00:00'
and
start_time is null
and 
end_time is null
---
---
---
print 'those indices that were rebuilt'
select COUNT(*) / 2
from UPHS_Archived_Fragmentation_Information.dbo.Archived_Fragmentation_Information
where 
start_time > '2015-03-20 00:00:00'
and 
end_time < '2015-03-24 00:00:00'
and
command like '%REBUILD%'
---
---
---
print 'those indices that were reorganized'
select COUNT(*) / 2
from UPHS_Archived_Fragmentation_Information.dbo.Archived_Fragmentation_Information
where 
start_time > '2015-03-20 00:00:00'
and
end_time < '2015-03-24 00:00:00'
and 
command like '%REORGANIZE%'
---
---
---
print 'show info about those that were rebuilt'
print 'note the date and time '
select *
from UPHS_Archived_Fragmentation_Information.dbo.Archived_Fragmentation_Information
where 
start_time > '2015-03-20 00:00:00'
and
end_time < '2015-03-24 00:00:00'
and 
command like '%REBUILD%'
order by start_time
---
---
---
print 'show info about those that were reorganized'
print 'note the date and time '
select	*
		, DATEDIFF(mi, start_time, end_time) as duration_in_minutes
		, DATEDIFF(hh, start_time, end_time) as duration_in_hours
from UPHS_Archived_Fragmentation_Information.dbo.Archived_Fragmentation_Information
where 
start_time > '2015-03-20 00:00:00'
and 
end_time < '2015-03-24 00:00:00'
and
command like '%REORGANIZE%'
------order by start_time
order by DATEDIFF(mi, start_time, end_time) desc
---
---
---
print 'count of the number of H fragmentation indices'
select COUNT(*) / 2
from UPHS_Archived_Fragmentation_Information.dbo.Archived_Fragmentation_Information
where 
start_time > '2015-03-20 00:00:00'
and 
end_time < '2015-03-24 00:00:00'
and
Fragmentation_Level = 'H'
---
---
---
print 'count of the number of M fragmentation indices'
select COUNT(*) / 2
from UPHS_Archived_Fragmentation_Information.dbo.Archived_Fragmentation_Information
where 
start_time > '2015-03-20 00:00:00'
and
end_time < '2015-03-24 00:00:00'
and 
Fragmentation_Level = 'M'
---
---
---
print 'count of the number of S fragmentation indices'
select COUNT(*) / 2
from UPHS_Archived_Fragmentation_Information.dbo.Archived_Fragmentation_Information
where 
start_time > '2015-03-20 00:00:00'
and 
end_time < '2015-03-24 00:00:00'
and
Fragmentation_Level = 'S'