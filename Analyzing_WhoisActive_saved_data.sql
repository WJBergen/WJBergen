---
---This is Analyzing_WhoisActive_saved_data.sql
---
select login_name, wait_info, tran_log_writes, cpu, tempdb_allocations, tempdb_current, reads, writes, physical_reads, used_memory, collection_time 
from [WHOISACTIVE_DB].[dbo].[WhoIsActive]
where 
(
collection_time >= '2017-08-14 00:00.00'
and
collection_time <= '2017-08-14 23:59.59'
)
union
select login_name, wait_info, tran_log_writes, cpu, tempdb_allocations, tempdb_current, reads, writes, physical_reads, used_memory, collection_time
from [WHOISACTIVE_DB].[dbo].[WhoIsActive]
where 
(
collection_time >= '2017-08-21 00:00.00'
and
collection_time <= '2017-08-21 23:59.59'
)
order by reads desc;