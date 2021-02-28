SET CONCAT_NULL_YIELDS_NULL OFF
declare	@cola_hold	int
declare	@colb_hold	char(1)
create table #Test
(
	ColA int,
	ColB char(1)
)

INSERT INTO #Test (ColA, ColB) VALUES (1, 'A')
INSERT INTO #Test (ColA, ColB) VALUES (1, 'B')
INSERT INTO #Test (ColA, ColB) VALUES (2, 'D')
INSERT INTO #Test (ColA, ColB) VALUES (2, 'E')
INSERT INTO #Test (ColA, ColB) VALUES (3, 'F')
INSERT INTO #Test (ColA, ColB) VALUES (4, 'G')

--Desired Result
/*
ColA		ColB
----------	-----
1		AB
2		DE
3		F
4		G

*/

print 'show all data'
select * from #test
print 'show distinct values of cola'
select	distinct a.cola
	from #test a

create table #combined
(
 col1	int,
 col2	varchar(10)
)
insert into #combined
 (col1)
select distinct cola from #test

declare raw_data_cursor cursor
for
select cola, colb from #test 
open raw_data_cursor
fetch raw_data_cursor into @cola_hold, @colb_hold
while (@@fetch_status = 0) 
begin
update #combined
 set col2 = col2 + @colb_hold
from #test a
where col1 = @cola_hold
fetch raw_data_cursor into @cola_hold, @colb_hold
end
close raw_data_cursor
deallocate raw_data_cursor
---
select * from #combined

drop table #test
drop table #combined

SET CONCAT_NULL_YIELDS_NULL ON