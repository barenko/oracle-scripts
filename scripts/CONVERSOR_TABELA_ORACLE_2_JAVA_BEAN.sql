DECLARE
    V_AUX VARCHAR2(32);
    V_LINE VARCHAR2(1000);
    V_TYPE VARCHAR2(32);
    V_NAME VARCHAR2(32);
    V_TABLE_NAME VARCHAR2(32) := '&TABLE_NAME';
    v_TEMPLATE_CLASS_OPEN VARCHAR2(1000) := 'public class #name# {';
    v_TEMPLATE_CLASS_BUILDER VARCHAR2(1000) := '    public #name#(){}';
    v_TEMPLATE_CLASS_CLOSE VARCHAR2(1000) := '}';
    v_TEMPLATE_ATTRIB VARCHAR2(1000) := '    private #type# #name#;';
    V_TEMPLATE_GET VARCHAR2(1000) := '    public #type# get#method_name#(){ return #name#; }';
    V_TEMPLATE_SET VARCHAR2(1000) := '    public void set#method_name#(#type# #name#){ this.#name# = #name#; }';
    
    FUNCTION TO_CAMEL_CASE(COLUMN_NAME VARCHAR2) RETURN VARCHAR2 IS
        V_AUX1 VARCHAR2(256) := LOWER(COLUMN_NAME);
    BEGIN
        FOR I IN 1..LENGTH(V_AUX1) LOOP
            IF SUBSTR(V_AUX1,I,1) = '_' THEN
                V_AUX1 := SUBSTR(V_AUX1,0,I-1) || UPPER(SUBSTR(V_AUX1,I+1,1)) || SUBSTR(V_AUX1,I+2,LENGTH(V_AUX1));
            END IF;
        END LOOP;
        RETURN V_AUX1;
    END TO_CAMEL_CASE;
    
    FUNCTION TO_CLASS_CAMEL_CASE(COLUMN_NAME VARCHAR2) RETURN VARCHAR2 IS
        V_AUX1 VARCHAR2(256) := TO_CAMEL_CASE(COLUMN_NAME);
    BEGIN
        V_AUX1 := UPPER(SUBSTR(V_AUX1,1,1)) || SUBSTR(V_AUX1,2);
        RETURN V_AUX1;
    END TO_CLASS_CAMEL_CASE;
BEGIN
    DBMS_OUTPUT.PUT_LINE(REPLACE(v_TEMPLATE_CLASS_OPEN,'#name#',TO_CLASS_CAMEL_CASE(V_TABLE_NAME)));
    FOR I IN (
        select column_name,data_type,data_length,data_precision,data_scale
        from user_tab_columns where table_name = UPPER(V_TABLE_NAME)
        ORDER BY DATA_TYPE,COLUMN_NAME
    )LOOP
        V_LINE := v_TEMPLATE_ATTRIB;
        
        V_NAME := TO_CAMEL_CASE(I.COLUMN_NAME);
        
        IF I.DATA_TYPE = 'CHAR' OR I.DATA_TYPE = 'VARCHAR2' THEN
            V_TYPE := 'String';
        ELSIF I.DATA_TYPE = 'NUMBER' THEN
            V_TYPE := 'Integer';
        ELSIF I.DATA_TYPE = 'DATE' THEN
            V_TYPE := 'Date';
        ELSIF I.DATA_TYPE = 'LONG' THEN
            V_TYPE := 'byte[]';
        ELSIF I.DATA_TYPE = 'LONG RAW' THEN
            V_TYPE := 'byte[]';
        ELSE
            V_TYPE := 'byte[]';
        END IF;

        V_LINE := REPLACE(V_LINE, '#type#', V_TYPE);
        V_LINE := REPLACE(V_LINE, '#name#', V_NAME);
        
        DBMS_OUTPUT.PUT_LINE(V_LINE);
        
        V_LINE := V_TEMPLATE_GET;
        V_LINE := REPLACE(V_LINE, '#type#', V_TYPE);
        V_LINE := REPLACE(V_LINE, '#name#', V_NAME);
        V_LINE := REPLACE(V_LINE, '#method_name#', TO_CLASS_CAMEL_CASE(I.COLUMN_NAME));
        
        DBMS_OUTPUT.PUT_LINE(V_LINE);

        V_LINE := V_TEMPLATE_SET;
        V_LINE := REPLACE(V_LINE, '#type#', V_TYPE);
        V_LINE := REPLACE(V_LINE, '#name#', V_NAME);
        V_LINE := REPLACE(V_LINE, '#method_name#', TO_CLASS_CAMEL_CASE(I.COLUMN_NAME));
        
        DBMS_OUTPUT.PUT_LINE(V_LINE);
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE(REPLACE(v_TEMPLATE_CLASS_BUILDER,'#name#',TO_CLASS_CAMEL_CASE(V_TABLE_NAME)));
    DBMS_OUTPUT.PUT_LINE(v_TEMPLATE_CLASS_CLOSE);
END;

-- select * from syn_usuario
--SELECT SUBSTR('123456',3) FROM DUAL
