/*
SELECT cd_unidade_educacao,
	nm_unidade_educacao
FROM unidade_educacao order by nm_unidade_educacao
*/
USE se1426
GO
alter PROCEDURE PaginaEscolas (
	@NomeEscola VARCHAR(80) = NULL,
	@ASC	BIT = 1,
	@PageSize INT,
	@PageNum INT
) AS BEGIN

	DECLARE @EscolasPossiveis TABLE (cd_unidade_educacao CHAR(6), Linha INT, PRIMARY KEY (cd_unidade_educacao))
	DECLARE @Inicio INT 

	SET @Inicio = ( @PageNum * @PageSize ) + 1;

	WITH Encontradas AS (
		SELECT cd_unidade_educacao, ROW_NUMBER() OVER (
			ORDER BY
				CASE WHEN @ASC = 1 THEN nm_unidade_educacao END ASC,
				CASE WHEN @ASC = 0 THEN nm_unidade_educacao END DESC
			) AS Linha
		FROM unidade_educacao
		WHERE ((@NomeEscola IS NULL) OR (@NomeEscola IS NOT NULL AND nm_unidade_educacao LIKE '%' + @NomeEscola + '%'))
	)

	INSERT INTO @EscolasPossiveis (cd_unidade_educacao, Linha)
	SELECT cd_unidade_educacao, Linha FROM Encontradas WHERE Linha BETWEEN @Inicio AND ( @INICIO + @PageSize - 1) 
	
	SELECT 
		B.Linha,
		A.cd_unidade_educacao,
		A.nm_unidade_educacao
	FROM unidade_educacao AS A
	INNER JOIN @EscolasPossiveis AS B ON B.cd_unidade_educacao = A.cd_unidade_educacao
	ORDER BY B.Linha
END
go


USE se1426
GO
EXEC PaginaEscolas @PageSize = 10, @PageNum = 1
