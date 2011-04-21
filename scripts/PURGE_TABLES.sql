set serveroutput on;

declare
  mask VARCHAR2(32);
begin
  select upper('&TableName') into mask from dual;
  dbms_output.put_line('Purging to mask: '''||mask||'''');
  for i in (select original_name, object_name 
            from recyclebin 
            where type = 'TABLE' 
              and original_name like mask 
            order by 1
  )loop
    dbms_output.put_line('Purging '||i.original_name||'('||i.object_name||')'||'...');
    execute IMMEDIATE 'purge table '||i.original_name;
  end loop;
  dbms_output.put_line('Finished.');
end;