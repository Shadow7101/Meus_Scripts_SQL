SELECT
	Processo      = spid
	,Computador   = hostname
	,Usuario      = loginame
	,Status       = status
	,BloqueadoPor = blocked
	,TipoComando  = cmd
	,Aplicativo   = program_name
FROM
	master..sysprocesses
WHERE
	status in ('runnable', 'suspended')
ORDER BY
	blocked desc, status, spid


/*
	Select Processo = spid
,Computador = hostname
,Usuario = loginame
,Status = status
,BloqueadoPor = blocked
,TipoComando = cmd
,Aplicativo = program_name
from master..sysprocesses
where status in ('runnable', 'suspended')
order by blocked desc, status, spid 
*/

Select
     spid,
      db_name(dbid) as [Database],
      Open_tran as 'Transacoes Abertas',
      Hostname as 'Estacao Trabalho',
      nt_username as 'Usuario Windows',
      loginame as 'Usuário SQL',
      program_name as Aplicacao,
      login_time as Hora_Login,
      waittime as 'Tempo de Duração',   
      status as 'Status',    
      --As páginas possuem 8 kb de tamanho
      --memusage * 8 as 'Memória Alocada no Processo KB',
      cmd as 'Comando SQL'
From sysProcesses
where Hostname <> '' --and Open_tran >= 1
order by Hostname, db_name(dbid),login_time desc

--DBCC INPUTBUFFER (51)