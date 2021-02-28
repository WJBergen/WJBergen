---
---This is athena_diagnostic_001.sql
---
/*
This is a microsoft provided query provided by Austin Mack to diagnose slowness in athena

*/
Use ServiceManager
Select Name, is_broker_enabled from sys.databases Where name = 'ServiceManager'
-- Line above added because it needs to be 1 or some stuff will not run
-- SubscriptionStatus.sql    -- Workflow / subscription status - (query does not work on SCSM 2010)
Use ServiceManager
DECLARE @MaxState INT, @MaxStateDate Datetime, @Delta INT, @Language nvarchar(3)
SET @Delta = 0
SET @Language = 'ENU'
SET @MaxState = (
    SELECT MAX(EntityTransactionLogId)
    FROM EntityChangeLog WITH(NOLOCK)
)
SET @MaxStateDate = (
                SELECT TimeAdded 
                FROM EntityTransactionLog
                WHERE EntityTransactionLogId = @MaxState
)
SELECT
    LT.LTValue AS 'Display Name',
                                S.State AS 'Current Workflow Watermark',
                @MaxState AS 'Current Transaction Log Watermark',
                DATEDIFF(mi,(SELECT TimeAdded 
                                                                                FROM EntityTransactionLog WITH(NOLOCK)
                                                                                WHERE EntityTransactionLogId = S.State), @MaxStateDate) AS 'Minutes Behind',
                S.EventCount,
                S.LastNonZeroEventCount,
                R.RuleName AS 'MP Rule Name',
    MT.TypeName AS 'Source Class Name',
    S.LastModified AS 'Rule Last Modified',
                S.IsPeriodicQueryEvent AS 'Is Periodic Query Subscription', --Note: 1 means it is a periodic query subscription
    R.RuleEnabled AS 'Rule Enabled', -- Note: 4 means the rule is enabled
                R.RuleID
FROM CmdbInstanceSubscriptionState AS S WITH(NOLOCK)
LEFT OUTER JOIN Rules AS R
    ON S.RuleId = R.RuleId
LEFT OUTER JOIN ManagedType AS MT
    ON S.TypeId = MT.ManagedTypeId
LEFT OUTER JOIN LocalizedText AS LT
                ON R.RuleId = LT.MPElementId
WHERE
    S.State <= @MaxState - @Delta 
                AND R.RuleEnabled <> 0 
                AND LT.LTStringType = 1
                AND LT.LanguageCode = @Language
                AND S.IsPeriodicQueryEvent = 0
                /* to look at a specific workflow uncomment on of the following */
                -- AND LT.LTValue  LIKE '%Test%' 
                -- AND S.RuleId='1D74409B-B2D9-8C45-6702-AB8C94AA0694'  -- aka Display Name="New Change Request Workflow"'
ORDER BY S.State Asc

