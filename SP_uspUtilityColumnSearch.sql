USE [AdventureWorks2014]
GO

/****** Object:  StoredProcedure [dbo].[uspUtilityColumnSearch]    Script Date: 6/5/2017 8:21:15 AM ******/
DROP PROCEDURE [dbo].[uspUtilityColumnSearch]
GO

/****** Object:  StoredProcedure [dbo].[uspUtilityColumnSearch]    Script Date: 6/5/2017 8:21:15 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


------------------------------------------------------------------------------
-- STORED PROCEDURE:
--		 uspUtilityColumnSearch
--
-- DESCRIPTION:  
--		Searches for tables with column name.
--
-- PARAMETERS:
--		@colName  -  Name of column to search for (can include wildcard characters)
--
-- RETURN VALUE:
--		TableName (schema+table), column name, column datatype 
--      ordered by column name and TableName         
--
-- PROGRAMMING NOTES:
--     
-- AUTHOR:	
--		David Noke

-- CHANGE HISTORY
-------------------------------------------------------------------------------


CREATE PROCEDURE [dbo].[uspUtilityColumnSearch]
    @colName [nvarchar](50)
AS
BEGIN

select t.TABLE_SCHEMA + '.' + t.TABLE_NAME as TableName,
   c.COLUMN_NAME, c.DATA_TYPE
from INFORMATION_SCHEMA.TABLES t
inner join INFORMATION_SCHEMA.COLUMNS c on c.TABLE_NAME = t.TABLE_NAME and c.TABLE_SCHEMA = t.TABLE_SCHEMA
where t.TABLE_TYPE = 'BASE TABLE' and c.COLUMN_NAME like @colName 
order by c.COLUMN_NAME, t.TABLE_SCHEMA, t.TABLE_NAME

END
GO


