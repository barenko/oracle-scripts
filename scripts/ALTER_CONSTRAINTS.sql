CREATE
PACKAGE alter_constraints AS
  PROCEDURE DROP_FK_CONSTRAINT(V_CONSTRAINT_NAME VARCHAR2);
  PROCEDURE CREATE_FK_CONSTRAINT(V_CONSTRAINT_NAME VARCHAR2);
  PROCEDURE CREATE_FK_CONSTRAINT_CASCADE(V_CONSTRAINT_NAME VARCHAR2);
  PROCEDURE DISABLE_ALL_TRIGGERS(V_TABLE_NAME VARCHAR2);
  PROCEDURE ENABLE_ALL_TRIGGERS(V_TABLE_NAME VARCHAR2);
  PROCEDURE DISABLE_ALL_CONSTRAINTS(V_TABLE_NAME VARCHAR2);
  PROCEDURE ENABLE_ALL_CONSTRAINTS(V_TABLE_NAME VARCHAR2);
  PROCEDURE DISABLE_CONSTRAINT(V_CONSTRAINT_NAME VARCHAR2);
  PROCEDURE ENABLE_CONSTRAINT(V_CONSTRAINT_NAME VARCHAR2);
END;
/

CREATE
PACKAGE BODY alter_constraints AS
-------------------------------------------------------------------------------------------
    PROCEDURE DISABLE_ALL_TRIGGERS(V_TABLE_NAME VARCHAR2) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('ALTER TABLE '||V_TABLE_NAME||' DISABLE ALL TRIGGERS;');
    END;
-------------------------------------------------------------------------------------------
    PROCEDURE ENABLE_ALL_TRIGGERS(V_TABLE_NAME VARCHAR2) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('ALTER TABLE '||V_TABLE_NAME||' ENABLE ALL TRIGGERS;');
    END;
-------------------------------------------------------------------------------------------
    PROCEDURE DISABLE_CONSTRAINT(V_CONSTRAINT_NAME VARCHAR2) IS
        TBL VARCHAR2(32);
    BEGIN
        SELECT TABLE_NAME INTO TBL FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME = V_CONSTRAINT_NAME;
        DBMS_OUTPUT.PUT_LINE('ALTER TABLE '||TBL||' DISABLE CONSTRAINT '||V_CONSTRAINT_NAME||';');
    END;
-------------------------------------------------------------------------------------------
    PROCEDURE ENABLE_CONSTRAINT(V_CONSTRAINT_NAME VARCHAR2) IS
        TBL VARCHAR2(32);
    BEGIN
        SELECT TABLE_NAME INTO TBL FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME = V_CONSTRAINT_NAME;
        DBMS_OUTPUT.PUT_LINE('ALTER TABLE '||TBL||' ENABLE CONSTRAINT '||V_CONSTRAINT_NAME||';');
    END;
-------------------------------------------------------------------------------------------
    PROCEDURE DISABLE_ALL_CONSTRAINTS(V_TABLE_NAME VARCHAR2) IS
    BEGIN
        FOR STAT IN(SELECT CONSTRAINT_NAME FROM USER_CONSTRAINTS WHERE TABLE_NAME = V_TABLE_NAME ORDER BY 1)
        LOOP
            DBMS_OUTPUT.PUT_LINE('ALTER TABLE '||V_TABLE_NAME||' DISABLE CONSTRAINT '||STAT.CONSTRAINT_NAME||';');
        END LOOP;
    END;
-------------------------------------------------------------------------------------------
    PROCEDURE ENABLE_ALL_CONSTRAINTS(V_TABLE_NAME VARCHAR2) IS
    BEGIN
        FOR STAT IN(SELECT CONSTRAINT_NAME FROM USER_CONSTRAINTS WHERE TABLE_NAME = V_TABLE_NAME ORDER BY 1)
        LOOP
            DBMS_OUTPUT.PUT_LINE('ALTER TABLE '||V_TABLE_NAME||' ENABLE CONSTRAINT '||STAT.CONSTRAINT_NAME||';');
        END LOOP;
    END;
-------------------------------------------------------------------------------------------
    PROCEDURE DROP_FK_CONSTRAINT(V_CONSTRAINT_NAME VARCHAR2) IS
    BEGIN
        FOR STAT IN (SELECT CONSTRAINT_NAME,TABLE_NAME,OWNER FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME = V_CONSTRAINT_NAME)
        LOOP
            DBMS_OUTPUT.PUT_LINE('ALTER TABLE '||STAT.OWNER||'.'||STAT.TABLE_NAME||' DROP CONSTRAINT '||STAT.CONSTRAINT_NAME||';');
        END LOOP;
    END;
-------------------------------------------------------------------------------------------
    PROCEDURE CREATE_FK_CONSTRAINT(V_CONSTRAINT_NAME VARCHAR2) IS
        AUX VARCHAR2(4000);
        COLUMNS_LIST VARCHAR2(2000);
        R_COLUMNS_LIST VARCHAR2(2000);
        R_TABLE_NAME VARCHAR2(32);
    BEGIN
        FOR STAT IN (
            SELECT
                    UCC.COLUMN_NAME COLUMN_NAME,
                    UCCR.COLUMN_NAME R_COLUMN_NAME
            FROM USER_CONSTRAINTS UC
            INNER JOIN USER_CONSTRAINTS UCR ON UCR.CONSTRAINT_NAME = UC.R_CONSTRAINT_NAME
            INNER JOIN USER_CONS_COLUMNS UCC ON  UCC.CONSTRAINT_NAME  = UC.CONSTRAINT_NAME AND UC.TABLE_NAME = UCC.TABLE_NAME
            INNER JOIN USER_CONS_COLUMNS UCCR ON UCCR.CONSTRAINT_NAME = UCR.CONSTRAINT_NAME AND UCR.TABLE_NAME = UCCR.TABLE_NAME AND UCCR.POSITION = UCC.POSITION
            WHERE UC.CONSTRAINT_NAME = V_CONSTRAINT_NAME
            AND UCR.CONSTRAINT_TYPE IN( 'P','U')
            ORDER BY COLUMN_NAME,R_COLUMN_NAME
        )
        LOOP
            IF COLUMNS_LIST IS NULL THEN
                COLUMNS_LIST := STAT.COLUMN_NAME;
            ELSE
                COLUMNS_LIST := COLUMNS_LIST||','||STAT.COLUMN_NAME;
            END IF;
            IF R_COLUMNS_LIST IS NULL THEN
                R_COLUMNS_LIST := STAT.R_COLUMN_NAME;
            ELSE
                R_COLUMNS_LIST := R_COLUMNS_LIST||','||STAT.R_COLUMN_NAME;
            END IF;
        END LOOP;

        SELECT UCR.TABLE_NAME INTO R_TABLE_NAME
        FROM USER_CONSTRAINTS UC
        INNER JOIN USER_CONSTRAINTS UCR ON UCR.CONSTRAINT_NAME = UC.R_CONSTRAINT_NAME
        WHERE UC.CONSTRAINT_NAME = V_CONSTRAINT_NAME
        AND UCR.CONSTRAINT_TYPE IN( 'P','U');

        SELECT 'ALTER TABLE '||OWNER||'.'||TABLE_NAME||' ADD CONSTRAINT '||CONSTRAINT_NAME||
            '  FOREIGN KEY ('||COLUMNS_LIST||')'||' REFERENCES '||R_OWNER||'.'||R_TABLE_NAME||
            ' ('||R_COLUMNS_LIST||')'|| DECODE(DELETE_RULE,'CASCADE',' ON DELETE CASCADE','NO ACTION','','')||
            DECODE(DEFERRABLE,'DEFERRABLE',' DEFERRABLE','')||
            DECODE(DEFERRED,'DEFERRED', ' INITIALLY DEFERRED','')||';'
        INTO AUX FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME = V_CONSTRAINT_NAME;

        DBMS_OUTPUT.PUT_LINE(AUX);
    END;
-------------------------------------------------------------------------------------------
    PROCEDURE CREATE_FK_CONSTRAINT_CASCADE(V_CONSTRAINT_NAME VARCHAR2) IS
        AUX VARCHAR2(4000);
        COLUMNS_LIST VARCHAR2(2000);
        R_COLUMNS_LIST VARCHAR2(2000);
        R_TABLE_NAME VARCHAR2(32);
    BEGIN
        FOR STAT IN (
            SELECT
                    UCC.COLUMN_NAME COLUMN_NAME,
                    UCCR.COLUMN_NAME R_COLUMN_NAME
            FROM USER_CONSTRAINTS UC
            INNER JOIN USER_CONSTRAINTS UCR ON UCR.CONSTRAINT_NAME = UC.R_CONSTRAINT_NAME
            INNER JOIN USER_CONS_COLUMNS UCC ON  UCC.CONSTRAINT_NAME  = UC.CONSTRAINT_NAME AND UC.TABLE_NAME = UCC.TABLE_NAME
            INNER JOIN USER_CONS_COLUMNS UCCR ON UCCR.CONSTRAINT_NAME = UCR.CONSTRAINT_NAME AND UCR.TABLE_NAME = UCCR.TABLE_NAME AND UCCR.POSITION = UCC.POSITION
            WHERE UC.CONSTRAINT_NAME = V_CONSTRAINT_NAME
            AND UCR.CONSTRAINT_TYPE IN( 'P','U')
            ORDER BY COLUMN_NAME,R_COLUMN_NAME
        )
        LOOP
            IF COLUMNS_LIST IS NULL THEN
                COLUMNS_LIST := STAT.COLUMN_NAME;
            ELSE
                COLUMNS_LIST := COLUMNS_LIST||','||STAT.COLUMN_NAME;
            END IF;
            IF R_COLUMNS_LIST IS NULL THEN
                R_COLUMNS_LIST := STAT.R_COLUMN_NAME;
            ELSE
                R_COLUMNS_LIST := R_COLUMNS_LIST||','||STAT.R_COLUMN_NAME;
            END IF;
        END LOOP;

        SELECT UCR.TABLE_NAME INTO R_TABLE_NAME
        FROM USER_CONSTRAINTS UC
        INNER JOIN USER_CONSTRAINTS UCR ON UCR.CONSTRAINT_NAME = UC.R_CONSTRAINT_NAME
        WHERE UC.CONSTRAINT_NAME = V_CONSTRAINT_NAME
        AND UCR.CONSTRAINT_TYPE IN( 'P','U');

        SELECT 'ALTER TABLE '||OWNER||'.'||TABLE_NAME||' ADD CONSTRAINT '||CONSTRAINT_NAME||
            '  FOREIGN KEY ('||COLUMNS_LIST||')'||' REFERENCES '||R_OWNER||'.'||R_TABLE_NAME||
            ' ('||R_COLUMNS_LIST||')'||' ON DELETE CASCADE'||
            DECODE(DEFERRABLE,'DEFERRABLE',' DEFERRABLE','')||
            DECODE(DEFERRED,'DEFERRED', ' INITIALLY DEFERRED','')||';'
        INTO AUX FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME = V_CONSTRAINT_NAME;

        DBMS_OUTPUT.PUT_LINE(AUX);
    END;

END;
/
