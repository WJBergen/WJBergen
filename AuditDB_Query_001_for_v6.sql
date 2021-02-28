USE AuditDB_Repository
GO
SELECT
	LA.[ActivityId]
	, LD.DatabaseName
	, LSVR.ServerName
	, LA.Time
	, LAT.Name "Activity Type"
	, LDBU.DbUserName
	, left(LS.StatementText, 3975) "Statement Text"
FROM	[AuditDB_Repository].[dbo].[lumActivities] LA
		, [AuditDB_Repository].[dbo].[lumClients] LC
		, [AuditDB_Repository].[dbo].[lumDbUsers] LDBU
		, [AuditDB_Repository].[dbo].[lumDatabases] LD
		, [AuditDB_Repository].[dbo].[lumServers] LSVR
		, [AuditDB_Repository].[dbo].[lumActivityTypes] LAT
		, [AuditDB_Repository].[dbo].[lumStatements] LS
where 
UPPER(LD.DatabaseName) = 'RB_ODS'
---
---Server on which the above database exists
---
and  UPPER(LSVR.ServerName) = 'WIL-SQL-D09'   
and  LA.Time > '06/01/05'
-- and  lo.opcodename not in ('backup', 'maintenance', 'login failed')
-- and  lo.opcodeid in (
--        select opcodeid from 
--          [AuditDB_Repository].[dbo].lumopcodes_Repository1     -- new 
--          where (opcodeid/100) in (2, 3, 4, 30)
--                and opcodeid not in (3020))
 and  LA.ClientId = LC.ClientId
 and  LC.DbUserId = LDBU.DbUserId
 and  LA.DatabaseId = LD.DatabaseId
 and  LD.ServerId = LSVR.ServerId
 and  LA.ActivityTypeId = LAT.ActivityTypeId
 and  LA.ActivityId = LS.ActivityId
order by LA.Time