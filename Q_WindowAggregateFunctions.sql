------------------------------------------------------------------------------
-- FILE NAME:
--		Q_WindowAggregateFunctions
-- AUTHOR:	
--		David Noke
--
-- DESCRIPTION:  
--		Various queries that use window aggregate functions.
--
-- KEY WORDS: COUNT, AVG, MIN, MAX, FORMAT, SUM, DISTINCT 
--            CLR, 
-------------------------------------------------------------------------------
-- Supported aggregate functions for windows include:
--    SUM, AVG, COUNT, COUNT_BIG, MIN, MAX, 
--    CHECKSUM_AGG, STDEV, STDEVP, VAR, VARP
-------------------------------------------------------------------------------
use AdventureWorks2014;

---------------------------------------------------------------
--Get a count of all products and the
--  average cost of all products
--  (note: over() will include all rows
--   no partition is used)
select ProductID, [Name], ListPrice,
    count(*) over () as ProductCount,
	avg(ListPrice) over () as AveragePrice
from Production.Product 
where FinishedGoodsFlag = 1

---------------------------------------------------------------
--Get a count of all products in 
--  the category and the
--  average cost based on category
--  (note: over() will include all rows
--   no partition is used)
select p.ProductID, p.[Name] as ProductName, p.ListPrice, c.[Name] as CategoryName,
    count(*) over (partition by c.ProductCategoryID) as ProductCount,
	avg(ListPrice) over (partition by c.ProductCategoryID) as AveragePrice,
	min(ListPrice) over() as MinListPrice_AllProducts,
	max(ListPrice) over() as MaxListPrice_AllProducts
from Production.Product p
inner join Production.ProductSubcategory s on s.ProductSubcategoryID = p.ProductSubcategoryID
inner join Production.ProductCategory  c on c.ProductCategoryID = s.ProductCategoryID
where FinishedGoodsFlag = 1

---------------------------------------------------------------
--Percent of sales for each type of bike for the year 2014
with Sales as 
(
	--First we get the total bike sales for each sub category
	select S.[Name] as BikeSubCategory, sum(LineTotal) as BikeSales
		from Sales.SalesOrderDetail sod
		inner join Sales.SalesOrderHeader soh on soh.SalesOrderID = sod.SalesOrderID
		inner join Production.Product p on p.ProductID = sod.ProductID
		inner join Production.ProductSubcategory s on s.ProductSubcategoryID = p.ProductSubcategoryID
		where s.[Name] like '%Bikes%'
			and soh.OrderDate >= '2014-01-01'
			and soh.OrderDate < '2015-01-01'
		group by s.[Name]
)
--Now we get the sub category percentage
select BikeSubCategory, BikeSales, 
	sum(BikeSales) over() as TotalSales, 
	format(BikeSales / sum(BikeSales) over(), 'P') as PercentOfSales
from Sales;

---------------------------------------------------------------
-- Aggregate examples
--  Total sales for each customer with grand total 
--  for all customers
--  Because we use "sum" in a group by query 
--    we need to add another "sum" to aggreate 
--    to get the grand total
select soh.CustomerID, 
	sum(TotalDue) as CustomerSales,
	sum(sum(TotalDue)) over() as TotalSales
from Sales.SalesOrderHeader soh
where OrderDate >= '2014-01-01' and OrderDate < '2015-01-01'
group by CustomerID;

--distinct list of customers and count
with Customers as 
(
	select distinct CustomerID 
	from Sales.SalesOrderHeader
)
select CustomerID,
	count(*) over () as CountOfCustomers
from Customers;

---------------------------------------------------------------
--Example using custom CLR function

--Enable CLR configuration
exec sp_configure 'clr enabled', 1;
reconfigure;
go

create assembly CustomAggregate from
   'C:\SQLServerCustomCLR\CustomAggregate.dll' with Permission_set = SAFE;
go

--create UDF
create Aggregate Median (@value int) returns int
external NAME CustomAggregate.Median;
go

select SalesOrderID, count(*) as DetailCount,
    --call CLR function in Window 
	dbo.Median(count(*)) over () as MedianDetailCount
	from Sales.SalesOrderDetail sod
	where SalesOrderID between 43660 and 43670
	group by SalesOrderID

--clean up CLR
drop aggregate dbo.Median;
drop assembly CustomAggregate;
exec sp_configure 'clr enabled', 0;
reconfigure;
---------------------------------------------------------------




