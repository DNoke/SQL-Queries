------------------------------------------------------------------------------
-- FILE NAME:
--		Q_GoldStarProblems
-- AUTHOR:	
--		David Noke
--
-- DESCRIPTION:  
--		Various queries that will determine a ranking of top customers
--        based on product sales.
--
-- KEY WORDS:  NTILE(), CHOOSE()
-------------------------------------------------------------------------------

use AdventureWorks2014;

--Get the top 4 customers categories and assign descriptive name 
--  Gold Star - 1st quartile, Silver Star - 2nd quartile
--  Bronze Star - 3rd quartile, No Star - 4th quartile
;with 
Sales as (
	select soh.CustomerID, sum(soh.TotalDue) as TotalSales
	from Sales.SalesOrderHeader soh
	where soh.OrderDate between '2014-01-01' and '2015-01-01'
	group by soh.CustomerID),
Buckets as (
	select CustomerID, TotalSales,
		ntile(4) over(order by TotalSales) as Bucket	  
	from Sales)
select CustomerID, TotalSales,Bucket,
		--choose works like case statement
		choose(Bucket, 'No Star', 'Bronze Star', 'Silver Star', 'Gold Star')
		   as CustomerCategory
 from Buckets;
