---
---This is All_View_Refresh.sql
---
/*
SQL Server All View Refresh

FROM:  http://www.sqlservercentral.com/scripts/Performance/167107/?utm_source=SSC&utm_medium=pubemail
 By Yusuf Kahveci, 2018/06/05 

run the script I prepared to update all the views in the database

Yusuf KAHVECI

yusufkahveci@sqlturkiye.com 

www.sqlturkiye.com 

Thanks 

*/

USE <Database_Name>
GO
DECLARE @sqlTrexec NVARCHAR(MAX)=''
SELECT @sqlTrexec = @sqlTrexec + 'EXEC sp_refreshview ''' + name + '''; 
'
FROM sys.objects AS syso
WHERE syso.type='V'
EXEC (@sqlTrexec)
--SELECT @sqlTrexec