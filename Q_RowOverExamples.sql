use AdventureWorks2014

------------------------------------------------------------------------------
-- FILE NAME:
--		Q_RowOverExamples
-- AUTHOR:	
--		David Noke
--
-- DESCRIPTION:  
--		Various queries that use the ROW OVER PARTITION function
--
-- KEY WORDS:  ROW_NUMBER(), COUNT(), SUM(), AVG(), RANK(), DENSE_RANK()
--                  NTILE()
-------------------------------------------------------------------------------

--count of person by person type
select PersonType, count(*) as PersonTypeCount
from Person.Person
group by PersonType

--row number and count by PersonType
select
	--row number of PersonType
	ROW_NUMBER() OVER(PARTITION BY PersonType ORDER BY PersonType ASC) 
    AS PersonTypeRowNumber, 
	--count of all PersonType
	COUNT(PersonType) OVER(PARTITION BY PersonType ORDER BY PersonType ASC) 
    AS PersonTypeRowCount, 
	PersonType, FirstName, MiddleName, LastName
from Person.Person p


--vacation hours, average and variance per employee/organizational level
select
    e.OrganizationLevel,
    p.FirstName, p.MiddleName, p.LastName, e.JobTitle,
	e.VacationHours,
	--sum of total vacation hrs per OrgLevel
	SUM(e.VacationHours) OVER(PARTITION BY  e.OrganizationLevel)  AS TotalVacationHrsPerOrgLevel,
	--average of vacation hrs per OrgLevel
	AVG(e.VacationHours) OVER(PARTITION BY  e.OrganizationLevel) AS AverageVacationHrsPerOrgLevel,
	--difference between individual vacation hours and OrgLevel average
	e.VacationHours - AVG(e.VacationHours) OVER(PARTITION BY  e.OrganizationLevel) AS IndividualVariance
from HumanResources.Employee e
inner join Person.Person p on p.BusinessEntityID = e.BusinessEntityID
order by e.OrganizationLevel

--sales orders usi
ng row_number, rank() and dense_rank()
--   dense_rank doesn't skip number when tied rank (ex: ProductID 710 1,1,1,1,2,2,2,2,3,3....) 
--   rank is positional - catches up with row number with new rank (ex: ProductID 710 (1,1,1,4,4,4,4,8....)
select sod.ProductID, format(soh.OrderDate, 'yyyy-MM-dd') as OrderDate,
	row_number() over(partition by sod.ProductID order by soh.OrderDate) as RowNumber,
	rank()  over(partition by sod.ProductID order by soh.OrderDate) as [Rank],
	dense_rank()   over(partition by sod.ProductID order by soh.OrderDate) as DenseRank
from Sales.SalesOrderHeader soh
inner join Sales.SalesOrderDetail sod on sod.SalesOrderID = soh.SalesOrderID
where sod.ProductID between 710 and 720
order by sod.ProductID, soh.SalesOrderID;

--example using ntile() 
--  result set is divided into 10 buckets
with Sales as(
select sod.ProductID,
     count(*) as OrderCount
from Sales.SalesOrderHeader soh
inner join Sales.SalesOrderDetail sod on sod.SalesOrderID = soh.SalesOrderID
group by sod.ProductID
)
select ProductID, OrderCount,
	ntile(10) over (order by OrderCount) as Bucket
from Sales;



