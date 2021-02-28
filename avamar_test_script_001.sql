---
---this is avamar_test_script_001.sql
---
USE DBATASKS
declare @date_hold   nvarchar(30)
declare       @sql_stmt     nvarchar(500)
SELECT @date_hold = replace(replace(replace(replace(CONVERT(VARCHAR(30),GETDATE(),121), ' ', '_'), ':', '_'), '.', '_'), '-', '_')
set @sql_stmt = 'CREATE TABLE DBATASKS.DBO.JOE_TEST_' + @date_hold + ' (COL_A     VARCHAR(30));  checkpoint; INSERT INTO DBATASKS.DBO.JOE_TEST_' + @date_hold + '  VALUES (''' + @date_hold + ''');'
print @sql_stmt
exec sp_executesql @sql_stmt
waitfor delay '00:01:00'
set @sql_stmt = 'INSERT INTO DBATASKS.DBO.JOE_TEST_' + @date_hold + '  VALUES (''' + @date_hold + ''');'
print @sql_stmt
exec sp_executesql @sql_stmt
waitfor delay '00:01:00'
set @sql_stmt = 'INSERT INTO DBATASKS.DBO.JOE_TEST_' + @date_hold + '  VALUES (''' + @date_hold + ''');'
print @sql_stmt
exec sp_executesql @sql_stmt
---
---
---Then i used redgate data generation
---
---THEN FROM  https://www.sqlshack.com/how-to-generate-random-sql-server-test-data-using-t-sql/      I USED THE FOLLOWING TO Generate random integer values 
---
;with randomvalues
    as(
       select 
	   1 id, 
	   CONVERT(varchar(20), CRYPT_GEN_RANDOM(10)) as mypassword
        union  all
        select 
		id + 1,  
		CONVERT(varchar(20), CRYPT_GEN_RANDOM(10)) as mypassword
        from randomvalues
        where 
          id < 100
      )
 
  
INSERT INTO DBATASKS.[dbo].[JOE_TEST_2020_12_04_14_34_23_070]
    select mypassword
    from randomvalues
    OPTION(MAXRECURSION 0)


;with randomvalues
    as(
       select 1 id, CAST(RAND(CHECKSUM(NEWID()))*100 as int) randomnumber
	   --select 1 id, RAND(CHECKSUM(NEWID()))*100 randomnumber
        union  all
        select id + 1, CAST(RAND(CHECKSUM(NEWID()))*100 as int)  randomnumber
		--select id + 1, RAND(CHECKSUM(NEWID()))*100  randomnumber
        from randomvalues
        where 
          id < 1000
      )
 
 
 
INSERT INTO DBATASKS.[dbo].[JOE_TEST_2020_12_04_14_34_23_070]
    select randomnumber
    from randomvalues
    OPTION(MAXRECURSION 0)
---
---
---






---
---The following is from
---https://www.mssqltips.com/sqlservertip/5148/populate-large-tables-with-random-data-for-sql-server-performance-testing/
---

USE Random_Data_DB
declare @datetime2_hold	datetime2
set @datetime2_hold = getdate()
----------print @datetime2_hold
CREATE Table tblAuthors
(
   Id int identity primary key,
   Author_name nvarchar(50),
   country nvarchar(50),
   entry_datetime2	datetime2
)
CREATE Table tblBooks
(
   Id int identity primary key,
   Auhthor_id int foreign key references tblAuthors(Id),
   Price int,
   Edition int,
   entry_datetime2	datetime2
);
---
---
---
Declare @Id int
Set @Id = 1

While @Id <= 12000
Begin 
	set @datetime2_hold = getdate()
   Insert Into tblAuthors values ('Author - ' + CAST(@Id as nvarchar(10)),
              'Country - ' + CAST(@Id as nvarchar(10)) + ' name'
			   , @datetime2_hold)

----------   Print @Id
   Set @Id = @Id + 1
End
---
---
---
Declare @RandomAuthorId int
Declare @RandomPrice int
Declare @RandomEdition int

Declare @LowerLimitForAuthorId int
Declare @UpperLimitForAuthorId int

Set @LowerLimitForAuthorId = 1
Set @UpperLimitForAuthorId = 12000


Declare @LowerLimitForPrice int
Declare @UpperLimitForPrice int

Set @LowerLimitForPrice = 50 
Set @UpperLimitForPrice = 100 

Declare @LowerLimitForEdition int
Declare @UpperLimitForEdition int

Set @LowerLimitForEdition = 1
Set @UpperLimitForEdition = 10


Declare @count int
Set @count = 1

While @count <= 20000
Begin 

   Select @RandomAuthorId = Round(((@UpperLimitForAuthorId - @LowerLimitForAuthorId) * Rand()) + @LowerLimitForAuthorId, 0)
   Select @RandomPrice = Round(((@UpperLimitForPrice - @LowerLimitForPrice) * Rand()) + @LowerLimitForPrice, 0)
   Select @RandomEdition = Round(((@UpperLimitForEdition - @LowerLimitForEdition) * Rand()) + @LowerLimitForEdition, 0)
   set @datetime2_hold = getdate()

   Insert Into tblBooks values (@RandomAuthorId, @RandomPrice, @RandomEdition, @datetime2_hold)
---------------------------------   Print @count
   Set @count = @count + 1
End
