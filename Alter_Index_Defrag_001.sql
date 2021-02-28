ALTER INDEX all ON sales02
  rebuild WITH (FILLFACTOR = 80, sort_in_tempdb = ON);


SELECT	a.index_id
	, CAST(name AS VARCHAR(15)) AS 'Index name'
	, avg_fragmentation_in_percent
FROM 
sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID('sales02'),null, null, null) AS a
join 
sys.indexes AS b 
ON a.OBJECT_ID = b.OBJECT_ID 
and 
a.index_id = b.index_id;