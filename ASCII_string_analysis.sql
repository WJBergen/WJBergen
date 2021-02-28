---
---This will tell you the ASCII number for each character in a string.
---
---
SET TEXTSIZE 0
-- Create variables for the character string and for the current 
-- position in the string.
DECLARE @position int, @string varchar(255)
-- Initialize the current position and the string variables.
SET @position = 1
SET @string = 'Bill Bergen is my Hero!  '
WHILE @position <= DATALENGTH(@string)
   BEGIN
   SELECT ASCII(SUBSTRING(@string, @position, 1)), 
      CHAR(ASCII(SUBSTRING(@string, @position, 1)))
   SET @position = @position + 1
   END
GO
