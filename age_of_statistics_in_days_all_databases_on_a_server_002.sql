---
---This is age_of_statistics_in_days_all_databases_on_a_server_002.sql
---
---NOTE:  problems on servers that are not up to 2008R2 sp2
---       Also, seems to be no way to eleminate master, model, msdb, tempdb, etc.
---
---
---@RETURN_VALUE - is the return value which will be set 
---by "sp_MSforeachdb" 
---@command1 - is the first command to be executed 
---by "sp_MSforeachdb" and is defined as nvarchar(2000) 
---@replacechar - is a character in the command string 
---that will be replaced with the table name being 
---processed (default replacechar is a "?") 
---@command2 and @command3 are two additional commands 
---that can be run against each database 
---@precommand - is a nvarchar(2000) parameter that 
---specifies a command to be run prior to processing any 
---database 
---@postcommand - is also an nvarchar(2000) field used 
---to identify a command to be run after all commands 
---have been processed against all databases. 
---
---
---
declare @RETURN_VALUE		int
declare	@replacechar		char(1)
declare	@precommand			nvarchar(2000)
declare	@command1			nvarchar(2000)
declare	@command2			nvarchar(2000)
declare	@command3			nvarchar(2000)
declare	@postcommand		nvarchar(2000)
---
---
---
set @RETURN_VALUE	= 0		
set @replacechar	= '?'
set @precommand		= ''
set @command1		= 
'
declare @statistics_days_old int
set @statistics_days_old = 3
use [?]
SELECT
	@@servername as servername
-----------	, @@version as sql_version
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
FROM 
sys.stats AS stat 
CROSS APPLY 
sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp
join
sys.objects so
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




'
------set @command2		= 'print  ''?'''	
set @command2 = ''			
set @command3		= ''			
set @postcommand	= ''
---
---
---
exec @RETURN_VALUE = master.dbo.sp_MSforeachdb 
	@command1
	, @replacechar
	, @command2
	, @command3
	, @precommand
	, @postcommand 







