select count(*) from DBATASKS.dbo.wtc_averbach_db_report

select count (distinct column_name) from DBATASKS.dbo.wtc_averbach_db_report

select substring(column_name, 1, 35), count(column_name)
from DBATASKS.dbo.wtc_averbach_db_report
group by column_name
having count(column_name) > 1
order by column_name