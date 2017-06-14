------------------------------------------------------------------------------
-- FILE NAME:
--		Q_SubscriptionProblem
-- AUTHOR:	
--		David Noke
--
-- DESCRIPTION:  
--		Solution to subsricption problem.  See article: 
--      https://www.simple-talk.com/sql/performance/writing-efficient-sql-set-based-speed-phreakery/
--
--
-- KEY WORDS:  SUM,  ROWS UNBOUNDED PRECEDING
-------------------------------------------------------------------------------
-- Problem:
--   Table containing a list of subscribers with dates the subscribers joined
--   and the dates they cancelled.  Need to produce a report by month with the 
--   following;
--			-Number of new subscriptions
--			-Number of subscribers that left
--			-Running total of current subscribers
-------------------------------------------------------------------------------
--First we will create some data to work with:
use TestData

if OBJECT_ID (N'Registrations', N'U') IS NULL 
create table Registrations 
(
	RegistrationID int identity ,
	FirstName nchar (150),
	LastName nchar (150),
	DateJoined datetime,
	DateLeft datetime
);

--  if table is empty
declare @rowCount as int
select @rowCount = count(*) from Registrations

if (@rowCount = 0)
begin
	USE [TestData]

	declare @count as int
	declare @FirstName as nchar(150)
	declare @LastName as nchar(150)
	declare @SubscriptionDate datetime
	declare @CancelDate datetime

	set @count = 0 

	while @count < 5000
	begin
		set @CancelDate = NULL
		SELECT TOP 1 @FirstName = FirstName, @LastName = LastName FROM TestNames ORDER BY NEWID()	
		select @SubscriptionDate = DATEADD(day, (ABS(CHECKSUM(NEWID())) % 365), '2016-1-1 00:00:00.001')

		--set canel date for every 50th record
		--  the cancel date must be > subscription date
		if (@count%50 = 0)
		    select @CancelDate =  DATEADD(day, (ABS(CHECKSUM(NEWID())) % 365), @SubscriptionDate)

		insert into Registrations (FirstName, LastName, DateJoined, DateLeft)
		    values (@FirstName, @LastName, @SubscriptionDate, @CancelDate)

	   set @count = @count + 1;
	end
end
-------------------------------------------------------------------------------
--Use two CTE's, one for new subscriptions and one for cancellations
--  group by year and month
--Use SUM OVER (ROWS UNBOUNDED PRECEDING) to accumulate a running total
;with Joins as (
	select count(*) as NewSubscriptions,
		year(DateJoined) as JoinYear, month(DateJoined) as JoinMonth
	from [Registrations] 
	group by year(DateJoined), month(DateJoined)
)
,Cancels as (
	select count(*) as Cancellations,
		year(DateLeft) as CancelYear, month(DateLeft) as CancelMonth
	from [Registrations] 
	group by year(DateLeft), month(DateLeft)
)
select J.JoinYear as [Year], J.JoinMonth as [Month], J.NewSubscriptions, C.Cancellations,
     J.NewSubscriptions - COALESCE(C.Cancellations, 0) as NetNewSubscription,
	--The problem can be solved using window aggregates
	 SUM(J.NewSubscriptions - COALESCE(C.Cancellations, 0))	
	    over(order by J.JoinYear, J.JoinMonth rows unbounded preceding)
	    as CurrentSubscribers
	
from Joins J
	left join Cancels C on c.CancelYear = J.JoinYear and C.CancelMonth = J.JoinMonth
	order by J.JoinYear, J.JoinMonth



-------------------------------------------------------------------------------
--Performance Hints:
--   Check the Execution plan and look for "Window Spool"
--      This is a work table that was created to help with calculations.
--      Usually this is created in memory.  Check to see if it was created 
--        in tempdb.  This will cause a slowdown in the execution.	If "RANGE"
--        is used the "Window Spool" will always be created in tempdb.
--        Otherwise you can check the STATISTICS IO in Messages.  If 
--        there are 0 logical reads then the "Window Spool" was created 
--        in memory.
--      Often using "ROW" in the OVER clause will be quicker than using
--        other methods.  If the query is taking a long time, try using
--        "ROW" in the query if possible.
--      If many rows are used it might be benefitial to create a 
--        temporary index on the field(s) you are ordering by or 
--        partitioning by.



