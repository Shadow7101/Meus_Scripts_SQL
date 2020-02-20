USE master
GO
DROP LOGIN [HomologUser]
GO
--CREATE LOGIN [HomologUser] WITH PASSWORD = 'E@syP@ssw0rd'
GO
USE [dealermate]
GO
DROP USER [HomologUser]
GO
--CREATE USER [HomologUser] FOR LOGIN [HomologUser]
GO
--REVOKE VIEW ANY DATABASE TO [HomologUser]
go
--REVOKE VIEW [CI-data1] DATABASE TO [HomologUser]
go
USE [dealermate]
GO
--ALTER USER [HomologUser] WITH DEFAULT_SCHEMA=[dbo]
GO
USE [dealer-mate-02]
GO
DROP USER [HomologUser]
GO
--CREATE USER [HomologUser] FOR LOGIN [HomologUser]
GO
USE [dealer-mate-02]
GO
--ALTER USER [HomologUser] WITH DEFAULT_SCHEMA=[dbo]
GO
USE [dealer-mate-03]
GO
DROP USER [HomologUser]
GO
--CREATE USER [HomologUser] FOR LOGIN [HomologUser]
GO
USE [dealer-mate-03]
GO
--ALTER USER [HomologUser] WITH DEFAULT_SCHEMA=[dbo]
GO
USE [dealer-mate-03]
GO
--ALTER ROLE [db_datareader] ADD MEMBER [HomologUser]
GO
USE [dealer-mate-03]
GO
--ALTER ROLE [db_datawriter] ADD MEMBER [HomologUser]
GO
USE [dealer-mate-03]
GO
--ALTER ROLE [db_ddladmin] ADD MEMBER [HomologUser]
GO
