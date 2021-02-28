 /***************************************************************
			 Script Name: 1.scr_Script1.sql
			 ***************************************************************/
			 SET NOCOUNT ON
			 SELECT SERVERPROPERTY('ProductVersion')
			 SELECT DB_NAME()
			 SET NOCOUNT OFF

             /**********************************************
			 Script Name: 2.scr_Script2.sql
			 **********************************************/
			 SET NOCOUNT ON
			 SELECT GETDATE()
			 SELECT @@VERSION
			 SET NOCOUNT OFF

             /**************************************************
			 Script Name: 4.scr_Script3.sql
			 ***************************************************/
			 SET NOCOUNT ON
			 SELECT SUSER_SNAME()
			 SET NOCOUNT OFF
