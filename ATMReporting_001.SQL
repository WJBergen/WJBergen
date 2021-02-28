select * from dbatasks.dbo.atmr

select branch, atm, denom, sum(amt)
from atmr
group by branch, atm, denom
order by branch, atm, denom