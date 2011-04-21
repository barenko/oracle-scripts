--habilita triggers
begin
for i in(
    select 'alter trigger '||trigger_name||' enable' stmt from user_triggers where status = 'DISABLED'
)loop
    execute immediate i.stmt;
end loop;
end;

--habilita constraints
begin
for i in(
    select 'alter table '||table_name||' enable constraint '||constraint_name stmt from user_constraints where status = 'DISABLED'
)loop
    execute immediate i.stmt;
end loop;
end;

