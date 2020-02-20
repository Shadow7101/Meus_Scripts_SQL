--> Criando tabelas temporarias
BEGIN TRY  CREATE TABLE #TB1 (Name VARCHAR(255), Id INT IDENTITY(1,1)); END TRY 
BEGIN CATCH TRUNCATE TABLE #TB1 END CATCH
BEGIN TRY  CREATE TABLE #TB2 (Id INT IDENTITY(1,1), Mensagem VARCHAR(200), ErrorNumber INT, ErrorMessagem VARCHAR(200), Data DATETIME) END TRY 
BEGIN CATCH TRUNCATE TABLE #TB2 END CATCH
BEGIN TRY  CREATE TABLE #TB3 (ID INT, Name VARCHAR(255), Fragmention DECIMAL (14,4)) END TRY 
BEGIN CATCH TRUNCATE TABLE #TB3 END CATCH

--> Preenchendo tabela 1
INSERT #TB1 (Name) select top 18 name from sys.tables ORDER BY name;
SET NOCOUNT ON
--VÁRIAVEIS DE CONTROLE
DECLARE	  @TableName VARCHAR(255)
		, @OBJECTID INT
		, @Contador1 INT
		, @Contador2 INT
		, @INDEXNAME VARCHAR(255)
		, @Fragmention DECIMAL (14,4)
		, @Command1 VARCHAR(8000)
		, @Mensagem VARCHAR(200)
--INICIO DO PROCESSAMENTO
SET @Contador1 = 1		
WHILE EXISTS(SELECT 1 FROM #TB1 WHERE ID = @Contador1)
BEGIN	
	--> IDENTIFICANDO TABELA ATUAL
	SELECT @TableName = NAME FROM #TB1 WHERE ID = @Contador1;
	SET @OBJECTID =  OBJECT_ID(@TableName);	
	
	--> RECUPERANDO INDICES DA TABELA ATUAL
	TRUNCATE TABLE #TB3
	INSERT INTO #TB3 (ID, Name, Fragmention) 
	SELECT a.index_id, name, avg_fragmentation_in_percent
	FROM sys.dm_db_index_physical_stats (DB_ID(), @OBJECTID, NULL, NULL, NULL) AS a
	JOIN sys.indexes AS b ON a.object_id = b.object_id AND a.index_id = b.index_id; 
	
	--ANALISANDO OS INDICES
	SET @Contador2 = 1
	WHILE EXISTS(SELECT 1 FROM #TB3 WHERE ID = @Contador2)
	BEGIN
		--RECUPERANDO DADOS SOBRE O INDICE
		SELECT @INDEXNAME = Name, @Fragmention = Fragmention FROM #TB3 WHERE ID =  @Contador2		
		IF @Fragmention > 0.35
		BEGIN
			BEGIN TRY
				--> CASO A FRAGMENTAÇÃO DO INDICE ESTEJA ACIMA DE 35% A ROTINA DE MANUTENÇÃO É EXECUTADA
				PRINT @Fragmention
				SET @Mensagem = 'RECRIANDO INDICE ' + @INDEXNAME + ' DA TABELA ' + @TableName + ' Fragmentacao: ' + CONVERT(VARCHAR, @Fragmention);
				PRINT @Mensagem + ' - ' +  CONVERT(VARCHAR, GETDATE(), 108);
				SET @Command1  = 'ALTER INDEX ' + @INDEXNAME + ' ON ' + @TableName + ' REBUILD;';
				EXEC(@Command1);
				--> REGISTRA LOG DE SUCESSO
				INSERT #TB2 (Mensagem, ErrorNumber, ErrorMessagem, Data) VALUES (@Mensagem, 0, 'OK', GETDATE());
			END TRY
			BEGIN CATCH
				--> REGISTRA LOG DE FALHA
				INSERT #TB2 (Mensagem, ErrorNumber, ErrorMessagem, Data) VALUES (@Mensagem, ERROR_NUMBER(), ERROR_MESSAGE(), GETDATE());
			END CATCH
		END
		SET @Contador2 = @Contador2 + 1
	END
	--> CASO EXISTA ALGUM INDICE COM A FRAGMENTAÇÃO ACIMA DE 35%
	IF EXISTS(SELECT 1 FROM #TB3 WHERE Fragmention > 0.35)
	BEGIN
		BEGIN TRY
			SET @Mensagem = 'ATUALIZANDO ESTATISTICAS DA TABELA ' + @TableName;
			PRINT @Mensagem
			SET @COMMAND1 = 'UPDATE STATISTICS ' + @TableName + ' WITH FULLSCAN;';	
			EXEC(@COMMAND1);
			--> REGISTRA LOG DE FALHA			
			INSERT #TB2 (Mensagem, ErrorNumber, ErrorMessagem, Data) VALUES (@Mensagem, 0, 'OK', GETDATE());
		END TRY
		BEGIN CATCH
			--> REGISTRA LOG DE FALHA
			INSERT #TB2 (Mensagem, ErrorNumber, ErrorMessagem, Data) VALUES (@Mensagem, ERROR_NUMBER(), ERROR_MESSAGE(), GETDATE());
		END CATCH	
	END	
	SET @Contador1 = @Contador1 + 1;
END
SET NOCOUNT OFF 
select * from #TB2

 