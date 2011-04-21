

DECLARE
    FUNCTION recompile(o_owner    IN VARCHAR2 := USER,
                     o_name     IN VARCHAR2 := '%',
                     o_type     IN VARCHAR2 := '%',
                     o_status   IN VARCHAR2 := 'INVALID'
                    ) RETURN NUMBER
    IS

      -- Return Codes

      INVALID_TYPE      CONSTANT INTEGER := 1;
      INVALID_PARENT    CONSTANT INTEGER := 2;

      cnt               NUMBER;
      dyncur            INTEGER;
      type_status       INTEGER := 0;
      parent_status     INTEGER := 0;
      object_status     VARCHAR2(30);
      CURSOR            invalid_parent_cursor(oowner    VARCHAR2,
                                              oname     VARCHAR2,
                                              otype     VARCHAR2,
                                              ostatus   VARCHAR2,
                                              oid       NUMBER
                                             )
                IS
                   SELECT /*+ RULE */
                          o.object_id
                    FROM  public_dependency d,
                          all_objects o
                    WHERE d.object_id = oid
                      AND o.object_id = d.referenced_object_id
                      AND o.status != 'VALID'
                  MINUS
                   SELECT /*+ RULE */
                          object_id
                    FROM  all_objects
                    WHERE owner LIKE UPPER(oowner)
                      AND object_name LIKE UPPER(oname)
                      AND object_type LIKE UPPER(otype)
                      AND status LIKE UPPER(ostatus);
      CURSOR recompile_cursor(oid NUMBER)
        IS
          SELECT  /*+ RULE */
                  'ALTER ' || DECODE(object_type, 'PACKAGE BODY', 'PACKAGE',
                        object_type) || ' ' || owner || '.' ||
                        object_name || ' COMPILE ' ||
                        DECODE(object_type, 'PACKAGE BODY', ' BODY', '') stmt,
                  object_type,
                  owner,
                  object_name
            FROM  all_objects
            WHERE object_id = oid;
      recompile_record  recompile_cursor%ROWTYPE;
      CURSOR obj_cursor(oowner  VARCHAR2,
                        oname   VARCHAR2,
                        otype   VARCHAR2,
                        ostatus VARCHAR2
                       )
        IS
          SELECT  /*+ RULE */
                  MAX(LEVEL) dlevel,
                  object_id
            FROM  sys.public_dependency
            START WITH object_id IN (SELECT  object_id
                                       FROM  all_objects
                                       WHERE owner LIKE UPPER(oowner)
                                         AND object_name LIKE UPPER(oname)
                                         AND object_type LIKE UPPER(otype)
                                         AND status LIKE UPPER(ostatus)
                                    )
            CONNECT BY object_id = prior referenced_object_id
            GROUP BY object_id
            HAVING MIN(LEVEL) = 1
            ORDER BY dlevel DESC;
      CURSOR status_cursor(oid NUMBER)
        IS
          SELECT  /*+ RULE */
                  status
            FROM  all_objects
            WHERE object_id = oid;
    BEGIN

      -- Recompile requested objects based on their dependency levels.

      DBMS_OUTPUT.PUT_LINE(CHR(0));
      DBMS_OUTPUT.PUT_LINE('RECOMPILING OBJECTS');
      DBMS_OUTPUT.PUT_LINE(CHR(0));
      DBMS_OUTPUT.PUT_LINE('Object Owner is  ' ||o_owner);
      DBMS_OUTPUT.PUT_LINE('Object Name is   ' ||o_name);
      DBMS_OUTPUT.PUT_LINE('Object Type is   ' ||o_type);
      DBMS_OUTPUT.PUT_LINE('Object Status is ' ||o_status);
      DBMS_OUTPUT.PUT_LINE(CHR(0));
      dyncur := DBMS_SQL.OPEN_CURSOR;
      FOR obj_record IN obj_cursor(o_owner,o_name,o_type,o_status)
        LOOP
          OPEN  recompile_cursor(obj_record.object_id);
          FETCH recompile_cursor INTO recompile_record;
          CLOSE recompile_cursor;
          -- We can recompile only Functions, Packages, Package Bodies,
          -- Procedures, Triggers and Views.

          IF recompile_record.object_type IN ('FUNCTION',
                                              'PACKAGE',
                                              'PACKAGE BODY',
                                              'PROCEDURE',
                                              'TRIGGER',
                                              'VIEW'
                                             )
            THEN

              -- There is no sense to recompile an object that depends on
              -- invalid objects outside of the current recompile request.

              OPEN invalid_parent_cursor(o_owner,
                                         o_name,
                                         o_type,
                                         o_status,
                                         obj_record.object_id
                                        );
              FETCH invalid_parent_cursor INTO cnt;
              IF invalid_parent_cursor%NOTFOUND
                THEN
                  -- Recompile object.
                  DBMS_SQL.PARSE(dyncur,
                                 recompile_record.stmt,
                                 DBMS_SQL.NATIVE
                                );
                  cnt := DBMS_SQL.EXECUTE(dyncur);
                  OPEN  status_cursor(obj_record.object_id);
                  FETCH status_cursor INTO object_status;
                  CLOSE status_cursor;
                  DBMS_OUTPUT.PUT_LINE(recompile_record.object_type || ' ' ||
                                        recompile_record.owner || '.' ||
                                        recompile_record.object_name ||
                                        ' is recompiled. Object status is ' ||
                                        object_status ||'.'
                                      );
                ELSE
                  DBMS_OUTPUT.PUT_LINE(recompile_record.object_type || ' ' ||
                                       recompile_record.owner || '.' ||
                                       recompile_record.object_name ||
                                       ' references invalid object(s)' ||
                                       ' outside of this request.'
                                      );
                  parent_status := invalid_parent;
              END IF;
              CLOSE invalid_parent_cursor;
            ELSE
              DBMS_OUTPUT.PUT_LINE(recompile_record.owner || '.' ||
                                   recompile_record.object_name ||
                                   ' is a ' ||
                                   recompile_record.object_type ||
                                   ' and can not be recompiled.'
                                  );
              type_status := invalid_type;
          END IF;
      END LOOP;
      DBMS_SQL.CLOSE_CURSOR(dyncur);
      RETURN type_status + parent_status;
    EXCEPTION
      WHEN OTHERS THEN
      IF obj_cursor%ISOPEN
        THEN
          CLOSE obj_cursor;
      END IF;
      IF recompile_cursor%ISOPEN
        THEN
          CLOSE recompile_cursor;
      END IF;
      IF invalid_parent_cursor%ISOPEN
        THEN
          dbms_output.put_line('Error on statement:'||chr(10)||recompile_record.stmt);
          CLOSE invalid_parent_cursor;
      END IF;
      IF status_cursor%ISOPEN
        THEN
          CLOSE status_cursor;
      END IF;
      IF DBMS_SQL.IS_OPEN(dyncur)
        THEN
          DBMS_SQL.CLOSE_CURSOR(dyncur);
      END IF;
      RAISE;
    END;
BEGIN
DBMS_OUTPUT.PUT_LINE(recompile());
END;
