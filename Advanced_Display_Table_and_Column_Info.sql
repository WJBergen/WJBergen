/*
Advanced Display Table and Column Info
By Luis Chiriff, 2014/01/03 
FROM:  http://www.sqlservercentral.com/scripts/columns/105526/

During development or an investigation, I've needed to find a field by its data type, 
or check if a table has a trigger or even check if a field has a 
default value against it.  

I generally create a view with the code to store in each database, however it is attached as a 
basic runnable script. 
The script also pulls the first 10 triggers a table could have, so if you are looking for which 
table has a trigger this query will help also. 

Hope you find it useful.  

*/
/*
- Advanced Display Table and Column Info
- Written by Luis Chiriff
- luis.chiriff@gmail.com @ 11/12/2013 @ 13:08
*/

select 
*
, row_number() over (order by SchemaName
, TableName
, ColumnOrder) as SortID 
from 
(
select
db_name() as database_name 
, S.Name as SchemaName
, O.Name as TableName
, C.Name as FieldName
, C.ID as TableID
, T.Name as FieldType
, C.Length
, C.ColOrder as ColumnOrder
, C.IsNullable
, C.ColStat as IsIdent
, isnull(D.Name,'') as DefaultName
, isnull(D.Definition,'') as DefaultValue
, isnull(FTR.First10Triggers,'') as First10Triggers
from 
syscolumns C
inner join 
sysobjects O 
on C.id = O.id
inner join 
systypes T 
on C.xtype = T.xtype
inner join 
sys.schemas S 
on S.schema_id = O.uid
left outer join 
sys.default_constraints D 
on C.Colid = D.parent_column_id 
and 
C.id = D.parent_object_id
left outer join 
(
select 
parent_obj
, replace(ISNULL(C1,'=')+', '+ISNULL(C2,'=')+', '+ISNULL(C3,'=')+', '+ISNULL(C4,'=')+', '+ISNULL(C5,'=')+', '+ISNULL(C6,'=')+', '+ISNULL(C7,'=')+', '+ISNULL(C8,'=')+', '+ISNULL(C9,'=')+', '+ISNULL(C10,'='),', =','') as First10Triggers  
from 
( 
select 
name
, parent_obj
, 'C'+cast((RANK() over (partition by parent_obj order by Name)) as varchar(2)) as MyRank 
from sysobjects 
where xtype = 'TR' ) as D pivot ( max(name) for MyRank in ([C1],[C2],[C3],[C4],[C5],[C6],[C7],[C8],[C9],[C10]) ) as data) FTR on O.id = FTR.parent_obj 
where O.XType = 'U') Data