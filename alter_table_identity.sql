USE DBATASKS
GO
create table wjb_tablea
(
 cola	int not null,
 colb	int
)
insert into wjb_tablea values (1, 1)
insert into wjb_tablea values (2, 2)
---
---
---
select * from wjb_tablea
---
---
---
alter table wjb_tablea
  alter column cola add identity(100, 1)
---
---can not alter an existing column to make that column an identity.  
---THE ONLY WAY TO DO IT IS TO BRING UP SQLSERVER MANAGEMENT STUDIO AND GO TO THE TABLES 
---ICON UNDER THE DATABASE THEN EXPAND THE TABLE TO SHOW ALL THE COLUMNS.  THEN RIGHT CLICK
---THE COLUMN YOU WANT TO MAKE AN IDENTITY AND SELECT MODIFY.  AT THIS POINT LOOK FOR THE IDENTITY OPTION
---AND SAY YES.  ALSO, REMEMBER TO SET THE INCREMENT TO 1 (THE DEFAULT) AND THE SEED TO 
---AT LEAST ONE HIGHER THAN THE MAXIMUM NUMBER ALREADY IN THE COLUMN THAT YOU WANT TO 
---MAKE THE IDENTITY AND ONE LESS THAN THE NEW BEGINNING NUMBER YOU WANT TO USE.
---
---
---
---
---In Sql Server management studio (2005) go to Tools|Options, then from the tree ---control select Query Execution->SQL Server General, Excution Timeout of 0 seconds ---indicates unlimited wait time.


---
---
---
insert into wjb_tablea (colb) values (3)
insert into wjb_tablea (colb) values (4)
insert into wjb_tablea (colb) values (5)
---
---
---
select * from wjb_tablea

drop table wjb_tablea