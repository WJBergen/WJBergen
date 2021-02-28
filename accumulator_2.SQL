SET CONCAT_NULL_YIELDS_NULL OFF
drop table #test 
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


select * from #test

select	distinct a.cola
	from #test a

select	a.cola,
	a.colb +
	(select b.colb from #test b where a.cola = b.cola and a.colb <> b.colb)
	from #test a

select	a.cola,
	(a.colb +
	(select b.colb from #test b where a.cola = b.cola and a.colb <> b.colb)) as xyz
	from #test a

drop table #combined
create table #combined
(
 cola	int,
 colb	varchar(30)
)
insert into #combined
(cola)
select	distinct a.cola
	from #test a

select * from #combined

update #combined 
	set #combined.colb = #combined.colb + a.colb
from	#test a
where	#combined.cola = a.cola

select * from #combined

select * from #test 