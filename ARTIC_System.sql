USE [Automatic_Restore_Test_Integrated_Capability]
GO

/****** Object:  Table [dbo].[ARTIC_Base_Table]    Script Date: 3/27/2014 2:24:07 PM ******/
DROP TABLE [dbo].[ARTIC_Base_Table]
GO

/****** Object:  Table [dbo].[ARTIC_Base_Table]    Script Date: 3/27/2014 2:24:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ARTIC_Base_Table]
(
	[SERVER_NAME] [nvarchar](128) NULL,
	[Cluster_Virtual_Server_Name] [nvarchar](128) NULL,
	[Cluster_Node_Name] [nvarchar](128) NULL,
	[DATABASE_NAME] [nvarchar](128) NULL,
	[BackUpType] [varchar](200) NOT NULL,
	[BACKUP_START_DATE] varchar(300) NULL,
	[BACKUP_FINISH_DATE] varchar(300) NULL,
	[Logical filename] [sysname] NOT NULL,
	[database_physical_file_name] [nvarchar](1000) NOT NULL,
	[backup_path_and_file] [nvarchar](1000) NULL,
	[sql_restore_command_with_move] [varchar](max) NULL,
	[target_db_mdf_path] [varchar](1000) NULL,
	[target_db_ndf_path] [varchar](1000) NULL,
	[target_db_ldf_path] [varchar](1000) NULL,
	[db_to_be_restored_from_csc] [char](1) NULL,
	[db_restored_from_csc] [char](1) NULL,
	[db_restore_successful] [char](1) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [Automatic_Restore_Test_Integrated_Capability]
GO

drop table [dbo].[ARTIC_Base_Table_Import_Work]

CREATE TABLE [dbo].[ARTIC_Base_Table_Import_Work]
(
	[Server Name varchar(123) null,		---NOTE THIS IS THE SERVER NAME FROM THE REGISTERED SERVERS
	[SERVER_NAME] [nvarchar](128) NULL,
	[Cluster_Virtual_Server_Name] [nvarchar](128) NULL,
	[Cluster_Node_Name] [nvarchar](128) NULL,
	[DATABASE_NAME] [nvarchar](128) NULL,
	[BackUpType] [varchar](200) NOT NULL,
	[BACKUP_START_DATE] varchar(300) NULL,
	[BACKUP_FINISH_DATE] varchar(300) NULL,
	[Logical filename] [sysname] NOT NULL,
	[database_physical_file_name] [nvarchar](1000) NOT NULL,
	[backup_path_and_file] [nvarchar](1000) NULL,
	[sql_restore_command_with_move] [varchar](max) NULL,
	[target_db_mdf_path] [varchar](1000) NULL,
	[target_db_ndf_path] [varchar](1000) NULL,
	[target_db_ldf_path] [varchar](1000) NULL
---	[db_to_be_restored_from_csc] [char](1) NULL,
---	[db_restored_from_csc] [char](1) NULL,
---	[db_restore_successful] [char](1) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
	

---
---NOTE THIS IS NOT USED YET SINCE THE FULL MSA CMS SERVER IS NOT FULLY SET UP
---THE DATA FROM THE CMS REGISTERED SERVERS HAS TO BE CREATED IN A GRID AND SAVED AS A CSV ON THE 
---C:\TRASH\ DRIVE OF TESTLAB-SQL-001 WHERE IT WILL BE BCP-ED INTO THE IMPORT WORK TABLE
---THE IMPORT WORK TABLE WILL BE USED IN THAT THE FIRST COLUMN WHICH IS THE SERVER NAME FROM THE REGISTERED 
---SERVERS WILL BE IGNORED AND THEN THE CORRECTLY FORMATTED INFO IN THE IMPORT_WORK TABLE WILL BE USED
---WITH THE LAST INSERT AND SUB-SELECT STATEMENT TO PUT DATA INTO THE BASE TABLE.
---<<<THE RESTORE STATEMENT WAS ALSO BE PLACED IN THE APPROPRIATE COLUMN IN A SUBSEQUENT STEP
---

insert into Automatic_Restore_Test_Integrated_Capability.dbo.ARTIC_Base_Table
(
	[SERVER_NAME],
	cluster_Virtual_Server_Name,
	cluster_Node_name,
	[DATABASE_NAME],
	[BackUpType],
	[BACKUP_START_DATE],
	[BACKUP_FINISH_DATE],
	[Logical filename],
	[database_physical_file_name],
	[backup_path_and_file]
)
SELECT  
	BS.SERVER_NAME					---servername\instance name
-----	, BS.Machine_name				---physical machine name
	, cast(SERVERPROPERTY('MachineName') as nvarchar(128))                                          as Cluster_Virtual_Server_Name
    	 , cast(SERVERPROPERTY('ComputerNamePhysicalNetBIOS') as nvarchar(128))    as Cluster_Node_Name
	, BS.DATABASE_NAME
	, CASE 
	  WHEN BS.TYPE = 'D' THEN 'DATABASE'				
	  WHEN BS.TYPE = 'L' THEN 'TRANSACTION LOG'		
	  WHEN BS.TYPE = 'I' THEN 'DATABASE DIFFERENTIAL'
	  WHEN BS.TYPE = 'F' THEN 'FILE OR FILEGROUP'		
	  ELSE 'UNKNOWN'	   
	  END as BackUpType
	, BS.BACKUP_START_DATE
	, BS.BACKUP_FINISH_DATE	
	, b.name as 'Logical filename'
	, b.filename as database_physical_file_name 
	, bmf.physical_device_name as backup_path_and_file 
FROM 
MSDB..BACKUPSET BS	
inner join
sys.sysdatabases a 
on bs.database_name = a.name
inner join 
sys.sysaltfiles b 
on a.dbid = b.dbid 
inner join
msdb.dbo.backupmediafamily bmf
on bmf.media_set_id = bs.media_set_id
where
a.name not in ('master', 'model', 'msdb', 'tempdb', 'DBATASKS', 'distribution')
and 
a.name not like ('ReportServer%')
and 
BS.type = 'D'
and 
BS.SERVER_NAME = @@SERVERNAME
and 
datediff(dd, BS.Backup_start_date, GETDATE()) <= 1
and 
bmf.physical_device_name  not like '%.TRN'


---
---
---
bulk insert [Automatic_Restore_Test_Integrated_Capability].[dbo].[ARTIC_Base_Table_Import_Work]
from 'C:\trash\ARTIC_Cluster_Info_04112014.csv';


insert into [Automatic_Restore_Test_Integrated_Capability].[dbo].[ARTIC_Base_Table]
(
	[SERVER_NAME],
	Cluster_Virtual_Server_Name, 
	Cluster_Node_Name, 
	[DATABASE_NAME],
	[BackUpType],
	[BACKUP_START_DATE],
	[BACKUP_FINISH_DATE],
	[Logical filename],
	[database_physical_file_name],
	[backup_path_and_file],
	[sql_restore_command_with_move],
	[target_db_mdf_path],
	[target_db_ndf_path],
	[target_db_ldf_path]
) 
select 
	[SERVER_NAME],
	Cluster_Virtual_Server_Name, 
	Cluster_Node_Name, 
	[DATABASE_NAME],
	[BackUpType],
	[BACKUP_START_DATE],
	[BACKUP_FINISH_DATE],
	[Logical filename],
	[database_physical_file_name],
	[backup_path_and_file],
	[sql_restore_command_with_move],
	[target_db_mdf_path],
	[target_db_ndf_path],
	[target_db_ldf_path]



from [Automatic_Restore_Test_Integrated_Capability].[dbo].[ARTIC_Base_Table_Import_Work]
