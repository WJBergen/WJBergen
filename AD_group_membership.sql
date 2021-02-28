---
---This is AD_group_membership.sql
---
---Also, use user_group_membership.sql
---
---Also, use AD_membership_info_001.sql 
---
---

/*
xp_logininfo 
[ [ @acctname = ] 'account_name' ] 
[ , [ @option = ] 'all' | 'members' ] 
[ , [ @privilege = ] variable_name OUTPUT]

xp_logininfo enables us to find out what Windows users are members of a particular Windows 
group. 
For instance: EXEC master.dbo.xp_logininfo 'DomainName\GroupName', 'members'

xp_logininfo also enables us to find out what Windows groups a particular Windows user is a 
member of. 
For instance: EXEC master.dbo.xp_logininfo 'DomainName\UserName'

@acctname must be full qualified. If your Windows user or Windows group is local rather than 
in Active Directory, simply use WorkgroupName instead of DomainName.

@privilege parameter returns the type of privilege avaialbe to the specified 
login - user, admin or null

If the Windows user or Windows group exists but does not have access to the SQL Server 
instance, you will get an empty result set returned. It will not error.

sys.xp_logininfo
    @acctname       sysname = null,             -- IN: NT login name
    @option         varchar(10) = null,         -- IN: 'all' | 'members' | null
    @privilege      varchar(10) = 'Not wanted' OUTPUT   -- OUT: 'admin' | 'user' | null




*/
---
---
---
EXEC master..xp_logininfo
	@acctname = '[UPHS\GROUPNAMEHERE]'
	, @option = 'members'


/*


The Is_Member function indicates whether the current user is a member of the specified 
Microsoft Windows group or SQL Server database role.

IS_MEMBER ( { 'group' | 'role' } )

Return value:

Current user is not a member of group or role, returns 0. 
Current user is a member of group or role, returns 1. 
Either group or role is not valid. When queried by a SQL Server login or a login using an 
application role, returns NULL for a Windows group. 
 

*/

