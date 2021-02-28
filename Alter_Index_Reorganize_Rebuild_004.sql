USE [DBATASKS]
GO

/****** Object:  StoredProcedure [dbo].[spr_Alter_Index_Reorganize_Rebuild]    Script Date: 11/10/2011 12:12:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spr_Alter_Index_Reorganize_Rebuild]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spr_Alter_Index_Reorganize_Rebuild]
GO

USE [DBATASKS]
GO

/****** Object:  StoredProcedure [dbo].[spr_Alter_Index_Reorganize_Rebuild]    Script Date: 11/10/2011 12:12:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[spr_Alter_Index_Reorganize_Rebuild]
	(
	 @input_db_name						sysname,
	 @input_fragmentation_percent		numeric(5,2) = 005.00,
	 @input_reorganize_percent			numeric(4,2) = 030.00,
	 @input_page_count					bigint = 100,
	 @input_execution_sw				char(1) = 'N'
	)
as
--- -----------------------------------------------------------------------------------------
--- Name:	DBATASKS.dbo.spr_Alter_Index_Reorganize_Rebuild
---
--- Author:	Bill Bergen
---
--- Date:	11/02/2011
---
--- Description:  The purpose of this stored procedure is to perform either a reorganize or 
---				  rebuild of indices on a specified database.  This may save time over a full
---				  dbcc reindex for all indices within the specified database.
---
--- Parameters:	@input_db_name - the name of the database that will have its indices reoganized
---					or reindexed
---				@input_fragmentation_percent - default is 5%.  Shown in 999.99 as a decimal
---				@input_page_count - number of pages used as a threshold for small tables.  
---					Default is 100 pages. The value is an integer
---				@execution_sw - will indicate whether or not to actually execute the alter
---					statement.  Values are Y or N
---
---This is DBATASKS.dbo.spr_Alter_Index_Reorganize_Rebuild_004.sql 
---
---NOTE by using the database name in the data management view we avoid the problem caused 
---when using DB_ID() which can only be used for compatibility mode 90 and above.
---
DECLARE 
	@loop SMALLINT,
	@count SMALLINT,
	@TableName VARCHAR(256), 
	@IndexName VARCHAR(256),
	@fragmentation NUMERIC(5,2),
	@SQL VARCHAR(512);
DECLARE	@sql_stmt				varchar(max)
declare	@compatibility_80_sw	char(1)
set @compatibility_80_sw = null
declare	@msg					varchar(3000)	
set @msg = 'Start of Stored Procedure DBATASKS.dbo.spr_Alter_Index_Reorganize_Rebuild '
			+ ' on server '
			+ ltrim(rtrim(@@servername))
			+ ' at '
			+ cast(getdate() as char)

---
---for debugging only
---
/*
declare	 @input_db_name						sysname
declare	 @input_fragmentation_percent		numeric(5,2)
declare	 @input_reorganize_percent			numeric(4,2) 
declare	 @input_page_count					bigint
declare	 @input_execution_sw				char(1)
set		@input_db_name					= 'Carmen_Farrow_10192011'
set		@input_fragmentation_percent	= 005.00
set		@input_reorganize_percent		= 30.00
set		@input_page_count				= 100
set		@input_execution_sw			= 'N'
*/
-----ignore fragementation < 005.00 for relativiely large tables
-----Ignore small table, REBUILD and Reorg has no impact on small tables with few pages, 
-----can increase the count upto 1000... 

print @msg
set @input_execution_sw = upper(@input_execution_sw)
set @msg = 'The input parameters have the following values:'
print @msg
set @msg = '@input_db_name = ' + @input_db_name
print @msg
set @msg = '@input_fragmentation_percent = ' + cast(@input_fragmentation_percent as char)
print @msg
set @msg = '@input_reorganize_percent = ' + cast(@input_reorganize_percent as char)
print @msg
set @msg = '@input_page_count = ' + cast(@input_page_count as char)
print @msg
set @msg = '@input_execution_sw = ' + @input_execution_sw
print @msg

create TABLE ##indexes
(
ID				INT IDENTITY(1,1),
TableName		VARCHAR(256), 
IndexName		VARCHAR(256),
fragmentation	NUMERIC(5,2),
page_count		bigint
)
---
---Create a global table to get the compatibility level
---of the database.  The DMV used below ONLY works if 
---compatibility level is 90 or higher.  In the case 
---of compatibility level 80 then a dbcc reindex will
---be required.
---
create table ##compatibility_level
(
database_name		varchar(max),
compatibility_level	varchar(max)
)

set @sql_stmt = 
				'insert into ##compatibility_level '
				+ char(10)
				+ 'select name, compatibility_level '
				+ char(10)
				+ 'from sys.databases '
				+ char(10)
				+ 'where name = ''' 
				+ @input_db_name
				+ ''''
print @sql_stmt
exec (@sql_stmt)
---
---
---
select *
from ##compatibility_level
---
---
---
select @compatibility_80_sw = 'Y'
from ##compatibility_level
where compatibility_level like '%80%'
---
---
---
select @compatibility_80_sw = 'N'
from ##compatibility_level
where compatibility_level not like '%80%'
---
if @compatibility_80_sw = 'Y'
begin
set @msg =  'For '
			+ @input_db_name
			+ char(10)
			+ 'the compatibility mode is 80'
			+ char(10)
			+ 'therefore using DMVs to determine '
			+ char(10)
			+ 'whether an index can be reorganized or '
			+ char(10)
			+ 'reindexed is NOT possible'
			+ char(10)
			+ 'A dbcc reindex must be done instead'
print @msg
goto endit			
end
---
---
---
SELECT @loop=1,@count=0;
---
---create the use statement and the select statement so that the entire sql statement is 
---dynamic and will run against the database indicated in the @input_db_name parameter
---
set @sql_stmt =
'USE ' + @input_db_name
+ char(10)
+ 'Insert into ##indexes'
+ char(10)
+ 'SELECT '
+ char(10)
+ '	o.name as TableName, '
+ char(10)
+ '	i.name as IndexName, '
+ char(10)
+ '	s.avg_fragmentation_in_percent, '
+ char(10)
+ ' s.page_count'
+ char(10)
+ '	FROM sys.dm_db_index_physical_stats(DB_ID(N'''+ @input_db_name + '''),NULL, NULL, NULL, ''LIMITED'') s '
+ char(10)
+ ' JOIN sys.objects o'
+ char(10)
+ ' on o.object_id = s.object_id '
+ char(10)
+ ' JOIN sys.indexes i '
+ char(10)
+ ' on o.object_id = i.Object_id '
+ char(10)
+ ' AND s.index_id = i.index_id '
+ char(10)
+ ' WHERE o.type_desc = ''USER_TABLE'''
+ char(10)
+ ' and avg_fragmentation_in_percent > ' + cast(@input_fragmentation_percent as char)
+ char(10)
+ ' and s.page_count > ' + cast(@input_page_count as char)
+ char(10)
+ ' and i.Name is not null '
print @sql_stmt
---
---
---
exec (@sql_stmt)
---
---
---
/*
Insert into ##indexes
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
	and s.page_count > 100 --Ignore small table, REBUILD and Reorg has no impact on small tables with few pages, can increase the count upto 1000... 
	and i.Name is not null
*/
SET @count = (SELECT COUNT(*) FROM ##indexes)

WHILE @loop<=@count
BEGIN
	SELECT	@TableName = TableName,
			@IndexName = IndexName,
			@fragmentation = fragmentation
	FROM ##indexes WHERE ID = @loop
	
	IF (@fragmentation <= @input_reorganize_percent)
		BEGIN
			SET @SQL=
			'USE ' + @input_db_name
			+ char(10)
			+ 'ALTER INDEX ['+ @IndexName  + '] ON [' + @TableName + '] REORGANIZE;'
			+ char(10)
			PRINT @SQL
			If @input_execution_sw = 'Y'
			begin
				EXEC(@SQL)
			end 
		END
	ELSE
		BEGIN
			SET @SQL=
			'USE ' + @input_db_name
			+ char(10)
			+ 'ALTER INDEX ['+ @IndexName  + '] ON [' + @TableName + '] REBUILD;'
			+ char(10)
			PRINT @SQL
			If @input_execution_sw = 'Y'
			begin
				EXEC(@SQL)
			end
		END
	
	SET @loop = @loop+1;		
END
---
---
---
print getdate()
print 'Fragmentation is as follows'
select * from ##indexes
endit:
drop table ##indexes
drop table ##compatibility_level
set @msg = 'End of Stored Procedure DBATASKS.dbo.spr_Alter_Index_Reorganize_Rebuild '
			+ ' on server '
			+ ltrim(rtrim(@@servername))
			+ ' at '
			+ cast(getdate() as char)
print @msg

GO


