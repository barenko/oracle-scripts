//conta a qtia de registro de TODAS as tabelas do usuário

select 'union select '''||table_name||''', count(*) from '||table_name
from user_tables
where table_name like '&TABLENAME_LIKE' --PADRAO DE NOME DAS TABELAS
