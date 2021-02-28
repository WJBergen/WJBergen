declare @counter 	bigint
declare @delaylength	char(9)
set @counter = 0
set @delaylength = '000:00:02'		---In HHH:MM:SS format  thus 2 sec
CREATE TABLE #temp_who2
(
	SPID		smallint,
	Status  	varchar(250),
	Login		varchar(250),
	HostName	varchar(250),
	BlkBy		char(05),
	DBName		varchar(250),	
	Command		varchar(250),
	CPUTime		bigint,
	DiskIO		bigint,
	LastBatch	varchar(250),
	ProgramName	varchar(250),
	SPID_2 		smallint
)
---
---
---
create table #Thread_Info
(
 Sample_Date			datetime,
 Total_Threads			bigint,
 Threads_with_no_cputime	bigint,
 Threads_with_cputime		bigint
)
---
---
---
while @counter < 70
begin
---
---
---
truncate table #temp_who2
set nocount on
insert into #temp_who2
	exec master.dbo.sp_who2
---
---
---
delete from #temp_who2
where spid <= 50
or    dbname <> 'Longview'
---
---
---
print 'Counter = ' + cast(@counter as char)
insert into #Thread_Info
(
 sample_date,
 Total_Threads,
 Threads_with_no_cputime,
 Threads_with_cputime
)
select 
	getdate()
	, count(*) as 'Total Longview Threads'
	, (select count(*) from #temp_who2 where CPUTime = 0) as 'No CPUTime'
	, (select count(*) from #temp_who2 where CPUTime <> 0) as 'Have CPUTime'
from	#temp_who2
---
---
---
if (@counter < 70) 
begin
	waitfor delay @delaylength
end
set @counter = @counter + 1
end
---
---
---
select * from #Thread_Info
set nocount off 
drop table #temp_who2
drop table #Thread_Info
