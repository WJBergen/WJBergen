---
---This is Apos_date_time_formatting_001.sql
---
---
---
SELECT Distinct ([SI_NAME]) 

          , [SI_SCHEDULE_STATUS]

       ,[SI_UPDATE_TS]

          ,concat(substring(si_update_ts, 1, 4), '-', substring(si_update_ts, 5, 2), '-', substring(si_update_ts, 7, 2), ' ', substring(si_update_ts, 9, 2), ':', substring(si_update_ts, 11, 2), ':', substring(si_update_ts, 13, 2))

       ,[SI_NEXTRUNTIME]
          ,concat(substring(si_nextruntime, 1, 4), '-', substring(si_nextruntime, 5, 2), '-', substring(si_nextruntime, 7, 2), ' ', substring(si_nextruntime, 9, 2), ':', substring(si_nextruntime, 11, 2), ':', substring(si_nextruntime, 13, 2))

       ,[SI_STARTTIME]
          ,concat(substring(si_starttime, 1, 4), '-', substring(si_starttime, 5, 2), '-', substring(si_starttime, 7, 2), ' ', substring(si_starttime, 9, 2), ':', substring(si_starttime, 11, 2), ':', substring(si_starttime, 13, 2))

       ,[SI_ENDTIME]
          ,concat(substring(si_endtime, 1, 4), '-', substring(si_endtime, 5, 2), '-', substring(si_endtime, 7, 2), ' ', substring(si_endtime, 9, 2), ':', substring(si_endtime, 11, 2), ':', substring(si_endtime, 13, 2))

       ,[SI_RECURRING]

       ,[SI_SUBMITTER]

       ,[AP_Location]

       ,[AP_Destination]

  FROM [APOS].[dbo].[AP_Schedules]

   Where 

   AP_Location like '%/PennChart/%'

   and

   SI_SCHEDULE_STATUS = '9'

   and 

   SI_RECURRING = '1'

   and

   AP_Info_Date = (Select max(AP_Info_Date) from AP_Schedules)

/*********************************
It is on the APOS db on UPHAPOSPDBS001 by Hassan, Moneeb
Hassan, Moneeb2:27 PM
It is on the APOS db on UPHAPOSPDBS001
the nvarchar fields are 
 ,[SI_UPDATE_TS] ... by Hassan, Moneeb
Hassan, Moneeb2:27 PM
the nvarchar fields are 
,[SI_UPDATE_TS]

,[SI_NEXTRUNTIME]

,[SI_STARTTIME]

,[SI_ENDTIME]
Id like to change them to datetime to displ... by Hassan, Moneeb
Hassan, Moneeb2:28 PM
Id like to change them to datetime to display as yyyy-mm-dd hh:mm:ss

********************************/
