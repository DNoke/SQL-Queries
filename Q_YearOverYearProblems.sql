------------------------------------------------------------------------------
-- FILE NAME:
--		Q_YearOverYearProblems
-- AUTHOR:	
--		David Noke
--
-- DESCRIPTION:  
--		Various queries that find values year over year
--
-- KEY WORDS: LAG, FORMAT
-------------------------------------------------------------------------------
use AdventureWorks2014;

--Year
--Step1:  get the total sales per year and month
--Step2:  use LAG to get last years totals
--Step3:  find percent change from last year
;with Step1 as (
	select year(OrderDate) as OrderYear, month(OrderDate) as OrderMonth, sum(TotalDue) as TotalSales
	from Sales.SalesOrderHeader 
	group by  year(OrderDate), month(OrderDate)),
Step2 as (
	select OrderYear, OrderMonth, TotalSales,
		lag(TotalSales, 12) over(order by OrderYear, OrderMonth) as LastYearsSales
	from Step1)
select OrderYear, OrderMonth, LastYearsSales,
     format((TotalSales - LastYearsSales)/LastYearsSales, 'P') as PercentChange
from Step2 
where LastYearsSales is not null;

--Quarters
--Step1:  get the total sales per year and quarter
--Step2:  use LAG to get last years totals
--Step3:  find percent change from last year
;with Step1 as (
	select year(OrderDate) as OrderYear, month(OrderDate)/4 + 1 as OrderQtr, sum(TotalDue) as TotalSales
	from Sales.SalesOrderHeader 
	group by  year(OrderDate), month(OrderDate)/4+1),
Step2 as (
	select OrderYear, OrderQtr, TotalSales,
		lag(TotalSales, 4) over(order by OrderYear, OrderQtr) as LastQtrSales
	from Step1)
select OrderYear, OrderQtr, LastQtrSales,
     format((TotalSales - LastQtrSales)/LastQtrSales, 'P') as PercentChange
from Step2 
where LastQtrSales is not null;



