------------------------------------------------------------------------------
-- FILE NAME:
--		Q_StatisicalFunctions
-- AUTHOR:	
--		David Noke
--
-- DESCRIPTION:  
--		Various queries that use statistical functions
--
-- KEY WORDS: PERCENT_RANK, CUME_DIST, PERCENTILE_CONT, PERCENTILE_DIST
-------------------------------------------------------------------------------
--  PERCENT_RANK	- calculates the rank over the group
--                         (90% - score is 90% better then other score)
--                         Function: (RANK - 1) / (N - 1)

--  CUME_DIST		- calculates the relative position
--                         (90% - score is at position 90)
--						   Function: RANK / N
--
--  PERCENTILE_CONT	- interpolates the value given a rank
--						opposite of PERCENT_RANK
--
--  PERCENTILE_DISC	- finds the value of a given rank
--						opposite of CUME_DIST
--
--      PERCENTILE_CONT and PERCENTILE_DISC use the WITHIN GROUP clause
--        SYNTAX:
--            PERCENTILE_CONT | PERCENTILE_DISC (<rank>)
--            WITHIN GROUP (ORDER BY <expression>)
--            OVER ([PARTITION BY <expression>])	
--  
--        Median can be found by using:
--            PERCENTILE_CONT(0.5)... or  PERCENTILE_DISC(0.5)...	
-------------------------------------------------------------------------------
use TestData;

--PERCENT_RANK and CUME_DIST examples:
select StudentID, Grade,
    rank() over (order by Grade) as GradeRank,
	format(percent_rank() over(order by grade), 'P') as PercentRank,
	format(cume_dist() over(order by grade), 'P') as CumeDist
from Grades;

--PERCENT_RANK and CUME_DIST examples using formulas:
;with DistinctGrades as (
	select distinct Grade
	from Grades
	group by Grade)
select Grade,
	format(percent_rank() over(order by Grade), 'P') as PercentRank,
	format((rank() over (order by Grade) - 1) / cast((count(*) over () -1) as float), 'P') as Calculated_PercentRank,
	format(cume_dist() over(order by grade), 'P') as CumeDist,
	format(rank() over (order by Grade) / cast((count(*) over ()) as float), 'P') as Calculated_CumulativeDistribution
from DistinctGrades

--PERCENTILE_CONT and PERCENTILE_DISC examples:

--Find the grade at 90%
select distinct 
	percentile_disc(0.9) within group (order by grade) over () as GradeAt90D,
    percentile_cont(0.9) within group (order by grade) over () as GradeAt90C
from Grades;






