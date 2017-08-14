------------------------------------------------------------------------------
-- FILE NAME:
--		Q_SQLServer2016_NewFeatures
-- AUTHOR:	
--		David Noke
--
-- DESCRIPTION:  
--		Queries to test new SQL Server 2016 commands 
--
-- KEY WORDS: 
--		DROP..IF EXISTS
--      SESSION_CONTEXT - sp_set_session_context
--      DDM Dynamic Data Masking - partial(), default(), email(), random() 
-------------------------------------------------------------------------------

use TestData
-----------------------------------------------------------------------
--DROP..IF EXISTS
--  Can be used for AGGREGATE, ASSEMBLY, DATABASE, DEFAULT, INDEX
--		PROCEDURE, ROLE, RULE, SCHEMA, SECURITY POLICY, SEQUENCE,
--		SYNONYM, TABLE, TRIGGER, TYPE, VIEW
--	Create table to drop
	CREATE TABLE [dbo].[DropTest](
		[DropTestId] [int] NOT NULL,
		[DropTestData] [nchar](70) NULL
	) ON [PRIMARY]

	DROP TABLE IF EXISTS dbo.DropTest

-----------------------------------------------------------------------
--SESSION_CONTEXT
--	KEY/VALUE pair that lives in memory for while session is active
--    KEY - is a UNICODE string
--    VALUE - is a sql_variant (any type)

-- Get session data example - returns null
DECLARE @UsRegion varchar(20)
SET @UsRegion = CONVERT(varchar(20), SESSION_CONTEXT(N'UsRegion'))
select r = @UsRegion

-- Set session data example - value will remail for lifetime of connection
--   read_only parameter doesn't allow value to be changed until the session 
--   is over
EXEC sp_set_session_context @key = N'UsRegion', @value = N'Southwest', @read_only = 1

SET @UsRegion = CONVERT(varchar(20), SESSION_CONTEXT(N'UsRegion'))
select r = @UsRegion

-----------------------------------------------------------------------
--DDM Dynamic Data Masking
--
--Create mask table for testing
CREATE TABLE DDM_Customer(
	FirstName varchar(20)
		MASKED WITH (FUNCTION='partial(1, "...", 0)'),
	LastName varchar(20),
	Phone varchar(12)
		MASKED WITH (FUNCTION='default()'),
	Email varchar(200)
		MASKED WITH (FUNCTION='email()'),
	Balance money
		MASKED WITH (FUNCTION='random(1000,5000)')
)

--To update existing table use alter table
ALTER TABLE DDM_Customer
	ALTER COLUMN LastName
	ADD MASKED WITH (FUNCTION='default()')

--Insert data into table
USE [TestData]
GO

INSERT INTO [dbo].[DDM_Customer]
           ([FirstName],[LastName],[Phone],[Email],[Balance])
     VALUES ('John','Doe','123-456-789','john.doe@jd.com',1000)

--to find which columns are masked
select * from sys.columns where is_masked = 1
select * from sys.masked_columns

--create a test user to see if masking is working
--CREATE USER TestUser WITHOUT LOGIN
--GRANT SELECT ON DDM_Customer To TestUser

EXECUTE AS USER = 'TestUser'
select * from DDM_Customer
REVERT
GO
