------------------------------------------------------------------------------
-- FILE NAME:
--		Q_MetadataQueries
-- AUTHOR:	
--		David Noke
--
-- DESCRIPTION:  
--		Queries to find metadata 
--
-- KEY WORDS: 
-------------------------------------------------------------------------------
use TestData;

--Find table data
select TABLE_CATALOG, TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE
from INFORMATION_SCHEMA.TABLES

--Find table columns
select TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, 
	DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_PRECISION_RADIX, NUMERIC_SCALE,
	COLLATION_NAME
from INFORMATION_SCHEMA.COLUMNS 

--Find table indexes
select 
	t.name as table_name,
	i.name as index_name,
	c.name as column_name,
	ic.index_column_id 
from sys.tables t
	inner join sys.indexes i on i.object_id = t.object_id
	inner join sys.index_columns ic on ic.object_id = i.object_id
	inner join sys.columns c on c.column_id = ic.column_id and c.object_id = ic.object_id
where i.name is not null

--Find table constraints
select tc.TABLE_NAME, tc.CONSTRAINT_NAME, u.COLUMN_NAME, tc.CONSTRAINT_TYPE
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
	inner join INFORMATION_SCHEMA.KEY_COLUMN_USAGE u on u.TABLE_NAME = tc.TABLE_NAME
													and u.TABLE_SCHEMA = tc.TABLE_SCHEMA
													and u.CONSTRAINT_NAME = tc.CONSTRAINT_NAME


--Find tables that have foreign keys columns without an index

select *
	from sys.indexes i inner join sys.index_columns c on i.index_id = c.index_id

select * from sys.foreign_keys