use AdventureWorks2014

------------------------------------------------------------------------------
-- FILE NAME:
--		Q_ExerciseExamples
-- AUTHOR:	
--		David Noke
--
-- DESCRIPTION:  
--		Various queries that use the AdventureWords2014 database
-------------------------------------------------------------------------------
--
--  DESC:  Distinct addresses and count (desc order)
select City, sp.Name, count(*) AS StateProvince 
from Person.Address a
inner join Person.StateProvince sp on sp.StateProvinceID = a.StateProvinceID
group by City, sp.Name
order by count(*) desc
-------------------------------------------------------------------------------
--
-- DESC: Employee counts by department
select
    h.DepartmentID,
	d.Name as DepartmentName, d.GroupName as DepartmentGroup,
	count(h.DepartmentID) as DepartmentCount
from HumanResources.Department d
inner join HumanResources.EmployeeDepartmentHistory h on d.DepartmentID = h.DepartmentID
where EndDate is null
group by h.DepartmentID, d.Name, d.GroupName
-------------------------------------------------------------------------------
--
-- DESC: Socks or Tights that are in sizes of Medium and Large
--         with a price between $50 and $100
select
	p.ProductID, p.Name, P.ProductNumber, p.Color, p.ListPrice, p.Size
from Production.Product p
where (p.Name like '%Socks%' or p.Name like '%tight%')
  and p.Size in ('M','L')
  and p.ListPrice between 50 and 180
-------------------------------------------------------------------------------
---
--  DESC: Products that don't have a product line associated with them
select
    p.Name,
	p.ProductNumber,
	p.Weight,
	p.ListPrice
from Production.Product p
where ProductLine is null
-------------------------------------------------------------------------------
--
-- DESC: Products grouped by Product Line, Description and Price
select
	p.ProductLine, p.Name, p.ListPrice
from Production.Product p
group by p.ProductLine, p.Name, p.ListPrice
order by p.ProductLine, p.Name, p.ListPrice
-------------------------------------------------------------------------------
--
-- DESC: List of VP vacation hours with total and average  
select
    p.FirstName, p.MiddleName, p.LastName, e.JobTitle,
	e.VacationHours,
	SUM(e.VacationHours) OVER(PARTITION BY  e.OrganizationLevel)  AS vpTotalVacationHrs,
	AVG(e.VacationHours) OVER(PARTITION BY  e.OrganizationLevel) AS vpAverageVacationHrs
from HumanResources.Employee e
inner join Person.Person p on p.BusinessEntityID = e.BusinessEntityID
where e.JobTitle like '%vice pres%'
-------------------------------------------------------------------------------
--














