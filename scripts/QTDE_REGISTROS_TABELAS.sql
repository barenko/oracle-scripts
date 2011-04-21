
/************************************************************************************************
*                                                                                               *
*                           	SYNCHRO SISTEMAS DE INFORMAÇÃO                                  *
*                              	  QTDE_REGISTROS_TABELAS.SQL                                    *
*                                                                                               *
* Este script lista todas as tabelas da base, e respectiva quantidade de registros.             *
*                                                                                               *
************************************************************************************************/

declare

  cursor cReg is
    select table_name
    from   user_tables
    order  by table_name;

  mReg cReg%rowtype;

  cur  integer;
  vQtde integer;

begin

  open cReg;
  loop
    fetch cReg into mReg;
    exit when cReg%notfound;

    cur := dbms_sql.open_cursor;
    dbms_sql.parse(cur,'select count(*) from ' || mReg.table_name,dbms_sql.v7);
    dbms_sql.define_column(cur,1,vQtde);
    if dbms_sql.execute_and_fetch(cur) > 0 then
      dbms_sql.column_value(cur,1,vQtde);
      dbms_output.put_line(rpad(mReg.table_name,32,' ') || vQtde);
    end if;
    dbms_sql.close_cursor(cur);

  end loop;

end;
