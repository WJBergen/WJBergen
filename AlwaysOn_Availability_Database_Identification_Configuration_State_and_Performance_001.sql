PRINT '' 
--AlwaysOn Availability Database Identification, Configuration, State and Performance 
PRINT '===================================================================================' 
PRINT 'AlwaysOn Availability Database Identification, Configuration, State and Performance' 
PRINT '===================================================================================' 
PRINT '' 
select  
database_name=cast(drcs.database_name as varchar(30)),  
drs.database_id, 
drs.group_id, 
drs.replica_id, 
drs.is_local, 
drcs.is_failover_ready, 
drcs.is_pending_secondary_suspend, 
drcs.is_database_joined, 
drs.is_suspended, 
drs.is_commit_participant, 
suspend_reason_desc=cast(drs.suspend_reason_desc as varchar(30)), 
synchronization_state_desc=cast(drs.synchronization_state_desc as varchar(30)), 
synchronization_health_desc=cast(drs.synchronization_health_desc as varchar(30)), 
database_state_desc=cast(drs.database_state_desc as varchar(30)), 
drs.last_sent_lsn, 
drs.last_sent_time, 
drs.last_received_lsn, 
drs.last_received_time, 
drs.last_hardened_lsn, 
drs.last_hardened_time, 
drs.last_redone_lsn, 
drs.last_redone_time, 
drs.log_send_queue_size, 
drs.log_send_rate, 
drs.redo_queue_size, 
drs.redo_rate, 
drs.filestream_send_rate, 
drs.end_of_log_lsn, 
drs.last_commit_lsn, 
drs.last_commit_time, 
drs.low_water_mark_for_ghosts, 
drs.recovery_lsn, 
drs.truncation_lsn, 
pr.file_id, 
pr.error_type, 
pr.page_id, 
pr.page_status, 
pr.modification_time 
from sys.dm_hadr_database_replica_cluster_states drcs join  
sys.dm_hadr_database_replica_states drs on drcs.replica_id=drs.replica_id 
and drcs.group_database_id=drs.group_database_id left outer join 
sys.dm_hadr_auto_page_repair pr on drs.database_id=pr.database_id  
order by drs.database_id 

