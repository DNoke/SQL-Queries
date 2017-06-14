------------------------------------------------------------------------------
-- FILE NAME:
--		Q_PerformanceProblems
-- AUTHOR:	
--		David Noke
--
-- DESCRIPTION:  
--		Various methods to troubleshoot performance problems.
--
-- KEY WORDS: STATISTICS IO, 
-------------------------------------------------------------------------------
use AdventureWorks2014;
go
set statistics io on
go
--Before running the query set Execution Plan on (CTRL-M)
--View the messages tab and see how many "logical reads" 
--   this is the number of pages read
--View the execution plan tab and check the
--   cost of the "Sort" and "Clustered Index Scan" 
--   Hover over the "Sort" cost and check sorting order
--     see if an index exists on Color+Name (order by in query)
--   Less costly to scan index rather than table
select ProductID, [Name], ListPrice, Color,
	row_number() over (partition by Color order by [Name]) as RowNumber
from Production.Product
