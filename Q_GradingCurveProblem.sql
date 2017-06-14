------------------------------------------------------------------------------
-- FILE NAME:
--		Q_GradingCurveProblem
-- AUTHOR:	
--		David Noke
--
-- DESCRIPTION:  
--		Find letter grades based on a curve
--
-- KEY WORDS: PERCENT_RANK
-------------------------------------------------------------------------------
use TestData;

--Grade based on percent rank
select StudentID, Grade,
	case when percent_rank() over (order by Grade) > .9 then 'A'
		 when percent_rank() over (order by Grade) > .8 then 'B'
		 when percent_rank() over (order by Grade) > .7 then 'C'
		 when percent_rank() over (order by Grade) > .6 then 'D'
	else 'F' end as LetterGrade
from Grades