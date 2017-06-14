------------------------------------------------------------------------------
-- FILE NAME:
--		Q_GapProblems
-- AUTHOR:	
--		David Noke
--
-- DESCRIPTION:  
--		Various queries that find gaps in a set of number or dates
-------------------------------------------------------------------------------

--find gaps in numbers
-- 1,2,3,4,5,8,9,13,14,16,17
-- gaps in 6,7  || 10,11,12  || 15
--
--set up table
declare @nums table (id  int);
insert into @nums values (1),(2),(3),(4),(5),(8),(9),(13),(14),(16),(17)

-------------------------------------------------------------------------------
--Finding number gap using row_number
;with diffs as (
select id, 
	row_number() over (order by id) as rowNumber,
	id - row_number() over (order by id) as diff
from @nums
)

select min(id) as begining, max(id) as ending from diffs group by diff

-------------------------------------------------------------------------------
--Finding number gap using	lead function
;with diffs as (
	select id,
	     lead(id) over (order by id) as NextValue,
		id - lead(id) over (order by id) as diff 
	from @nums)
select id + 1 as StartOfGap,NextValue - 1 as EndOfGap 
from diffs where diff <> -1


--find gaps in set of dates
--  use datediff to group similar dates
declare @dates table (dateID  date);
insert into @dates values ('2017-01-01'),('2017-01-01'),('2017-01-01'),('2017-01-01'),
    ('2017-01-02'),('2017-01-02'),('2017-01-03'),('2017-01-05'),('2017-01-06'),('2017-01-14'),('2017-01-15')

--finding date gap using dense_rank
;with diffs as (
select dateID, 
    dense_rank() over (order by dateID) as date_denseRank,
    datediff(d,dateadd(d,dense_rank() over (order by dateID), '2016-12-31'),dateID) as diff
	from @dates)

select min(dateID) as beginingDate, max(dateID) as endingDate from diffs group by diff

--finding date gap using lead
;with Step1 as (
	select dateID 
	from @dates
	group by dateID),
Step2 as (
    select dateID,lead(dateID) over (order by dateID) as NextValue,
	   datediff(d, lead(dateID) over (order by dateID), dateID) as diff 
 	from Step1)
select dateadd(d,1,dateID) as StartOfGap,dateadd(d,-1,NextValue)  as EndOfGap 
from Step2 where diff <> -1


