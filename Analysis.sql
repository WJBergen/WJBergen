---
---This script is called Analysis.sql.  It is used to analyze what is going on.
---
DECLARE @RC int
DECLARE @parm1 char(1)
DECLARE @parm2 varchar(20)
DECLARE @parm3 varchar(300)
-- Set parameter values
EXEC @RC = [DBATasks].[dbo].[spr_whodat] 
	@parm1 = 'Y'
	, @parm2 = 'Dynam'
------	, @parm3 = 'Hostname like ''HAR02%'' order by cputime desc '
	, @parm3 = '1 = 1 order by cputime desc '


dbcc inputbuffer(195)
dbcc outputbuffer(195)

exec sp_lock 195

DECLARE @spid_hold char(6)
DECLARE @Handle binary(20)
set @spid_hold = 195
SELECT @Handle = sql_handle FROM master.dbo.sysprocesses WHERE spid = @spid_hold 
----print @handle
---SELECT spid, getdate(), * into #full_sql_text FROM ::fn_get_sql(@Handle)
SELECT * FROM ::fn_get_sql(@Handle)