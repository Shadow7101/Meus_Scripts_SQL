USE [master]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[sp_BackupDatabases] @backupType = 'F', @backupLocation = 'D:\temp\'

SELECT	'Return Value' = @return_value

GO
