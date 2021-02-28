---
---Add the new column
---
alter table dbo.tb_test
add [new_column] int NULL
---Then we can immediately add a constraint WITH NOCHECK 
---for NEW records that will come in until we have time to 
---update the old records. In this way the constarint isn’t 
---checked and will not fail:
ALTER TABLE tb_test WITH NOCHECK
ADD CONSTRAINT DF_tb_test_defaults DEFAULT 0 FOR [new_column]
---
---
---
----UPDATE TABLE tb_text set new_column in small TRANSACTION sets
---
---And then when all the records have been updated to 0, we 
---can make the column NOT NULL
---
alter table dbo.tb_test
alter column [new_column]  NOT NULL
