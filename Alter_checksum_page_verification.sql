---
---This is check_checksum_page_verification.sql
---
SELECT 
'ALTER DATABASE ' + QUOTENAME(s.name) + ' SET PAGE_VERIFY CHECKSUM  WITH NO_WAIT;' 
FROM sys.databases AS s 
WHERE s.page_verify_option_desc <> 'CHECKSUM'; 