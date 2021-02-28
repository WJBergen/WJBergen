-- SQLMag - create the Linked Server Connection
Exec sp_addlinkedserver 'ADSI', 'Active Directory Services 2.5', 'ADSDSOObject', 'adsdatasource'


-- MSDN
-- method 1 -- not working... don't know why... 
SELECT * FROM OpenQuery( ADSI, 'SELECT name, adsPath FROM "LDAP://DC=wtcnt,DC=wtc,DC=com" WHERE objectCategory = "Person" AND objectClass= "user""')
 
-- method 2, using ADSI LDAP dialect
-- works, but brings back 1000 rows... network limit -- being fixed
SELECT * FROM OpenQuery(ADSI,'<LDAP://DC=wtcnt,DC=wtc,DC=COM>;
      (&(objectCategory=Person)(objectClass=user));
      name, displayname, adspath;subtree')
 where name like 'W60%'   --- 3sec, 8 rows  -- relies on SQL server to filter on entire (1000 row limit) result set

-- My own testing... 
SELECT * FROM OpenQuery(ADSI,'<LDAP://DC=wtcnt,DC=wtc,DC=COM>;
      (&(objectCategory=Person)(objectClass=user)(name=w60*));
      name, displayname, adspath;subtree')  --0sec, 27 rows  -- filters within AD and just returns what I want... faster and more reliable


SELECT * FROM OpenQuery(ADSI,'<LDAP://CN=w6034,OU=Users_temp,DC=wtcnt,DC=wtc,DC=com>;
      (&(objectCategory=Person)(objectClass=user));
      name, displayname, adspath;subtree')  --0sec, 27 rows  -- gets just me... 


-- params that work thus far in the above syntax:
--    homedrive, homedirectory, mail (null),       


-- test 1a using a qualified category should be fastest since categories are indexed
SELECT * FROM OpenQuery(ADSI,'<LDAP://DC=wtcnt,DC=wtc,DC=COM>;
      (&(ObjectCategory=computer)(name=wil-sql*));
      name;subtree')

-- test 1b this returns same results, but is doing a scan of ALL objects in ADS
SELECT * FROM OpenQuery(ADSI,'<LDAP://DC=wtcnt,DC=wtc,DC=COM>;
      ((name=wil-sql*));
      name;subtree')

-- test 1c this returns same results, but not indexed, but using a particular class
SELECT * FROM OpenQuery(ADSI,'<LDAP://DC=wtcnt,DC=wtc,DC=COM>;
      (&(ObjectClass=computer)(name=wil-sql*));
      name;subtree')




-- --From DBForums


For more information, please refer to this article:

Q299410 INFO: Performing a SQL Distributed Query by Using ADSI
http://support.microsoft.com/support/kb/articles/q299/4/10.asp


