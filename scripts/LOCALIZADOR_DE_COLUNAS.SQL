--EXIBE TODAS AS TABELAS QUE TENHAM UM DETERMINADO NOME DE COLUNA



select table_name
    ,column_name
    ,data_type
from user_tab_columns utc
inner join user_tables ut on  ut.table_name = utc.table_name
where column_name = '&COLUMN_NAME' -- COLUNA
