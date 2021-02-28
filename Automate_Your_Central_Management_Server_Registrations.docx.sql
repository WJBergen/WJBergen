/*
The word document that explains this is called 
Automate_Your_Central_Management_Server_Registrations.docx

This is Automate_Your_Central_Management_Server_Registrations.sql
and contains all the scripts mentioned in the word document.


*/
---
---this is 01_create_inventory_tables.sql
---
/*

S. Kusen 2014-07-14:
Used in the sqlservercentral.com article "Automating Central Management Server Registrations".
This script will create the inventory tables and populate them with dummy data to be used for the CMS.  
It is a simplified table structure for demo purposes.

If you have actual instance that you would like to register, change the dummy data to real instances.
*Note that there is no activity that occurs on the destination system by registering them with a CMS.





*/


USE [master]
GO

--create the test database
IF NOT EXISTS (select 1 from sys.databases where name = 'CMSInventoryTest')
BEGIN
	EXEC sp_executesql N'CREATE DATABASE [CMSInventoryTest]'
END
GO


USE [CMSInventoryTest]
GO

IF EXISTS (SELECT 1 from sys.objects where object_id = object_id('dbo.Instances'))
BEGIN
	DROP TABLE [dbo].[Instances]
END
GO


IF EXISTS (SELECT 1 from sys.objects where object_id = object_id('[dbo].[Servers]'))
BEGIN
	DROP TABLE [dbo].[Servers]
END
GO

CREATE TABLE [dbo].[Servers](
	[computername] [varchar](255) NOT NULL,
	[IPAddresses] [varchar](500) NULL,
	[OSVersion] [varchar](1000) NULL,
	[OSPatchLevel] [varchar](10) NULL,
	[description] [varchar](max) NULL,
	[owner] [varchar](1000) NULL,
	[isActive] [int] NOT NULL,
	[isProd] [int] NOT NULL,
	[hasSAN] [int] NULL,
	[systemModel] [varchar](1000) NULL,
	[processorModel] [varchar](1000) NULL,
	[numofprocessors] [int] NULL,
	[RAM] [varchar](255) NULL,
	[functionalGroupName] [varchar](255) NULL,
	[insertDate] [datetime] NOT NULL,
	[OSEdition] [varchar](1000) NULL,
	[last_update] [datetime] NULL,
	[domain_name] [varchar](50) NULL,
	[last_reboot_datetime] [datetime] NULL,
	[fqdn] [varchar](255) NULL,
	[serialNumber] [varchar](255) NULL,
 CONSTRAINT [PK_ServerNames] PRIMARY KEY CLUSTERED 
(
	[computername] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO




CREATE TABLE [dbo].[Instances](
	[instancename] [varchar](255) NOT NULL,
	[SQLVersion] [varchar](800) NULL,
	[SQLPatchlevel] [varchar](100) NULL,
	[SQLEdition] [varchar](100) NULL,
	[computerName] [varchar](255) NOT NULL,
	[insertDate] [datetime] NULL,
	[last_update] [datetime] NULL
) ON [PRIMARY]
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[Instances] ADD [TcpPort] [varchar](20) NULL
ALTER TABLE [dbo].[Instances] ADD [ModifyUser] [varchar](100) NULL
SET ANSI_PADDING ON
ALTER TABLE [dbo].[Instances] ADD [primaryDBA] [varchar](100) NULL
ALTER TABLE [dbo].[Instances] ADD [SQLBuildNumber] [varchar](50) NULL
 CONSTRAINT [PK_instanceNames] PRIMARY KEY CLUSTERED 
(
	[instancename] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 85) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Instances] ADD  CONSTRAINT [DF_DBA_P_instancenames_insertDate]  DEFAULT (getdate()) FOR [insertDate]
GO

ALTER TABLE [dbo].[Instances]  WITH CHECK ADD  CONSTRAINT [fk_computername] FOREIGN KEY([computerName])
REFERENCES [dbo].[Servers] ([computername])
ON UPDATE CASCADE
GO



/* Insert dummy data for demo purposes */


USE [CMSInventoryTest]
GO

--insert into the Servers table
INSERT INTO [dbo].[Servers] ([computername],[isActive],[isProd], insertDate) VALUES ('mc2005tst',1,4, GETDATE()) --active, critical server
INSERT INTO [dbo].[Servers] ([computername],[isActive],[isProd], insertDate) VALUES ('mc2008tst',1,4, GETDATE()) --active, critical server
INSERT INTO [dbo].[Servers] ([computername],[isActive],[isProd], insertDate) VALUES ('mc2008r2tst',1,4, GETDATE()) --active, critical server
INSERT INTO [dbo].[Servers] ([computername],[isActive],[isProd], insertDate) VALUES ('mc2012tst',1,4, GETDATE()) --active, critical server
															   
INSERT INTO [dbo].[Servers] ([computername],[isActive],[isProd], insertDate) VALUES ('pnc2005tst',1,1, GETDATE()) --active, production non-critical server
INSERT INTO [dbo].[Servers] ([computername],[isActive],[isProd], insertDate) VALUES ('pnc2008tst',1,1, GETDATE()) --active, production non-critical server
INSERT INTO [dbo].[Servers] ([computername],[isActive],[isProd], insertDate) VALUES ('pnc2008r2tst',1,1, GETDATE()) --active, production non-critical server
INSERT INTO [dbo].[Servers] ([computername],[isActive],[isProd], insertDate) VALUES ('pnc2012tst',1,1, GETDATE()) --active, production non-critical server
															   
INSERT INTO [dbo].[Servers] ([computername],[isActive],[isProd], insertDate) VALUES ('np2005tst',1,0, GETDATE()) --active, non-production
INSERT INTO [dbo].[Servers] ([computername],[isActive],[isProd], insertDate) VALUES ('np2008tst',1,0, GETDATE()) --active, non-production
INSERT INTO [dbo].[Servers] ([computername],[isActive],[isProd], insertDate) VALUES ('np2008r2tst',1,0, GETDATE()) --active, non-production
INSERT INTO [dbo].[Servers] ([computername],[isActive],[isProd], insertDate) VALUES ('np2012tst',1,0, GETDATE()) --active, non-production



--insert into the Instances table
INSERT INTO [dbo].[Instances]([instancename],[computerName],[SQLEdition]) VALUES ('mc2005tst', 'mc2005tst', 'SQL 2005 - Enterprise Edition')
INSERT INTO [dbo].[Instances]([instancename],[computerName],[SQLEdition]) VALUES ('mc2008tst', 'mc2008tst', 'SQL 2008 - Enterprise Edition')
INSERT INTO [dbo].[Instances]([instancename],[computerName],[SQLEdition]) VALUES ('mc2008r2tst', 'mc2008r2tst', 'SQL 2008 R2 - Enterprise Edition')
INSERT INTO [dbo].[Instances]([instancename],[computerName],[SQLEdition]) VALUES ('mc2012tst', 'mc2012tst', 'SQL 2012 - Enterprise Edition')

INSERT INTO [dbo].[Instances]([instancename],[computerName],[SQLEdition]) VALUES ('pnc2005tst', 'pnc2005tst', 'SQL 2005 - Enterprise Edition')
INSERT INTO [dbo].[Instances]([instancename],[computerName],[SQLEdition]) VALUES ('pnc2008tst', 'pnc2008tst', 'SQL 2008 - Enterprise Edition')
INSERT INTO [dbo].[Instances]([instancename],[computerName],[SQLEdition]) VALUES ('pnc2008r2tst', 'pnc2008r2tst', 'SQL 2008 R2 - Enterprise Edition')
INSERT INTO [dbo].[Instances]([instancename],[computerName],[SQLEdition]) VALUES ('pnc2012tst', 'pnc2012tst', 'SQL 2012 - Enterprise Edition')

INSERT INTO [dbo].[Instances]([instancename],[computerName],[SQLEdition]) VALUES ('np2005tst', 'np2005tst', 'SQL 2005 - Enterprise Edition')
INSERT INTO [dbo].[Instances]([instancename],[computerName],[SQLEdition]) VALUES ('np2008tst', 'np2008tst', 'SQL 2008 - Enterprise Edition')
INSERT INTO [dbo].[Instances]([instancename],[computerName],[SQLEdition]) VALUES ('np2008r2tst', 'np2008r2tst', 'SQL 2008 R2 - Enterprise Edition')
INSERT INTO [dbo].[Instances]([instancename],[computerName],[SQLEdition]) VALUES ('np2012tst', 'np2012tst', 'SQL 2012 - Enterprise Edition')
GO

---
---this is 02_create_procedures.sql
---
---===================================================================================
---===================================================================================
---===================================================================================

/*

S. Kusen 2014-07-14:
Used in the sqlservercentral.com article "Automating Central Management Server Registrations".
This script will create the stored procedures used to create and populate the CMS folders.


*/

USE [CMSInventoryTest]
GO
/****** Object:  StoredProcedure [dbo].[ap_CMS_Get_Instance_List]    Script Date: 5/27/2014 1:58:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF EXISTS (select 1 from sys.objects where object_id = object_id('[dbo].[ap_CMS_Get_Instance_List]'))
BEGIN
	DROP PROCEDURE [dbo].[ap_CMS_Get_Instance_List]
END
GO

--additional sp to get instance list for sql 2005 servers
CREATE PROCEDURE [dbo].[ap_CMS_Get_Instance_List]

@p_isProd int, --0 nonprod, 1 prod, 4 critical
@p_version varchar(7), 
@p_isActive int = 1

AS

/*
Sample executions:
EXEC [dbo].[ap_CMS_Get_Instance_List] @p_isProd = 1, @p_version = '2005', @p_isActive = 1
EXEC [dbo].[ap_CMS_Get_Instance_List] @p_isProd = 4, @p_version = '2012', @p_isActive = 1
EXEC [dbo].[ap_CMS_Get_Instance_List] @p_isProd = 0, @p_version = '2008 R2', @p_isActive = 1

*/

/*
S.Kusen: This procedure will return the "actual" instance name as well as the name to be displayed
by the CMS folder drill-down.  In this query, the actual and display names are the same column, but the
flexibility is there if you want to display a different name (ie append an application name or dba name)
*/

SELECT	[dpi].[instancename], 
		[dpi].[instancename]
FROM	[dbo].[Instances] [dpi]
			INNER JOIN
		[dbo].[Servers] [dpp]
			ON
		[dpi].[computername] = [dpp].[computername]
WHERE
	   [dpp].[isprod] = @p_isProd
			and
	   [dpp].[isactive] = @p_isActive
			and
		(
			[dpi].[SQLEdition] LIKE '%'+@p_version+' -%'
		)
		
			and [dpi].[instancename] <> @@SERVERNAME /* Cannot register the CMS instance as a member of one of the folders */
ORDER BY [dpi].[instancename]
GO








IF EXISTS (select 1 from sys.objects where object_id = object_id('[dbo].[ap_CMS_Populate_CMS_folder]'))
BEGIN
	DROP PROCEDURE [dbo].[ap_CMS_Populate_CMS_folder]
END
GO


CREATE PROCEDURE [dbo].[ap_CMS_Populate_CMS_folder]

@p_parent_folder_name nvarchar(100)

AS

/*
Sample executions:
EXEC [dbo].[ap_CMS_Populate_CMS_folder] 'Mission Critical'
EXEC [dbo].[ap_CMS_Populate_CMS_folder] 'Non-Production'
EXEC [dbo].[ap_CMS_Populate_CMS_folder] 'Production Non-Critical'
*/

/*
S.Kusen: This procedure will look at a "parent" folder at the top level and drop and re-create it
and then populate the folders with the appropriate subfolders for 2005, 2008, 2008 R2, and 2012, and
populate each folder with the appropriate list of instances from inventory.

In this samples above, every parent folder passed in will get the same 4 subfolders:
Mission Critical
	2005
	2008
	2008 R2
	2012

Non-Production
	2005
	2008
	2008 R2
	2012

Production Non-Critical
	2005
	2008
	2008 R2
	2012

*/

DECLARE @v_instance_name varchar(255), @v_display_name varchar(255), @v_registered_server_id int

DECLARE @v_parent_folder_name nvarchar(100),
		@v_parent_folder_group_id int,
		@v_sql_main_version varchar(10), /*2005, 2008, 2008 R2, 2012*/
		@v_environment_flag int, /*1=prod non-critical, 0=non-prod, 4=mission critical*/
		@v_subgroup_name nvarchar(100),
		@v_subgroup_group_id int

DECLARE @tbl_instances_to_add_to_group TABLE (instancename varchar(255), displayname varchar(255))

SELECT	@v_parent_folder_name = @p_parent_folder_name /*Production, Non-Production, Mission Critical*/

SELECT @v_environment_flag = 
		CASE @v_parent_folder_name 
			WHEN 'Non-Production' THEN 0
			WHEN 'Production Non-Critical' THEN 1
			WHEN 'Mission Critical' THEN 4
			ELSE -1
			END;

If EXISTS (select top 1 * from msdb.dbo.sysmanagement_shared_server_groups
where parent_id is not null
and name = @v_parent_folder_name)
BEGIN

	--get production base folder ID
	DECLARE @prod_group_id int
	SELECT @prod_group_id = server_group_id
	FROM msdb.dbo.sysmanagement_shared_server_groups
	where parent_id is not null
	and name = @v_parent_folder_name

	EXEC msdb.dbo.sp_sysmanagement_delete_shared_server_group @server_group_id=@prod_group_id

END


--Create the Production Folder at the main parent level
EXEC msdb.dbo.sp_sysmanagement_add_shared_server_group 
			@parent_id=1, 
			@name=@v_parent_folder_name , 
			@description=N'', 
			@server_type=0, 
			@server_group_id=@v_parent_folder_group_id OUTPUT





/*************************************************************************/
/************* create and populate 2005 instances *************/
/*************************************************************************/

SELECT  @v_sql_main_version = '2005',
		@v_subgroup_name = 'SQL 2005'


--create the SQL 2005 folder under production
EXEC msdb.dbo.sp_sysmanagement_add_shared_server_group 
			@parent_id=@v_parent_folder_group_id, 
			@name=@v_subgroup_name,
			@description=N'', 
			@server_type=0, 
			@server_group_id=@v_subgroup_group_id OUTPUT

DELETE FROM @tbl_instances_to_add_to_group
INSERT INTO @tbl_instances_to_add_to_group (instancename, displayname)
EXEC [dbo].[ap_CMS_Get_Instance_List] @p_isProd = @v_environment_flag, @p_version=@v_sql_main_version /*this will pull back production SQL 2005 machines*/

--SELECT UPPER(instancename), UPPER(displayname) FROM @tbl_instances_to_add_to_group

/* loop through each instance that was pulled from inventory */
DECLARE cur_insances_to_add_to_group CURSOR FOR
SELECT UPPER(instancename), UPPER(displayname) FROM @tbl_instances_to_add_to_group

--open cursor
OPEN cur_insances_to_add_to_group

--pull first instance
FETCH NEXT FROM cur_insances_to_add_to_group INTO @v_instance_name, @v_display_name

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC msdb.dbo.sp_sysmanagement_add_shared_registered_server 
	   @server_group_id=@v_subgroup_group_id, 
	   @name=@v_display_name, 
	   @server_name=@v_instance_name, 
	   @description=N'', 
	   @server_type=0,
	   @server_id = @v_registered_server_id OUTPUT;

	FETCH NEXT FROM cur_insances_to_add_to_group INTO @v_instance_name, @v_display_name
END

CLOSE cur_insances_to_add_to_group
DEALLOCATE cur_insances_to_add_to_group







/*************************************************************************/
/************* create and populate 2008 instances *************/
/*************************************************************************/

SELECT  @v_sql_main_version = '2008',
		@v_subgroup_name = 'SQL 2008'


--create the SQL 2005 folder under production
EXEC msdb.dbo.sp_sysmanagement_add_shared_server_group 
			@parent_id=@v_parent_folder_group_id, 
			@name=@v_subgroup_name,
			@description=N'', 
			@server_type=0, 
			@server_group_id=@v_subgroup_group_id OUTPUT

DELETE FROM @tbl_instances_to_add_to_group
INSERT INTO @tbl_instances_to_add_to_group (instancename, displayname)
EXEC [dbo].[ap_CMS_Get_Instance_List] @p_isProd = @v_environment_flag, @p_version=@v_sql_main_version /*this will pull back production SQL 2005 machines*/


/* loop through each instance that was pulled from inventory */
DECLARE cur_insances_to_add_to_group CURSOR FOR
SELECT UPPER(instancename), UPPER(displayname) FROM @tbl_instances_to_add_to_group

--open cursor
OPEN cur_insances_to_add_to_group

--pull first instance
FETCH NEXT FROM cur_insances_to_add_to_group INTO @v_instance_name, @v_display_name

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC msdb.dbo.sp_sysmanagement_add_shared_registered_server 
	   @server_group_id=@v_subgroup_group_id, 
	   @name=@v_display_name, 
	   @server_name=@v_instance_name, 
	   @description=N'', 
	   @server_type=0,
	   @server_id = @v_registered_server_id OUTPUT;

	FETCH NEXT FROM cur_insances_to_add_to_group INTO @v_instance_name, @v_display_name
END

CLOSE cur_insances_to_add_to_group
DEALLOCATE cur_insances_to_add_to_group






/*************************************************************************/
/************* create and populate 2008 R2 instances *************/
/*************************************************************************/

SELECT  @v_sql_main_version = '2008 R2',
		@v_subgroup_name = 'SQL 2008 R2'


--create the SQL 2005 folder under production
EXEC msdb.dbo.sp_sysmanagement_add_shared_server_group 
			@parent_id=@v_parent_folder_group_id, 
			@name=@v_subgroup_name,
			@description=N'', 
			@server_type=0, 
			@server_group_id=@v_subgroup_group_id OUTPUT

DELETE FROM @tbl_instances_to_add_to_group
INSERT INTO @tbl_instances_to_add_to_group (instancename, displayname)
EXEC [dbo].[ap_CMS_Get_Instance_List] @p_isProd = @v_environment_flag, @p_version=@v_sql_main_version /*this will pull back production SQL 2005 machines*/


/* loop through each instance that was pulled from inventory */
DECLARE cur_insances_to_add_to_group CURSOR FOR
SELECT UPPER(instancename), UPPER(displayname) FROM @tbl_instances_to_add_to_group

--open cursor
OPEN cur_insances_to_add_to_group

--pull first instance
FETCH NEXT FROM cur_insances_to_add_to_group INTO @v_instance_name, @v_display_name

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC msdb.dbo.sp_sysmanagement_add_shared_registered_server 
	   @server_group_id=@v_subgroup_group_id, 
	   @name=@v_display_name, 
	   @server_name=@v_instance_name, 
	   @description=N'', 
	   @server_type=0,
	   @server_id = @v_registered_server_id OUTPUT;

	FETCH NEXT FROM cur_insances_to_add_to_group INTO @v_instance_name, @v_display_name
END

CLOSE cur_insances_to_add_to_group
DEALLOCATE cur_insances_to_add_to_group





/*************************************************************************/
/************* create and populate 2012 instances *************/
/*************************************************************************/

SELECT  @v_sql_main_version = '2012',
		@v_subgroup_name = 'SQL 2012'


--create the SQL 2005 folder under production
EXEC msdb.dbo.sp_sysmanagement_add_shared_server_group 
			@parent_id=@v_parent_folder_group_id, 
			@name=@v_subgroup_name,
			@description=N'', 
			@server_type=0, 
			@server_group_id=@v_subgroup_group_id OUTPUT

DELETE FROM @tbl_instances_to_add_to_group
INSERT INTO @tbl_instances_to_add_to_group (instancename, displayname)
EXEC [dbo].[ap_CMS_Get_Instance_List] @p_isProd = @v_environment_flag, @p_version=@v_sql_main_version /*this will pull back production SQL 2005 machines*/


/* loop through each instance that was pulled from inventory */
DECLARE cur_insances_to_add_to_group CURSOR FOR
SELECT UPPER(instancename), UPPER(displayname) FROM @tbl_instances_to_add_to_group

--open cursor
OPEN cur_insances_to_add_to_group

--pull first instance
FETCH NEXT FROM cur_insances_to_add_to_group INTO @v_instance_name, @v_display_name

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC msdb.dbo.sp_sysmanagement_add_shared_registered_server 
	   @server_group_id=@v_subgroup_group_id, 
	   @name=@v_display_name, 
	   @server_name=@v_instance_name, 
	   @description=N'', 
	   @server_type=0,
	   @server_id = @v_registered_server_id OUTPUT;

	FETCH NEXT FROM cur_insances_to_add_to_group INTO @v_instance_name, @v_display_name
END

CLOSE cur_insances_to_add_to_group
DEALLOCATE cur_insances_to_add_to_group
GO




---
---this is 03_populate_cms_folders_from_inventory.sql
---
---===================================================================================
---===================================================================================
---===================================================================================



USE CMSInventoryTest
GO

EXEC [dbo].[ap_CMS_Populate_CMS_folder] 'Mission Critical'
EXEC [dbo].[ap_CMS_Populate_CMS_folder] 'Non-Production'
EXEC [dbo].[ap_CMS_Populate_CMS_folder] 'Production Non-Critical'