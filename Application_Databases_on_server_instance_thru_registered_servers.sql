---
---When run under registered servers this will show the application databases on a server and instance
---Make sure the output is in grid mode.
---
select name
from sys.databases
where name not in ('master', 'model', 'tempdb', 'DBATASKS')
order by name;