---Check active connections in all databases

SELECT 
	db_name(dbid) as DatabaseName
	, count(dbid) as NoOfConnections
	, loginame as LoginName
FROM sys.sysprocesses
WHERE dbid > 0
GROUP BY dbid, loginame
