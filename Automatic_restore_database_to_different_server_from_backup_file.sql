---
---This is Automatic_restore_database_to_different_server_from_backup_file.sql
---
/*
Automatic restore database to different server from backup file
By David Zhou, 2016/11/10 


EXEC  [dbo].[sp_1RestoreFullandtran]   @restoreFromDir = N'c:\work\data',--folder for store backup file
  @onlyFUllbakup = N'N',
  @ServerName = N'ServerA',--for server which backup file come from, it is for step 3 and 4 to know
  @moveto = N'Y',--move to differential path on new server or N same path on new server
  @restoreToDataDir = N'c:\work\database\data',--if move to if Y, must be new database data file location
  @restoreToLogDir = N'c:\work\database\log' 


FROM:  http://www.sqlservercentral.com/scripts/Restore/120156/

*/
---
---
---
Use Master

/****** Object:  StoredProcedure [dbo].[sp_RestoreDir]    Script Date: 12/5/2014 3:06:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_1RestoreFullandtran]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_1RestoreFullandtran]
GO


/***************************************************************************************/

CREATE proc [dbo].[sp_1RestoreFullandtran] 
    @restoreFromDir varchar(255),
	@onlyFUllbakup Char(1)='Y',
	@ServerName  varchar(20)='ServerA',
	@moveto        char(1)='N',
    @restoreToDataDir varchar(255)= null,
	@restoreToLogDir varchar(255) = null
as

set nocount on
/*
Author David Zhou
Date Dec 10 2014


    @restoreFromDir  backup file location
	@onlyFUllbakup  folder only full backup or full backup plus transaction back in the same folder
	@moveto         Move to different folder, if Y, Must input @restoreTodataDir Paramenter value
	@ServerName  if those script will run on ServerA, just put serverA-- it is just for future build mirror 

    @restoreToDataDir varchar(255)= null,
	@restoreToLogDir varchar(255) = null

exec sp_1RestoreFullandtran  @restoreFromDir ='c:\worrk',@onlyFUllbakup='N',@ServerName ='ServerA'-- restore full backup and transaction database with same location

exec sp_1RestoreFullandtran @restoreFromDir ='c:\worrk',@onlyFUllbakup='N',@ServerName ='ServerA',@moveto='Y',@restoreToDataDir='d:\data',@restoreToLogDir='D:\log-- restore full backup and transaction database with same location

*/


if @moveto='Y' and @restoreToDataDir is null

begin
  print ' you move to paramenter is yes, you need input move to folder informaiton'
  return

end

declare @filename         varchar(200),
	 @cmd              varchar(1000), 
	 @cmd2             varchar(500), 
     @DataName         varchar (255),
	 @LogName          varchar (255),
     @LogicalName      varchar(255), 
	 @PhysicalName     varchar(255), 
	 @Type             varchar(20), 
	 @FileGroupName    varchar(255), 
	 @Size             varchar(20), 
	 @MaxSize          varchar(20),
	 @restoreToDir     varchar(255),
        @searchName       varchar(255),
	 @DBName           varchar(255),
        @PhysicalFileName varchar(255),
		@DBExist   int=0,
		@newDbanema varchar(255)



if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[restorMirrorDB]'))
 truncate table [dbo].[restorMirrorDB]


 else
 Create table [dbo].[restorMirrorDB] (DBname varchar(100),Sqlstatement varchar(1000),flagmirror int,ServerName varchar(20))




create table #dirList (filename varchar(200))

create table #filelist (LogicalName varchar(255), PhysicalName varchar(255), Type varchar(20), FileGroupName varchar(255), Size varchar(20), MaxSize varchar(20),
                                    FileId int,CreateLSN bit, DropLSN bit, UniqueID varchar(255),ReadOnlyLSn bit, ReadWriteLSN bit, backupSizeInBytes varchar(50), SourceBlockSize int,
                                    FileGroupid Int, LogGroupGUID varchar(255),DifferentialBaseLSN varchar(255),DifferentialBaseGUID  varchar(255),isReadOnly bit, IsPresent bit,TDEThumbprint varchar(255) )

 print ' --This restore script will run on ' + @ServerName  
 print ' '

If @restoreToLogDir is null
	set @restoreToLogDir = @restoreToDataDir



--Get the list of database backups that are in the restoreFromDir directory

   select @cmd = 'dir /b /on "' +@restoreFromDir+ '"'


insert #dirList exec master..xp_cmdshell @cmd  

--select * from #dirList where filename like '%_backup_%' --order by filename

if @onlyFUllbakup='Y'
   declare BakFile_csr cursor for 
  	select * from #dirList where filename like '%_backup_%bak' order by filename
else
   begin  -- single db, don't order by filename, take default latest date /o-d parm in dir command above
    
     declare BakFile_csr cursor for 
  	 select * from #dirList where (filename like '%_backup_%bak') or (filename like '%_backup_%trn') order by filename
 end




open BakFile_csr
fetch next from BakFile_csr into @filename

while @@fetch_status = 0
   begin
        
		
		

		   select @dbName =substring(@filename,0,charindex('_backup_',@filename,0) )

		     select @DBExist =count(*) from [dbo].[restorMirrorDB] where DBname=@dbName
		   
		 

		 
	       select @cmd = "RESTORE FILELISTONLY FROM disk = '" + @restoreFromDir + "\" + @filename + "'" 

		   insert #filelist exec ( @cmd )
		   -- PRINT '' 
		  -- PRINT 'RESTORING DATABASE ' + @dbName
	   
         
		   if @DBExist =0

		   Begin 
		       
			   select @cmd = "RESTORE DATABASE " + @dbName + 
			" FROM DISK = '" + @restoreFromDir + "\" + @filename  +"'   WITH "

			   declare DataFileCursor cursor for  
				select LogicalName, PhysicalName, Type, FileGroupName, Size, MaxSize
				from #filelist

				open DataFileCursor
			   fetch next from DataFileCursor into @LogicalName, @PhysicalName, @Type, @FileGroupName, @Size, @MaxSize

				while @@fetch_status = 0
				  begin
		   		 
					  if @Moveto = 'Y'  
					   begin 
						select @PhysicalFileName = reverse(substring(reverse(rtrim(@PhysicalName)),1,patindex('%\%',reverse(rtrim(@PhysicalName)))-1 )) 

       					if @Type = 'L'
       						select @restoreToDir = @restoreToLogDir
       					else
       						select @restoreToDir = @restoreToDataDir
       
       					select @cmd = @cmd + 
            					" MOVE '" + @LogicalName + "' TO '" + @restoreToDir + "\" + @PhysicalFileName + "', " 
					  end 
		 
				  fetch next from DataFileCursor into @LogicalName, @PhysicalName, @Type, @FileGroupName, @Size, @MaxSize

			   end  -- DataFileCursor loop

			close DataFileCursor
     		deallocate DataFileCursor

			 select @cmd = @cmd  + '  NORECOVERY, REPLACE'
	   end 
	
	
	else  if @DBExist > 0
	   begin
	       select @cmd = "RESTORE Log  " + @dbName + 
			" FROM DISK = '" + @restoreFromDir + "\" + @filename  +"'   WITH "
	  		select @cmd = @cmd  + '  NORECOVERY'
       end   
    
	    
 
	  insert into [dbo].[restorMirrorDB](dbname,sqlstatement,flagmirror,ServerName) select @dbName,@cmd,1,@ServerName
	   print @cmd
	   print ''

      
        truncate table #filelist

      fetch next from BakFile_csr into @filename
 end -- BakFile_csr loop

close BakFile_csr
deallocate BakFile_csr

drop table #dirList

return

GO


