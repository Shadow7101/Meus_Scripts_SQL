USE se1426 
GO
	SELECT
    OBJECT_NAME(object_id) As Tabela, Rows As Linhas,
    SUM(Total_Pages * 8) As Reservado,
    SUM(CASE WHEN Index_ID > 1 THEN 0 ELSE Data_Pages * 8 END) As Dados,
        SUM(Used_Pages * 8) -
        SUM(CASE WHEN Index_ID > 1 THEN 0 ELSE Data_Pages * 8 END) As Indice,
    SUM((Total_Pages - Used_Pages) * 8) As NaoUtilizado
FROM
    sys.partitions As P
    INNER JOIN sys.allocation_units As A ON P.hobt_id = A.container_id
	WHERE  (OBJECT_NAME(object_id) not LIKE 'sys%' and OBJECT_NAME(object_id) not LIKE 'sqlagent%' )
	--and OBJECT_NAME(object_id) not LIKE 'plan_%' and OBJECT_NAME(object_id) not LIKE 'filestream_%'
	--and OBJECT_NAME(object_id) not LIKE 'queue_%' and OBJECT_NAME(object_id) not LIKE 'filetable_%'
	--and OBJECT_NAME(object_id) not LIKE '__%')
GROUP BY OBJECT_NAME(object_id), Rows
ORDER BY Dados desc
