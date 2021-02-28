---
---This is Add_Users_and_Add_Them_to_the_DBO_Role_in_a_Passthru_Database_001.sql
---
SET TEXTSIZE -1
USE CLARITY_SNAPSHOT_DB_PASSTHRU;
DECLARE @execute_sw	char(10)
set @execute_sw = 'Y'
declare	@username_hold							sysname
declare	@create_user_statement_hold				nvarchar(MAX)
declare	@add_db_datareader_statement_hold		nvarchar(MAX)
---
---
---
DROP TABLE IF EXISTS #ADD_DB_DATAREADER_TO_ALL_USERS ;
---
---
---
select name as username
       , create_date
       , modify_date
       , type_desc as type
       , authentication_type_desc as authentication_type
	   , concat('USE CLARITY_SNAPSHOT_DB_PASSTHRU; ', CHAR(10), 'CREATE USER [', name, '] WITH DEFAULT_SCHEMA=DBO;')
	     as CREATE_USER_statement
	   , concat(CHAR(10), 'USE CLARITY_SNAPSHOT_DB_PASSTHRU; ', CHAR(10), 'ALTER ROLE DB_DATAREADER ADD MEMBER [', name, '];')
	     as add_db_datareader_statement
INTO #ADD_DB_DATAREADER_TO_ALL_USERS 
from 
clarity.sys.database_principals
where 
type not in ('A', 'G', 'R', 'X')
and 
sid is not null
and 
name != 'guest'
and
name <> 'dbo'
order by username;
---
---
---
/************************
use mydb
go

ALTER ROLE db_datareader
  ADD MEMBER MYUSER;
************************/
---
---
---
DROP TABLE IF EXISTS #ADD_DB_DATAREADER_TO_ALL_USERS;
DROP TABLE IF EXISTS #ALL_SERVERS_USERS;
select name as username
       , create_date
       , modify_date
       , type_desc as type
       , authentication_type_desc as authentication_type
	   , concat('USE CLARITY_SNAPSHOT_DB_PASSTHRU; ', CHAR(10), 'CREATE USER [', name, '] WITH DEFAULT_SCHEMA=DBO;')
	     as CREATE_USER_statement
	   , concat(CHAR(10), 'USE CLARITY_SNAPSHOT_DB_PASSTHRU; ', CHAR(10), 'ALTER ROLE DB_DATAREADER ADD MEMBER [', name, '];')
	     as add_db_datareader_statement
INTO #ADD_DB_DATAREADER_TO_ALL_USERS 
from 
clarity.sys.database_principals
where 
type not in ('A', 'G', 'R', 'X')
and 
sid is not null
and 
name != 'guest'
and
name <> 'dbo'
order by username;
---
---
---
/************************
use mydb
go

ALTER ROLE db_datareader
  ADD MEMBER MYUSER;
************************/
---
---
---
select sp.name as login,
       sp.type_desc as login_type,
       sl.password_hash,
       sp.create_date,
       sp.modify_date,
       case when sp.is_disabled = 1 then 'Disabled'
            else 'Enabled' end as status
INTO #ALL_SERVERS_USERS
from 
sys.server_principals sp
left join 
sys.sql_logins sl
on 
sp.principal_id = sl.principal_id
where 
sp.type not in ('G', 'R')
and 
sp.name not like '##%'
and
sp.name not like 'NT %'
and 
sp.name not like '%UPHS\svc_spotlight%'
order by sp.name;
---
---THE FOLLOWING CODE WILL GET ALL THE USERS THAT ARE ON THE SERVER BUT NOT IN THE DATABASE
---
SELECT * FROM #ALL_SERVERS_USERS;
SELECT * FROM #ADD_DB_DATAREADER_TO_ALL_USERS;

SELECT	A.*
FROM 
#ALL_SERVERS_USERS A
WHERE 
A.LOGIN NOT IN (SELECT B.USERNAME FROM #ADD_DB_DATAREADER_TO_ALL_USERS B)
and 
A.LOGIN <> 'SA'

---
---
---
declare user_cursor cursor static
for
select username, create_user_statement, add_db_datareader_statement 
from #ADD_DB_DATAREADER_TO_ALL_USERS;
---
---
---
open user_cursor;
fetch next from user_cursor into @username_hold, @create_user_statement_hold, @add_db_datareader_statement_hold;
while (@@FETCH_STATUS = 0)
begin
select concat('THE USER ', @username_hold, ' IS ABOUT TO BE ADDEDED IN DATABASE ', DB_NAME(), ' WITH THE FOLLOWING STATEMENTS ===> ', CHAR(10), @CREATE_USER_statement_hold);
select concat(CHAR(10), 'DB_DATAREADER IS ABOUT TO BE ADDED TO USER ', @username_hold, ' IN DATABASE ', DB_NAME(), ' WITH THE FOLLOWING STATEMENT ===> ',CHAR(10), @add_db_datareader_statement_hold);
if @execute_sw = 'Y'
begin
exec sp_executesql @create_user_statement_hold
exec sp_executesql @add_db_datareader_statement_hold
end
fetch next from user_cursor into @username_hold, @create_user_statement_hold, @add_db_datareader_statement_hold;
end
---
---
---
close user_cursor;
deallocate user_cursor;
---
---
---
DROP TABLE IF EXISTS #ADD_DB_DATAREADER_TO_ALL_USERS;
DROP TABLE IF EXISTS #ALL_SERVERS_USERS;
---
---
---