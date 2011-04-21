/*
  VERIFICA LOCK DE TABELAS
*/
SELECT substr(o.object_name,1,25) objeto,
l.session_id session_id,
l.oracle_username ora_user,
l.os_user_name os_user
from dba_objects o, v$locked_object l
where l.object_id = o.object_id
order by 1,3,4
