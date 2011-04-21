/*ADDRESS=LOCALHOST PORT=1521 SERVICE=ORCL USER=DEV PASSWORD=DEV
	SCRIPT QUE DROPA TODOS OS OBJETOS DO BANCO.
*/
DECLARE
    V_USER VARCHAR2(50)  := UPPER('&Usuario_a_ser_dropado');
    V_CURRENT_USER VARCHAR2(50);
BEGIN
    SELECT UPPER(USER) INTO V_CURRENT_USER FROM DUAL;

    IF V_USER <> V_CURRENT_USER THEN
        RAISE_APPLICATION_ERROR(-20001,'O usuário que você deseja dropar ('||V_USER||') é diferente do usuário atual ('||V_CURRENT_USER||').');
    END IF;
    
    IF V_CURRENT_USER NOT IN('RCP','DEV', 'RCP_TST') THEN 
        RAISE_APPLICATION_ERROR(-20001, 'Se deseja realmente dropar a base '||V_USER||', insira-a manualmente na lista de bases dentro do script.');
    END IF;

    FOR I IN (
        SELECT 'DROP '||OBJECT_TYPE||' '|| OBJECT_NAME||  DECODE(OBJECT_TYPE,'TABLE',' CASCADE CONSTRAINTS','') STMT
        FROM USER_OBJECTS 
        WHERE OBJECT_NAME NOT IN (
                            SELECT OBJECT_NAME 
                            FROM USER_RECYCLEBIN
                            )
              AND OBJECT_TYPE NOT IN ('TRIGGER','PACKAGE BODY','INDEX')
        ORDER BY OBJECT_TYPE
    )LOOP
    	BEGIN
	        EXECUTE IMMEDIATE I.STMT;
	    EXCEPTION WHEN OTHERS THEN
	    	NULL;
	    END;
    END LOOP;
    	BEGIN
	        EXECUTE IMMEDIATE 'PURGE RECYCLEBIN';
	    EXCEPTION WHEN OTHERS THEN
	    	NULL;
	    END;
END;


