---
---This is Activity_Monitor_view_in_TSQL.sql
---
/*
To see the same list in Activity Monitor's Processes view in T-SQL.
FROM:  http://databasescripts.com/s/66/sql-server/activity-monitor-view-t-sql

*/

SELECT
   [Session ID]    = s.session_id,
   [User Process]  = CONVERT(CHAR(1), s.is_user_process),
   [Login]         = s.login_name,  
   [Database]      = ISNULL(db_name(r.dbid), N''),
   [Task State]    = ISNULL(t.task_state, N''),
   [Command]       = ISNULL(r.cmd, N''),
   [Application]   = ISNULL(s.program_name, N''),
   [Wait Time (ms)]     = ISNULL(w.wait_duration_ms, 0),
   [Wait Type]     = ISNULL(w.wait_type, N''),
   [Wait Resource] = ISNULL(w.resource_description, N''),
   [Blocked By]    = ISNULL(CONVERT (varchar, w.blocking_session_id), ''),
   [Head Blocker]  =
        CASE
            -- session has an active request, is blocked, but is blocking others
            WHEN r2.session_id IS NOT NULL AND r.blocked = 0 THEN '1'
            -- session is idle but has an open tran and is blocking others
            WHEN r.spid IS NULL THEN '1'
            ELSE ''
        END,
   [Total CPU (ms)] = s.cpu_time,
   [Total Physical I/O (MB)]   = (s.reads + s.writes) * 8 / 1024,
   [Memory Use (KB)]  = s.memory_usage * 8192 / 1024,
   [Open Transactions] = ISNULL(r.open_tran,0),
   [Login Time]    = s.login_time,
   [Last Request Start Time] = s.last_request_start_time,
   [Host Name]     = ISNULL(s.host_name, N''),
   [Net Address]   = ISNULL(c.client_net_address, N''),
   [Execution Context ID] = ISNULL(t.exec_context_id, 0),
   [Request ID] = ISNULL(r.request_id, 0),
   [Workload Group] = N''

FROM sys.dm_exec_sessions s LEFT OUTER JOIN sys.dm_exec_connections c ON (s.session_id = c.session_id)
LEFT OUTER JOIN sys.sysprocesses r ON (s.session_id = r.spid)
LEFT OUTER JOIN sys.dm_os_tasks t ON (r.spid = t.session_id AND r.request_id = t.request_id)
LEFT OUTER JOIN
(
    -- In some cases (e.g. parallel queries, also waiting for a worker), one thread can be flagged as
    -- waiting for several different threads.  This will cause that thread to show up in multiple rows
    -- in our grid, which we don't want.  Use ROW_NUMBER to select the longest wait for each thread,
    -- and use it as representative of the other wait relationships this thread is involved in.
    SELECT *, ROW_NUMBER() OVER (PARTITION BY waiting_task_address ORDER BY wait_duration_ms DESC) AS row_num
    FROM sys.dm_os_waiting_tasks
) w ON (t.task_address = w.waiting_task_address) AND w.row_num = 1
LEFT OUTER JOIN sys.dm_exec_requests r2 ON (r.spid = r2.blocking_session_id)
WHERE s.login_name not in ('sa','NT AUTHORITY\SYSTEM')  -- no sys internal
AND r.dbid not in (1,2,3,4)  -- master, temp, model, msdb
ORDER BY s.session_id;