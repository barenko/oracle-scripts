BEGIN
    FOR I IN (
        SELECT 'ALTER TABLE '||TABLE_NAME||' DROP CONSTRAINT '||CONSTRAINT_NAME STMT
        FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME IN(SELECT CONSTRAINT_NAME FROM USER_CONSTRAINTS WHERE R_CONSTRAINT_NAME = UPPER('&CONSTRAINT_PAI'))
    )LOOP
        DBMS_OUTPUT.PUT_LINE(I.STMT);
        EXECUTE IMMEDIATE I.STMT;
    END LOOP;
END;
