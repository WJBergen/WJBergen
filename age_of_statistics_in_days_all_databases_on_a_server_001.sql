---
---this is age_of_statistics_in_days_all_databases_on_a_server_001.sql
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
------------------declare	@statistics_days_old	int
------------------set @statistics_days_old = 3
---
---
---
set @RETURN_VALUE	= 0		
set @replacechar	= '?'
set @precommand		= ''
set @command1		= 'print  ''?'''			
set @command2		= 
'
USE [?]
declare	@statistics_days_old	int
set @statistics_days_old = 3
SELECT 
	   @@servername
	   , ''?'' as database_name
	   , OBJECT_NAME(object_id) [TableName]
       , name [IndexName]
       , STATS_DATE(object_id, stats_id) [LastStatsUpdate]
FROM [?].sys.stats
WHERE 
''?'' not in (''tempdb'', ''master'', ''model'', ''msdb'', ''ReportServer'', ''ReportServerTempDB'')
and
name NOT LIKE ''_WA%''
AND 
STATS_DATE(object_id, stats_id) IS NOT NULL
AND 
OBJECTPROPERTY(object_id, ''IsMSShipped'') = 0      ---application tables
and
datediff(dd, STATS_DATE(object_id, stats_id), getdate()) > @statistics_days_old
ORDER BY TableName, IndexName
'			
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


