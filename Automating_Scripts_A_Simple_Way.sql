/****************************************************************************************************************
			Script Name: scr_Run_Multiple_Scripts_AgainstDBs.sql
			Author: Sadequl Hussain (C) Sadequl Hussain 2009
			Purpose: This script is used to run a series of scripts in a defined order against multiple databases
			            in a target server.
			Assumptions / Requirements:
			            a) The SQL Server instance where the script is running should have xp_cmdshell enabled
			            b) The call to "sqlcmd" is valid for SQL 2005. For SQL 2000, "osql" can be used
			            c) The SQLCMD / OSQL command to the server can use trusted connection switch or use username & password
			            d) The script names are prefixed with the order of their execution.
			                  e.g. 1.Script.sql is supposed to be executed first
			            e) The reference to sys.databases can be replaced with master..sysdatabases for SQL 2000 based systems.
			                  However, for that to work, the field name database_id needs to be changed to dbid
			Notes: This can be turned into an effective DBA stored procedure
			*******************************************************************************************************************/
			SET NOCOUNT ON
			DECLARE @ServerName		sysname
			DECLARE @DBName			sysname
			DECLARE @SourceFolder		nvarchar(500)
			DECLARE @OutputFolder		nvarchar(500)
			DECLARE @ScriptName		nvarchar(500)
			DECLARE @ScriptFullPathName	nvarchar(500)
			DECLARE @Cmd			nvarchar(1000)
			DECLARE @ScriptList                table
			            (
			                  ScriptRunOrder   tinyint NOT NULL,
			                  ScriptName        nvarchar (500)NOT NULL
			            )
			DECLARE @ScriptListTemp      table
			            (
			                  ScriptName        nvarchar (500)NULL
			            )
			DECLARE @DatabaseList        table
			            (
			                  DatabaseID        int,
			                  DBName                 sysname
			            )
			DECLARE     @Pos                   tinyint
			DECLARE     @Order                       tinyint
			DECLARE     @ScriptRunOrder         tinyint
			DECLARE     @Message               nvarchar(1000)
			/***************************************/
			-- Initialisation...
			/**************************************/
			SELECT @ServerName = '<target_server_name>' -- change it to reflect target server name...
			SELECT @SourceFolder = 'C:\Scripts' -- change it to reflect script source location...
			SELECT @OutputFolder = 'C:\Script_Output' -- change it to reflect script output location...
			SELECT @Cmd = 'master..xp_cmdshell ''DIR ' + @SourceFolder + ' /B'''
			IF ((SELECT @@SERVERNAME) <> @ServerName)
			      BEGIN
			            RAISERROR ('Sorry, wrong server !!!', 17, 1)
			            RETURN
			      END
			INSERT INTO @DatabaseList (DatabaseID, DBName)
			      SELECT            database_id, name
			      FROM        sys.databases
			      WHERE       name NOTIN ('master','model', 'msdb','tempdb') -- this can be changed to include one or more databases
			      ORDERBY    database_id ASC
			INSERT INTO @ScriptListTemp EXEC(@Cmd)
			DELETE FROM @ScriptListTemp WHERE ScriptName IS NULL
			IF NOT EXISTS (SELECT* FROM @ScriptListTemp)
			      BEGIN
			            RAISERROR ('Sorry, no files present in the source folder !!!', 17, 1) WITH NOWAIT
			            RETURN
			      END
			SELECT TOP 1 @ScriptName = ScriptName FROM @ScriptListTemp ORDER BY ScriptName ASC
			WHILE EXISTS(SELECT * FROM @ScriptListTemp)
			      BEGIN
			            SELECT @Pos =CHARINDEX('.', @ScriptName)
			            SELECT @Order =CONVERT(tinyint,LEFT(@ScriptName, @Pos -1))
			            SELECT @ScriptFullPathName = @SourceFolder + '\'+ @ScriptName
			            INSERT INTO @ScriptList (ScriptRunOrder, ScriptName)VALUES (@Order, @ScriptFullPathName)
			            DELETE FROM @ScriptListTemp WHERE ScriptName = @ScriptName
			            SELECT TOP 1 @ScriptName = ScriptName FROM @ScriptListTemp ORDER BY ScriptName ASC
			      END
			/***************************************/
			-- Execution of scripts...
			/**************************************/
			SELECT TOP 1 @DBName = DBName FROM @DatabaseList ORDER BY DatabaseID ASC
			WHILE EXISTS (SELECT *FROM @DatabaseList)
			      BEGIN
			            SELECT @Message = 'Database - '+ @DBName
			            RAISERROR (@Message, 10,1) WITHNOWAIT
			            SELECT @Message = '====================================================================='
			            RAISERROR (@Message, 10,1) WITHNOWAIT
			            SELECT TOP 1 @ScriptName = ScriptName, @Order = ScriptRunOrder FROM @ScriptList ORDER BY ScriptRunOrder ASC
			            WHILEEXISTS (SELECT ScriptRunOrder FROM @ScriptList WHERE ScriptRunOrder = @Order)
			                  BEGIN
			                        SELECT @ScriptRunOrder = @Order
			                        SELECT @Message = 'Now processing script file ' + @ScriptName
			                        RAISERROR (@Message, 10,1) WITHNOWAIT
			                        SET @Cmd ='sqlcmd -E -S ' + @ServerName +' -d ' + @DBName +' -i "' + @ScriptName +'" -o "' + @OutputFolder + '\'+ @DBName + '_ScriptRun'+ CONVERT(nvarchar(5),@Order)+ '_Results.txt"'
			                        EXEC master..xp_cmdshell @Cmd, no_output
			                        SELECT TOP 1 @ScriptName = ScriptName, @Order = ScriptRunOrder    FROM @ScriptList WHERE ScriptRunOrder > @Order ORDER BY ScriptRunOrder ASC
			                        IF (@Order = @ScriptRunOrder) BREAK
			                  END
			            PRINT''
			            DELETE FROM @DatabaseList WHERE DBName = @DBName
			            SELECT TOP 1 @DBName = DBName FROM @DatabaseList ORDER BY DatabaseID ASC
			      END
			RETURN
