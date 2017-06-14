------------------------------------------------------------------------------
-- FILE NAME:
--		Q_DuplicateProblems
-- AUTHOR:	
--		David Noke
--
-- DESCRIPTION:  
--		Various queries that find and correct duplicates
--
-- KEY WORDS:  GROUP BY, HAVING, ROW_NUMBER()
-------------------------------------------------------------------------------
use TestData;
-------------------------------------------------------
--Create a table with various values, some duplicated
-------------------------------------------------------
if OBJECT_ID (N'DuplicateTest', N'U') IS NULL 
	create table DuplicateTest
	(
		Val1 nvarchar(20),
		Val2 nvarchar(20),
		Val3 nvarchar(20)
	);

delete from DuplicateTest;
insert into DuplicateTest (Val1, Val2, Val3) values 
	 ('a','b','c'),('a','b','g'),('a','b','h')
	,('a','b','c'), ('a','b','d'), ('a','b','d')
	,('a','b','e'), ('a','b','e'), ('a','b','e')
	,('a','b','e'), ('b','b','c'), ('b','b','c');
-------------------------------------------------------
--To find duplicates using 'group by' and 'having'
-------------------------------------------------------
select Val1, Val2, Val3, count(*) as duplicateCount 
from DuplicateTest 
group by Val1, Val2, Val3 having count(*) > 1
-------------------------------------------------------
--To find duplicates using 'row_number()' and 'over'
--  all rows with RowNum > 1 are duplicates
-------------------------------------------------------
select Val1, Val2, Val3,
	row_number() over (partition by Val1, Val2, Val3
	  order by  Val1, Val2, Val3 ) as RowNum
from DuplicateTest;
-------------------------------------------------------
--To delete duplicate rows using CTE
-------------------------------------------------------
with Dupes as (
		select Val1, Val2, Val3,
		row_number() over (partition by Val1, Val2, Val3
		order by  Val1, Val2, Val3 ) as RowNum
		from DuplicateTest
)
delete Dupes where RowNum <> 1
--verify duplicates are deleted
select Val1, Val2, Val3, count(*) as duplicateCount 
from DuplicateTest 
group by Val1, Val2, Val3 having count(*) > 1
-------------------------------------------------------









