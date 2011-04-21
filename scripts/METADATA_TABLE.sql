--CRIA TABELA TEMPORARIA PARA O RELATORIO
DECLARE
    STMT VARCHAR2(2000) := 
        'CREATE GLOBAL TEMPORARY TABLE OUTPUT_REPORT ( '||
        '    LINE NUMBER, '||
        '    CONTENT VARCHAR2(4000) '||
        ') ON COMMIT PRESERVE ROWS';
    EXISTS_OUTPUT_REPORT INTEGER;
BEGIN
    SELECT COUNT(*) INTO EXISTS_OUTPUT_REPORT 
    FROM USER_TABLES 
    WHERE TABLE_NAME = 'OUTPUT_REPORT';
    
    IF EXISTS_OUTPUT_REPORT = 0 THEN
        EXECUTE IMMEDIATE STMT;
    END IF;
    
END;
/

--POPULA O RELATORIO
DECLARE
    ----------------------------------------------------------------------------
    ---------- FORMATADORES
    ----------------------------------------------------------------------------
    G_COLUMN_NAME_LENGTH        INTEGER := 33;      --VALOR MINIMO: 33
    G_CONSTRAINT_NAME_LENGTH    INTEGER := 33;      --VALOR MINIMO: 33
    G_CONSTRAINT_TYPE_LENGTH    INTEGER := 5;       --VALOR MINIMO: 5
    G_DATA_TYPE_LENGTH          INTEGER := 15;      --VALOR MINIMO: 15
    G_INDEX_NAME_LENGTH         INTEGER := 33;      --VALOR MINIMO: 33
    G_INDEX_TYPE_LENGTH         INTEGER := 33;      --VALOR MINIMO: 33
    G_KEY_LENGTH                INTEGER := 6;       --VALOR MINIMO: 6
    G_LINE_LIMIT                INTEGER := 200;     --VALOR MINIMO RECOMENDADO: 80
    G_NULLABLE_LENGTH           INTEGER := 9;       --VALOR MINIMO: 9
    G_TABLE_NAME_LENGTH         INTEGER := 33;      --VALOR MINIMO: 33
    G_TABULATION_LENGTH         INTEGER := 5;       --VALOR MINIMO: 1
    ----------------------------------------------------------------------------
    ---------- AUXILIARES
    ----------------------------------------------------------------------------
    G_OUTPUT_COUNTER INTEGER := 0; --CONTROLE DE PAGINAÇÃO. NÃO ALTERAR.
    PROCEDURE OUTPUT(CONTENT VARCHAR2) IS
    BEGIN
        G_OUTPUT_COUNTER := G_OUTPUT_COUNTER + 1;
        INSERT INTO OUTPUT_REPORT(LINE,CONTENT) VALUES(G_OUTPUT_COUNTER,CONTENT);
    END OUTPUT;
    ----------------------------------------------------------------------------
    PROCEDURE SEPARATOR IS
    BEGIN
        OUTPUT(RPAD('-', G_LINE_LIMIT, '-'));
    END SEPARATOR;
    ----------------------------------------------------------------------------
    PROCEDURE NEW_LINE (P_LINES_QUANTITY INTEGER DEFAULT 1) IS
    BEGIN
        FOR I IN 1..P_LINES_QUANTITY LOOP
            OUTPUT('');
        END LOOP;
    END NEW_LINE;
    ----------------------------------------------------------------------------
    FUNCTION DATA_TYPE_FORMATTER(P_DATA_TYPE VARCHAR2, P_DATA_LENGTH INTEGER, 
                                 P_DATA_PRECISION INTEGER, P_DATA_SCALE INTEGER) 
    RETURN VARCHAR2 IS
        AUX VARCHAR2(64) := P_DATA_TYPE;
    BEGIN
        IF P_DATA_TYPE IN('VARCHAR2','CHAR') THEN
            AUX := AUX || '(' || P_DATA_LENGTH || ')';
        ELSIF P_DATA_TYPE = 'NUMBER' THEN
            IF P_DATA_PRECISION IS NOT NULL AND P_DATA_SCALE IS NOT NULL THEN
                AUX := AUX || '(' || P_DATA_PRECISION || ',' || P_DATA_SCALE || ')';
            ELSIF P_DATA_PRECISION IS NOT NULL AND P_DATA_SCALE IS NULL THEN
                AUX := AUX || '(' || P_DATA_PRECISION || ')';
            END IF;
        END IF;
        
        RETURN AUX;
    END DATA_TYPE_FORMATTER;
    ----------------------------------------------------------------------------
    ---------- PRINCIPAIS
    ----------------------------------------------------------------------------
    PROCEDURE TABLE_METADATA (P_TABLE_NAME VARCHAR2) IS
        V_TAB_COMMENTS VARCHAR2(2000);
    BEGIN
        SELECT COMMENTS INTO V_TAB_COMMENTS FROM USER_TAB_COMMENTS WHERE TABLE_NAME = P_TABLE_NAME;

        SEPARATOR;
        OUTPUT( RPAD('TABELA', G_TABLE_NAME_LENGTH,' ')||
                RPAD('COMENTARIO', G_LINE_LIMIT-(G_TABLE_NAME_LENGTH),' '));
        SEPARATOR;
        NEW_LINE;
        OUTPUT( RPAD(P_TABLE_NAME, G_TABLE_NAME_LENGTH,' ')||
                                RPAD(NVL(V_TAB_COMMENTS, ' '), G_LINE_LIMIT-(G_TABLE_NAME_LENGTH),' '));
        SEPARATOR;
        NEW_LINE;
        SEPARATOR;
        OUTPUT( RPAD('COLUNA', G_COLUMN_NAME_LENGTH,' ')||
                RPAD('CHAVE', G_KEY_LENGTH,' ')||
                RPAD('TIPO', G_DATA_TYPE_LENGTH,' ')||
                RPAD('ANULAVEL', G_NULLABLE_LENGTH,' ')||
                RPAD('COMENTARIO', G_LINE_LIMIT-(G_COLUMN_NAME_LENGTH+G_KEY_LENGTH+G_DATA_TYPE_LENGTH+G_NULLABLE_LENGTH),' '));
        SEPARATOR;
        NEW_LINE;
        FOR I IN (
            SELECT  UTC.COLUMN_NAME, NVL2(UCC.COLUMN_NAME,'S','N') HAS_KEY, 
                    UTC.DATA_TYPE, UTC.DATA_LENGTH, UTC.DATA_PRECISION, 
                    UTC.DATA_SCALE, DECODE(UTC.NULLABLE,'Y','S','N') NULLABLE, UCCT.COMMENTS
            FROM USER_TAB_COLUMNS UTC
            LEFT JOIN USER_COL_COMMENTS UCCT ON UTC.TABLE_NAME = UCCT.TABLE_NAME AND UTC.COLUMN_NAME = UCCT.COLUMN_NAME
            LEFT JOIN(
                SELECT UCC.TABLE_NAME, UCC.COLUMN_NAME FROM USER_CONS_COLUMNS UCC
                INNER JOIN USER_CONSTRAINTS UC ON UCC.CONSTRAINT_NAME = UC.CONSTRAINT_NAME
                WHERE UC.CONSTRAINT_TYPE = 'P'
            ) UCC ON UTC.TABLE_NAME = UCC.TABLE_NAME AND UTC.COLUMN_NAME = UCC.COLUMN_NAME
            WHERE UTC.TABLE_NAME = P_TABLE_NAME
            ORDER BY 1
        ) LOOP 
            OUTPUT( RPAD(I.COLUMN_NAME, G_COLUMN_NAME_LENGTH,' ')||
                    RPAD(I.HAS_KEY, G_KEY_LENGTH,' ')||
                    RPAD(DATA_TYPE_FORMATTER(I.DATA_TYPE, I.DATA_LENGTH, I.DATA_PRECISION, I.DATA_SCALE), G_DATA_TYPE_LENGTH,' ')||
                    RPAD(I.NULLABLE, G_NULLABLE_LENGTH,' ')||
                    RPAD(NVL(I.COMMENTS, ' '), G_LINE_LIMIT-(G_COLUMN_NAME_LENGTH+G_KEY_LENGTH+G_DATA_TYPE_LENGTH+G_NULLABLE_LENGTH),' '));
        END LOOP;
        SEPARATOR;
        NEW_LINE(2);
    END TABLE_METADATA;
    ----------------------------------------------------------------------------
    PROCEDURE TABLE_CONSTRAINTS(P_TABLE_NAME VARCHAR2) IS
    BEGIN
        SEPARATOR;
        OUTPUT( RPAD('REGRA', G_CONSTRAINT_NAME_LENGTH,' ')||
                RPAD('TIPO', G_CONSTRAINT_TYPE_LENGTH,' ')||
                RPAD('INDICE', G_INDEX_NAME_LENGTH,' ')||
                RPAD('CONDICAO', G_LINE_LIMIT-(G_CONSTRAINT_NAME_LENGTH+G_CONSTRAINT_TYPE_LENGTH+G_INDEX_NAME_LENGTH),' '));
        SEPARATOR;
        NEW_LINE;
        FOR I IN (  SELECT  CONSTRAINT_NAME, DECODE(CONSTRAINT_TYPE,'U','UK','R','FK','P','PK','C','CK','') CONSTRAINT_TYPE, 
                            INDEX_NAME, SEARCH_CONDITION
                    FROM USER_CONSTRAINTS 
                    WHERE TABLE_NAME = P_TABLE_NAME 
                    ORDER BY CONSTRAINT_TYPE, CONSTRAINT_NAME
        ) LOOP
            OUTPUT( RPAD(I.CONSTRAINT_NAME, G_CONSTRAINT_NAME_LENGTH,' ')||
                    RPAD(I.CONSTRAINT_TYPE, G_CONSTRAINT_TYPE_LENGTH,' ')||
                    RPAD(NVL(I.INDEX_NAME, ' '), G_INDEX_NAME_LENGTH,' ')||
                    RPAD(NVL(I.SEARCH_CONDITION, ' '), G_LINE_LIMIT-(G_CONSTRAINT_NAME_LENGTH+G_CONSTRAINT_TYPE_LENGTH+G_INDEX_NAME_LENGTH),' '));
            FOR J IN (
                SELECT TABLE_NAME, COLUMN_NAME, NVL2(POSITION,'('||POSITION||')','') POSITION
                FROM USER_CONS_COLUMNS WHERE CONSTRAINT_NAME = I.CONSTRAINT_NAME
                ORDER BY POSITION
            ) LOOP
                OUTPUT( RPAD(' ',G_TABULATION_LENGTH,' ')||
                        RPAD('COLUNA'||J.POSITION||':', 12,' ')||
                        RPAD(J.TABLE_NAME||'.'||J.COLUMN_NAME, G_LINE_LIMIT-(G_COLUMN_NAME_LENGTH+G_TABULATION_LENGTH),' '));
            END LOOP;
            SEPARATOR;
            NEW_LINE(2);
        END LOOP;
    END TABLE_CONSTRAINTS;
    ----------------------------------------------------------------------------
    PROCEDURE TABLE_INDEXES(P_TABLE_NAME VARCHAR2) IS
    BEGIN
        SEPARATOR;
        OUTPUT( RPAD('INDICE', G_INDEX_NAME_LENGTH,' ')||
                RPAD('TIPO', G_INDEX_TYPE_LENGTH,' ')||
                RPAD('TIPO DA TABELA', G_INDEX_TYPE_LENGTH,' ')||
                RPAD('UNICIDADE', G_LINE_LIMIT-(G_INDEX_NAME_LENGTH+G_INDEX_TYPE_LENGTH+G_INDEX_TYPE_LENGTH),' '));
        SEPARATOR;
        NEW_LINE;
        FOR I IN (  
            SELECT  INDEX_NAME, INDEX_TYPE, TABLE_TYPE, 
                    DECODE(UNIQUENESS,'UNIQUE','S','N') UNIQUENESS
            FROM USER_INDEXES
            WHERE TABLE_NAME = P_TABLE_NAME
            ORDER BY INDEX_NAME
        ) LOOP
            OUTPUT( RPAD(I.INDEX_NAME, G_INDEX_NAME_LENGTH,' ')||
                    RPAD(I.INDEX_TYPE, G_INDEX_TYPE_LENGTH,' ')||
                    RPAD(I.TABLE_TYPE, G_INDEX_TYPE_LENGTH,' ')||
                    RPAD(I.UNIQUENESS, G_LINE_LIMIT-(G_INDEX_NAME_LENGTH+G_INDEX_TYPE_LENGTH+G_INDEX_TYPE_LENGTH),' '));
            SEPARATOR;
        END LOOP;
        NEW_LINE(2);
    END TABLE_INDEXES;
    ----------------------------------------------------------------------------
    PROCEDURE FULL_METADATA(P_TABLE_NAME VARCHAR2) IS
    BEGIN
        TABLE_METADATA(P_TABLE_NAME);
        TABLE_CONSTRAINTS(P_TABLE_NAME);
        TABLE_INDEXES(P_TABLE_NAME);
        OUTPUT(RPAD('#', G_LINE_LIMIT, '#'));
        OUTPUT(RPAD('#', G_LINE_LIMIT, '#'));
    END FULL_METADATA;
    ----------------------------------------------------------------------------
    PROCEDURE FULL_METADATA_BATCH(P_TABLE_NAME_LIKE_PATTERN VARCHAR2, P_CLEAR_BEFORE CHAR DEFAULT 'N') IS
    BEGIN
        IF P_CLEAR_BEFORE = 'S' THEN
            EXECUTE IMMEDIATE 'TRUNCATE TABLE OUTPUT_REPORT';
        ELSE
            SELECT MAX(LINE) INTO G_OUTPUT_COUNTER FROM OUTPUT_REPORT;
        END IF;
        
        FOR I IN (  SELECT TABLE_NAME FROM USER_TABLES 
                    WHERE TABLE_NAME LIKE UPPER(P_TABLE_NAME_LIKE_PATTERN)
                    ORDER BY 1
        )LOOP
            FULL_METADATA(I.TABLE_NAME);
        END LOOP;
    END FULL_METADATA_BATCH;
BEGIN
    FULL_METADATA_BATCH('&LIKE_DO_NOME_DA_TABELA',UPPER(SUBSTR('&LIMPAR_SAIDA_ANTES_S_N',1,1))); --PEGA TODAS TABELAS DA USER_TABLES. CASO QUEIRA RESTRINGIR, COLOQUE UM FILTRO LIKE NO PARAMETRO DESSA FUNÇÃO...
END;
/

SELECT CONTENT FROM OUTPUT_REPORT ORDER BY LINE
/


