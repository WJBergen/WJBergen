

-----Original Message-----
From: David L. Penton [mailto:david@davidpenton.com]
Sent: Friday, March 14, 2003 4:05 PM
To: sswug-sql2k@topica.com
Subject: RE: [sswug:sql2k] Aggregate Character Columns


And as Tom's suggestion through Bruce:

    SET @s = ''

    SELECT @s = @s + COALESCE(a.ColB, '')
    FROM dbo.TestA a
    WHERE a.ColA = @ColA

would be better than

    SELECT @s = COALESCE(@s, '') + a.ColB
    FROM dbo.TestA a
    WHERE a.ColA = @ColA

 - dave

-----Original Message-----
From: David L. Penton [mailto:david@davidpenton.com]

This is not entirely supported :-)

drop table TestA
go

create table TestA (
	ColA int,
	ColB char(1))
GO

INSERT INTO TestA (ColA, ColB) VALUES (1, 'A')
INSERT INTO TestA (ColA, ColB) VALUES (1, 'B')
INSERT INTO TestA (ColA, ColB) VALUES (2, 'D')
INSERT INTO TestA (ColA, ColB) VALUES (2, 'E')
INSERT INTO TestA (ColA, ColB) VALUES (3, 'F')
INSERT INTO TestA (ColA, ColB) VALUES (4, 'G')

--Desired Result Set
--
-- ColA		ColB
-- ----------	-----
-- 1		AB
-- 2		DE
-- 3		F
-- 4		G
--

GO
drop FUNCTION dbo.ConcatTestAColA
go
CREATE FUNCTION dbo.ConcatTestAColA(@ColA int)
RETURNS varchar(8000)
AS
BEGIN
    DECLARE @s varchar(8000)

    SELECT @s = COALESCE(@s, '') + a.ColB
    FROM dbo.TestA a
    WHERE a.ColA = @ColA

    RETURN @s
END
GO

SELECT
    a.ColA, dbo.ConcatTestAColA(a.ColA) [ConcatColA]
FROM
    TestA a
GROUP BY
    a.ColA

-- resultset
ColA        ConcatColA


----------- -----------
1           AB
2           DE
3           F
4           G

-----Original Message-----
From: Driscoll, David J. [mailto:DDriscoll@WilmingtonTrust.com]

Kind of like a pivot table with characters and not sums...

The solution needs to take into account an unlimited number of rows where
ColA is the same.

I cannot figure out how to do this without a cursor. Can you? If so, show
off for the list please! ;-)

create table #TestA (
	ColA int,
	ColB char(1))

INSERT INTO #TestA (ColA, ColB) VALUES (1, 'A')
INSERT INTO #TestA (ColA, ColB) VALUES (1, 'B')
INSERT INTO #TestA (ColA, ColB) VALUES (2, 'D')
INSERT INTO #TestA (ColA, ColB) VALUES (2, 'E')
INSERT INTO #TestA (ColA, ColB) VALUES (3, 'F')
INSERT INTO #TestA (ColA, ColB) VALUES (4, 'G')

--Desired Result Set

ColA		ColB
----------	-----
1		AB
2		DE
3		F
4		G

Thanks,

Dave

David J. Driscoll
Database Administration
(302) 636-6558

------------
http://www.SSWUG.org
The Independent SQL Server Worldwide User's Group

List Archives at http://www.SSWUG.org/archives

==^================================================================
This email was sent to: DDriscoll@WilmingtonTrust.com

EASY UNSUBSCRIBE click here: http://topica.com/u/?a2i2Ti.a4uXHN.RERyaXNj
Or send an email to: sswug-sql2k-unsubscribe@topica.com

TOPICA - Start your own email discussion group. FREE!
http://www.topica.com/partner/tag02/create/index2.html
==^================================================================
