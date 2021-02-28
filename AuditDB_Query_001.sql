---------------- THE MAIN QUERY RIGHT HERE
SELECT	lt.[ACTIVITYID]
		, LD.databasename
		, LSVR.SERVERNAME
		, lt.[TIME]
		, lo.opcodename
		, ll.LoginName
		, LTD.detailTEXT
FROM	[AuditDB_Repository].[dbo].[lumtransactions_Repository1] LT
		, [AuditDB_Repository].[dbo].[lumsessions_Repository1] LS
		, [AuditDB_Repository].[dbo].[lumlogins_Repository1] LL
		, [AuditDB_Repository].[dbo].[lumdatabases_Repository1] LD
		, [AuditDB_Repository].[dbo].[lumservers_Repository1] LSVR
		, [AuditDB_Repository].[dbo].[lumopcodes_Repository1] LO
		, [AuditDB_Repository].[dbo].[lumTraceDetails_Repository1] LTD
where
      ld.databasename = 'ework'
 and  lsvr.servername = 'wil-sql-12'
 and  lt.time > '06/01/05'
-- and  lo.opcodename not in ('backup', 'maintenance', 'login failed')
 and  lo.opcodeid in (
        select opcodeid from
          [AuditDB_Repository].[dbo].lumopcodes_Repository1     -- new
          where (opcodeid/100) in (2, 3, 4, 30)
                and opcodeid not in (3020))
 and   LT.sessionID = LS.sessionID
 and  LS.LoginID = LL.LoginID
 and  lt.DATABASEID = LD.databaseid
 and  lt.SERVERID = LSVR.SERVERID
 and  lt.opcodeID = LO.opcodeID
 and  LT.ACTIVITYID = LTD.ACTIVITYID
order by lt.time

