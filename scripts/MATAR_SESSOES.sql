BEGIN 
	FOR matarSessoesSniped 
	IN (
	   SELECT 'alter system kill session '''||sid||','||serial#||'''' AS matarSessao
	   FROM v$session 
	   where status in ('SNIPED','INACTIVE') 
	   		 AND seconds_in_wait > 600 
			 AND Upper(username) in ('TESTE','IMASTERS','BRUNO' )) 
	LOOP
		EXECUTE IMMEDIATE matarSessoesSniped.matarSessao;
	END LOOP;
END;
/
