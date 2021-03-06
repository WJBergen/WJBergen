---
---This is Alter_Index_Reorganize_Rebuild_002.sql
---
DECLARE 
	@loop SMALLINT,
	@count SMALLINT,
	@TableName VARCHAR(256), 
	@IndexName VARCHAR(256),
	@fragmentation NUMERIC(5,2),
	@SQL VARCHAR(512);

DECLARE @Indexes TABLE
(
ID INT IDENTITY(1,1),
TableName VARCHAR(256), 
IndexName VARCHAR(256),
fragmentation NUMERIC(5,2)
)

create table #online_databases
(
database_name		sysname,
status				int
)
insert into #online_databases
select	name
		, status
from sys.sysdatabases
where status <> 528			---for databases that are offline

select *
from #online_databases
order by database_name 

drop table #online_databases

SELECT @loop=1,@count=0;

INSERT INTO @Indexes
	SELECT
	o.name as TableName,
	i.name as IndexName,
	s.avg_fragmentation_in_percent
	FROM sys.dm_db_index_physical_stats(DB_ID(),NULL, NULL, NULL, 'LIMITED') s 
		JOIN sys.objects o
			on o.object_id = s.object_id
		JOIN sys.indexes i
		on o.object_id = i.Object_id
		AND s.index_id = i.index_id
	WHERE o.type_desc = 'USER_TABLE'
	and avg_fragmentation_in_percent > 5 -- ignore fragementation <5 for relativiely large tables
	and s.page_count> 100 --Ignore small table, REBUILD and Reorg has no impact on small tables with few pages, can increase the count upto 1000... 
	and i.Name is not null

SET @count = (SELECT COUNT(*) FROM @Indexes)

WHILE @loop<=@count
BEGIN
	SELECT	@TableName = TableName,
			@IndexName = IndexName,
			@fragmentation = fragmentation
	FROM @Indexes WHERE ID = @loop
	
	IF (@fragmentation <=30.0)
		BEGIN
			SET @SQL='ALTER INDEX '+ @IndexName  + ' ON [' + @TableName + '] REORGANIZE;'
			PRINT @SQL
			EXEC(@SQL)
		END
	ELSE
		BEGIN
			SET @SQL='ALTER INDEX '+ @IndexName  + ' ON [' + @TableName + '] REBUILD;'
			PRINT @SQL
			EXEC(@SQL)
		END
	
	SET @loop = @loop+1;		
END
