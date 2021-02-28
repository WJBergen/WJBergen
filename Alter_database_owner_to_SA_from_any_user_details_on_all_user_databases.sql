---
---This is Alter_database_owner_to_SA_from_any_user_details_on_all_user_databases.sql
---
/*
Alter database owner to SA from any user details on all user databases
By S M, 2016/08/17 


Copy and paste the code in the SQL Management Studio. 
It will generate the final script for you in the output screen. 
Copy them and run in the SQL Management Studio again and alter database owner details to SA. 

FROM:  http://www.sqlservercentral.com/scripts/Security/121222/

*/
---
---
---
SELECT 'use '+QUOTENAME(name)
+ 
' exec sp_changedbowner @loginame =''sa'' ' FROM sys.databases AS d WHERE d.database_id > 4;