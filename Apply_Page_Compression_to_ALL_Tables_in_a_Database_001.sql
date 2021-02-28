---
---This is Apply_Page_Compression_to_ALL_Tables_in_a_Database_001.sql
---
---FROM:  FROM:  https://blog.sqlauthority.com/2019/05/22/sql-server-script-to-enable-page-and-row-level-compression-disable-compression/
---
/*****
ALTER TABLE [NameofYourTable] REBUILD PARTITION = ALL
    WITH (DATA_COMPRESSION = PAGE);
******/
USE Dac_custom_Tables
declare	@table_catalog_hold	sysname
declare	@table_schema_hold	sysname
declare	@table_name_hold	sysname
declare	@alter_table_stmt	nvarchar(max)
declare	@execute_sw			char(1)
---
---
---
set @execute_sw = 'Y'
---
---
---
declare table_cursor cursor static
for
select table_catalog
       , table_schema
       , table_name
from Dac_custom_Tables.INFORMATION_SCHEMA.TABLES
where 
TABLE_TYPE like '%TABLE%';
open table_cursor
fetch next from table_cursor into 	@table_catalog_hold, @table_schema_hold, @table_name_hold;
while (@@FETCH_STATUS = 0)
begin
set @alter_table_stmt = concat('ALTER TABLE  ', @table_catalog_hold, '.', @table_schema_hold, '.', @table_name_hold, ' REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);')
select @alter_table_stmt
if @execute_sw = 'Y'
begin
exec sp_executesql @alter_table_stmt
end
fetch next from table_cursor into 	@table_catalog_hold, @table_schema_hold, @table_name_hold;
end
close table_cursor;
deallocate table_cursor;