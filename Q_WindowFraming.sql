------------------------------------------------------------------------------
-- FILE NAME:
--		Q_WindowFraming
-- AUTHOR:	
--		David Noke
--
-- DESCRIPTION:  
--		Various queries that use window framing.
--        Framing divides OVER() partition into
--        smaller subsets
--
-- KEY WORDS: OVER, PARTITION BY, SUM, AVG 
-------------------------------------------------------------------------------
--  Framing terms:
--     CURRENT ROW - current row which calculation is being performed
--     UNBOUNDED PRECEDING - frame starts at the first row in the partition
--     UNBOUNDED FOLLOWING - last row of partition
--     BETWEEN - rows between specified range
--     N PRECEDING - specified number of rows preceding from current row
--     N FOLLOWING - specified number of rows after current row
-------------------------------------------------------------------------------
--     RANGE VS. ROWS
--        RANGE works similar to 'RANK' - ROWS works similr to 'ROW NUMBER'

use AdventureWorks2014;

--Window aggregate vs. accumulating window aggregate
--  using "order by" is a running total	
--  without "order by" we get a total per partition
select CustomerID, SalesOrderID, TotalDue,
	sum(TotalDue) over(partition by CustomerID) as SubTotal,
	sum(TotalDue) over(partition by CustomerID order by SalesOrderID) as RunningTotal,
	sum(TotalDue) over(partition by CustomerID order by SalesOrderID
		rows between current row and unbounded following) as ReverseRunningTotal 
from Sales.SalesOrderHeader
order by CustomerID, SalesOrderID;

--Running average
--  Monthly sales for year 2012
--  Average is an accumulation up
--   to that point
with Sales as (
		select month(OrderDate) as OrderMonth,
			sum(TotalDue) as MonthlySales 
		from Sales.SalesOrderHeader
		where OrderDate >= '2012-01-01' and OrderDate < '2013-01-01'
		group by month(OrderDate))
select OrderMonth, MonthlySales,
     avg(MonthlySales) over(order by OrderMonth) as Average
from Sales;


--Three month running average
--  Monthly sales for year 2012
with Totals as (
		select month(OrderDate) as OrderMonth,
			sum(TotalDue) as MonthlySales 
		from Sales.SalesOrderHeader
		where OrderDate >= '2012-01-01' and OrderDate < '2013-01-01'
		group by month(OrderDate))
select OrderMonth, MonthlySales,
	-- frame using previous 2 rows to get the 3 month average
     avg(MonthlySales) over(order by OrderMonth
	     rows between 2 preceding and current row) as ThreeMonthMovingAverage1,
	-- excluding averages with less than 3 months
	   case 
			when count(*) over (order by OrderMonth rows between unbounded preceding and current row) > 2
		then
			avg(MonthlySales) over(order by OrderMonth
				rows between 2 preceding and current row) 
		else null end as ThreeMonthMovingAverage2
from Totals






