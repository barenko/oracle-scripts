REM ##############################################
REM # COLETA DE DADOS                            #
REM # ---------------                            #
REM # Rodrigo Almeida Consultoria                       #
REM # Autor : Rodrigo Almeida                    #
REM # E-mail: dbarodrigo@gmail.com                #
REM # Data: 31/10/2006                           #
REM # Versão: 1.0                                #
REM ##############################################

set line 150
set linesize 150
col "Tamanho (MB)" format 999,999,999
col SERVIDOR format a20
col SO format a30
col "MODO ARQUIVAMENTO" format a20
col "TOTAL" format 999,999,999

spool coleta_dados.txt

prompt
prompt ===========================================================
prompt BANCO DE DADOS
prompt ===========================================================
prompt
set pagesize 10000
select a.instance_name as "INSTANCIA", a.host_name as "SERVIDOR",  b.platform_name as "SO", a.status as "STATUS", a.archiver as "MODO ARQUIVAMENTO",
to_char(b.created,'DD-MM-RRRR HH24:MI:SS') as "DATA CRIACAO"
from v$instance a, v$database b
where a.instance_name=b.name;

prompt
prompt ===========================================================
prompt BANCO DE DADOS
prompt ===========================================================
prompt
select name, type, value from v$parameter;

prompt
prompt ===========================================================
prompt VERSAO DO BANCO DE DADOS
prompt ===========================================================
prompt

set pagesize 0
select * from v$version;

prompt
prompt ===========================================================
prompt VOLUMETRIA FISICA
prompt ===========================================================
prompt
set pagesize 10000
select sum(bytes)/1024/1024 as "Tamanho (MB)" from dba_data_files;

prompt
prompt ===========================================================
prompt VOLUMETRIA LOGICA
prompt ===========================================================
prompt
select sum(bytes)/1024/1024 as "Tamanho (MB)" from dba_segments;

prompt
prompt ===========================================================
prompt RESUMO DE OCUPACAO DE ESPACO POR ESQUEMA
prompt ===========================================================
prompt
select owner as "ESQUEMA", segment_type as "TIPO DE OBJETO", sum(bytes)/1024/1024 as "TAMANHO (MB)"
from dba_segments
group by owner, segment_type
order by owner;

prompt
prompt ===========================================================
prompt TABLESPACES
prompt ===========================================================
prompt
select tablespace_name as "TABLESPACE", block_size as "BLOCO DE DADOS", status as "STATUS", logging as "LOGGING",
extent_management as "GER.EXTENSAO", allocation_type as "TIPO DE ALOCACAO", segment_space_management as "GER.SEGMENTO",
retention as "RETENCAO"
from dba_tablespaces;

prompt
prompt ===========================================================
prompt RESUMO POR TABLESPACES
prompt ===========================================================
prompt
select decode(grouping(tablespace_name),0,null,1,'TOTAL (MB) =') as "1",
tablespace_name as "TABLESPACE", segment_type as "TIPO DE OBJETO", sum(bytes)/1024/1024 as "TAMANHO (MB)"
from dba_segments
group by rollup(tablespace_name, segment_type)
order by tablespace_name;

prompt
prompt ===========================================================
prompt VERIFICACAO DE ESTATISTICAS NAS TABELAS
prompt ===========================================================
prompt
select decode(to_char(last_analyzed,'DD-MM-RRRR'),null,'SEM ESTATISTICA',to_char(last_analyzed,'DD-MM-RRRR')) as "ANALISE",
count(table_name) as "TOTAL DE TABELAS"
from dba_tables
group by to_char(last_analyzed,'DD-MM-RRRR')
order by to_char(last_analyzed,'DD-MM-RRRR');

prompt
prompt ===========================================================
prompt VERIFICACAO DE ESTATISTICAS NOS INDICES
prompt ===========================================================
prompt
select decode(to_char(last_analyzed,'DD-MM-RRRR'),null,'SEM ESTATISTICA',to_char(last_analyzed,'DD-MM-RRRR')) as "ANALISE",
count(index_name) as "TOTAL DE INDICES"
from dba_indexes
group by to_char(last_analyzed,'DD-MM-RRRR')
order by to_char(last_analyzed,'DD-MM-RRRR');

prompt
prompt ===========================================================
prompt VERIFICACAO DO STATUS NOS INDICES
prompt ===========================================================
prompt
select a.status as "STATUS", count(a.index_name) as "TOTAL", sum(b.bytes)/1024/1024 as "TAMANHO (MB)"
from dba_indexes a, dba_segments b
where a.index_name=b.segment_name
group by a.status;


spool off
