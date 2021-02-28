---
---See the word document of the same name for more information
---
select 
 BackupDate = convert(varchar(10),a.backup_start_date, 111) 
 ,SizeInGigs=floor(a.backup_size/1024000000) 
from msdb..backupset a
where 
 database_name = 'clarity'
 and type = 'd'
order by 
 backup_start_date desc
 
 
 
select 
BackupDate = convert(varchar(10),a.backup_start_date, 111) 
,SizeInGigs=floor(a.backup_size/1024000000) 
, decimal_percent_change =  
(floor(a.backup_size/1024000000) 
- (select floor(b.backup_size/1024000000)
   from msdb..backupset b
   where database_name = 'Clarity'
   and   type = 'd'
   and b.backup_size > 0
   and   convert(varchar(10),b.backup_start_date, 111) =
		(select max(convert(varchar(10),c.backup_start_date, 111))
		 from msdb..backupset c
		 where database_name = 'Clarity'
		 and   type = 'd'
		 and c.backup_size > 0
		 and   convert(varchar(10),c.backup_start_date, 111) <>
		       convert(varchar(10),a.backup_start_date, 111)))
 )		       
 / floor(a.backup_size/1024000000)           
from msdb..backupset a
where 
database_name = 'clarity'
and type = 'd'
and a.backup_size > 0
and floor(a.backup_size/1024000000) > 0
order by 
 backup_start_date desc



select 
BackupDate = convert(varchar(10),a.backup_start_date, 111) 
,SizeInGigs=floor(a.backup_size/1024000000) 
, percent_change =  
((floor(a.backup_size/1024000000) 
- (select floor(b.backup_size/1024000000)
   from msdb..backupset b
   where database_name = 'Clarity'
   and   type = 'd'
   and b.backup_size > 0
   and   convert(varchar(10),b.backup_start_date, 111) =
		(select max(convert(varchar(10),c.backup_start_date, 111))
		 from msdb..backupset c
		 where database_name = 'Clarity'
		 and   type = 'd'
		 and c.backup_size > 0
		 and   convert(varchar(10),c.backup_start_date, 111) <>
		       convert(varchar(10),a.backup_start_date, 111)))
 )		       
 / floor(a.backup_size/1024000000) ) * 100.00         
from msdb..backupset a
where 
database_name = 'clarity'
and type = 'd'
and a.backup_size > 0
and floor(a.backup_size/1024000000) > 0
order by 
 backup_start_date desc

 

