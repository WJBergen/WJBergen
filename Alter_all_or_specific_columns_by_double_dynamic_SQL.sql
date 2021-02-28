---
---This is Alter_all_or_specific_columns_by_double_dynamic_SQL.sql
---
/*
Alter all/specific columns by double dynamic SQL
By Ashish Shevale, 2015/11/03 

FROM:  http://www.sqlservercentral.com/scripts/Alter/132584/

Change the database, schema and coumn name which are prefix as 'My' respectively 


You will need to have access to create temp table if there are multiple DDL to be created. The script will take care of multiple DDL creation though 


Most Important DO NOT EXECUTE DIRECTLY ON PRODUCTION 

*/

USE MyDB
GO


DECLARE @sqlselect NVARCHAR(500);
DECLARE @sql NVARCHAR(500);
DECLARE @ID INT;

SELECT @sqlselect = 'select ''ALTER TABLE ''+TABLE_CATALOG+''.''+TABLE_SCHEMA+''.''+TABLE_NAME+'' ALTER COLUMN ''+COLUMN_NAME+'' ''+DATA_TYPE+'' ''+case when DATA_TYPE=''varchar''
then ''(''+LTRIM(RTRIM(cast(CHARACTER_MAXIMUM_LENGTH as char(3))))+'')''
else ''''
end+'' NULL;''	 from INFORMATION_SCHEMA.COLUMNS
where TABLE_CATALOG=''MyDB'' and TABLE_SCHEMA=''Myschema''
and IS_NULLABLE=''NO''
and COLUMN_NAME not in (''MyColumn if required'')';

IF OBJECT_ID('tempdb.dbo.#tempQuery', 'U') IS NOT NULL
	DROP TABLE #tempQuery;

CREATE TABLE #tempQuery (
	ID INT IDENTITY(1, 1)
	,abc NVARCHAR(max)
	);

INSERT INTO #tempQuery
EXEC @sql = sp_executesql @sqlselect;

SELECT @ID = max(ID)
FROM #tempQuery;

WHILE (@ID > 0)
BEGIN
	SELECT @sql = abc
	FROM #tempQuery
	WHERE ID = @ID;

	EXECUTE (@sql);

	SET @ID = @ID - 1;
END;

IF OBJECT_ID('tempdb.dbo.#tempQuery', 'U') IS NOT NULL
	DROP TABLE #tempQuery;
