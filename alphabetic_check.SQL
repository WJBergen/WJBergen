---
---check for alphabetic characters in a column
---
print 'Create the temp table used for testing'
create table #holdit
(
col_a char(1)
)
print 'Insert both upper and lower case as well as blank and nothing'
insert into #holdit values ('a')
insert into #holdit values ('')
insert into #holdit values (' ')
insert into #holdit values ('b')
insert into #holdit values ('c')
insert into #holdit values ('d')
insert into #holdit values ('e')
insert into #holdit values ('f')
insert into #holdit values ('g')
insert into #holdit values ('h')
insert into #holdit values ('i')
insert into #holdit values ('j')
insert into #holdit values ('k')
insert into #holdit values ('l')
insert into #holdit values ('m')
insert into #holdit values ('n')
insert into #holdit values ('o')
insert into #holdit values ('p')
insert into #holdit values ('q')
insert into #holdit values ('r')
insert into #holdit values ('s')
insert into #holdit values ('t')
insert into #holdit values ('u')
insert into #holdit values ('v')
insert into #holdit values ('w')
insert into #holdit values ('x')
insert into #holdit values ('y')
insert into #holdit values ('z')
---
insert into #holdit values ('A')
insert into #holdit values ('B')
insert into #holdit values ('C')
insert into #holdit values ('D')
insert into #holdit values ('E')
insert into #holdit values ('F')
insert into #holdit values ('G')
insert into #holdit values ('H')
insert into #holdit values ('I')
insert into #holdit values ('J')
insert into #holdit values ('K')
insert into #holdit values ('L')
insert into #holdit values ('M')
insert into #holdit values ('N')
insert into #holdit values ('O')
insert into #holdit values ('P')
insert into #holdit values ('Q')
insert into #holdit values ('R')
insert into #holdit values ('S')
insert into #holdit values ('T')
insert into #holdit values ('U')
insert into #holdit values ('V')
insert into #holdit values ('W')
insert into #holdit values ('X')
insert into #holdit values ('Y')
insert into #holdit values ('Z')
---
insert into #holdit values ('0')
insert into #holdit values ('1')
insert into #holdit values ('2')
insert into #holdit values ('3')
---
print 'Show all the columns with alphabetic data'
select	col_a
	from #holdit
	where	col_a >= 'a'
	and	col_a <= 'Z'
---
print 'Show a count of all rows NOT containing alphabetic characters'
select count(col_a)
	from #holdit
	where	NOT(col_a >= 'a'
	and	col_a <= 'Z')
	group by col_a
---
drop table #holdit
