CREATE TRIGGER [trg_INTL_USSC_Delta] ON [dbo].[INTL_USSC] 
FOR INSERT, DELETE 
AS 

IF UPDATE(USR_ID) 
INSERT INTO [dbo].[OLPCONV_Capture_Changes_Audit]
( Audit_Type_CD,
  User_Action,
  User_ID,
  Host_Table_ID,
  Host_Table_DS
)
SELECT
  'INTL_USSC',
  'INSERT',
  INS.USR_ID,
  INS.acct_id,
  'Inserted Record'
FROM INSERTED INS

ELSE

INSERT INTO [dbo].[OLPCONV_Capture_Changes_Audit]
( Audit_Type_CD,
  User_Action,
  User_ID,
  Host_Table_ID,
  Host_Table_DS
)
SELECT
  'INTL_USSC',
  'DELETED',
  DEL.USR_ID,
  DEL.acct_id,
  'Deleted Record'
FROM DELETED DEL


