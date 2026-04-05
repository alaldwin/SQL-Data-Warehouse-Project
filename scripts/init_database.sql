/*
=============================================================================
Create Database and Schemas
=============================================================================
Scripts Purpose:
	This scripts creates a new database named 'datamodeling' after checking if it already exists.
	If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
	within the database: 'bronze', 'silver', 'gold'.


WARNING:
	Running this scripts will drop the entire 'datamodeling' database if it exits.
	All data in the database will be permanenlty deleted. Proceed with caution
	and ensure you have proper backups before running this scripts.
*/


-- Drop and recreate the 'datamodeling' database 
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'datamodeling')
BEGIN
	ALTER DATABASE datamodeling SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE datamodeling;
END;

-- create the "datamodeling" database
CREATE DATABASE datamodeling;
USE datamodeling
GO

-- Create Schemas
CREATE SCHEMA src_data;

CREATE SCHEMA bronze;

CREATE SCHEMA silver;

CREATE SCHEMA gold;
