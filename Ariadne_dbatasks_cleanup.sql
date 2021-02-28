select distinct sample_date
from db_space_metrics

select count(*) from db_space_metrics

select count(*) from db_space_metrics
where sample_date < '11/01/2000'

select count(*) from db_space_metrics_summary

select count(*) from db_space_metrics_summary
where sample_date < '01/01/2003'



dump tran DBATasks with no_log 
go
checkpoint
go
---
delete from db_space_metrics
where sample_date < '03/01/2001'
checkpoint
---This job will truncate the transaction log for a database
dump tran DBATasks with no_log 
go
checkpoint
go

delete from db_space_metrics_summary
where sample_date < '01/01/2001'

---This job will truncate the transaction log for a database
dump tran DBATasks with no_log 
go
checkpoint
go