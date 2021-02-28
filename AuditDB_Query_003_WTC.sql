print getdate()
---
---
---
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[WTC_MFM_Report_1]') AND type in (N'U'))
DROP TABLE [dbo].[WTC_MFM_Report_1]
checkpoint
CREATE TABLE AuditDB_Repository.[dbo].[WTC_MFM_Report_1]
(
	dummy_pk	int identity,
	[ActivityId] [numeric](20, 0) NULL,
	[ActivityTypeID] int null,
	[DatabaseName] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ServerName] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Time] [datetime]  NULL,
	[ClientID] int null,
	[Activity Type] [nvarchar](512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DbUserName] [nvarchar](256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Statement Text] [nvarchar](3975) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
---
---
---
print 'Creating clustered primary key'
print getdate()
create unique clustered index
WTC_clustered_pk
on AuditDB_Repository.[dbo].[WTC_MFM_Report_1]
(dummy_pk)
---
---
---
print 'creating ActivityID index'
print getdate()
create index
WTC_ActivityID_idx
on AuditDB_Repository.[dbo].[WTC_MFM_Report_1]
(ActivityID)
---
---
---
print 'Creating ClientID index'
print getdate()
create index
WTC_ClientID_idx
on AuditDB_Repository.[dbo].[WTC_MFM_Report_1]
(ClientID)
---
---
---
print 'Creating ActivityTypeID index'
print getdate()
create index
WTC_ActivityTypeID_idx
on AuditDB_Repository.[dbo].[WTC_MFM_Report_1]
(ActivityTypeID)
---
---Get the core values and fill in the rest later
---
print 'Inserting into Core Table'
print getdate()
insert into AuditDB_Repository.[dbo].[WTC_MFM_Report_1]
(
	[ActivityId]
	, [ActivityTypeID]
	, [DatabaseName] 
	, [ServerName]
	, [Time]
	, [ClientID]
	, [Activity Type] 
	, [DbUserName]
	, [Statement Text] 
)
SELECT 
	LA.[ActivityId]
	, LA.[ActivityTypeID]
	, LD.DatabaseName
	, LSVR.ServerName
	, LA.Time
	, LA.ClientID
	, null
	, null
	, null
FROM
	[AuditDB_Repository].[dbo].[lumActivities] LA
	, [AuditDB_Repository].[dbo].[lumDatabases] LD
	, [AuditDB_Repository].[dbo].[lumServers] LSVR
where 
UPPER(LD.DatabaseName) = 'RB_ODS'
and  UPPER(LSVR.ServerName) = 'WIL-SQL-D09'
and  LA.Time > '06/01/05'
and  LD.ServerId = LSVR.ServerId
---
---Got the core values now fill in the other columns
---
print 'Updating Activity Type'
print getdate()
update AuditDB_Repository.[dbo].[WTC_MFM_Report_1]
	set [Activity Type] = WAT.Name
from [AuditDB_Repository].[dbo].[WT_ActivityTypes] WAT
where WTC_MFM_Report_1.ActivityTypeId = WAT.ActivitytypeId
---
---
---
print 'Updating DBUserName'
print getdate()
update AuditDB_Repository.[dbo].[WTC_MFM_Report_1]
	set [DBUserName] = LDBU.DbUserName
from [AuditDB_Repository].[dbo].[lumClients] LC
	, [AuditDB_Repository].[dbo].[lumDbUsers] LDBU
where [WTC_MFM_Report_1].ClientID = LC.ClientId
and   LC.DbUserId = LDBU.DbUserId
---
---
---
print 'Updating Statement Text'
print getdate()
update AuditDB_Repository.[dbo].[WTC_MFM_Report_1]
	set [Statement Text] = left(LS.StatementText, 3975)
from [AuditDB_Repository].[dbo].[lumStatements] LS
where [WTC_MFM_Report_1].ActivityID = LS.ActivityId
---
---
---
print getdate()






/*


---
---
---
SELECT 
	LA.[ActivityId]
	, LD.DatabaseName
	, LSVR.ServerName
	, LA.Time
	, WAT.Name "Activity Type"
	, LDBU.DbUserName
	, left(LS.StatementText, 3975) "Statement Text"
into WTC_MFM_Report_1
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
print getdate()

*/