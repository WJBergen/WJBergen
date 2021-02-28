drop table #test 
create table #Test
(
	ColA int,
	ColB char(1)
)

INSERT INTO #Test (ColA, ColB) VALUES (1, 'A')
INSERT INTO #Test (ColA, ColB) VALUES (1, 'B')
insert into #test (cola, colb) values (1, 'C')
insert into #test (cola, colb) values (1, 'D')
insert into #test (cola, colb) values (1, 'E')
insert into #test (cola, colb) values (1, 'E')
INSERT INTO #Test (ColA, ColB) VALUES (2, 'D')
INSERT INTO #Test (ColA, ColB) VALUES (2, 'E')
INSERT INTO #Test (ColA, ColB) VALUES (3, 'F')
INSERT INTO #Test (ColA, ColB) VALUES (4, 'G')

drop table #result
create table #result
(
	cola int,
	colb varchar(20)
)

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
declare @cola_hold	int
declare @colb_hold	char(1)
declare @colb_concat	varchar(20)
declare	@tablecnt	int
declare @distinct_as	int
declare @unique_a_hold	int
set @cola_hold = 0
set @colb_hold = ''
set @colb_concat = ''
select @Tablecnt = count(*) from #Test
select @distinct_as = 0
select @distinct_as=count(distinct cola) from #test
print 'starting values'
select @tablecnt
select @distinct_as
while	@distinct_as > 0
begin
select	top 1	@cola_hold=cola
		, @colb_hold=colb
	from #test
	where cola > @cola_hold
select @unique_a_hold=count(cola) from #test
	where cola = @cola_hold
select @tablecnt = @unique_a_hold 
print 'unique_a_hold'
select @unique_a_hold
while	@Tablecnt > 0
	begin
		if @tablecnt = @unique_a_hold
		begin
			select top 1	@colb_hold = colb
			from		#Test
			where [cola] = @cola_hold
		end
		else
		begin
			select top 1	@colb_hold = colb
			from		#Test
			where [cola] = @cola_hold
			and   [colb] > @colb_hold
		end
		set @colb_concat = @colb_concat + @colb_hold
		set @tableCnt = @TableCnt - 1
	end
print 'concatenated value'
select @cola_hold, @colb_concat
insert into #result
(
 cola,
 colb
)
select @cola_hold, @colb_concat
set @distinct_as = @distinct_as - 1
set @colb_concat = ''
end
print 'Now print the entire result table '
select * from #result

