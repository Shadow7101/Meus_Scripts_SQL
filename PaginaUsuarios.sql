USE master
GO
CREATE DATABASE Paginacao
GO
USE Paginacao
GO
CREATE TABLE Usuarios1 (
	UserId INT IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(80) NOT NULL,
	Email VARCHAR(80) NOT NULL
)
GO
DECLARE @Contador INT SET @Contador = 1
WHILE @Contador <= 10000
BEGIN
	INSERT INTO Usuarios1 (Name, Email)VALUES ('Name #' + CONVERT(varchar(80), @Contador), 'email' + CONVERT(varchar(80), @Contador) + '@dominio.com')
	SET @Contador = @Contador + 1
END
SELECT * FROM Usuarios1
GO
ALTER PROCEDURE PaginaUsuarios (
	@NOME_USUARIO VARCHAR(80) = NULL,
	@ASC BIT = 0,
	@PAGENUM INT,
	@PAGESIZE INT
)
AS BEGIN

	DECLARE @Usuairos_Possiveis TABLE (UserId INT, Linha int, PRIMARY KEY (UserId))

	DECLARE @Inicio INT

	SET @Inicio = (@PAGENUM * @PAGESIZE) + 1 ;

	WITH Encontrados AS (
		SELECT UserId, ROW_NUMBER() OVER (
			ORDER BY 
				CASE WHEN @ASC = 1 THEN UserId END ASC,
				CASE WHEN @ASC = 0 THEN UserId END DESC 	) AS Linha

		FROM Usuarios1

		WHERE ((@NOME_USUARIO IS NULL) OR (@NOME_USUARIO IS NOT NULL AND [Name] LIKE '%' + @NOME_USUARIO + '%'))
	)

	INSERT INTO @Usuairos_Possiveis (UserId, Linha)
	SELECT UserId, Linha FROM Encontrados

	SELECT
		PU.Linha,
		US.UserId, 
		US.Name,
		US.Email
	FROM Usuarios1 US
	JOIN @Usuairos_Possiveis PU	
	ON US.UserId = PU.UserId
	WHERE LINHA BETWEEN @INICIO AND ( @INICIO + @PAGESIZE) -1
	ORDER BY PU.Linha
END
GO

EXEC PaginaUsuarios  @PageNum = 0, @PageSize = 100