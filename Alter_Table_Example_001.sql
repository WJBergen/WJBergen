create table wjb_default_test
(
 column_a	int
)
---
---
---
alter table wjb_default_test
add column_b int not null default(0)
---
---
---
alter table wjb_default_test
add column_c int 
---
---
---
alter table wjb_default_test 
 alter column column_c int not null
---
---
---
ALTER TABLE wjb_default_test WITH NOCHECK
ADD CONSTRAINT column_c_default DEFAULT 0 FOR [column_c]





---CREATE TABLE [dbo].[WJB_DEFAULT_TEST]
---(
---	[column_a] [int] NOT NULL CONSTRAINT [DF_WJB_DEFAULT_TEST_column_a]  DEFAULT ((0))
---)







-----ALTER TABLE doc_exd WITH NOCHECK 
-----ADD CONSTRAINT exd_check CHECK (column_a > 1) 




-----alter table dbo.tb_FinancialFact
-----add   [CenterID] [int] NOT NULL   DEFAULT ((0)),
-----	  [EmployeeID] [int] NOT NULL   DEFAULT ((0))
