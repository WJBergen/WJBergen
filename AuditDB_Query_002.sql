-- The following SQL Statement would need to be run once to create the Activity Types table with only the activities that Wilmington Trust
--  wants to see
drop table AuditDB_Repository.dbo.WT_ActivityTypes
---
---
---
select * into AuditDB_Repository.dbo.WT_ActivityTypes
from AuditDB_Repository.dbo.lumActivityTypes
where ActivityTypeId in (101, 102, 201, 202, 203, 212, 214, 215, 216, 217, 218, 219, 220, 221, 233, 235, 236, 237, 238, 239, 240, 241, 242, 254, 255, 256, 257, 258, 259, 260, 261, 262, 264, 281, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 401, 402, 403, 404, 405, 501, 502, 601, 602, 1001, 1201, 1301, 1302, 1401, 1601, 1900, 1901, 1902, 1903, 1908, 1909, 1910, 1911, 1916, 1917, 1918, 3026)

----


SELECT 
	LA.[ActivityId]
	, LD.DatabaseName
	, LSVR.ServerName
	, LA.Time
	, WAT.Name "Activity Type"
	, LDBU.DbUserName
	, left(LS.StatementText, 3975) "Statement Text"
FROM
	[AuditDB_Repository].[dbo].[lumActivities] LA
	, [AuditDB_Repository].[dbo].[lumClients] LC
	, [AuditDB_Repository].[dbo].[lumDbUsers] LDBU
	, [AuditDB_Repository].[dbo].[lumDatabases] LD
	, [AuditDB_Repository].[dbo].[lumServers] LSVR
	, [AuditDB_Repository].[dbo].[WT_ActivityTypes] WAT
	, [AuditDB_Repository].[dbo].[lumStatements] LS

where 
UPPER(LD.DatabaseName) = 'RB_ODS'
and  UPPER(LSVR.ServerName) = 'WIL-SQL-D09'
and  LA.Time > '06/01/05'
and  LA.ClientId = LC.ClientId
and  LC.DbUserId = LDBU.DbUserId
and  LA.DatabaseId = LD.DatabaseId
and  LD.ServerId = LSVR.ServerId
and  LA.ActivityTypeId = WAT.ActivityTypeId
and  LA.ActivityId = LS.ActivityId
order by LA.Time