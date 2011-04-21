--TESTA SINTAXE SEM EXECUTAR O COMANDO...
DECLARE
    PROCEDURE TESTA_SINTAXE(INSTRUCAO VARCHAR2) 
    IS
        cur INTEGER;
        str dbms_sql.varchar2s;
        CONTENT VARCHAR2(2000) := INSTRUCAO;
    BEGIN
        str.delete;
    
        str(nvl(str.last, 0) + 1) := 'SELECT ';
        str(nvl(str.last, 0) + 1) := CONTENT;
        str(nvl(str.last, 0) + 1) := ' FROM DUAL';
    DBMS_OUTPUT.PUT_LINE('SELECT '||CONTENT||' FROM DUAL');
        cur := dbms_sql.open_cursor;
        dbms_sql.parse(cur, str, str.first, str.last, false, dbms_sql.v7);
        dbms_sql.close_cursor(cur);
    END;
BEGIN
    TESTA_SINTAXE('&SINTAXE');
END;
