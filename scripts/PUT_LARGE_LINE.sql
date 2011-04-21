-- FUNÇÃO PARA RETORNAR + DE 255 LINHAS NO DBMS_OUTPUT.PUT_LINE
DECLARE
    PROCEDURE PUT_LARGE_LINE(CONTENTS VARCHAR2) IS
        VAR NUMBER := 1;
    BEGIN
        WHILE VAR <= LENGTH(CONTENTS) 
        LOOP
            DBMS_OUTPUT.PUT_LINE(SUBSTR(CONTENTS, VAR, 200));
            VAR := VAR + 200;
        END LOOP;
        DBMS_OUTPUT.NEW_LINE;
    END;
BEGIN
    PUT_LARGE_LINE('We are uncovering better ways of developing software by doing it and helping others do it. Through this work we have come to value: Individuals and interactions over processes and tools; Working software over comprehensive documentation; Customer collaboration over contract negotiation; Responding to change over following a plan. That is, while there is value in the items on the right, we value the items on the left more.');
END;
