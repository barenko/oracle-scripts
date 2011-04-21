-- verifica estado das sessões e o q está sendo executado nelas
SELECT SID, SERIAL#, STATUS, PROGRAM, PIECE, SQL_TEXT, LOCKWAIT,PROCESS,USERNAME,OSUSER
,DECODE(STATUS
	,'INACTIVE',(DECODE(PIECE
					,0,'ALTER SYSTEM KILL SESSION '''||SID||','||SERIAL#||''''
					,NULL,'ALTER SYSTEM KILL SESSION '''||SID||','||SERIAL#||''''
					,''))
	,'') "KILL INACTIVE SESSIONS"
FROM V$SESSION SES 
LEFT JOIN V$SQLTEXT TXT ON SES.SQL_ADDRESS = TXT.ADDRESS AND SES.SQL_HASH_VALUE = TXT.HASH_VALUE
WHERE SID IN ( SELECT SES.SID
             FROM V$SESSION SES, V$SESS_IO IO
             WHERE SES.SID = IO.SID
             AND SES.USERNAME = UPPER('&&usuario_base')
             AND SES.SID IN(
                SELECT SID FROM V$SESSION
                WHERE USERNAME = ses.username AND program NOT IN ('gerimp.exe','SQLNav5.exe')
             )
           )
ORDER BY program, SID, PIECE





-- verifica as sessões e a quantia de cursores abertos por sessão
SELECT 
V$SESSION.USERNAME                  "Usuário",
V$SESSION.STATUS                    "Estado Sessão",
V$SESSION.PROGRAM                   "Programa",
V$SESSION.STATE                     "Estado atual",
V$SESSION.SECONDS_IN_WAIT           "Tempo de espera (s)",
V$OPEN_CURSOR.SID                   "Sessão", 
COUNT(*)                            "Cursores ativos", 
(SELECT value FROM V$PARAMETER WHERE NAME = LOWER('OPEN_CURSORS')) "Máximo de cursores",
to_char(COUNT(*)*100/(SELECT value FROM V$PARAMETER WHERE NAME = LOWER('OPEN_CURSORS')),'990.99') "Utilização(%)"
FROM V$OPEN_CURSOR
INNER JOIN V$SESSION ON V$SESSION.SID = V$OPEN_CURSOR.SID
WHERE V$SESSION.USERNAME = UPPER('&&usuario_base')
GROUP BY V$OPEN_CURSOR.SID,V$SESSION.USERNAME,V$SESSION.STATUS,
V$SESSION.PROGRAM,V$SESSION.STATE,V$SESSION.SECONDS_IN_WAIT
ORDER BY 1,2,3,6 DESC




--VERIFICA O Q ESTÁ SENDO EXECUTADO NOS CURSORES....
select ss.SID, ss.SERIAL#, ss.STATUS, ss.PROGRAM,oc.user_name, DBMS_LOB.substr(sa.sql_fulltext,4000,1) sql_text
from v$open_cursor oc
inner join v$sqlarea sa ON oc.sql_id = sa.sql_id
inner JOIN v$session ss ON ss.sid = oc.sid
WHERE oc.user_name = UPPER('&usuario_base')
AND ss.status <> 'KILLED'
AND SS.USERNAME = OC.USER_NAME
AND SS.program NOT IN ('gerimp.exe','SQLNav5.exe')
ORDER BY program, status




-- mostra os comandos executados no usuário e seu custo
SELECT 
       SQL_TEXT         SQL
       ,OPTIMIZER_MODE  MODO
       ,OPTIMIZER_COST  CUSTO
       ,USERNAME        USUARIO
FROM V$SQL, DBA_USERS
WHERE PARSING_SCHEMA_ID = USER_ID
      AND username = UPPER('&usuario_base') --COLOQUE O NOME DO USUÁRIO AQUI
      AND TO_DATE(FIRST_LOAD_TIME,'YYYY-MM-DD/HH24:MI:SS') >= TRUNC(SYSDATE)
ORDER BY TO_DATE(FIRST_LOAD_TIME,'YYYY-MM-DD/HH24:MI:SS') DESC 




SELECT * FROM v$open_cursor
SELECT * FROM V$SQL
select * from v$sqltext;
select * FROM v$sqlarea;

SELECT * FROM V$LOCK;
