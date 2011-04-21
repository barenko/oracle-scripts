DECLARE
    new_user VARCHAR2(32) := '&NEW_USER_NAME';
    new_pwd varchar2(32) := '&NEW_USER_PASSWORD';
    all_grants char(1) := '&WISH_ALL_GRANTS';
    parameters_wrong_exception EXCEPTION;
    create_user_command varchar2(1000);
    connect_grant varchar2(1000);
    resource_grant varchar2(1000);
    other_grant varchar2(1000);
BEGIN
    if(new_user IS NULL OR new_pwd is null) THEN
        dbms_output.put_line('User and/or password can not be null!');
        RAISE parameters_wrong_exception;
    END IF;

    create_user_command := 'CREATE USER '||new_user||' IDENTIFIED BY '||new_pwd||'';
    dbms_output.put_line(create_user_command);
    EXECUTE IMMEDIATE create_user_command;

    connect_grant :='GRANT resource TO '||new_user;
    dbms_output.put_line(connect_grant);
    EXECUTE IMMEDIATE connect_grant;
    
    resource_grant :='GRANT resource TO '||new_user;
    dbms_output.put_line(resource_grant);
    EXECUTE IMMEDIATE connect_grant;

    if(all_grants IN ('s','S','y','Y','1','t','T','v','V')) then
    FOR g IN ( SELECT name FROM system_privilege_map) LOOP
      other_grant := 'GRANT '||g.name||' TO '||new_user;
      dbms_output.put_line(other_grant);
      begin
        EXECUTE IMMEDIATE other_grant;
      exception when others then
        dbms_output.put_line('ERROR: '||sqlerrm);
      end;
    END LOOP;
    END IF;
    dbms_output.put_line('User '''|| new_user||' created!');
END;

