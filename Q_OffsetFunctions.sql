------------------------------------------------------------------------------
-- FILE NAME:
--		Q_OffsetFunctions
-- AUTHOR:	
--		David Noke
--
-- DESCRIPTION:  
--		Queries involving data from other rows. 
--
-- KEY WORDS:  LAG, LEAD, FIRST_VALUE, LAST_VALUE
-------------------------------------------------------------------------------
--    LAG - Previous row
--    LEAD - Next row
--	  FIRST_ROW - first row of partition
--    LAST_ROW - last row of partition
--
--    LAG and LEAD no frame required.  
--    Have two optional parameters: 
--           OFFSET: number of rows away from current row (default = 1)
--           DEFAULT: default value for NULL values
--
--    FIRST_ROW and LAST_ROW - frame is required
--	  If no frame is specified default is 
--       "RANGE BETWEEN UNBOUNDED	PRECEDING AND CURRENT ROW"
-------------------------------------------------------------------------------

use AdventureWorks2014;

-------------------------------------------------------------------------------
--LAG AND LEAD EXAMPLES
-------------------------------------------------------------------------------

--LAG Example:
select CustomerID, SalesOrderID, TotalDue,
	lag(TotalDue) over(partition by CustomerID order by SalesOrderID) as PrevTotalDue,
	lag(SalesOrderID) over(partition by CustomerID order by SalesOrderID) as PrevOrderID
from Sales.SalesOrderHeader;

--LEAD Example:
select CustomerID, SalesOrderID, TotalDue,
	lead(TotalDue) over(partition by CustomerID order by SalesOrderID) as PrevTotalDue,
	lead(SalesOrderID) over(partition by CustomerID order by SalesOrderID) as PrevOrderID
from Sales.SalesOrderHeader;

--LAG, LEAD nested in expression
select CustomerID, cast(OrderDate as date) as OrderDate,
	datediff(d,lag(OrderDate) over (partition by CustomerID order by SalesOrderID), OrderDate) as DaysSincePrevOrder,
	datediff(d,OrderDate, lead(OrderDate) over (partition by CustomerID order by SalesOrderID)) as DateTillPrevOrder
from Sales.SalesOrderHeader;


--Using optional parameters
--Compare sales by year
with Sales as (
	select year(OrderDate) as OrderYear,
		month(OrderDate) as OrderMonth,
		sum(TotalDue) as TotalSales
	from Sales.SalesOrderHeader
	group by year(OrderDate), month(OrderDate)
)
select OrderYear, OrderMonth, TotalSales,
    lag(TotalSales, 12, 0) over(order by OrderYear, OrderMonth) as PreviousYearsSales
from Sales
order by OrderYear, OrderMonth

-------------------------------------------------------------------------------
--FIRST_ROW AND LAST_ROW EXAMPLES
-------------------------------------------------------------------------------
select CustomerID, cast(OrderDate as date) as OrderDate,
    SalesOrderID, TotalDue,
	first_value(TotalDue) over (partition by CustomerID order by SalesOrderID) as FirstOrderTotal,
	last_value(TotalDue) over (partition by CustomerID order by SalesOrderID
	   rows between current row and unbounded following) as LastOrderTotal
from Sales.SalesOrderHeader;
	

--Compare last year's sales to current year
;with Sales as (
		select year(OrderDate) as OrderYear, month(OrderDate) as OrderMonth, sum(TotalDue) as TotalSales
		from Sales.SalesOrderHeader 
		group by year(OrderDate), month(OrderDate))
select OrderYear, OrderMonth, TotalSales,
   --get 12 rows preceding the current row to get last years totals
   --  this will only work if you have 12 rows before current row
   first_value(TotalSales) over (order by OrderYear, OrderMonth
		rows between 12 preceding and current row) as LastYearsSales,
   --use a case statement if you don't have 12 rows before current row
   --  if we don't have 12 rows then we will set the value to NULL
   case 
		when 
			count(*) over (order by OrderYear, OrderMonth rows between 12 preceding and current row) = 13
		then 
			first_value(TotalSales) over (order by OrderYear, OrderMonth
				rows between 12 preceding and current row)
		else null end as LastYearsSales
from Sales
order by OrderYear, OrderMonth



